# TF_VAR_hcloud_token
variable "hcloud_token" {
  sensitive = true
  type      = string
}

# TF_VAR_ssh_port
variable "ssh_port" {
  sensitive = true
  type      = string
}
