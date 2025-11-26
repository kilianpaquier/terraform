resource "gitlab_project_label" "labels" {
  for_each = { for label in var.labels : label.name => label }
  project  = var.project

  color       = each.value.color
  description = each.value.description
  name        = each.value.name
}
