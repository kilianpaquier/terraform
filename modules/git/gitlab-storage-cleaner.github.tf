resource "github_repository" "gitlab-storage-cleaner" {
  name        = "gitlab-storage-cleaner"
  description = "Easily clean gitlab maintained repositories storage (jobs artifacts only) with a simple command"

  has_discussions = true
  has_downloads   = false
  has_issues      = true

  allow_auto_merge   = false
  allow_merge_commit = false
  allow_rebase_merge = true
  allow_squash_merge = false

  archive_on_destroy          = true
  delete_branch_on_merge      = true
  web_commit_signoff_required = true

  topics = ["artifacts", "cleaner", "gitlab-ci", "golang"]

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

resource "github_branch_protection" "gitlab-storage-cleaner" {
  depends_on = [github_repository.gitlab-storage-cleaner]
  for_each   = toset(["main"])

  pattern       = each.value
  repository_id = github_repository.gitlab-storage-cleaner.name

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

module "gitlab-storage-cleaner" {
  depends_on = [
    github_repository.gitlab-storage-cleaner,
    gitlab_project.gitlab-storage-cleaner
  ]
  source     = "./github"
  repository = github_repository.gitlab-storage-cleaner.name

  actions_disabled = false
  default_branch   = "main"
  labels = module.shared.labels

  environments = [
    { environment = "docker" },
    {
      environment        = "kickr"
      protected_branches = true
      secrets            = [{ secret_name = "KICKR_PRIVATE_KEY", from = "TF_VAR_kickr_private_key" }]
    },
    { environment = "release", protected_branches = true }
  ]
  secrets = [{ secret_name = "CODECOV_TOKEN", from = "TF_VAR_codecov_token" }]
}
