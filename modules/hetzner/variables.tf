# TF_VAR_hcloud_token
variable "hcloud_token" {
  sensitive = true
  type      = string
}

# TF_VAR_ssh_port
# used in Hetzner provisioning but not yet in Git one
# tflint-ignore: terraform_unused_declarations
variable "ssh_port" {
  sensitive = true
  type      = string
}
