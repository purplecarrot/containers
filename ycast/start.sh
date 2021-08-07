#!/bin/bash
IMAGE="registry.local/purplecarrot/ycast:latest"

podman run -d \
  --rm \
  --name ycast \
  -p 2001:2001 \
  --cap-drop all \
  $IMAGE


