terraform {
  required_version = ">= 0.14.0"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.56.0"
    }

    ovh = {
      source  = "ovh/ovh"
      version = "2.10.0"
    }

    sops = {
      source  = "carlpett/sops"
      version = "1.3.0"
    }
  }
}
