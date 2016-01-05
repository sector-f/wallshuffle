### wallshuffle.sh

Usage: **wallshuffle.sh** [**-r**] [**-v**] [**-i** *NUMBER*] *IMAGE OR DIRECTORY*...

#### OPTIONS
`-i <NUMBER>` Specify the wait time between changing wallpapers, in seconds. The default is 60.

`-r` Recursively find images inside directories

`-v` Output more information about what the script is doing

Currently only supports jpg and png, until I can find a complete list of filetypes supported by feh

####TODO
- Figure out which filetypes feh/Imlib2 actually supports
