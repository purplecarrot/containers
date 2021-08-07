#!/bin/bash
IMAGE="registry.local/purplecarrot/homeassistant:latest"

PROC=$(readlink -f $0)
ROOT_DIR=${PROC%/*}

HTTP_TLS_CERTIFICATE="/etc/pki/tls/certs/home.local.crt"
HTTP_TLS_KEY="/etc/pki/tls/private/home.local.key"

podman run -d \
  --rm \
  --name homeassistant \
  -p 8123:8123 \
  -v ${ROOT_DIR}/config:/config:Z \
  -v ${ROOT_DIR}/media:/media:Z \
  $IMAGE

 # --cap-drop all \
 # --cap-add CAP_DAC_OVERRIDE \
 # --restart always \

