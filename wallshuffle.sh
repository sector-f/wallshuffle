#!/usr/bin/env bash

SHORT="i:"
LONG="interval:"
OPTIONS=$(getopt -o "$SHORT" -l "$LONG" -n "$(basename $0)" -- "$@")
eval set -- "$OPTIONS"

shopt -s nullglob

for argument in $@; do
	case "$1" in
		-i|--interval)
			interval="$2"
			shift 2
			;;
		*)
			if [[ -d "$1" ]]; then
				images+=("$(dirname $1)/$(basename $1)"/*.{jpg,jpeg,png})
			elif [[ -f "$1" ]]; then
				images+=("$1")
			fi
			shift
			;;
	esac
done

shuffleimages() {
	for image in "${images[@]}"; do
		echo $image
	done | shuf
}

setbackground() {
	while true; do
		for image in $(shuffleimages); do
			feh --bg-fill "$image"
			sleep ${interval:-60}
		done
	done
}

setbackground
