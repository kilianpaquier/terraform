variable "environments" {
  type = list(object({
    description = string
    environment = string
    tier        = string

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
