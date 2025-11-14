resource "github_repository_ruleset" "tags" {
  name       = "tags"
  repository = var.repository

  target      = "tag"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~ALL"]
      exclude = []
    }
  }

  rules {
    deletion = true
    update   = true
  }
}
