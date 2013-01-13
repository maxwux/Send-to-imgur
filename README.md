imgur script by Bart Nagel <bart at tremby.net>, acelan, maxwux <maxwux at gmail.com>
version 7
Bart Nagel release this into the public domain. Do with it what you will.

Required: curl 

Optional: xsel or xclip for automatically putting the URLs on the X selection
for easy pasting

Instructions:

Put it somewhere in your path and maybe rename it:

mv ~/Downloads/send_to_imgur.sh ~/bin/send_to_imgur.sh 

Make it executable:

chmod +x ~/bin/send_to_imgur.sh 

Optional, since Alan kindly provided an API key for this script: stick your
API key in the top:

vim ~/bin/send_to_imgur.sh 

Upload an image:

send_to_imgur.sh images/hilarious/manfallingover.jpg

Upload multiple images:

send_to_imgur.sh images/delicious/cake.png images/exciting/bungeejump.jpg

The URLs will be displayed (and the delete page's URLs will be displayed on
stderr). If you have xsel or xclip the URLs will also be put on the X
selection, which you can usually paste with a ctrl v.

