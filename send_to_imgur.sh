#!/bin/bash

# imgur script by Bart Nagel <bart at tremby.net>, acelan, maxwux <maxwux at gmail.com>
# version 7
# I release this into the public domain. Do with it what you will.

# Required: curl
#
# Optional: xsel or xclip for automatically putting the URLs on the X selection 
# for easy pasting
#
# Instructions:
# Put it somewhere in your path and maybe rename it:
# 	mv ~/Downloads/imgurbash.sh ~/bin/imgur
# Make it executable:
# 	chmod +x ~/bin/imgur
# Optional, since Alan kindly provided an API key for this script: stick your 
# API key in the top:
# 	vim ~/bin/imgur
# Upload an image:
# 	imgur images/hilarious/manfallingover.jpg
# Upload multiple images:
# 	imgur images/delicious/cake.png images/exciting/bungeejump.jpg
# The URLs will be displayed (and the delete page's URLs will be displayed on 
# stderr). If you have xsel or xclip the URLs will also be put on the X 
# selection, which you can usually paste with a middle click.

client_id="2df86cb1deb663c"

# function to output usage instructions
function usage {
	echo "Usage: $(basename $0) <filename> [<filename> [...]]" >&2
	echo "Upload images to imgur and output their new URLs to stdout. Each one's" >&2
	echo "delete page is output to stderr between the view URLs." >&2
	echo "If xsel or xclip is available, the URLs are put on the X selection for" >&2
	echo "easy pasting." >&2
}

# check arguments
if [ "$1" = "-h" -o "$1" = "--help" ]; then
	usage
	exit 0
elif [ $# == 0 ]; then
	echo "No file specified" >&2
	usage
	exit 16
fi

# check curl is available
type curl >/dev/null 2>/dev/null || {
	echo "Couln't find curl, which is required." >&2
	exit 17
}

clip=""
errors=false

# loop through arguments
while [ $# -gt 0 ]; do
	file="$1"
	shift

	# check file exists
	if [ ! -f "$file" ]; then
		echo "file '$file' doesn't exist, skipping" >&2
		errors=true
		continue
	fi

	# upload the image
	response=$(curl -H "Authorization: Client-ID $client_id" -F "image=@$file" \
		https://api.imgur.com/3/image 2>/dev/null)
	# the "Expect: " header is to get around a problem when using this through 
	# the Squid proxy. Not sure if it's a Squid bug or what.
	if [ $? -ne 0 ]; then
		echo "Upload failed" >&2
		errors=true
		continue
	elif [ $(echo $response | grep -c "<error_msg>") -gt 0 ]; then
		echo "Error message from imgur:" >&2
		echo $response | sed -r 's/.*<error_msg>(.*)<\/error_msg>.*/\1/' >&2
		errors=true
		continue
	fi

	# parse the response and output our stuff
	url=$(echo $response | sed -r 's/.*"link"\:"(.*)"\},"success.*/\1/'|sed -r 's/\\//g')
	deleteurl=$(echo "http://imgur.com/delete/$(echo $response | sed -r 's/.*"deletehash"\:"(.*)","link".*/\1/')")
	echo $url
	echo "Delete page: $deleteurl" >&2

	# append the URL to a string so we can put them all on the clipboard later
	clip="$clip$url"
done

# put the URLs on the clipboard if we have xsel or xclip
if [ $DISPLAY ]; then
		{ type xsel >/dev/null 2>/dev/null && echo -n $deleteurl | xsel -i -b; 
		type xsel >/dev/null 2>/dev/null && echo -n $clip | xsel -i -b;
		notify-send "Done"; }\
		|| { type xclip >/dev/null 2>/dev/null && echo -n $deleteurl | xclip -selection c;
		type xclip >/dev/null 2>/dev/null && echo -n $clip | xclip -selection c;
		notify-send "Done"; } \
		|| echo "Haven't copied to the clipboard: no xsel or xclip" >&2
else
	echo "Haven't copied to the clipboard: no \$DISPLAY" >&2
fi

if $errors; then
	exit 1
fi
