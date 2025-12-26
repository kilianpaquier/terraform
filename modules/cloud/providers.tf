provider "hcloud" {
  endpoint = "https://api.hetzner.cloud/v1"
  token    = data.sops_file.sops["providers"].data["hcloud_token"]
}

provider "ovh" {
  endpoint           = "ovh-eu"
  application_key    = data.sops_file.sops["providers"].data["application_key"]
  application_secret = data.sops_file.sops["providers"].data["application_secret"]
  consumer_key       = data.sops_file.sops["providers"].data["consumer_key"]
}

provider "sops" {}

module "shared" {
  source = "../shared"
}
