terraform {
  required_version = ">= 0.14.0"

  required_providers {
    external = {
      source  = "hashicorp/external"
      version = "2.3.5"
    }

    github = {
      source  = "integrations/github"
      version = "6.8.3"
    }

    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "18.6.1"
    }

    sops = {
      source  = "carlpett/sops"
      version = "1.3.0"
    }
  }
}
