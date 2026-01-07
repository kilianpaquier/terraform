terraform {
  required_version = ">= 0.14.0"

  backend "http" {}

  required_providers {
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.3.7"
    }

    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.58.0"
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
