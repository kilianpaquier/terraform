terraform {
  backend "http" {}
}

locals {
  # ovh_url       = "https://eu.api.ovh.com/v1"
  ovh_endpoint  = "ovh-eu"
  ovh_cloud_url = "https://auth.cloud.ovh.net/v3/"
}

provider "openstack" {
  auth_url    = local.ovh_cloud_url
  domain_name = "default"
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
