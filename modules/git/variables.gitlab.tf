# TF_VAR_codecov_token
# not yet used (or used as environment variable)
# tflint-ignore: terraform_unused_declarations
variable "codecov_token" {
  sensitive = true
  type      = string
}

# TF_VAR_github_com_token
variable "github_com_token" {
  sensitive = true
  type      = string
}

# TF_VAR_github_mirror_token
variable "github_mirror_token" {
  sensitive = true
  type      = string
}

# TF_VAR_gitlab_terraform_token
variable "gitlab_terraform_token" {
  sensitive = true
  type      = string
}

# TF_VAR_netlify_auth_token
variable "netlify_auth_token" {
  sensitive = true
  type      = string
}
