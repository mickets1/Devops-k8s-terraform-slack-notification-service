######################################################################
# Variables
    
variable "openstack_auth_url" {
  description = "..."
  type        = string
  default     = "https://cscloud.lnu.se:5000/v3"
}

variable "openstack_username" {
  description = "..."
  type        = string
  default     = "ma225gn-2dv013"
}

variable "openstack_project_id" {
  description = "..."
  type        = string
  default     = "f74c8dfcd0424d3998d3ef20099e32f1"
}

variable "openstack_project_name" {
  description = "..."
  type        = string
  default     = "ma225gn-2dv013-ht22"
}

variable "openstack_user_domain_name" {
  description = "..."
  type        = string
  default     = "Default"
}

variable "openstack_region_name" {
  description = "..."
  type        = string
  default     = "RegionOne"
}

variable "openstack_interface" {
  description = "..."
  type        = string
  default     = "public"
}

variable "openstack_identity_api_version" {
  description = "..."
  type        = number
  default     = 3
}

######################################################################
# Sensitive variables

variable "openstack_password" {
  description = "Openstack password"
  type        = string
  sensitive   = true
}
