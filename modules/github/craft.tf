# resource "github_repository" "craft" {
#   name        = "craft"
#   description = "Easily generate identical projects layout to enforce consistency over repositories"
#   archived    = false

#   has_downloads = false
#   has_issues    = true

#   allow_auto_merge   = false
#   allow_merge_commit = false
#   allow_rebase_merge = true
#   allow_squash_merge = false

#   archive_on_destroy          = true
#   delete_branch_on_merge      = true
#   web_commit_signoff_required = true

#   topics = ["generator", "golang", "layout", "repository-tools", "templates"]

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

# resource "github_branch_protection" "craft" {
#   depends_on = [github_repository.craft]
#   for_each   = toset(["beta", "main"])

#   pattern       = each.value
#   repository_id = github_repository.craft.name

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

# module "craft" {
#   depends_on = [github_repository.craft]
#   source     = "./repository"

#   owner      = var.github_repository_owner
#   repository = github_repository.craft.name

#   environments = [{ environment = "release", protected_branches = true }]
#   secrets      = [{ secret_name = "CODECOV_TOKEN", from = "TF_VAR_codecov_token" }]
# }
