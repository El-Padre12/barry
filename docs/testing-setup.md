# Barry's Testing Environment Setup-Guide

This document details the steps i took to build my 'testing' environment for Barry my homelab-server.
Phase one consists of the manual steps I took to build this.
Phase two consists of the IaC I write to automate the deployment and configuration of the testing env.

## Table of Contents

1. [Phase One](#phase-one-manual-setup)

## Phase One: Manual Setup

Phase one consists of manually provisioning and configuring the testing environment on Barry. 
Followed by deploying my applications one at a time, using docker-compose and getting comfortable with docker networking, volumes, and env vars.

### Create VM in Proxmox
    **If not specified here leave as default**
   - In Proxmox provision a 12gb, 4-cores, 60gb-disk VM
   - ensure Qemu Agent checkboxed is check - you will need to also install the Qemu software post install on the Debian VM
   - Under 'Disks" tab ensure 60gb is set for the disk size
   - Under 'CPU' tab set cores to 4 and the rest default
   - Memory should = 12048mb or 12gb
   - For network config the 'vmbr0' bridge should be selected and for now there is no 'VLAN Tag'.
   - Confirm/Review and then create
### Install Debian12
   - Graphical Install english and CST for locale and keyboard
   - set hostname, root-password, sudo user/password
   - partition - use entire disk, for now leave all defualt
   - configure package manager - use a debian mirror in the U.S. default everything else
   - For 'software selection' uncheck the 'Debian desktop enviroment' and 'Gnome' if it is selected. Ensure 'SSH server' & 'standard system utilities' are checked
     as we will need this but we will not need a GUI.
   - Install GRUB boot loader to your primary drive by selecting the device '/dev/sda'
   - reboot
### Install Qemu Guest Agent
   ```bash
   apt update && apt upgrade -y 
   ```
   ```bash
   apt install qemu-guest-agent
   ``` 
### Install Docker & Docker Compose on debian

When debian 12 is initially installed tools like 'sudo' and 'curl' won't be installed. So you must install 'sudo' as root and ensure your user has 'sudo privileges'
   - uninstall old versions
   ```bash
   sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-doc podman-docker containerd runc | cut -f1)
   ```
   - set up dockers apt repository
   ```bash
   # Add Docker's official GPG key:
   sudo apt update
   sudo apt install ca-certificates curl
   sudo install -m 0755 -d /etc/apt/keyrings
   sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
   sudo chmod a+r /etc/apt/keyrings/docker.asc

   # Add the repository to Apt sources:
   sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
   Types: deb
   URIs: https://download.docker.com/linux/debian
   Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
   Components: stable
   Signed-By: /etc/apt/keyrings/docker.asc
   EOF

   sudo apt update
   ```
   - install docker packages
   ```bash
   sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
   ```
   - add your user to the 'docker' group so you don't need to preface docker commands with 'sudo' everytime
   ```bash
   sudo usermod -aG docker $USER
   ```
   - verify install/user added to docker-group by running the hello-world image
   ```bash
   docker run hello-world
   ``` 

### Homepage Deployment

   - following the documentation at the [Homepage-Website](https://gethomepage.dev/installation) was pretty straight forward.
   - I dont feel the need to go step by step, but I wanted to say that when it comes to docker volumes I'm going to store them on a *dedicated seperate mount point*.
     Seperating the Docker volumes from the OS, this will be good Backup&Recovery, Storage management, and performance.

## Phase Two: IaC   
