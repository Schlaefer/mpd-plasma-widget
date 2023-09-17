#!/usr/bin/env bash

# Script args:
# 1: mpd host address
# 2: mpd file path
# 3: Path to cover directory
# 4: Prefix for cover file name
# 5: Caching "yes"

# We assume that albums have the same cover, saving only one cover per album, not for every song.
hash="uncached"
if [ "${5}" = "yes" ]; then
    album="$(mpc --host="${1}" -f '%album%' | head -n -2)"
    if [ -z "${album}" ]; then
        hashBase="${2}"
    else
        hashBase="${album}"
    fi
    hash="$(echo -n "${hashBase}" | md5sum | cut -d' ' -f1)"
fi

# Use hash as cover identifier in path
coverPath="${3}/${4}-${hash}"

if [ ! -f "${coverPath}" ] || [ ! "${5}" = "yes" ]; then
    # Request and save new cover
    mpc --host=${1} readpicture "${2}" > "${coverPath}"

    if [ "${5}" = "yes" ]; then
        # @TODO cache limit low for testing at the moment
        # Clear out old cache files so they don't stay around forever
        find "${3}" -type f -name "${4}-*" -mtime +0 -exec rm "{}" \; 2>/dev/null
    fi
fi

# Return path to current cover file
echo -n "${coverPath}"

exit 0
