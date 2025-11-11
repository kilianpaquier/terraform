# resource "github_repository" "cli-sdk" {
#   name        = "cli-sdk"
#   description = "Helpers for extensible CLI developments (upgrade feature, logger interface, filesystem features, etc.)"
#   archived    = false

#   has_downloads = false
#   has_issues    = true
#   homepage_url  = "https://pkg.go.dev/github.com/kilianpaquier/cli-sdk"

#   allow_auto_merge   = false
#   allow_merge_commit = false
#   allow_rebase_merge = true
#   allow_squash_merge = false

#   archive_on_destroy          = true
#   delete_branch_on_merge      = true
#   web_commit_signoff_required = true

#   vulnerability_alerts = true
#   security_and_analysis {
#     secret_scanning {
#       status = "enabled"
#     }
#     secret_scanning_push_protection {
#       status = "enabled"
#     }
#   }
# }

# resource "github_branch_protection" "cli-sdk" {
#   depends_on = [github_repository.cli-sdk]
#   for_each   = toset(["main"])

#   pattern       = each.value
#   repository_id = github_repository.cli-sdk.name

#   enforce_admins                  = true
#   require_conversation_resolution = true

#   required_pull_request_reviews {
#     dismiss_stale_reviews           = true
#     require_code_owner_reviews      = true
#     require_last_push_approval      = true
#     required_approving_review_count = 1
#   }
#   required_status_checks {
#     strict = true
#   }
# }

# module "cli-sdk" {
#   depends_on = [github_repository.cli-sdk]
#   source     = "./repository"

#   owner      = var.github_repository_owner
#   repository = github_repository.cli-sdk.name

#   environments = [{ environment = "release", protected_branches = true }]
#   secrets      = [{ secret_name = "CODECOV_TOKEN", from = "TF_VAR_codecov_token" }]
# }
