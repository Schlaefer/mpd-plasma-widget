#!/usr/bin/env bash

# Script to create a pling store plasmoid file

# Break on errors
set -e

# Move to project root
cd "$(dirname "$0")"
cd ..

# Get git tag
TAG=$(git describe --tags --abbrev=0)
TAG_DASHED=${TAG//./-}
BASENAME="plasma-mpd-widget${TAG}"
ZIP_NAME="${BASENAME}.zip"
PLASMOID_NAME="${BASENAME}.plasmoid"

# Create the zip, excluding unnecessary runtime an lib files
zip -qr "release/${ZIP_NAME}" package/ \
    -x "*/__pycache__/*" \
    -x "*.pyc" \
    -x "*/tests.py"

mv "release/${ZIP_NAME}" "release/${PLASMOID_NAME}"

REALPATH=$(realpath "release/${PLASMOID_NAME}")
echo
echo "✅ Plasmoid created: ${REALPATH}"
