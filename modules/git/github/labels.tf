resource "github_issue_labels" "labels" {
  repository = var.repository

  dynamic "label" {
    for_each = { for label in var.labels : label.name => label }
    content {
      color       = trimprefix(label.value.color, "#")
      description = label.value.description
      name        = label.key
    }
  }
}
