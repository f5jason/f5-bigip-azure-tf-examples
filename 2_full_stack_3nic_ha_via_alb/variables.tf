# Variables

# Tags
variable "tags" {
  description = "Environment tags for objects"
  type        = map(string)
  default = {
    "owner"       = "f5email"
    "application" = "f5app"
    "environment" = "f5env"
    "costcenter"  = "f5costcenter"
    "group"       = "f5group"
  }
}

# Prefix for objects being created
variable "prefix" {
  description = "This value is inserted at the beginning of each Azure object (alpha-numeric, no special character)"
  type        = string
  default     = "f5tfdemo"
}

# Location
variable "location" {
  description = "Azure location"
  type        = string
  default     = ""
}

# Networking
variable "vnet_name" {
  description = "Virtual network name"
  default     = "demo_vnet"
}

# VNets
variable "vnet_cidrs" {
  description = "VNet subnets (CIDR)"
  type        = map(map(string))
  default = {
    main_vnet = {
      "vnet"        = "10.1.0.0/16"
      "management"  = "10.1.1.0/24"
      "external"    = "10.1.10.0/24"
      "internal"    = "10.1.20.0/24"
      "application" = "10.1.30.0/24"
    }

  }
}

# VIP route
variable "vip_udr" {
  description = "Static route for VIP range (via Azure LB)"
  type        = map(string)
  default = {
    dest    = "10.10.10.0/24"
    gateway = "10.1.10.5"
  }
}


# Lab admin user name (for all VMs). 
# Lab admin password is randomly generated and stored in local.admin_password.
variable "admin_username" {
  type    = string
  default = "azureuser"
}
