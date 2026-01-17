terraform {
  required_version = ">= 0.14.0"

  backend "http" {}

  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.9.1"
    }

    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "18.7.0"
    }

    sops = {
      source  = "carlpett/sops"
      version = "1.3.0"
    }
  }
}
