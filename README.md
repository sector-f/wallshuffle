### wallshuffle.sh

Usage: **wallshuffle.sh** [**-r**] [**-v**] [**-i** *NUMBER*] *IMAGE OR DIRECTORY*...

#### OPTIONS
`-i|--interval <NUMBER>` Specify the wait time between changing wallpapers, in seconds. The default is 60.

`-r|--recursive` Recursively find images inside directories

`-v|--verbose` Output more information about what the script is doing

Currently only supports jpg and png, until I can find a complete list of filetypes supported by feh

####TODO
- Make the script use `getopts`
- Figure out which filetypes feh/Imlib2 actually supports
