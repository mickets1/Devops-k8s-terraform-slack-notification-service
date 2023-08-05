######################################################################
# Variables

variable "external_network_name" {
  description = "The name of the external network to be used"
  type        = string
  default     = "public"
}

variable "flavor_name" {
  description = "The name of the flavor to be used"
  type        = string
  default     = "c2-r2-d20"
}

variable "image_name" {
  description = "The name of the image to be used"
  type        = string
  default     = "Ubuntu server 20.04"
}

variable "keypair" {
  description = "The name of the keypair to be used"
  type    = string
  default = "ma225gn_Keypair" 
}

variable "network_name" {
  description = "The name of the network to create"
  type    = string
  default = "nodenet"
}

variable "port_name" {
  description = "The name of the port to create"
  type    = string
  default = "nodenet-port"
}

variable "router_name" {
  description = "The name of the router to create"
  type    = string
  default = "nodenet-router"
}

variable "security_groups" {
  description = "Map of security groups"
  type = map(any)
  # type = map(object({
  #   description = string
  #   from_port   = number
  #   to_port     = number
  #   ip_protocol = string
  #   cidr        = string
  # }))

  default = {
    default = {},
    taskitssh = {
      description = "TASKIT-SSH"
      from_port   = 22
      to_port     = 22
      ip_protocol = "tcp"
      cidr        = "0.0.0.0/0"
    },
    taskithttp = {
      description = "TASKIT-HTTP"
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr        = "0.0.0.0/0"
    },
    taskithttps = {
      description = "TASKIT-HTTPS"
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr        = "0.0.0.0/0"
    }
  }
}

variable "control_plane_node_machine_name" {
  description = "The name of the server to create"
  type    = string
  default = "control-plane"
}

variable "worker_node_machine_name" {
  description = "The prefix name of the worker node machine to create"
  type    = string
  default = "node"
}


variable "subnet_name" {
  description = "The name of the subnet to create"
  type    = string
  default = "	nodenetsubnet2"
}
