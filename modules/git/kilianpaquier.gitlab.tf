# data "gitlab_user" "user_owner" {
#   username = "u.${local.owner}"
# }

# resource "gitlab_user_sshkey" "ssh_key" {
#   for_each = { for k, repo in module.shared.public_keys : k => repo if k == "codespace" }
#   user_id  = data.gitlab_user.user_owner.id

#   title      = each.key
#   key        = each.value
#   expires_at = "2026-01-31T00:00:00.000Z"
# }

resource "gitlab_group" "kilianpaquier" {
  name        = "kilianpaquier"
  path        = "kilianpaquier"
  description = "All my projects sync'ed with https://github.com/kilianpaquier"

  default_branch = "main"
  emails_enabled = false

  project_creation_level  = "owner"
  subgroup_creation_level = "owner"
  visibility_level        = "public"
  wiki_access_level       = "disabled"

  auto_devops_enabled          = false
  permanently_remove_on_delete = false
  request_access_enabled       = false

  require_two_factor_authentication = true
  two_factor_grace_period           = 24

  default_branch_protection_defaults {
    allow_force_push           = false
    allowed_to_merge           = ["maintainer"]
    allowed_to_push            = ["maintainer"]
    developer_can_initial_push = false
  }

  push_rules {
    commit_message_regex    = ""
    deny_delete_tag         = true
    prevent_secrets         = true
    reject_non_dco_commits  = true
    reject_unsigned_commits = true
  }
}

resource "gitlab_group_access_token" "access_tokens" {
  depends_on = [gitlab_group.kilianpaquier]
  for_each = {
    "kickr" = {
      name         = "kickr[bot]"
      description  = "Kickr token to create branches and pull requests for kickr layout maintainance purposes"
      access_level = "developer"
      scopes       = ["api", "self_rotate", "write_repository"]
    }
    "mirror" = {
      name         = "github-webhook[bot]"
      description  = "Webhhook token for GitHub when an action is executed on a repository mirrored on GitHub"
      access_level = "maintainer"
      scopes       = ["api", "self_rotate"]
    }
    "release" = {
      name         = "release[bot]"
      description  = "Release token to create releases on GitLab, push commit(s) for version files and comment on issues and pull requests"
      access_level = "maintainer"
      scopes       = ["api", "self_rotate", "write_repository"]
    }
    "renovate" = {
      name         = "renovate[bot]"
      description  = "Renovate token to create branches and pull requests for versions maintainance purposes"
      access_level = "developer"
      scopes       = ["api", "self_rotate", "write_repository"]
    }
    # "terraform" = {
    #   name         = "Terraform CICD"
    #   description  = "Terraform GitLab token to apply resources"
    #   access_level = "terraform"
    #   scopes       = ["api", "self_rotate"]
    # }
  }

  group       = gitlab_group.kilianpaquier.id
  name        = each.value.name
  description = each.value.description

  access_level = each.value.access_level
  scopes       = each.value.scopes

  rotation_configuration = {
    expiration_days    = 365
    rotate_before_days = 15
  }
}

resource "gitlab_group_label" "labels" {
  depends_on = [gitlab_group.kilianpaquier]
  for_each   = { for label in module.shared.labels : label.name => label }
  group      = gitlab_group.kilianpaquier.id

  color       = each.value.color
  description = each.value.description
  name        = each.value.name
}

resource "gitlab_group_level_mr_approvals" "approvals" {
  depends_on = [gitlab_group.kilianpaquier]
  group      = gitlab_group.kilianpaquier.id

  allow_author_approval                              = true
  allow_committer_approval                           = true
  allow_overrides_to_approver_list_per_merge_request = false
  keep_settings_on_destroy                           = true
  retain_approvals_on_push                           = false
}

resource "gitlab_group_membership" "memberships" {
  depends_on = [
    gitlab_group_service_account.service_accounts,
    # gitlab_member_role.terraform
  ]
  for_each = {
    # "kickr" = {
    #   user_id      = gitlab_group_service_account.service_accounts["kickr"].service_account_id
    #   access_level = "developer"
    # }
    # "renovate" = {
    #   user_id      = gitlab_group_service_account.service_accounts["renovate"].service_account_id
    #   access_level = "developer"
    # }
    "terraform" = {
      user_id      = gitlab_group_service_account.service_accounts["terraform"].service_account_id
      access_level = "owner"
      # member_role_id = gitlab_member_role.terraform.iid
    }
  }

  group_id = gitlab_group.kilianpaquier.id
  user_id  = each.value.user_id

  access_level   = each.value.access_level
  member_role_id = lookup(each.value, "member_role_id", null)

  unassign_issuables_on_destroy = true
  skip_subresources_on_destroy  = false
}

