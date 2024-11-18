terraform {
  required_providers {
    opennebula = {
      source = "OpenNebula/opennebula"
      version = "~> 1.4"
    }
  }
}

provider "opennebula" {
  endpoint      = "${var.one_endpoint}"
  username      = "${var.one_username}"
  password      = "${var.one_password}"
}

# resource "opennebula_image" "os-image" {
#     name = "${var.vm_image_name}"
#     datastore_id = "${var.vm_imagedatastore_id}"
#     persistent = false
#     path = "${var.vm_image_url}"
#     permissions = "600"
# }

resource "opennebula_virtual_machine" "loadbalancer-node-vm" {
  count = var.vm_lb_instance_count
  name = "loadbalancer-node-vm-${count.index + 1}"
  description = "LB Testing VM #${count.index + 1}"
  cpu = 1
  vcpu = 1
  memory = 1024
  permissions = "600"
  group = "users"

  context = {
    NETWORK  = "YES"
    HOSTNAME = "$NAME"
    SSH_PUBLIC_KEY = "${var.vm_ssh_pubkey}"
  }
  os {
    arch = "x86_64"
    boot = "disk0"
  }
  disk {
    image_id = 571 # opennebula_image.os-image.id
    target   = "vda"
    size     = 6000 # 16GB
  }

  graphics {
    listen = "0.0.0.0"
    type   = "vnc"
  }

  nic {
    network_id = var.vm_network_id
  }

  connection {
    type = "ssh"
    user = "root"
    host = "${self.nic[0].computed_ip}" # or just self.ip, but that's undocumented afaik
	private_key = file(var.vm_ssh_privatekey_file)
  }

  provisioner "file" {
    source = "provisioning-scripts/"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "export INIT_USER=${var.vm_admin_user}",
      "export INIT_PUBKEY='${var.vm_ssh_pubkey}'",
      "export INIT_LOG=${var.vm_node_init_log}",
      "export INIT_HOSTNAME=${self.name}",
      "touch ${var.vm_node_init_log}",
      "sh /tmp/init-node.sh",
      "sh /tmp/init-users.sh",
      "reboot"
    ]
  }

#   provisioner "local-exec" {
#     command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${self.nic[0].computed_ip},' ../ansible/site.yml"
#   }
}

resource "opennebula_virtual_machine" "backend-node-vm" {
  count = var.vm_be_instance_count
  name = "backend-node-vm-${count.index + 1}"
  description = "BE Testing VM #${count.index + 1}"
  cpu = 1
  vcpu = 1
  memory = 1024
  permissions = "600"
  group = "users"

  context = {
    NETWORK  = "YES"
    HOSTNAME = "$NAME"
    SSH_PUBLIC_KEY = "${var.vm_ssh_pubkey}"
  }
  os {
    arch = "x86_64"
    boot = "disk0"
  }
  disk {
    image_id = 571 # opennebula_image.os-image.id
    target   = "vda"
    size     = 6000 # 16GB
  }

  graphics {
    listen = "0.0.0.0"
    type   = "vnc"
  }

  nic {
    network_id = var.vm_network_id
  }

  connection {
    type = "ssh"
    user = "root"
    host = "${self.nic[0].computed_ip}" # or just self.ip, but that's undocumented afaik
	private_key = file(var.vm_ssh_privatekey_file)
  }

  provisioner "file" {
    source = "provisioning-scripts/"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
      "export INIT_USER=${var.vm_admin_user}",
      "export INIT_PUBKEY='${var.vm_ssh_pubkey}'",
      "export INIT_LOG=${var.vm_node_init_log}",
      "export INIT_HOSTNAME=${self.name}",
      "touch ${var.vm_node_init_log}",
      "sh /tmp/init-node.sh",
      "sh /tmp/init-users.sh",
      "reboot"
    ]
  }
}

# generate inventory file for Ansible
resource "local_file" "hosts_cfg" {
  content = templatefile("${path.module}/templates/hosts.tpl",
    {
      backends = opennebula_virtual_machine.backend-node-vm.*.ip
      loadbalancers = opennebula_virtual_machine.loadbalancer-node-vm.*.ip
    }
  )
  filename = "../ansible/inventory/hosts"
}

#-------OUTPUTS ------------

output "loadbalancer_ips" {
  value = "${opennebula_virtual_machine.loadbalancer-node-vm.*.ip}"
  description = "IP addresses of all load balancer instances"
}

output "backend_ips" {
  value = "${opennebula_virtual_machine.backend-node-vm.*.ip}"
  description = "IP addresses of all backend instances"
}
