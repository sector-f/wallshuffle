### wallshuffle.sh

**wallshuffle.sh** is a bash script used to randomize the desktop wallpaper. It uses either hsetroot or feh as a backend.

Usage: **wallshuffle.sh** [**-r**] [**-v**] [**-d** *NUMBER*|**-o**] [**-b** *NUMBER*] [**-p** *PROGRAM*] *IMAGE OR DIRECTORY*...

#### OPTIONS
`-h` Print help information

`-d <NUMBER>` Specify the wait time between changing wallpapers, in seconds. The default is 60.

`-b <NUMBER>` Specify the blur radius; only works if hsetroot is used

`-p <PROGRAM>` Specify which program to use; either 'hsetroot' or 'feh'

`-r` Recursively find images inside directories

`-o` Randomly select a single image from the specified directories/images and exit

`-v` Output more information about what the script is doing

Currently only supports jpg and png

####TODO
- Figure out which filetypes Imlib2 actually supports
