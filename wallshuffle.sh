#!/usr/bin/env bash

declare recursive=false
declare verbose=false
declare oneshot=false
declare bold="$(tput bold)"
declare italic="$(tput sitm)"
declare reset="$(tput sgr0)"
declare interval
declare -a images
declare -a search_dirs

err() {
	echo -e "\e[31m$1\e[0m" >&2
}

die() {
	[[ -n "$1" ]] && err "$1"
	exit 1
}

printhelp() {
	echo "${bold}NAME${reset}
	$(basename $0) - wallpaper shuffling script written in bash

${bold}SYNOPSIS${reset}
	${bold}$(basename $0)${reset} [${bold}-v${reset}] [${bold}-r${reset}] [${bold}-i${reset} ${italic}NUMBER${reset}|${bold}-o${reset}] ${italic}DIRECTORY${reset}... ${italic}IMAGE${reset}...

${bold}Description${reset}
	$(basename $0) is a bash script written to simplify randomizing
	your desktop wallpaper. It allows any number of images or
	directories to be specified, then randomly cycles through
	the given images and the images contained within the given
	directories. If only one image is found/specified, it will
	set that image as the wallpaper and exit.

${bold}OPTIONS${reset}
	${bold}-h${reset} - Print this help information

	${bold}-i${reset} ${italic}NUMBER${reset} - Set interval (in seconds) between wallpaper
		    changes (default: 60)

	${bold}-r${reset} - Recursively find images in directores

	${bold}-o${reset} - Randomly select a single image from the specified directories/images
	     and exit

	${bold}-v${reset} - Enable verbose output"
	exit
}

while getopts ':vri:ho' option; do
	case "$option" in
		h)
			printhelp
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
		i)
			if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
				interval="$OPTARG"
			fi
			;;
		\?)
			err "-$OPTARG is not a valid option"
			;;
	esac
done
shift $((OPTIND-1))

if [[ -z "$1" ]]; then
	printhelp
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
			sleep ${interval:-60}
		done
	done
else
	mapfile -t images < <(printf '%s\n' "${images[@]}" | shuf)
	[[ -z $verbose ]] && echo "Loading ${images[0]}"
	feh --bg-fill ${images[0]}
fi
