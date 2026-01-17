resource "github_repository" "default" {
  name         = var.name
  description  = var.description
  visibility   = var.visibility
  homepage_url = var.homepage_url

  has_discussions = var.has_discussions
  has_downloads   = false
  has_issues      = var.has_issues
  has_projects    = var.has_projects
  has_wiki        = var.has_wiki

  allow_auto_merge   = false
  allow_merge_commit = false
  allow_rebase_merge = true
  allow_squash_merge = false

  archive_on_destroy          = true
  delete_branch_on_merge      = true
  web_commit_signoff_required = true

  topics = var.topics

  vulnerability_alerts = var.vulnerability_alerts
  security_and_analysis {
    secret_scanning {
      status = var.secret_scanning
    }
    secret_scanning_push_protection {
      status = var.secret_scanning_push_protection
    }
  }
}
