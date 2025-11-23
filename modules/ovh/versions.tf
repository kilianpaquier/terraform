terraform {
  required_version = ">= 0.14.0"

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "3.4.0"
    }

    ovh = {
      source  = "ovh/ovh"
      version = "2.9.0"
    }

    sops = {
      source  = "carlpett/sops"
      version = "1.3.0"
    }
  }
}
