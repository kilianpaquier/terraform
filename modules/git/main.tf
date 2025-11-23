terraform {
  backend "http" {}
}

locals {
  owner = "kilianpaquier"
}

provider "external" {}

provider "github" {
  owner = local.owner
  token = data.sops_file.sops["github"].data["terraform_token"]
}

provider "gitlab" {
  token = data.sops_file.sops["gitlab"].data["terraform_token"]
}

provider "sops" {}

module "shared" {
  source = "../shared"
}
