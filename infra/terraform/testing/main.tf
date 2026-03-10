terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc04"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure     = true
}

# Docker Testing VM
resource "proxmox_vm_qemu" "docker_vm" {
  name        = var.vm_name
  target_node = var.proxmox_node
  
  # Clone from template
  clone      = var.template_name
  full_clone = true

  # Enable QEMU guest agent
  agent = 1
  
  # Boot configuration
  boot   = "order=scsi0"
  onboot = false
  
  # VM will be ready when guest agent is running
  define_connection_info = true
  
  # CPU and Memory
  cores  = var.vm_cores
  memory = var.vm_memory
  
  # Network
  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }
  
  # Disks
  disks {
    scsi {
      scsi0 {
        disk {
          storage = "local-lvm"
          size    = 60
        }
      }
      scsi1 {
        disk {
          storage = "local-lvm"
          size    = var.data_disk_size
        }
      }
    }
  }
  
  # Cloud-init configuration
  os_type    = "cloud-init"
  ipconfig0  = "ip=${var.vm_ip}/24,gw=${var.gateway}"
  ciuser     = var.ssh_user
  sshkeys    = var.ssh_public_key
  nameserver = var.nameserver
  
  # Wait for cloud-init to complete
  provisioner "local-exec" {
    command = "sleep 30"
  }
  
  lifecycle {
    ignore_changes = [
      network,
    ]
  }
}
