#!/usr/bin/env bash

# Configuration
declare duration=60
declare recursive=false
declare verbose=false
declare oneshot=false
declare bold="$(tput bold)"
declare italic="$(tput sitm)"
declare reset="$(tput sgr0)"
declare -a images
declare -a search_dirs

# Colors
esc="\033"
bld="${esc}[1m"            #  Bold
rst="${esc}[0m"            #  Reset

bla="${esc}[30m"           #  Black          - Text
red="${esc}[31m"           #  Red            - Text
grn="${esc}[32m"           #  Green          - Text
ylw="${esc}[33m"           #  Yellow         - Text
blu="${esc}[34m"           #  Blue           - Text
mag="${esc}[35m"           #  Magenta        - Text
cya="${esc}[36m"           #  Cyan           - Text
whi="${esc}[37m"           #  Light Grey     - Text

bldbla=${bld}${bla}        #  Dark Grey      - Text
bldred=${bld}${red}        #  Red            - Bold Text
bldgrn=${bld}${grn}        #  Green          - Bold Text
bldylw=${bld}${ylw}        #  Yellow         - Bold Text
bldblu=${bld}${blu}        #  Blue           - Bold Text
bldmag=${bld}${mag}        #  Magenta        - Bold Text
bldcya=${bld}${cya}        #  Cyan           - Bold Text
bldwhi=${bld}${whi}        #  White          - Text

bgbla="${esc}[40m"         #  Black          - Background
bgred="${esc}[41m"         #  Red            - Background
bggrn="${esc}[42m"         #  Green          - Background
bgylw="${esc}[43m"         #  Yellow         - Background
bgblu="${esc}[44m"         #  Blue           - Background
bgmag="${esc}[45m"         #  Magenta        - Background
bgcya="${esc}[46m"         #  Cyan           - Background
bgwhi="${esc}[47m"         #  Light Grey     - Background

bldbgbla=${bld}${bgbla}    #  Dark Grey      - Background
bldbgred=${bld}${bgred}    #  Red            - Bold Background
bldbggrn=${bld}${bggrn}    #  Green          - Bold Background
bldbgylw=${bld}${bgylw}    #  Yellow         - Bold Background
bldbgblu=${bld}${bgblu}    #  Blue           - Bold Background
bldbgmag=${bld}${bgmag}    #  Magenta        - Bold Background
bldbgcya=${bld}${bgcya}    #  Cyan           - Bold Background
bldbgwhi=${bld}${bgwhi}    #  White          - Background

err() {
	echo -e ${red}"$1"${rst} >&2
}

die() {
	[[ -n "$1" ]] && err "$1"
	exit 1
}

usage() {
	more <<-'HELP'
wallshuffle.sh - wallpaper shuffling script
[-v] [-r] [-d NUMBER|-o] DIRECTORY... IMAGE...

-d NUMBER  - Set duration (in seconds) between wallpaper changes (default: 60)
-o         - Set a random wallpaper once and quit
-r         - Recursively find images in directories
-h         - Print this help information
-v         - Enable verbose output
HELP
}

while getopts ':vrd:ho' option; do
	case "$option" in
		h)
			usage
			exit
			;;
		o)
			unset oneshot
			;;
		v)
			unset verbose
			;;
		r)
			unset recursive
			;;
		d)
			if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
				duration="$OPTARG"
			fi
			;;
		\?)
			err "-$OPTARG is not a valid option"
			;;
	esac
done
shift $((OPTIND-1))

if [[ -z "$1" ]]; then
	usage
	exit 1
fi

for argument in $@; do
	if [[ -d "$1" ]]; then
		search_dirs+=( "$1" )
		shift
	elif [[ -f "$1" ]]; then
		if [[ "$1" =~ \.(jpeg|jpg|png)$ ]]; then
			images+=( "$1" )
		elif [[ -z $verbose ]]; then
			err "$1 is not an acceptable file, must be png or jpg"
		fi
		shift
	fi
done

if (( ${#search_dirs[@]} > 0 )); then
	for d in "${search_dirs[@]}"; do
		files=$(find $(realpath "$d") ${recursive:+-maxdepth 1} -iregex '.*\.\(jpeg\|jpg\|png\)')
		mapfile -t -O ${#images[@]} images <<< "$files"
	done
fi

[[ -z $verbose ]] && echo "${#images[@]} images found"

if (( ${#images[@]} < 1 )); then
	die 'No images found'
elif (( ${#images[@]} == 1 )); then
	feh --bg-fill "${images[@]}"
	exit
fi

if [[ -n "$oneshot" ]]; then
	while true; do
		printf '%s\n' "${images[@]}" | shuf | while IFS= read -r image; do
			[[ -z $verbose ]] && echo "Loading $image"
			feh --bg-fill "$image"
			sleep $duration
		done
	done
else
	mapfile -t images < <(printf '%s\n' "${images[@]}" | shuf)
	[[ -z $verbose ]] && echo "Loading ${images[0]}"
	feh --bg-fill ${images[0]}
fi
