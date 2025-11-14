terraform {
  backend "http" {}
}

locals {
  owner         = "kilianpaquier"
  gitlab_url    = "https://gitlab.com"
  gitlab_api_v4 = "${local.gitlab_url}/api/v4"
}

provider "external" {}

provider "github" {
  owner = local.owner
  token = var.github_terraform_token
}

provider "gitlab" {
  base_url = local.gitlab_url
  token    = var.gitlab_terraform_token
}

module "shared" {
  source = "../shared"
}
