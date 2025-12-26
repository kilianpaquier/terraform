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

variable "datacenter" {
  type        = string
  description = "Server datacenter location (nbg1-dc3, etc.)"
}

variable "dns_records" {
  type = list(object({
    subdomain = string
    domain    = string
  }))
  default     = []
  description = "List of DNS records to set with OVH domain zone"
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

variable "placement_group_id" {
  type        = number
  default     = null
  description = "Hetzner Cloud placement group in case this server must be close to others"
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

variable "user_data" {
  type        = string
  description = "Cloud Init userdata"
  default     = null
}

variable "server_name" {
  type        = string
  description = "Server name"
}
