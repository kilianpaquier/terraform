variable "cloudinit" {
  type = object({
    file             = string
    sops_file        = string
    sops_private_key = string
    user             = string
    vars = optional(object({
      raw       = optional(map(any), {})
      sops_keys = optional(list(string), [])
    }), {})
  })
  default     = null
  description = "Cloud Init configuration, since OVH VPS doesn't support yet an userdata input, this script must be a shell script to be run by 'terraform_data' after VPS provisioning"
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
    action     = string
    name       = string
    port       = optional(number, null)
    protocol   = string
    sequence   = number
    tcp_option = optional(string, null)
  }))
  default     = []
  description = "List of firewalls to apply on this VPS"
}

variable "image_id" {
  type        = string
  default     = null
  description = "Technical image associated to the Operating System"
}

variable "ovh_subsidiary" {
  type        = string
  default     = null
  description = "The subsidiary (catalog country) from which the order should be made"
}

variable "plan" {
  type = object({
    datacenter   = string
    duration     = string
    os           = string
    plan_code    = string
    pricing_mode = optional(string, "default")
  })
  default     = null
  description = "VPS plan with its model (vps-2025-model1, etc.), its datacenter (GRA, etc.), Operating System (Debian 13, Ubuntu 24.04, etc.) and pricing configuration (P1M, P6M, etc.)"
}

variable "public_key" {
  type        = string
  description = "Initial public key to associate to the root user"
}

variable "server_name" {
  type        = string
  description = "Server name"
}
