variable "backups" {
  type        = bool
  default     = false
  description = "Whether backups should be enabled for this server or not"
}

variable "cloudinit" {
  type = object({
    file      = string
    sops_file = string
    vars = optional(object({
      raw       = optional(map(any), {})
      sops_keys = optional(list(string), [])
    }), {})
  })
  default     = null
  description = "Cloud Init configuration. Templating will be made inside the module with data being a merge of all provided cloudinit.vars.sops_keys key/value and cloudinit.vars.raw map"
}

variable "location" {
  type        = string
  description = "Server location (nbg1-dc3, fsn1-dc14, etc.). More at https://docs.hetzner.com/cloud/general/locations/#what-datacenters-are-there"
}

variable "dns_records" {
  type = list(object({
    subdomain = string
    domain    = string
  }))
  default     = []
  description = "List of DNS records to set with OVH domain zone"
}

variable "firewalls" {
  type = list(object({
    description     = optional(string, null)
    destination_ips = optional(set(string), null)
    port            = optional(string, null)
    direction       = string
    protocol        = string
    source_ips      = optional(set(string), null)
  }))
  default = []
}

variable "image" {
  type        = string
  description = "Server image name (debian-13, ubuntu-24.04, docker-ce, etc.)"
}

variable "labels" {
  type        = list(string)
  default     = []
  description = "Server labels"
}

variable "networks" {
  type = list(object({
    alias_ips  = optional(set(string), null)
    ip         = optional(string, null)
    network_id = number
  }))
  default     = []
  description = "Private networks to connect to the private server"
}

variable "placement_group_id" {
  type        = number
  default     = null
  description = "Hetzner Cloud placement group in case this server must be close to others"
}

variable "public_net" {
  type = object({
    ipv4_enabled = optional(bool, true)
    ipv6_enabled = optional(bool, true)
  })
  default     = {}
  description = "Public network configuration, whether to enable public access to the server or not (default yes)"
}

variable "protected" {
  type        = bool
  default     = false
  description = "Whether the server should be protected from deletion and rebuild"
}

variable "public_keys" {
  type        = list(string)
  description = "List of public keys names (those must already be registered in Hetzner Console) to associate to the root user"
}

variable "server_type" {
  type        = string
  description = "Hetzner Cloud server type (cx23, etc.)"
}

variable "server_name" {
  type        = string
  description = "Server name"
}

variable "user_data" {
  type    = string
  default = null
}
