terraform {
  backend "http" {}
}

locals {
  hcloud_url = "https://api.hetzner.cloud/v1"
}

provider "hcloud" {
  endpoint = local.hcloud_url
  token    = data.sops_file.sops["hetzner"].data["hcloud_token"]
}

provider "sops" {}

module "shared" {
  source = "../shared"
}
