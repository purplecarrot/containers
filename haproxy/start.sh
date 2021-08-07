#!/bin/bash

# sysctl net.ipv4.ip_forward=1
# sysctl net.ipv4.ip_unprivileged_port_start=443
# --cap-add CAP_NET_BIND_SERVICE

IMAGE="haproxy:0.1"
podman run --name haproxy --rm -d -p 80:80 -p 443:443 -p 8000:8000 -p 1936:1936 $IMAGE 
