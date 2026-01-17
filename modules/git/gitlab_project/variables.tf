variable "namespace_id" {
  type = number
}

variable "name" {
  type = string
}

variable "default_branch" {
  type = string
}

variable "description" {
  type = string
}

variable "visibility_level" {
  type = string
}

variable "merge_pipelines_enabled" {
  type    = bool
  default = true
}

variable "merge_trains_enabled" {
  type    = bool
  default = true
}

variable "packages_enabled" {
  type    = bool
  default = false
}

variable "public_jobs" {
  type    = bool
  default = false
}

variable "mirror" {
  type    = string
  default = ""
}

variable "analytics_access_level" {
  type    = string
  default = "enabled"
}

variable "builds_access_level" {
  type    = string
  default = "enabled"
}

variable "container_registry_access_level" {
  type    = string
  default = "enabled"
}

variable "environments_access_level" {
  type    = string
  default = "enabled"
}

variable "feature_flags_access_level" {
  type    = string
  default = "enabled"
}

variable "forking_access_level" {
  type    = string
  default = "enabled"
}

variable "infrastructure_access_level" {
  type    = string
  default = "enabled"
}

variable "issues_access_level" {
  type    = string
  default = "enabled"
}

variable "merge_requests_access_level" {
  type    = string
  default = "enabled"
}

variable "model_experiments_access_level" {
  type    = string
  default = "enabled"
}

variable "model_registry_access_level" {
  type    = string
  default = "enabled"
}

variable "monitor_access_level" {
  type    = string
  default = "enabled"
}

variable "pages_access_level" {
  type    = string
  default = "enabled"
}

variable "releases_access_level" {
  type    = string
  default = "enabled"
}

variable "repository_access_level" {
  type    = string
  default = "enabled"
}

variable "requirements_access_level" {
  type    = string
  default = "enabled"
}

variable "security_and_compliance_access_level" {
  type    = string
  default = "enabled"
}

variable "snippets_access_level" {
  type    = string
  default = "enabled"
}

variable "wiki_access_level" {
  type    = string
  default = "enabled"
}

variable "only_allow_merge_if_pipeline_succeeds" {
  type    = bool
  default = true
}

variable "branch_name_regex" {
  type = string
}

variable "commit_message_regex" {
  type = string
}
