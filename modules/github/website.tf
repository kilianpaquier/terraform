resource "github_repository" "website" {
  name        = "website"
  description = "Personal portfolio"

  has_downloads = false
  has_issues    = true
  homepage_url  = "https://kilianpaquier.dev"

  allow_auto_merge   = false
  allow_merge_commit = false
  allow_rebase_merge = true
  allow_squash_merge = false

  archive_on_destroy          = true
  delete_branch_on_merge      = true
  web_commit_signoff_required = true

  topics = ["github-pages", "hugo", "portfolio"]

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

resource "github_branch_protection" "website" {
  depends_on = [github_repository.website]
  for_each   = toset(["main"])

  pattern       = each.value
  repository_id = github_repository.website.name

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

module "website" {
  depends_on = [github_repository.website]
  source     = "./repository"

  owner      = var.github_repository_owner
  repository = github_repository.website.name

  environments = [
    {
      environment        = "kickr"
      protected_branches = true
      secrets            = [{ secret_name = "KICKR_PRIVATE_KEY", from = "TF_VAR_kickr_private_key" }]
    },
    {
      environment = "netlify"
      secrets     = [{ secret_name = "NETLIFY_AUTH_TOKEN", from = "TF_VAR_netlify_auth_token" }]
      variables   = [{ variable_name = "NETLIFY_SITE_ID", value = "a2abcddd-4ac5-431b-9d2c-11e391b8ec8c" }]
    },
    { environment = "release", protected_branches = true }
  ]
}
