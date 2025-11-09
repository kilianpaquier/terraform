resource "github_repository" "terraform" {
  name        = "terraform"
  description = ""

  has_downloads = false
  has_issues    = true

  allow_auto_merge   = false
  allow_merge_commit = false
  allow_rebase_merge = true
  allow_squash_merge = false

  archive_on_destroy          = true
  delete_branch_on_merge      = true
  web_commit_signoff_required = true

  topics = ["terraform", "terraform-resources"]

  vulnerability_alerts = true
  security_and_analysis {
    secret_scanning {
      status = "enabled"
    }
    secret_scanning_push_protection {
      status = "enabled"
    }
  }
}

resource "github_branch_protection" "terraform" {
  depends_on = [github_repository.terraform]
  for_each   = toset(["next"])

  pattern       = each.value
  repository_id = github_repository.terraform.name

  require_conversation_resolution = true

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
    require_last_push_approval      = true
    required_approving_review_count = 1
  }
  required_status_checks {
    strict = true
  }
}

module "terraform" {
  depends_on = [github_repository.terraform]
  source     = "./repository"

  owner      = var.github_repository_owner
  repository = github_repository.terraform.name

  environments = [
    {
      environment        = "kickr"
      protected_branches = true
      secrets            = [{ secret_name = "KICKR_PRIVATE_KEY", from = "TF_VAR_kickr_private_key" }]
    },
    { environment = "release", protected_branches = true },
    {
      environment = "terraform"
      secrets = [
        { secret_name = "AWS_ACCESS_KEY", from = "AWS_ACCESS_KEY" },
        { secret_name = "AWS_SECRET_KEY", from = "AWS_SECRET_KEY" },
        { secret_name = "CODECOV_TOKEN", from = "TF_VAR_codecov_token" },
        { secret_name = "RENOVATE_TOKEN", from = "TF_VAR_renovate_token" },
        { secret_name = "TERRAFORM_TOKEN", from = "TF_VAR_terraform_token" }
      ]
    }
  ]
}
