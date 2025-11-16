resource "github_repository" "pooling" {
  name        = "pooling"
  description = "Easily dispatch functions (and subfunctions indefinitely) into a shared pool of routines in golang"

  has_downloads = false
  has_issues    = true
  homepage_url  = "https://pkg.go.dev/github.com/kilianpaquier/pooling"

  allow_auto_merge   = false
  allow_merge_commit = false
  allow_rebase_merge = true
  allow_squash_merge = false

  archive_on_destroy          = true
  delete_branch_on_merge      = true
  web_commit_signoff_required = true

  topics = ["golang", "parallel-computing", "queue-tasks", "recursive-algorithm"]

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

resource "github_branch_protection" "pooling" {
  depends_on = [github_repository.pooling]
  for_each   = toset(["main"])

  pattern       = each.value
  repository_id = github_repository.pooling.name

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

module "pooling" {
  depends_on = [github_repository.pooling]
  source     = "./github"
  repository = github_repository.pooling.name

  actions_disabled = true
  default_branch   = "main"
  labels           = module.shared.labels
}
