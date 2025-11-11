resource "github_repository" "dotfiles" {
  name        = "dotfiles"
  description = "My dotfiles tests and final configuration"

  has_downloads = false
  has_issues    = true

  allow_auto_merge   = false
  allow_merge_commit = false
  allow_rebase_merge = true
  allow_squash_merge = false

  archive_on_destroy          = true
  delete_branch_on_merge      = true
  web_commit_signoff_required = true

  topics = ["dotfiles"]

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

resource "github_branch_protection" "dotfiles" {
  depends_on = [github_repository.dotfiles]
  for_each   = toset(["main"])

  pattern       = each.value
  repository_id = github_repository.dotfiles.name

  # enforce_admins                  = true
  require_conversation_resolution = true

  # required_pull_request_reviews {
  #   dismiss_stale_reviews           = true
  #   require_code_owner_reviews      = true
  #   require_last_push_approval      = true
  #   required_approving_review_count = 1
  # }
  required_status_checks {
    strict = true
  }
}

module "dotfiles" {
  depends_on = [github_repository.dotfiles]
  source     = "./repository"

  owner      = var.github_repository_owner
  repository = github_repository.dotfiles.name

  environments = [
    {
      environment        = "kickr"
      protected_branches = true
      secrets            = [{ secret_name = "KICKR_PRIVATE_KEY", from = "TF_VAR_kickr_private_key" }]
    }
  ]
}
