#!/bin/bash
# Unifi Controller
#
# UDP 	3478 	Port used for STUN.
# UDP 	5514 	Port used for remote syslog capture.
# TCP 	8080 	Port used for device and application communication.
# TCP 	8443 	Port used for application GUI/API as seen in a web browser.
# TCP 	8880 	Port used for HTTP portal redirection.
# TCP 	8843 	Port used for HTTPS portal redirection.
# TCP 	6789 	Port used for UniFi mobile speed test.
# TCP 	27117 	Port used for local-bound database communication.
# UDP 	5656-5699 	Ports used by AP-EDU broadcasting.
# UDP 	10001 	Port used for device discovery.
# UDP 	1900 	Port used for "Make application discoverable on L2 network" in the UniFi Network settings.

IMAGE="linuxserver/unifi-controller:latest"
NAME="unifi"

PROC=$(readlink -f $0)
ROOT_DIR=${PROC%/*}

podman run -d \
  --name ${NAME} \
  --rm \
  -e PUID=1000 \
  -e PGID=1000 \
  -p 3478:3478/udp \
  -p 10001:10001/udp \
  -p 8080:8080 \
  -p 8443:8443 \
  -p 8843:8880 \
  -p 8880:8880 \
  -p 6789:6789 \
  -v $ROOT_DIR/config:/config:Z \
  $IMAGE
  #--restart always \

