variable "name" {
  type = string
}

variable "description" {
  type = string
}

variable "visibility" {
  type = string
}

variable "homepage_url" {
  type    = string
  default = null
}

variable "has_discussions" {
  type    = bool
  default = false
}

variable "has_issues" {
  type    = bool
  default = true
}

variable "has_projects" {
  type    = bool
  default = false
}

variable "has_wiki" {
  type    = bool
  default = false
}

variable "topics" {
  type    = list(string)
  default = []
}

variable "vulnerability_alerts" {
  type    = bool
  default = true
}

variable "secret_scanning" {
  type    = string
  default = "enabled"
}

variable "secret_scanning_push_protection" {
  type    = string
  default = "enabled"
}
