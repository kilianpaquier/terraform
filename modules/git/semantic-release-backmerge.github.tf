resource "github_repository" "semantic-release-backmerge" {
  name        = "semantic-release-backmerge"
  description = "Backmerge feature for semantic-release with automatic PR creation when a conflict is identified. Available for GitHub, GitLab, Bitbucket and Gitea"

  has_downloads = false
  has_issues    = true
  homepage_url  = "https://npmjs.com/package/@kilianpaquier/semantic-release-backmerge"

  allow_auto_merge   = false
  allow_merge_commit = false
  allow_rebase_merge = true
  allow_squash_merge = false

  archive_on_destroy          = true
  delete_branch_on_merge      = true
  web_commit_signoff_required = true

  topics = ["backmerge", "semantic-release-plugin"]

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

resource "github_branch_protection" "semantic-release-backmerge" {
  depends_on = [github_repository.semantic-release-backmerge]
  for_each   = toset(["main"])

  pattern       = each.value
  repository_id = github_repository.semantic-release-backmerge.name

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

module "semantic-release-backmerge" {
  depends_on = [
    github_repository.semantic-release-backmerge,
    gitlab_project.semantic-release-backmerge
  ]
  source     = "./github"
  repository = github_repository.semantic-release-backmerge.name

  actions_disabled = false
  default_branch   = "main"
  labels           = module.shared.labels

  environments = [
    {
      environment        = "kickr"
      protected_branches = true
      secrets            = [{ secret_name = "KICKR_PRIVATE_KEY", plaintext_value = data.sops_file.sops["github"].data["kickr_private_key"] }]
    },
    { environment = "release", protected_branches = true }
  ]
  secrets = [{ secret_name = "CODECOV_TOKEN", plaintext_value = data.sops_file.sops["gitlab"].data["codecov_token"] }]
}
