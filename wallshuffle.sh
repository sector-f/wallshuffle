#!/usr/bin/env bash

################
# Declarations #
################
declare program
declare blurvalue
declare duration=60
declare recursive=false
declare verbose=false
declare oneshot=false
declare checkblur=false
declare bold="$(tput bold)"
declare italic="$(tput sitm)"
declare reset="$(tput sgr0)"
declare -a images
declare -a search_dirs

#############
# Functions #
#############
err() {
	echo -e "\e[31m$1\e[0m" >&2
}

die() {
	[[ -n "$1" ]] && err "$1"
	exit 1
}

blur() {
	case $program in
		feh)
			err "-b can only be used with hsetroot"
			;;
	esac
}

usage() {
	more <<-'HELP'
wallshuffle.sh - wallpaper shuffling script
[-v] [-r] [-d NUMBER|-o] [-b NUMBER] [-p PROGRAM] IMAGE OR DIRECTORY...

-d NUMBER  - Set duration (in seconds) between wallpaper changes (default: 60)
-b NUMBER  - Set blur radius; only works with hsetroot
-p PROGRAM - Set which program to use; either 'hsetroot' or 'feh'
-o         - Set a random wallpaper once and quit
-r         - Recursively find images in directories
-h         - Print this help information
-v         - Enable verbose output
HELP
}

# Get which program to use
if type hsetroot &> /dev/null; then
	program="hsetroot"
elif type feh &> /dev/null; then
	program="feh"
else
	echo "This script depends on either hsetroot or feh"
	exit 1
fi

while getopts ':vrd:hob:p:' option; do
	case "$option" in
		h)
			usage
			exit
			;;
		p)
			program="$OPTARG"
			;;
		b)
			unset checkblur
			blurvalue="$OPTARG"
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

if [[ -z $checkblur ]]; then
	blur "$blurvalue"
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
	case $program in
		hsetroot)
			hsetroot -fill "${images[@]}" -blur ${blurvalue:-0}
			;;
		feh)
			feh --bg-fill "${images[@]}"
			;;
	esac
	exit
fi

if [[ -n "$oneshot" ]]; then
	while true; do
		printf '%s\n' "${images[@]}" | shuf | while IFS= read -r image; do
			[[ -z $verbose ]] && echo "Loading $image"
			case $program in
				hsetroot)
					hsetroot -fill "$image" -blur ${blurvalue:-0}
					;;
				feh)
					feh --bg-fill "$image"
					;;
			esac
			sleep $duration
		done
	done
else
	mapfile -t images < <(printf '%s\n' "${images[@]}" | shuf)
	[[ -z $verbose ]] && echo "Loading ${images[0]}"
	case $program in
		hsetroot)
			hsetroot -fill "${images[0]}" -blur ${blurvalue:-0}
			;;
		feh)
			feh --bg-fill ${images[0]}
			;;
	esac
fi
