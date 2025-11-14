resource "github_repository" "zsh-plugins" {
  name        = "zsh-plugins"
  description = "A bunch of ZSH plugins that also acts as installation plugins to avoid running an installation script"

  has_downloads = false
  has_issues    = false

  allow_auto_merge   = false
  allow_merge_commit = false
  allow_rebase_merge = true
  allow_squash_merge = false

  archive_on_destroy          = true
  delete_branch_on_merge      = true
  web_commit_signoff_required = true

  topics = ["zsh-plugin", "zsh-plugins"]

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

resource "github_branch_protection" "zsh-plugins" {
  depends_on = [github_repository.zsh-plugins]
  for_each   = toset(["main"])

  pattern       = each.value
  repository_id = github_repository.zsh-plugins.name

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

module "zsh-plugins" {
  depends_on = [github_repository.zsh-plugins]
  source     = "./github"

  owner      = local.owner
  repository = github_repository.zsh-plugins.name

  actions_disabled = true
  default_branch   = "main"
}
