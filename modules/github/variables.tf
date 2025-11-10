# TF_VAR_codecov_token
# used as environment variable
# tflint-ignore: terraform_unused_declarations
variable "codecov_token" {
  sensitive = true
  type      = string
}

# TF_VAR_github_repository_owner
variable "github_repository_owner" {
  type = string
  default = "kilianpaquier"
}

# TF_VAR_kickr_private_key
# used as environment variable
# tflint-ignore: terraform_unused_declarations
variable "kickr_private_key" {
  sensitive = true
  type      = string
}

# TF_VAR_netlify_auth_token
# used as environment variable
# tflint-ignore: terraform_unused_declarations
variable "netlify_auth_token" {
  sensitive = true
  type      = string
}

# TF_VAR_renovate_token
# used as environment variable
# tflint-ignore: terraform_unused_declarations
variable "renovate_token" {
  sensitive = true
  type      = string
}

# TF_VAR_terraform_token
variable "terraform_token" {
  sensitive = true
  type      = string
}
