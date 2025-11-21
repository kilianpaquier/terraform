# TF_VAR_hcloud_token
variable "hcloud_token" {
  sensitive = true
  type      = string
}

variable "ssh_port" {
  sensitive = true
  type      = number
}
