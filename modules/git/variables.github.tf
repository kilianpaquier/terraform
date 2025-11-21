# TF_VAR_github_terraform_token
variable "github_terraform_token" {
  sensitive = true
  type      = string
}

# TF_VAR_kickr_private_key
# used as environment variable
# tflint-ignore: terraform_unused_declarations
variable "kickr_private_key" {
  sensitive = true
  type      = string
}

# TF_VAR_renovate_token
# used as environment variable (will be removed soon)
# tflint-ignore: terraform_unused_declarations
variable "renovate_token" {
  sensitive = true
  type      = string
}
