variable "environments" {
  type = list(object({
    environment = string

    custom_branch_policies = optional(bool, false)
    protected_branches     = optional(bool, false)

    secrets = optional(list(object({
      secret_name     = string
      from            = optional(string, null)
      encrypted_value = optional(string, null)
    })), [])

    variables = optional(list(object({
      variable_name = string
      value         = string
    })), [])
  }))
  default  = []
}

variable "labels" {
  type = list(object({
    name        = string
    color       = string
    description = string
  }))
  default  = []
}

variable "owner" {
  type = string
}

variable "repository" {
  type = string
}

variable "secrets" {
  type = list(object({
    secret_name     = string
    from            = optional(string, null)
    encrypted_value = optional(string, null)
  }))
  default  = []
}

variable "variables" {
  type = list(object({
    variable_name = string
    value         = string
  }))
  default  = []
}