resource "gitlab_group_protected_environment" "environments" {
  depends_on = [gitlab_group.kilianpaquier]
  for_each   = toset(["production", "staging"])
  group      = gitlab_group.kilianpaquier.id

  environment          = each.value
  approval_rules       = [{ access_level = "maintainer" }]
  deploy_access_levels = [{ access_level = "maintainer" }]
}

resource "gitlab_group_service_account" "service_accounts" {
  depends_on = [gitlab_group.kilianpaquier]
  for_each = {
    # "kickr" = { name = "Kickr", username = "kilianpaquier.kickr.bot" }
    # "renovate" = { name = "Renovate", username = "kilianpaquier.renovate.bot" }
    "terraform" = { name = "terraform[bot]", username = "kilianpaquier.terraform.bot" }
  }

  group    = gitlab_group.kilianpaquier.id
  name     = each.value.name
  username = each.value.username
}

resource "gitlab_group_service_account_access_token" "access_tokens" {
  depends_on = [gitlab_group_service_account.service_accounts]
  for_each = {
    # "kickr" = {
    #   user_id = gitlab_group_service_account.service_accounts["kickr"].service_account_id
    #   name    = "Kickr CICD"
    #   scopes  = ["api", "self_rotate", "write_repository"]
    # }
    # "renovate" = {
    #   user_id = gitlab_group_service_account.service_accounts["renovate"].service_account_id
    #   name    = "Renovate CICD"
    #   scopes  = ["api", "self_rotate", "write_repository"]
    # }
    "terraform" = {
      user_id = gitlab_group_service_account.service_accounts["terraform"].service_account_id
      name    = "terraform[bot]"
      scopes  = ["api", "self_rotate"]
    }
  }

  group   = gitlab_group.kilianpaquier.id
  user_id = each.value.user_id

  name   = each.value.name
  scopes = each.value.scopes

  rotation_configuration = {
    expiration_days    = 365
    rotate_before_days = 15
  }
}

resource "gitlab_group_variable" "variables" {
  depends_on = [gitlab_group_access_token.access_tokens]
  for_each = { for variable in [
    {
      key         = "CODECOV_TOKEN"
      description = "CodeCov access token for coverage analysis"
      sensitive   = true
      protected   = false
      value       = var.codecov_token
    },
    # {
    #   key         = "GITHUB_MIRROR_TOKEN"
    #   description = "Mirroring GitHub token to push repositories updates onto"
    #   sensitive   = true
    #   protected   = true
    #   value       = var.github_mirror_token
    # },
    # {
    #   key         = "KICKR_TOKEN"
    #   description = gitlab_group_access_token.access_tokens["kickr"].description
    #   sensitive   = true
    #   protected   = true
    #   value       = gitlab_group_access_token.access_tokens["kickr"].token
    # },
    {
      key         = "RELEASE_TOKEN"
      description = gitlab_group_access_token.access_tokens["release"].description
      sensitive   = true
      protected   = true
      value       = gitlab_group_access_token.access_tokens["release"].token
    }
  ] : variable.key => variable }

  group       = gitlab_group.kilianpaquier.id
  key         = each.key
  description = each.value.description

  environment_scope = "*"
  hidden            = each.value.sensitive
  masked            = each.value.sensitive
  protected         = each.value.protected
  raw               = true
  value             = sensitive(each.value.value)
  variable_type     = "env_var"
}

# resource "gitlab_member_role" "terraform" {
#   depends_on = [gitlab_group.kilianpaquier]
#   group_path = gitlab_group.kilianpaquier.name

#   name        = "Terraform"
#   description = "Maintainer that can do more, but yet not an Owner"

#   lifecycle {
#     ignore_changes = [enabled_permissions] # see https://gitlab.com/gitlab-org/terraform-provider-gitlab/-/merge_requests/2785
#   }

#   base_access_level = "MAINTAINER"
#   enabled_permissions = [
#     "ADMIN_CICD_VARIABLES",
#     "ADMIN_GROUP_MEMBER",
#     "ADMIN_INTEGRATIONS",
#     # "ADMIN_PROTECTED_ENVIRONMENTS", # see https://gitlab.com/gitlab-org/terraform-provider-gitlab/-/merge_requests/2785
#     "ARCHIVE_PROJECT",
#     "MANAGE_DEPLOY_TOKENS",
#     "MANAGE_GROUP_ACCESS_TOKENS",
#     "MANAGE_MERGE_REQUEST_SETTINGS"
#   ]
# }
