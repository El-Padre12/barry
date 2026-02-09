# Phase One: Manual Setup

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
### Install Docker & Docker Compose on debian
   - ...
