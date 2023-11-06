#!/usr/bin/env bash

# @SOMEDAY rewrite in python

# Script args:
# 1: mpd host address
# 2: mpd file path
# 3: Path to cover directory
# 4: mpd port
# 5: filename

# Check if imagemagick is installed
if ! command -v convert &> /dev/null
then
    echo "No data"
    exit 0
fi

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
    waitTarget=60
    while [ -f "${lockfile}" -a $i -lt $waitTarget ]; do
        sleep 1
        ((i = i + 1))
    done
    # Alas sometimes things go wrong while downloading, e.g. a plasmashell crash. This
    # recovers eventually.
    if [ $i = $waitTarget ]; then
        rm "${lockfile}"
    fi
else
    # Migrating from from 4.x to 5.0: remove old, unprocessed images without suffix
    if [ -f "${coverPath}" ]; then
        rm "${coverPath}"
    fi
fi

if [ ! -f "${coverPath}" ]; then
    touch "${lockfile}"
    # mpc --host=${1} readpicture "${2}" >"${coverPath}" 2>&1
    scriptDir="$(dirname "$(readlink -f "$0")")"
    python3 "${scriptDir}/mpdPlasmaWidgetExec.py" --host ${1} --port ${4} --cmd readpicture "${2}" "${coverPath}"
    # We don't check the return value of the "request image"-cmd. After requesting the
    # cover it is either available for processing or not.
    if [ -f "${coverPath}" ]; then
        convert "${coverPath}" -resize 1500x\> "${coverPath}-large.jpg"
        convert "${coverPath}" -resize 64x64 "${coverPath}-small.jpg"
        rm "${coverPath}"
    else
        echo "No data"
    fi

    rm "${lockfile}"
fi

exit 0
