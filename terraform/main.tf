resource "libvirt_domain" "node" {
  for_each = toset(["monitor-01", "web-01", "db-01"])

  name = each.key
  memory = "1524"
  vcpu = 2

  cpu {
    mode = "host-passthrough"
    }
  
  qemu_agent = false

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_id = libvirt_network.mon_net.id
    hostname = each.key
    addresses = [
      each.key == "monitor-01" ? "192.168.110.10" :
      each.key == "web-01" ? "192.168.110.20" :
      "192.168.110.30"

   ]

   wait_for_lease = true
  }

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "vnc"
    listen_type = "address"
    autoport = true
  }

  disk {
   volume_id = libvirt_volume.node_disk[each.key].id
   scsi = true
  }
}
