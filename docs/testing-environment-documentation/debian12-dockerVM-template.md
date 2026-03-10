# Creating a Debian 12 Template from Existing VM

#### This documents how I converted my working dockerVM into a cloud-init template for automated provisioning with Terraform. This approach uses a known-good VM configuration rather than starting from a generic cloud image.

### Prerequisites
- Working VM with Docker, SSH, and desired base configuration
- VM must have qemu-guest-agent installed and running

### Step 1 - Clone the Working VM
- Clone VM 1212 to create template base:
```bash
  qm clone 1212 9000 --name debian12-docker-template --full
```
  This creates a full clone (takes ~2 minutes to copy disks)

### Step 2 - Detach Data Disk from Clone
- Remove the data disk so template only contains OS:
```bash
  qm set 9000 --delete scsi1
```
- Verify only OS disk remains:
```bash
  qm config 9000 | grep scsi
```
  Should show only `scsi0`, no `scsi1`

### Step 3 - Boot Clone and Fix fstab
- Start the cloned VM:
```bash
  qm start 9000
```
- VM will enter emergency mode due to missing data disk in fstab
- Access via Proxmox UI Console
- Edit fstab and remove docker-data mount:
```bash
  nano /etc/fstab
  # Delete or comment out the line with /var/lib/docker-data
  reboot
```

### Step 4 - SSH In and Clean Docker State
- SSH into the clone once it boots
- Remove all Docker containers, images, and volumes:
```bash
  docker stop $(docker ps -aq)
  docker rm $(docker ps -aq)
  docker rmi $(docker images -q)
  docker volume prune -a -f
  docker network prune -f
  docker system prune -a -f --volumes
```
- Remove application directories:
```bash
  rm -rf ~/linkding
  rm -rf ~/homepage
```

### Step 5 - Clean Tailscale State
- Remove Tailscale identity (so cloned VMs get unique identities):
```bash
  sudo tailscale logout
  sudo systemctl stop tailscaled
  sudo rm -rf /var/lib/tailscale/
```

### Step 6 - Clean System State
- Clear bash history:
```bash
  history -c
  rm ~/.bash_history
```
- Reset machine ID (cloud-init will regenerate):
```bash
  sudo truncate -s 0 /etc/machine-id
  sudo rm /var/lib/dbus/machine-id
  sudo ln -s /etc/machine-id /var/lib/dbus/machine-id
```

### Step 7 - Install and Configure Cloud-Init
- Install cloud-init package:
```bash
  sudo apt update
  sudo apt install -y cloud-init
```
- Clean cloud-init state:
```bash
  sudo cloud-init clean --logs --seed
```

### Step 8 - Final Cleanup
- Remove SSH host keys (regenerate on first boot):
```bash
  sudo rm -f /etc/ssh/ssh_host_*
```
- Clear logs:
```bash
  sudo find /var/log -type f -exec truncate -s 0 {} \;
```
- Clean apt cache:
```bash
  sudo apt clean
```
- Shutdown:
```bash
  sudo poweroff
```

### Step 9 - Convert to Template
- Once VM is stopped, convert to template:
```bash
  qm template 9000
```
  Disk will be renamed to `base-9000-disk-0` (read-only template disk)

### Step 10 - Test the Template (Optional)
- Clone template to test VM:
```bash
  qm clone 9000 9001 --name test-template --full
  qm set 9001 --ipconfig0 ip=192.168.1.199/24,gw=192.168.1.254
  qm start 9001
```
- SSH in and verify:
```bash
  ssh sre@192.168.1.199
  docker --version
  sudo systemctl status qemu-guest-agent
```
- Destroy test VM when done:
```bash
  qm stop 9001
  qm destroy 9001
```

### Notes
- Template VM ID 9000 contains: Debian 12, Docker, Docker Compose, qemu-guest-agent, cloud-init
- Cloud-init will configure hostname, IP, SSH keys, and user on first boot
- Docker is installed but no containers or data exist in template
- Tailscale will need to be authenticated on each new VM
- Original working VM (1212) remains untouched and operational
- Future VMs cloned from this template will be production-ready in ~60 second
