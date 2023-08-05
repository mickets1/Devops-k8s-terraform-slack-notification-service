######################################################################
# Configure the OpenStack provider

terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}

provider "openstack" {
  auth_url         = var.openstack_auth_url
  user_name        = var.openstack_username
  password         = var.openstack_password
  tenant_id        = var.openstack_project_id
  tenant_name      = var.openstack_project_name
  user_domain_name = var.openstack_user_domain_name
  region           = var.openstack_region_name
}

######################################################################
# Data sources

## Get Image ID
data "openstack_images_image_v2" "_image" {
  name        = var.image_name
  most_recent = true
}

## Get flavor id
data "openstack_compute_flavor_v2" "_flavor" {
  name = var.flavor_name
}

## Get external network ID
data "openstack_networking_network_v2" "_extnet" {
  name = var.external_network_name
}

######################################################################
# Create a router

resource "openstack_networking_router_v2" "_router" {
  name = var.router_name
  external_network_id = data.openstack_networking_network_v2._extnet.id
}

######################################################################
# Create networks

resource "openstack_networking_network_v2" "_network" {
  name = var.network_name
}

resource "openstack_networking_subnet_v2" "_subnet" {
  name       = var.subnet_name
  network_id = openstack_networking_network_v2._network.id
  cidr       = "172.16.0.0/16"
  dns_nameservers = [ "194.47.110.95", "194.47.110.96" ]
  ip_version = 4
}

resource "openstack_networking_router_interface_v2" "_router_interface" {
  router_id = openstack_networking_router_v2._router.id
  subnet_id = openstack_networking_subnet_v2._subnet.id
}

######################################################################
# Create security groups

resource "openstack_compute_secgroup_v2" "_secgroups" {
  for_each =  { for k,v in var.security_groups : k => v if length(v) > 0 }

  name        = each.key
  description = each.value.description

  rule {
    from_port   = each.value.from_port
    to_port     = each.value.to_port
    ip_protocol = each.value.ip_protocol
    cidr        = each.value.cidr
  }
}

######################################################################
# Create port

resource "openstack_networking_port_v2" "_port" {
  name               = var.port_name
  network_id         = openstack_networking_network_v2._network.id
  admin_state_up     = "true"
  security_group_ids = values(openstack_compute_secgroup_v2._secgroups)[*].id
}

######################################################################
# Create ...

resource "openstack_networking_floatingip_v2" "_fip_control_plane" {
  pool = "public"
}

######################################################################
# Create an instance

resource "openstack_compute_instance_v2" "control_plane_machine" {
  depends_on        = [openstack_networking_subnet_v2._subnet]
  name              = var.control_plane_node_machine_name
  image_id          = data.openstack_images_image_v2._image.id
  flavor_id         = data.openstack_compute_flavor_v2._flavor.id
  key_pair          = var.keypair
  security_groups   = keys(var.security_groups)
  availability_zone = "Education"

  network {
    uuid = "${openstack_networking_network_v2._network.id}"
  }
}

resource "openstack_compute_instance_v2" "worker_node_machines" {
  depends_on        = [openstack_networking_subnet_v2._subnet]
  count             = 3
  name              = "${var.worker_node_machine_name}-${count.index + 1}"
  image_id          = data.openstack_images_image_v2._image.id
  flavor_id         = data.openstack_compute_flavor_v2._flavor.id
  key_pair          = var.keypair
  security_groups   = ["default"]
  availability_zone = "Education"

  network {
    uuid = "${openstack_networking_network_v2._network.id}"
  }
}

######################################################################
# Floating IP

resource "openstack_compute_floatingip_associate_v2" "_fipa_control_plane" {
  floating_ip = openstack_networking_floatingip_v2._fip_control_plane.address
  instance_id = openstack_compute_instance_v2.control_plane_machine.id

  connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = file("~/.ssh/ma225gn_key_ssh.pem")
    host        = "${openstack_networking_floatingip_v2._fip_control_plane.address}"
  }    

  provisioner "remote-exec" {
    inline = [
      "mkdir $HOME/bin"
    ]
  }  

  provisioner "file" {
    source = "~/.ssh/ma225gn_key_ssh.pem"
    destination = "/home/ubuntu/.ssh/ma225gn_key_ssh.pem"
  }

  provisioner "file" {
    source = "./provisioner/bootstrap-cluster.sh"
    destination = "/home/ubuntu/bin/bootstrap-cluster.sh"
  }

  provisioner "file" {
    source = "./provisioner/node-init.sh"
    destination = "/home/ubuntu/bin/node-init.sh"
  }

  provisioner "file" {
    source = "./provisioner/control-plane-init.sh"
    destination = "/home/ubuntu/bin/control-plane-init.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 $HOME/.ssh/ma225gn_key_ssh.pem",
      "chmod +x $HOME/bin/bootstrap-cluster.sh",
      "chmod +x $HOME/bin/node-init.sh",
      "chmod +x $HOME/bin/control-plane-init.sh",
      "$HOME/bin/node-init.sh",
      "$HOME/bin/control-plane-init.sh",
    ]
  }  
}

######################################################################
# Bootstrap cluster nodes

resource "null_resource" "cluster" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_ids = "${join(",", openstack_compute_instance_v2.worker_node_machines.*.id)}"
  }

  # Bootstrap script runs on the control-plane instance
  connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = file("~/.ssh/ma225gn_key_ssh.pem")
    host        = "${openstack_compute_floatingip_associate_v2._fipa_control_plane.floating_ip}"
  }    

  provisioner "remote-exec" {
    # Bootstrap script called with access_ip_v4 of each worker node in the cluster
    inline = [
      "$HOME/bin/bootstrap-cluster.sh ${join(" ", openstack_compute_instance_v2.worker_node_machines.*.access_ip_v4)}"
    ]
  }
}

######################################################################
# Output IP Addresses

output "control-plane-machine" {
 value = [
    openstack_networking_floatingip_v2._fip_control_plane.address,
    openstack_compute_instance_v2.control_plane_machine.access_ip_v4
  ]
}

output "worker_nodes_machines" {
 value = openstack_compute_instance_v2.worker_node_machines.*.access_ip_v4
}
