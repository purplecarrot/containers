#!/bin/bash 

# Source Image
SOURCE_IMAGE="scratch"
SOURCE_IMAGE="fedora:33"
#SOURCE_IMAGE="registry.access.redhat.com/ubi8/ubi"

# Destination Image
DEST_VERSION="0.1"
DEST_IMAGE="haproxy:$DEST_VERSION"

# Source Root directory
SRC_DIR=$(pwd -P)

# Build new container image
NEW_IMAGE=$(buildah from $SOURCE_IMAGE)
MOUNTPOINT=$(buildah mount $NEW_IMAGE)

cat << EOF
Building new image $DEST_IMAGE ($NEW_IMAGE)
        from image $SOURCE_IMAGE
           src dir $SRC_DIR
        mounted at $MOUNTPOINT

EOF

buildah run $NEW_IMAGE yum install -y haproxy 
buildah run $NEW_IMAGE yum clean all
buildah config --port 443 $NEW_IMAGE
buildah config --port 8000 $NEW_IMAGE
buildah config --port 1936 $NEW_IMAGE
buildah copy $NEW_IMAGE $SRC_DIR/haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg

buildah config --label maintainer="mark@purplecarrot.co.uk" $NEW_IMAGE
buildah config --entrypoint "/usr/sbin/haproxy -d -f /usr/local/etc/haproxy/haproxy.cfg" $NEW_IMAGE

buildah commit --squash $NEW_IMAGE $DEST_IMAGE
# buildah rm $NEW_IMAGE
# podman generate systemd haproxy
