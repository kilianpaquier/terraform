terraform {
  backend "http" {}
}

locals {
  hcloud_url = "https://api.hetzner.cloud/v1"
}

provider "hcloud" {
  endpoint = local.hcloud_url
  token    = var.hcloud_token
}

module "shared" {
  source = "../shared"
}
