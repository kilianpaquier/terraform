resource "github_repository" "go-builder-generator" {
  name        = "go-builder-generator"
  description = "Easily generate builders for golang structs"

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

  topics = ["builders", "generator", "golang"]

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

resource "github_branch_protection" "go-builder-generator" {
  depends_on = [github_repository.go-builder-generator]
  for_each   = toset(["main"])

  pattern       = each.value
  repository_id = github_repository.go-builder-generator.name

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

module "go-builder-generator" {
  depends_on = [github_repository.go-builder-generator]
  source     = "./github"
  repository = github_repository.go-builder-generator.name

  actions_disabled = false
  default_branch   = "main"
  labels           = module.shared.labels

  environments = [
    {
      environment        = "kickr"
      protected_branches = true
      secrets            = [{ secret_name = "KICKR_PRIVATE_KEY", plaintext_value = data.sops_file.sops["github"].data["kickr_private_key"] }]
    },
    { environment = "release", protected_branches = true },
    {
      environment        = "renovate"
      protected_branches = true
      secrets            = [{ secret_name = "RENOVATE_TOKEN", plaintext_value = data.sops_file.sops["github"].data["renovate_token"] }]
    }
  ]
  secrets = [{ secret_name = "CODECOV_TOKEN", plaintext_value = data.sops_file.sops["gitlab"].data["codecov_token"] }]
}
