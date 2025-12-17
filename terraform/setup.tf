resource "libvirt_pool" "tf_pool" {
  name = "project_10_pool"
  type = "dir"
  path = "/var/lib/libvirt/images/project_10_pool"
}

resource "libvirt_volume" "os_image" {
  name = "alma-p10-base.qcow2"
  pool = libvirt_pool.tf_pool.name
  source = "https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2"
  format = "qcow2"

  depends_on = [ libvirt_pool.tf_pool ]

}

resource "libvirt_volume" "node_disk" {
  for_each = toset(["monitor-01", "web-01", "db-01"])
  name = "${each.key}.qcow2"
  base_volume_id = libvirt_volume.os_image.id
  pool = libvirt_pool.tf_pool.name

}

resource "libvirt_cloudinit_disk" "commoninit" {
  name = "mon_init.iso"
  pool = libvirt_pool.tf_pool.name
  user_data = templatefile("../build/cloud_init.cfg", {
    ssh_key = file("../build/id_ed25519.pub")})
}

resource "libvirt_network" "mon_net" {
  name = "mon_network"
  mode = "nat"
  autostart = true
  addresses = ["192.168.110.0/24"]
  dhcp {
    enabled = true
    }
  dns {
    enabled = true
    }
}



