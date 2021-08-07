#!/bin/bash

# If you want to run nginx with rootless podman, you do have
# to allow it to bind to the privileged ports
#
#   1. Allow nginx running under rootless podman to bind to 80/443
#   cat << EOF > /etc/sysctl.d/podman-nginx.conf
#   net.ipv4.ip_unprivileged_port_start=443
#   2. setcap cap_net_bind_service
#   3. run as root, then drop --cap-drop=all --cap-add CAP_NET_BIND_SERVICE

IMAGE="nginx"

podman run \
  --rm \
  -d \
  --name nginx \
  -p 443:443 \
  -p 80:80 \
  -v /data/nginx/www:/www:Z \
  -v /data/nginx/root/etc/nginx/nginx.conf:/etc/nginx/nginx.conf:Z \
  -v /data/nginx/root/etc/pki/tls:/etc/pki/tls:Z \
  $IMAGE
