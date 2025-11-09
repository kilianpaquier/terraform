provider "external" {}

provider "github" {
  owner = var.github_repository_owner
  token = var.terraform_token
}

module "shared" {
  source = "../shared"
}
