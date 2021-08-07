#!/bin/bash
# SmokePing
#
# If you want to run smokeping with rootless podman, it needs
# to be able to send pings :-) 
# 
#   1. sysctl net.ipv4.ping_group_range="0 100100"
#   2. setcap CAP_NET_RAW

IMAGE="linuxserver/smokeping:latest"
NAME="smokeping"

PROC=$(readlink -f $0)
ROOT_DIR=${PROC%/*}

podman run -d \
  --name=${NAME} \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Europe/London \
  -e HOSTNAME=smokeping.local \
  -p 2001:80\
  -v /data/smokeping/config:/config:Z \
  -v /data/smokeping/data:/data:Z \
  --restart no \
  --rm \
  $IMAGE
