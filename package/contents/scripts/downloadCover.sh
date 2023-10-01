#!/usr/bin/env bash

# Script args:
# 1: mpd host address
# 2: mpd file path
# 3: Path to cover directory
# 4: Prefix for cover file name
# 5: filename

# Create cover path
if [ ! -d "${3}" ]; then
    mkdir -p "${3}"
fi
# Use hash as cover identifier in path
coverPath="${3}/${5}"

# Running multiple widget instances on the same system: Some other widget on the same
# system already started to request a cover, so this instance wont and waits instead.
lockfile="${coverPath}.lock"
if [ -f "${lockfile}" ]; then
    i=1
    # Observed worst case download time so far 30 seconds
    waitTarget=200
    while [ -f "${lockfile}" -a $i -lt $waitTarget ]; do
        sleep 0.2
        ((i = i + 1))
    done
    # Alas sometimes things go wrong while downloading, e.g. a plasmashell crash. This
    # recovers eventually.
    if [ $i = $waitTarget ]; then
        rm "${lockfile}"
    fi
fi

if [ ! -f "${coverPath}" ]; then
    touch "${lockfile}"
    mpc --host=${1} readpicture "${2}" > "${coverPath}" 2>&1
    noData=$(head -c 7 "${coverPath}")

    if [ "$noData" = "No data" ]; then
        echo "No data"
        rm "${coverPath}"
    else
        echo -n "${coverPath}"
    fi

    rm "${lockfile}"
fi

exit 0
