resource "proxmox_virtual_environment_vm" "talos_node" {
  for_each = var.nodes

  name        = each.key
  vm_id       = each.value.vm_id
  node_name   = var.node_name
  description = "Talos node managed by Terraform"
  tags        = ["talos", "kubernetes", "terraform"]

  on_boot         = true
  started         = true
  stop_on_destroy = true

  machine       = "q35"
  bios          = "seabios"
  scsi_hardware = "virtio-scsi-single"

  operating_system {
    type = "l26"
  }

  agent {
    enabled = true
    timeout = "5m"
  }

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 8192
    floating  = 0
  }

  disk {
    datastore_id = var.disk_datastore
    interface    = "scsi0"
    iothread     = true
    discard      = "on"
    file_format  = "raw"
    size         = 100
    import_from  = var.talos_image_file_id
  }

  network_device {
    bridge  = var.bridge
    model   = "virtio"
    vlan_id = var.vlan_id
  }

  initialization {
    datastore_id = var.disk_datastore
    interface    = "ide2"

    ip_config {
      ipv4 {
        address = each.value.address
        gateway = var.gateway
      }
    }

    dns {
      servers = [var.dns_server]
    }
  }

  serial_device {}
}
