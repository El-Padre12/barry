# Docker Data Disk Setup

#### This is how I setup the seperated disk in the proxmox webUI for my application data to live so that the data is seperated from the host machine. Hopefully this makes my life easier when it comes to automating resources, backups, continous deployment.

- I used linkding and homepage as examples because its what I had deployed at the time. from now on
  every docker-compose file for the testing environment in my Barry home-lab will use this mount point.

### Step 1 - Create Disk and Add Disk to VM
- make sure your VM is turned off
- In proxmox UI select hardware tab under your respective hostVM
- click Add -> Harddisk
- storage -> for me its "local-lvm"
- size -> whatever fits your needs
- everything else defualt 
- boot up, ssh into it and type ```bash lsblk ``` to see the name of the device

### Step 2 - Partition
- make one big partition 
  ```bash 
  sudo fdisk /dev/sda   # your device name might be different
  ```
- type 'n' (new partition)
  press "Enter" for default partition number (1)
  press "Enter" for default first sector
  press "Enter" for default last sector (uses whole disk)
  type w (write and exit)

### Step 3 - Format With ext4
- ```bash
  sudo mkfs.ext4 /dev/sda1
  ```
  this can take a minute

### Step 4 - Mount the New Disk
- ```bash
  # create mount point
  sudo mkdir -p /var/lib/docker-data

  # mount the new disk
  sudo mount /dev/sda1 /var/lib/docker-data

  # verify it's mounted
  df -h | grep docker-data
  ```

### Step 5 - Copy Existing Data to New Mount Point
- ```bash
  # stop your containers first
  cd ~/linkding && docker-compose down
  cd ~/homepage && docker-compose down

  # create directory structure on new disk
  sudo mkdir -p /var/lib/docker-data/linkding
  sudo mkdir -p /var/lib/docker-data/homepage

  # copy data (this preserves permissions)
  sudo cp -a ~/linkding/data /var/lib/docker-data/linkding/
  sudo cp -a ~/homepage/config /var/lib/docker-data/homepage/

  # change ownership to your user
  sudo chown -R sre:sre /var/lib/docker-data

  # verify the data copied
  ls -la /var/lib/docker-data/linkding/data
  ls -la /var/lib/docker-data/homepage/config
  ```

### Step 6 - Update Compose Files to Point to New Location
- change 
  ```bash
  - "${LD_HOST_DATA_DIR:-./data}:/etc/linkding/data"
  ```
  to
  ```bash
  - "/var/lib/docker-data/linkding/data:/etc/linkding/data"
  ```
  then do the same for homepage

### Step 7 - Test
- run docker compose up and docker ps to test. success!
- check logs for any errors 
  ```bash
  docker logs linkding, etc
  ```
- `Never Delete VM Without Detaching scsi1 First!!`

### Step 8 - Make Mount Persistent (fstab)
- get disk UUID:
  ```bash
    sudo blkid /dev/sda1
  ```
- edit fstab:
  ```bash
    sudo nano /etc/fstab
  ```
- add line (replace UUID):
  ```
    UUID=your-uuid-here /var/lib/docker-data ext4 defaults 0 2
  ```
- test:
  ```bash
    sudo umount /var/lib/docker-data
    sudo mount -a
    df -h | grep docker-data
  ```


