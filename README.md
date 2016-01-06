### wallshuffle.sh

Usage: **wallshuffle.sh** [**-r**] [**-v**] [**-d** *NUMBER*|**-o**] *IMAGE OR DIRECTORY*...

#### OPTIONS
`-h` Print help information

`-d <NUMBER>` Specify the wait time between changing wallpapers, in seconds. The default is 60.

`-r` Recursively find images inside directories

`-o` Randomly select a single image from the specified directories/images and exit

`-v` Output more information about what the script is doing

Currently only supports jpg and png, until I can find a complete list of filetypes supported by feh

####TODO
- Figure out which filetypes feh/Imlib2 actually supports
