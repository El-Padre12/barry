# Barry
Single source of truth for my home proxmox server infrastructure & app configs

## Hardware

- 1 Node
  - 6th gen intel core i7
  - 64gb ram
  - 1 TB nvme storage
  - 876gb local-lvm for VMs and CTs
  - 100gb local for Backups, ISO, etc

## Future Plans

- 3-5 VM node k8s cluster
- IaC & CaC with ansible and terraform for infra-automation.
- PostgreSQL database and Persistent Volumes in k3s for data persistence
- CICD with a GitOps approach, either using ArgoCD or FluxCD

## Services I Want To Implement

- *arr suite for shows, movies, music streaming
- linkding for global bookmarks
- pgadmin
- monitoring(grafana/prometheus)
- homepage

## Dev-Containers/OpsBoxes

### consistent, reproducible, & portable work environments for development/operations

- Ansible-OpsBox
- Terraform-OpsBox
- Python-WebDev-Container
