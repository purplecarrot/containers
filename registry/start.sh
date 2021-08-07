#!/bin/bash
IMAGE="docker.io/library/registry"
NAME="registry"

# Source Root directory
PROC=$(readlink -f $0)
ROOT_DIR=${PROC%/*}

REGISTRY_HTTP_TLS_CERTIFICATE="/etc/pki/tls/certs/home.local.crt"
REGISTRY_HTTP_TLS_KEY="/etc/pki/tls/private/home.local.key"

podman run -d \
  --rm \
  --name ${NAME} \
  -p 5000:5000 \
  -v ${ROOT_DIR}/var-lib-registry:/var/lib/registry:Z \
  -v ${ROOT_DIR}/root/etc/pki:/etc/pki:Z \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=$REGISTRY_HTTP_TLS_CERTIFICATE \
  -e REGISTRY_HTTP_TLS_KEY=$REGISTRY_HTTP_TLS_KEY \
  --cap-drop all \
  --cap-add CAP_DAC_OVERRIDE \
  $IMAGE
