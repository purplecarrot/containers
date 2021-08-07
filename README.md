# Containers

This repository contains files and notes used create my homelab containers after I decided to migrate to running all services running as unprivileged rootless podman containers, running under user systemd services. Where a new container is being build, the buildah.sh shell scripts in each directory were used instead of Dockerfiles to test this functionality of buildah.

  * **nginx**<br><br>To run nginx as a rootless container, you have to address the permissons required to bind to a privileged port. You have a few different options:<br><br>
     * Use high ports such as 8443 instead of 443
     * Set the net.ipv4.ip_unprivileged_port start to 443
     * Give the container CAP_NET_BIND_SERVICE capability<br><br>
  
  * **unifi**<br><br>This image is the linuxserver.io Unifi controller image. It was pretty straight forward to run. The only caveat was when trying to adopt an access point when running inside a container, the Unifi controller returns the IP of the container, which is obviously not addressable by the AP outside the host (see also [Configuring container networking with Podman](https://www.redhat.com/sysadmin/container-networking-podman) as it's very interesting seeing how podman does rootless networking)<br><br>To address this, you can simply go to the _Settings -> Controller_ section of the Unifi Controller, and select _Override inform host with controller hostname/IP_ and then set the hostname/IP value to be that of the host itself (nginx container above in this case)<br><br>

  * **homeassistant**<br><br>This was as much an exercise in curiosity and looking at building a container using buildah shell scripts (instead of a Dockerfile) and without requiring root. It's actually very straight forward. The advantage is you can run commands using tools outside the container, with the advantage that those tools aren't installed or left inside the container after build time. You can also use shell script constructs which makes many things easier.<br><br>

  * **registry**<br><br> The standard docker container registry set to start up using certifcate issued by my private CA (every self-respecting geek should have one!)<br><br>

  * **ycast**<br><br>Simple python program that emulates the vTuner internet radio service. I use this so I can continue using an old Marantz AVR that I only ever use to listen to a couple of stations.<br><br>

  * **smokeping**<br><br>To run smokeping in a rootless container, the processes inside the container need to be able to ping. You have two options here:
    * Set sysctl net.ipv4.ping_group_range="0 101000" to allow the user running the container permissions
    * Give the container CAP_NET_RAW capability<br><br>


## Configuration

To set all these containers to startup on boot, I first created a shell script to start the container and then used the podman generate systemd command to generate podman user systemd units. The commands listed below are examples for the homeassistant container.

#### Setup system/service account user
You could run this using your own interactive login account, but I prefer to have a separate service account that isn't used for day to day activities.

```go
# useradd home -r -m -s /bin/false home
```
You'll also need to "enable linger" so that any systemd processes remain after any user logouts.
```go
$ loginctl enable-linger home
```

#### Start pod manually
First create a simple script to start the container with the parameters needed:
```bash 
$ cd ./homeassistant
$ ./start-homeassistant.sh
```

#### Generate, enable and start userspace systemd Unit
```bash
$ podman generate systemd --name homeassistant --new > ~/.config/systemd/user/homeassistant.service
$ systemctl --user start homeassistant.service
$ systemctl --user enable homeassistant.service
```

