terraform {
  required_version = ">= 0.14.0"

  required_providers {
    # imported module, unnecessary to specify its version
    # tflint-ignore: terraform_required_providers
    gitlab = {
      source  = "gitlabhq/gitlab"
    }
  }
}
