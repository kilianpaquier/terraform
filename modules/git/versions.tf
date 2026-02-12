terraform {
  required_version = ">= 0.14.0"

  backend "http" {}

  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.11.1"
    }

    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "18.8.2"
    }

    sops = {
      source  = "carlpett/sops"
      version = "1.3.0"
    }
  }
}
