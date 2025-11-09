terraform {
  required_version = ">= 0.14.0"

  required_providers {
    # imported module, unnecessary to specify its version
    # tflint-ignore: terraform_required_providers
    external = {
      source = "hashicorp/external"
    }

    # imported module, unnecessary to specify its version
    # tflint-ignore: terraform_required_providers
    github = {
      source = "integrations/github"
    }
  }
}
