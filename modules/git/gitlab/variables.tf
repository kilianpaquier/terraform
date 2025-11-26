variable "environments" {
  type = list(object({
    description = string
    environment = string
    tier        = string

    external_url = optional(string, null)

    variables = optional(list(object({
      description = string
      key         = string
      raw         = bool
      sensitive   = bool
      value       = string
    })), [])
  }))
  default = []
}

variable "labels" {
  type = list(object({
    name        = string
    color       = string
    description = string
  }))
  default = []
}

variable "mirror" {
  type = object({
    token = string
    url   = string
  })
  default  = null
  nullable = true
}

variable "project" {
  type = string
}

variable "protected_branches" {
  type = set(string)
  default = []
}

variable "variables" {
  type = list(object({
    description = string
    key         = string
    raw         = bool
    sensitive   = bool
    protected   = optional(bool, false)
    value       = string
  }))
  default = []
}
