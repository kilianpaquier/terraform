# resource "github_repository" "exithandler" {
#   name        = "exithandler"
#   description = "Easily handle exit signals in golang"
#   archived    = false

#   has_downloads = false
#   has_issues    = true
#   homepage_url  = "https://pkg.go.dev/github.com/kilianpaquier/exithandler/pkg"

#   allow_auto_merge   = false
#   allow_merge_commit = false
#   allow_rebase_merge = true
#   allow_squash_merge = false

#   archive_on_destroy          = true
#   delete_branch_on_merge      = true
#   web_commit_signoff_required = true

#   topics = ["golang", "sigint", "signal-processing", "sigterm"]

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

# resource "github_branch_protection" "exithandler" {
#   depends_on = [github_repository.exithandler]
#   for_each   = toset(["main"])

#   pattern       = each.value
#   repository_id = github_repository.exithandler.name

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

# module "exithandler" {
#   depends_on = [github_repository.exithandler]
#   source     = "./repository"

#   owner      = var.github_repository_owner
#   repository = github_repository.exithandler.name

#   environments = [{ environment = "release", protected_branches = true }]
#   secrets      = [{ secret_name = "CODECOV_TOKEN", from = "TF_VAR_codecov_token" }]
# }
