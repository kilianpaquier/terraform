terraform {
  backend "http" {}
}

locals {
  owner = "kilianpaquier"
}

provider "external" {}

provider "github" {
  owner = local.owner
  token = var.github_terraform_token
}

provider "gitlab" {
  token = var.gitlab_terraform_token
}

module "shared" {
  source = "../shared"
}
