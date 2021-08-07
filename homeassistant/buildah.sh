#!/bin/bash 
# Buildah script for homeassistant image

# Source Image
SOURCE_IMAGE="docker.io/library/python:3.8-slim"

# Destination Image
DEST_IMAGE="registry.local/purplecarrot/homeassistant:latest"

# Source Root directory
PROC_CWD=$(readlink -f $0)
SRC_DIR=${PROC_CWD%/*}

# Build new container image
NEW_IMAGE=$(buildah from $SOURCE_IMAGE)
MOUNTPOINT=$(buildah mount $NEW_IMAGE)
echo "New image $NEW_IMAGE"
echo "Mounted at $MOUNTPOINT"

# Image Config
VIRTUAL_ENV=/homeassistant
buildah config --env PYTHONUNBUFFERED=1 $NEW_IMAGE
buildah config --env PIP_NO_CACHE_DIR=off $NEW_IMAGE
buildah config --env LANG=en_US.UTF-8 $NEW_IMAGE
buildah config --env VIRTUAL_ENV=$VIRTUAL_ENV $NEW_IMAGE
buildah config --env PATH="$VIRTUAL_ENV/bin:/bin:/usr/bin:/usr/local/bin" $NEW_IMAGE

# Install from inside container
# buildah run $NEW_IMAGE -- bash -e <<- EOF
#    python3 -m venv $VIRTUAL_ENV
#    python3 -m pip install homeassistant
#EOF

# Install from outside (don't have to install gcc as required for modules without wheels)
set -x
buildah run $NEW_IMAGE /usr/local/bin/python3 -m venv $VIRTUAL_ENV

LD_LIBRARY_PATH=$MOUNTPOINT/usr/local/lib $MOUNTPOINT/usr/local/bin/python3 -m pip install denonavr ffmpeg --prefix=$MOUNTPOINT/$VIRTUAL_ENV
LD_LIBRARY_PATH=$MOUNTPOINT/usr/local/lib $MOUNTPOINT/usr/local/bin/python3 -m pip install homeassistant --prefix=$MOUNTPOINT/$VIRTUAL_ENV

buildah run $NEW_IMAGE ls -l $VIRTUAL_ENV/{bin,lib/python3.8}
buildah config --port 8123 $NEW_IMAGE
buildah config --cmd "$VIRTUAL_ENV/bin/python -m homeassistant -c /config --debug" $NEW_IMAGE

buildah commit --squash $NEW_IMAGE $DEST_IMAGE
buildah unmount $NEW_IMAGE
buildah rm $NEW_IMAGE

set +x
echo "Built new image $DEST_IMAGE ($NEW_IMAGE)"
echo "     from image $SOURCE_IMAGE"

