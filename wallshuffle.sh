#!/usr/bin/env bash

declare duration=60
declare recursive=false
declare -a images
declare -a search_dirs
declare verbose=false

err() {
	echo -e "\e[31m$1\e[0m" >&2
}

die() {
	[[ -n "$1" ]] && err "$1"
	exit 1
}

usage() {
	more <<-'HELP'
wallshuffle.sh - wallpaper shuffling script
[-v] [-r] [ -i NUMBER] DIRECTORY... IMAGE...

-d NUMBER  - Set duration (in seconds) between wallpaper changes (default: 60)
-r         - Recursively find images in directories
-h         - Print this help information
-v         - Enable verbose output
HELP
}

while getopts ':vri:h' option; do
	case "$option" in
		h)
			usage
			exit
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

while true; do
	printf '%s\n' "${images[@]}" | shuf | while IFS= read -r image; do
		[[ -z $verbose ]] && echo "Loading $image"
		feh --bg-fill "$image"
		sleep "$duration"
	done
done
