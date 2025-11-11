# resource "github_repository" "hugot" {
#   name        = "hugot"
#   description = "Simple hugo theme for docs and blog production with a bottom right menu"
#   archived    = false

#   has_downloads = false
#   has_issues    = true
#   homepage_url  = "https://hugot.netlify.app"

#   allow_auto_merge   = false
#   allow_merge_commit = false
#   allow_rebase_merge = true
#   allow_squash_merge = false

#   archive_on_destroy          = true
#   delete_branch_on_merge      = true
#   web_commit_signoff_required = true

#   topics = ["blog", "hugo-theme"]

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

# resource "github_branch_protection" "hugot" {
#   depends_on = [github_repository.hugot]
#   for_each   = toset(["main"])

#   pattern       = each.value
#   repository_id = github_repository.hugot.name

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

# module "hugot" {
#   depends_on = [github_repository.hugot]
#   source     = "./repository"

#   owner      = var.github_repository_owner
#   repository = github_repository.hugot.name

#   environments = [
#     {
#       environment = "netlify"
#       secrets     = [{ secret_name = "NETLIFY_AUTH_TOKEN", from = "TF_VAR_netlify_auth_token" }]
#       variables   = [{ variable_name = "NETLIFY_SITE_ID", value = "4bd25bd1-5661-46e8-bbd4-62d68dd7bac3" }]
#     },
#     { environment = "release", protected = true }
#   ]
# }
