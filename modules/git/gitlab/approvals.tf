# resource "gitlab_project_approval_rule" "approvals" {
#   name    = "Approvals"
#   project = var.project

#   applies_to_all_protected_branches                     = true
#   approvals_required                                    = 1
#   disable_importing_default_any_approver_rule_on_create = true
#   report_type                                           = "code_coverage"
#   rule_type                                             = "regular"
# }
