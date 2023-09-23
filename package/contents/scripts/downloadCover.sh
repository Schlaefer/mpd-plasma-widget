#!/usr/bin/env bash

# Script args:
# 1: mpd host address
# 2: mpd file path
# 3: Path to cover directory
# 4: Prefix for cover file name
# 5: Caching "yes"
# 6: filename

# Create cover path
if [ ! -d "${3}" ]; then
    mkdir -p "${3}"
fi
# Use hash as cover identifier in path
coverPath="${3}/${6}"

# Running multiple widget instances on the same system: Some other widget on the same
# system already started to request a cover, so this instance wont and waits instead.
lockfile="${3}/${4}-lock"
if [ -f "${lockfile}" ]; then
    i=1
    # Observed worst case download time so far 30 seconds
    waitTarget=120
    while [ -f "${lockfile}" -a $i -lt $waitTarget ]; do
        sleep 0.5
        ((i = i + 1))
    done
    # Alas sometimes things go wrong while downloading, e.g. a plasmashell crash. This
    # recovers eventually.
    if [ $i = $waitTarget ]; then
        rm "${lockfile}"
    fi
fi

if [ ! -f "${coverPath}" -o "${5}" != "yes" ]; then
    touch "${lockfile}"
    mpc --host=${1} readpicture "${2}" >"${coverPath}"
    rm "${lockfile}"
    # @TODO move to seperate command and call from QML timer
    if [ "${5}" = "yes" ]; then
        # Clear out old cache files so they don't stay around forever
        find "${3}" -type f -name "${4}-*" -mtime +1 -exec rm "{}" \; 2>/dev/null
    fi
fi

# Return path to current cover file
echo -n "${coverPath}"

exit 0
