variable "proxmox_api_url" {
  description = "Proxmox API URL"
  type        = string
  default     = "https://192.168.1.90:8006/api2/json"
}

variable "proxmox_user" {
  description = "Proxmox user (format: user@pam or user@pve)"
  type        = string
  default     = "achavez@pve!terraform"
}

variable "proxmox_api_token_id" {
  description = "Proxmox API token ID"
  type        = string
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
  default     = "pve"  # Change to match your node name
}

variable "template_name" {
  description = "Cloud-init template name"
  type        = string
  default     = "debian-12-cloudinit"  # cloud init template
}

variable "ssh_user" {
  description = "SSH user for VMs"
  type        = string
  default     = "sre"
}

#variable "ssh_public_key_path" {
#  description = "Path to SSH public key"
#  type        = string
#  default     = "~/.ssh/id_ed25519.pub"
#}

variable "ssh_public_key" {
  description = "SSH public key content"
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGAlzsDkfsRxoB9T3e81kTCW1NEAeWdmQ0OGe36div7M noel0402.ac@gmail.com"
}

variable "control_node_ip" {
  description = "IP address for control plane node"
  type        = string
  default     = "192.168.1.210"  # VMs on physical dumb network
}

variable "worker_node_ips" {
  description = "IP addresses for worker nodes"
  type        = list(string)
  default     = [
    "192.168.1.211",
    "192.168.1.212",
    "192.168.1.213"
  ]
}

variable "gateway" {
  description = "Network Gateway"
  type        = string
  default     = "192.168.1.254"
}

variable "nameserver" {
  description = "DNS nameserver"
  type        = string
  default     = "192.168.1.254"
}
