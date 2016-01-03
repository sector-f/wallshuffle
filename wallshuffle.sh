#!/usr/bin/env bash

SHORT="i:"
LONG="interval:"
OPTIONS=$(getopt -o "$SHORT" -l "$LONG" -n "$(basename $0)" -- "$@")
eval set -- "$OPTIONS"

shopt -s nullglob
IFS=$'\n'

for argument in $@; do
	case "$1" in
		-i|--interval)
			interval="$2"
			shift 2
			;;
		*)
			if [[ -d "$1" ]]; then
				cd $1
				images+=("$(dirname $1)/$(basename $1)"/*.{jpg,jpeg,png})
			elif [[ -f "$1" ]]; then
				images+=("$1")
			fi
			shift
			;;
	esac
done

if [[ "${#images[@]}" -eq 0 ]]; then
	echo "No images specified"
	exit 1
elif [[ "${#images[@]}" -eq 1 ]]; then
	feh --bg-fill "${images[@]}"
	exit
fi

shuffleimages() {
	for image in "${images[@]}"; do
		echo "$image"
	done | shuf
}

while true; do
	for image in $(shuffleimages); do
		feh --bg-fill "$image"
		sleep ${interval:-60}
	done
done
