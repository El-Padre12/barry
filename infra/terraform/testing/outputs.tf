output "vm_id" {
  description = "The VM ID in Proxmox"
  value       = proxmox_vm_qemu.docker_vm.vmid
}

output "vm_name" {
  description = "The VM name"
  value       = proxmox_vm_qemu.docker_vm.name
}

output "vm_ip" {
  description = "The VM IP address"
  value       = var.vm_ip
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "ssh ${var.ssh_user}@${var.vm_ip}"
}
