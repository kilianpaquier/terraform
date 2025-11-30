terraform {
  backend "http" {}
}

locals {
  hcloud_url   = "https://api.hetzner.cloud/v1"
  ovh_endpoint = "ovh-eu"
}

provider "hcloud" {
  endpoint = local.hcloud_url
  token    = data.sops_file.sops["hetzner"].data["hcloud_token"]
}

provider "ovh" {
  endpoint           = local.ovh_endpoint
  application_key    = data.sops_file.sops["ovh"].data["application_key"]
  application_secret = data.sops_file.sops["ovh"].data["application_secret"]
  consumer_key       = data.sops_file.sops["ovh"].data["consumer_key"]
}

provider "sops" {}

module "shared" {
  source = "../shared"
}
