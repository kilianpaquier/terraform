resource "github_repository" "zsh-customs" {
  name        = "zsh-customs"
  description = "Handle multiple ZSH_CUSTOM at once"

  has_downloads = false
  has_issues    = true

  allow_auto_merge   = false
  allow_merge_commit = false
  allow_rebase_merge = true
  allow_squash_merge = false

  archive_on_destroy          = true
  delete_branch_on_merge      = true
  web_commit_signoff_required = true

  topics = ["zsh", "zsh-plugins"]

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

resource "github_branch_protection" "zsh-customs" {
  depends_on = [github_repository.zsh-customs]
  for_each   = toset(["main"])

  pattern       = each.value
  repository_id = github_repository.zsh-customs.name

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

module "zsh-customs" {
  depends_on = [github_repository.zsh-customs]
  source     = "./repository"

  owner      = var.github_repository_owner
  repository = github_repository.zsh-customs.name
}
