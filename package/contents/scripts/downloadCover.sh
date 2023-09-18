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

# Running multiple widget instances on the same system: Some other widget on the same
# system already started to request a cover, so this instance wont and waits instead.
# @TODO Prevent a permanent lock.
lockfile="${3}/${4}-lock"
if [ -f "${lockfile}" ]; then
    while [ -f "${lockfile}" ]; do
        sleep 0.1
    done 
fi

if [ ! -f "${coverPath}" ]; then
    touch "${lockfile}"
    mpc --host=${1} readpicture "${2}" > "${coverPath}"
    rm "${lockfile}"

    if [ "${5}" = "yes" ]; then
        # Clear out old cache files so they don't stay around forever
        find "${3}" -type f -name "${4}-*" -mtime +1 -exec rm "{}" \; 2>/dev/null
    fi
fi

# Return path to current cover file
echo -n "${coverPath}"

exit 0
