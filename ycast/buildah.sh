#!/bin/bash 
# Buildah script for ycast image

# Source Image
SOURCE_IMAGE="docker.io/library/python:3.8-slim"

# Destination Image
DEST_IMAGE="registry.local/purplecarrot/ycast:latest"

# Source Root directory
PROC_CWD=$(readlink -f $0)
SRC_DIR=${PROC_CWD%%/*}

# Build new container image
NEW_IMAGE=$(buildah from $SOURCE_IMAGE)
MOUNTPOINT=$(buildah mount $NEW_IMAGE)
echo "New image $NEW_IMAGE"
echo "Mounted at $MOUNTPOINT"

# Image Config
buildah config --env PYTHONUNBUFFERED=1 $NEW_IMAGE
buildah config --env PIP_NO_CACHE_DIR=off $NEW_IMAGE
buildah config --env LANG=en_US.UTF-8 $NEW_IMAGE

# Create and activate virtualenv
buildah run $NEW_IMAGE -- bash -e <<- EOF
    python3 -m venv /venvs/ycast
    . /venvs/ycast/bin/activate
    python3 -m pip install ycast
EOF

buildah config --port 2001 $NEW_IMAGE
buildah config --entrypoint "/venvs/ycast/bin/python3 -m ycast -p 2001 -l localhost" $NEW_IMAGE

buildah commit --squash $NEW_IMAGE $DEST_IMAGE
buildah unmount $NEW_IMAGE
buildah rm $NEW_IMAGE

echo "Built new image $DEST_IMAGE ($NEW_IMAGE)"
echo "     from image $SOURCE_IMAGE"

