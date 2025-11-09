resource "github_repository" "hugo-primer" {
  name        = "hugo-primer"
  description = "Extensible Hugo theme based on Primer, the Design System for GitHub"

  has_discussions = true
  has_downloads   = false
  has_issues      = true
  homepage_url    = "https://hugo-primer.netlify.app"

  allow_auto_merge   = false
  allow_merge_commit = false
  allow_rebase_merge = true
  allow_squash_merge = false

  archive_on_destroy          = true
  delete_branch_on_merge      = true
  web_commit_signoff_required = true

  topics = ["hugo", "hugo-module", "hugo-site", "hugo-theme"]

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

resource "github_branch_protection" "hugo-primer" {
  depends_on = [github_repository.hugo-primer]
  for_each   = toset(["main"])

  pattern       = each.value
  repository_id = github_repository.hugo-primer.name

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

module "hugo-primer" {
  depends_on = [github_repository.hugo-primer]
  source     = "./repository"

  owner      = var.github_repository_owner
  repository = github_repository.hugo-primer.name

  environments = [
    {
      environment        = "kickr"
      protected_branches = true
      secrets            = [{ secret_name = "KICKR_PRIVATE_KEY", from = "TF_VAR_kickr_private_key" }]
    },
    {
      environment = "netlify"
      secrets     = [{ secret_name = "NETLIFY_AUTH_TOKEN", from = "TF_VAR_netlify_auth_token" }]
      variables   = [{ variable_name = "NETLIFY_SITE_ID", value = "30039a6c-ce0b-4884-a570-63dcc7022c8a" }]
    },
    { environment = "release", protected_branches = true },
    {
      environment        = "renovate"
      protected_branches = true
      secrets            = [{ secret_name = "RENOVATE_TOKEN", from = "TF_VAR_renovate_token" }]
    }
  ]
}
