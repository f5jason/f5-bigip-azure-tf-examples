# F5 BIG-IP VM Settings
#
variable "instance_type" {
  description = "Azure instance type to be used for the BIG-IP VE. Note: D8 is needed to support more then 2 vNICs"
  type        = string
  default     = "Standard_D8s_v4"
}

variable "product" {
  description = "Azure BIG-IP VE Offer"
  type        = string
  default     = "f5-big-ip-byol"
}

variable "image_name" {
  description = "F5 SKU (image) to deploy. all-2slot is recommended to support in-place software upgrades."
  type        = string
  default     = "f5-big-all-2slot-byol"
}

variable "bigip_version" {
  description = "BIG-IP VE image version"
  type        = string
  default     = "17.1.104000"
}

variable "bigip_subnets" {
  description = "Subnets for the BIG-IP NICs"
  type        = list(string)
  default     = ["management", "external", "internal"]
}

# BIG-IP Settings (2-node cluster)
#
variable "bigip_netcfg" {
  type = map(map(string))
  default = {
    bigip1 = {
      az          = "1"
      hostname    = "bigip1.f5demo.lab"
      license_key = "license-key-value-if-byol-license"
      tag         = "bigip1_3nic"
      management  = "10.1.1.10/24"
      external    = "10.1.10.10/24"
      internal    = "10.1.20.10/24"
      default_gw  = "10.1.10.1"
    }
    bigip2 = {
      az          = "2"
      hostname    = "bigip2.f5demo.lab"
      license_key = "license-key-value-if-byol-license"
      tag         = "bigip2_3nic"
      management  = "10.1.1.11/24"
      external    = "10.1.10.11/24"
      internal    = "10.1.20.11/24"
      default_gw  = "10.1.10.1"
    }
  }
}

# BIG-IP BYOL Licenses (if applicable)
#
variable "byol_licenses" {
  type = map(string)
  default = {
    bigip1 = "device-1-license-key"
    bigip2 = "device-2-license-key"
  }
}

variable "dns_servers" {
  description = "DNS server(s) for the BIG-IP. Azure's default DNS is 168.63.129.16."
  type        = string
  default     = "\"168.63.129.16\""
  #format for multiple DNS servers: "\"8.8.8.8\", \"4.4.4.4\""
}

variable "ntp_servers" {
  description = "NTP server(s) for the BIG-IP"
  type        = string
  default     = "\"0.pool.ntp.org\", \"1.pool.ntp.org\", \"2.pool.ntp.org\""
}

variable "timezone" {
  description = "Time zone for the BIG-IP. This is based on the tz database found in /usr/share/zoneinfo (see the full list [here](https://github.com/F5Networks/f5-azure-arm-templates/blob/master/azure-timezone-list.md)). Example values: UTC, US/Pacific, US/Eastern, Europe/London or Asia/Singapore."
  type        = string
  default     = "US/Eastern"
}

# Static route to app subnet
#
variable "app_route" {
  description = "Static route for app subnet"
  type        = map(string)
  default = {
    dest    = "10.1.30.0/24"
    gateway = "10.1.20.1"
  }
}

# Application Virtual Server
#
variable "app1_vs" {
  description = "IP address for the application virtual server"
  type        = map(string)
  default = {
    dest       = "10.10.10.80"
    port       = "80"
    pool       = "app1_pool"
    poolmember = "10.1.30.100"
    monitor    = "http"
  }
}

