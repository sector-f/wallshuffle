#!/usr/bin/env bash

# Okay, let's start with some variables

# If the first argument is a directory, then we'll use that
# Otherwise, exit
if [[ -d "$1" ]]; then
	dir=$1
else
	echo "No directory specified"
	exit 1
fi

# Now we'll see if the second arg is an integer
# If it is, we'll use it as the time between image changes (in seconds)
# If it isn't...eh, who cares? We can just default to 60
if [[ "$2" =~ ^-?[0-9]+$ ]]; then
	interval="$2"
fi

# Now for the fun part!

# First we get every image in the directory and shuffle them
# We'll make this a function so we can call it more easily
shuffle() {
	for image in $dir/*.{jpg,jpeg,png}; do
		[[ -f "$image" ]] && echo "$image"
	done | shuf
}

# Then we actually start setting them as a background
# If we set an interval, we'll use that instead of 60
while true; do
	for image in $(shuffle); do
		feh --bg-fill "$image"
		sleep ${interval:-60}
	done
done
