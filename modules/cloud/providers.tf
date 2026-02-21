provider "hcloud" {
  token = data.sops_file.sops["providers"].data["hcloud.token"]
}

provider "ovh" {
  endpoint           = "ovh-eu"
  application_key    = data.sops_file.sops["providers"].data["ovh.application_key"]
  application_secret = data.sops_file.sops["providers"].data["ovh.application_secret"]
  consumer_key       = data.sops_file.sops["providers"].data["ovh.consumer_key"]
}

provider "sops" {}

provider "tailscale" {
  oauth_client_id     = data.sops_file.sops["providers"].data["tailscale.client_id"]
  oauth_client_secret = data.sops_file.sops["providers"].data["tailscale.client_secret"]
  tailnet             = data.sops_file.sops["providers"].data["tailscale.tailnet"]
}

module "shared" {
  source = "../shared"
}
