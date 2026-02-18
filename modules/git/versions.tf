terraform {
  required_version = ">= 0.14.0"

  backend "http" {}

  required_providers {
    github = {
      source  = "integrations/github"
      version = "< 7.0.0"
    }

    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "< 19.0.0"
    }

    sops = {
      source  = "carlpett/sops"
      version = "< 2.0.0"
    }
  }
}
