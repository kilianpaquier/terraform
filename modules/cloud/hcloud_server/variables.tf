variable "backups" {
  type        = bool
  default     = false
  description = "Whether backups should be enabled for this server or not"
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

variable "keep_disk" {
  type        = bool
  default     = true
  description = "Whether the disk size must be retained when upscaling the server. By keeping the disk size a downscale is later possible."
}

variable "labels" {
  type        = list(string)
  default     = []
  description = "Server labels"
}

variable "networks" {
  type = list(object({
    alias_ips = optional(set(string), null)
    ip        = optional(string, null)
    subnet_id = string
  }))
  default     = []
  description = "Private networks to connect to the private server"
}

variable "placement_group_id" {
  type        = number
  default     = null
  description = "Hetzner Cloud placement group in case this server must be close to others"
}

variable "public_ipv4" {
  type = object({
    auto_delete = optional(bool, true)
  })
  default     = {}
  description = "Provision an IPv4 and associate it to the hcloud server"
}

variable "public_ipv6" {
  type = object({
    auto_delete = optional(bool, true)
  })
  default     = {}
  description = "Provision an IPv6 and associate it to the hcloud server"
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
