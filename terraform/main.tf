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

# K3s Control Plane Node
resource "proxmox_vm_qemu" "k3s_control" {
  name        = "k3s-control-1"
  target_node = var.proxmox_node
  clone       = var.template_name
  full_clone  = true
  
  cores   = 4
  sockets = 1
  memory  = 8192  # 8GB
  
  # Network configuration
  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"  # Physical bridge - VMs on same network as router
  }
  
  # Disk configuration
  disks {
    scsi {
      scsi0 {
        disk {
          storage = "local-lvm"
          size    = 40
        }
      }
    }
  }
  
  # Cloud-init configuration
  os_type    = "cloud-init"
  ipconfig0  = "ip=${var.control_node_ip}/24,gw=${var.gateway}"
  ciuser     = var.ssh_user
  sshkeys    = file(var.ssh_public_key_path)
  nameserver = var.nameserver
  
  tags = "k3s,control-plane"
  
  lifecycle {
    ignore_changes = [
      network,
    ]
  }
}

# K3s Worker Nodes
resource "proxmox_vm_qemu" "k3s_workers" {
  count       = 3
  name        = "k3s-worker-${count.index + 1}"
  target_node = var.proxmox_node
  clone       = var.template_name
  full_clone  = true
  
  cores   = 4
  sockets = 1
  memory  = 12288  # 12GB per worker
  
  # Network configuration
  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }
  
  # Disk configuration
  disks {
    scsi {
      scsi0 {
        disk {
          storage = "local-lvm"
          size    = 60
        }
      }
    }
  }
  
  # Cloud-init configuration
  os_type    = "cloud-init"
  ipconfig0  = "ip=${var.worker_node_ips[count.index]}/24,gw=${var.gateway}"
  ciuser     = var.ssh_user
  sshkeys    = file(var.ssh_public_key_path)
  nameserver = var.nameserver
  
  tags = "k3s,worker"
  
  lifecycle {
    ignore_changes = [
      network,
    ]
  }
}

# Output IP addresses for Ansible inventory
output "control_node_ip" {
  value = var.control_node_ip
}

output "worker_node_ips" {
  value = var.worker_node_ips
}

output "all_node_ips" {
  value = concat([var.control_node_ip], var.worker_node_ips)
}
