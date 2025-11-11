resource "github_repository" "compare" {
  name        = "compare"
  description = "Compare files and directories with Golang internal diff library"

  has_downloads = false
  has_issues    = true
  homepage_url  = "https://pkg.go.dev/github.com/kilianpaquier/compare"

  allow_auto_merge   = false
  allow_merge_commit = false
  allow_rebase_merge = true
  allow_squash_merge = false

  archive_on_destroy          = true
  delete_branch_on_merge      = true
  web_commit_signoff_required = true

  topics = ["compare-files", "compare-text", "compare-directories", "golang", "golang-library"]

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

resource "github_branch_protection" "compare" {
  depends_on = [github_repository.compare]
  for_each   = toset(["main"])

  pattern       = each.value
  repository_id = github_repository.compare.name

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

module "compare" {
  depends_on = [github_repository.compare]
  source     = "./repository"

  owner      = var.github_repository_owner
  repository = github_repository.compare.name

  environments = [
    {
      environment        = "kickr"
      protected_branches = true
      secrets            = [{ secret_name = "KICKR_PRIVATE_KEY", from = "TF_VAR_kickr_private_key" }]
      variables          = [{ variable_name = "KICKR_APP_ID", value = "2184379" }]
    },
    { environment = "release", protected_branches = true }
  ]
  secrets = [{ secret_name = "CODECOV_TOKEN", from = "TF_VAR_codecov_token" }]
}
