terraform {
  required_version = ">= 0.14.0"

  backend "http" {}

  required_providers {
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "< 3.0.0"
    }

    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "< 2.0.0"
    }

    ovh = {
      source  = "ovh/ovh"
      version = "< 3.0.0"
    }

    sops = {
      source  = "carlpett/sops"
      version = "< 2.0.0"
    }
  }
}
