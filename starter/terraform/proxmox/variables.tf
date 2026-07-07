variable "proxmox_endpoint" {
  description = "Proxmox API endpoint, for example https://proxmox.example.internal:8006"
  type        = string
}

variable "proxmox_insecure_tls" {
  description = "Set true only for a lab endpoint with a self-signed certificate"
  type        = bool
  default     = false
}

variable "node_name" {
  description = "Proxmox node name that will host the VMs"
  type        = string
}

variable "talos_image_file_id" {
  description = "Existing Proxmox file ID for the Talos nocloud disk image"
  type        = string
}

variable "disk_datastore" {
  description = "Datastore for VM disks"
  type        = string
}

variable "bridge" {
  description = "Proxmox bridge for cluster nodes"
  type        = string
}

variable "vlan_id" {
  description = "Optional VLAN ID for cluster nodes"
  type        = number
  default     = null
}

variable "gateway" {
  description = "Cluster network gateway, example documentation value shown in terraform.tfvars.example"
  type        = string
}

variable "dns_server" {
  description = "DNS server for node bootstrap"
  type        = string
}

variable "nodes" {
  description = "Three Talos nodes. Use your own VM IDs and addresses in your private repo."
  type = map(object({
    vm_id   = number
    address = string
  }))
}

