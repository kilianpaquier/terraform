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

  # avatar      = "${path.module}/avatars/kilianpaquier.png"
  # avatar_hash = filesha256("${path.module}/avatars/kilianpaquier.png")

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
    branch_name_regex    = local.branch_name_regex
    commit_message_regex = local.commit_message_regex

    deny_delete_tag         = true
    max_file_size           = 25
    prevent_secrets         = true
    reject_non_dco_commits  = true
    reject_unsigned_commits = false
  }
}

resource "gitlab_group_access_token" "access_tokens" {
  depends_on = [gitlab_group.kilianpaquier]
  for_each = {
    "kickr" = {
      name         = "my-kickr[bot]"
      description  = "Kickr token to create branches and pull requests for kickr layout maintainance purposes"
      access_level = "developer"
      scopes       = ["api", "self_rotate", "write_repository"]
    }
    "release" = {
      name         = "my-release[bot]"
      description  = "Release token to create releases on GitLab, push commit(s) for version files and comment on issues and pull requests"
      access_level = "maintainer"
      scopes       = ["api", "self_rotate", "write_repository"]
    }
    "renovate" = {
      name         = "my-renovate[bot]"
      description  = "Renovate token to create branches and pull requests for versions maintainance purposes"
      access_level = "developer"
      scopes       = ["api", "self_rotate", "write_repository"]
    }
    # "terraform" = {
    #   name         = "terraform[bot]"
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
  for_each   = { for label in local.labels : label.name => label }
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
  depends_on = [gitlab_group_service_account.service_accounts]
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
      user_id = gitlab_group_service_account.service_accounts["terraform"].service_account_id
      # cannot have a custom role between Maintainer and Owner because there's no scope to rotate or create its own tokens
      # cannot be just a Group Access Token because a custom role cannot be assigned to that and Group Access Token(s) (even Owner) cannot rotate or create Group Access Token(s)
      access_level = "owner"
    }
  }

  group_id = gitlab_group.kilianpaquier.id
  user_id  = each.value.user_id

  access_level   = each.value.access_level
  member_role_id = lookup(each.value, "member_role_id", null)

  unassign_issuables_on_destroy = true
  skip_subresources_on_destroy  = false
}

resource "gitlab_group_service_account" "service_accounts" {
  depends_on = [gitlab_group.kilianpaquier]
  for_each = {
    # "kickr"     = { name = "kickr[bot]", username = "kilianpaquier.kickr.bot" }
    # "renovate"  = { name = "renovate[bot]", username = "kilianpaquier.renovate.bot" }
    "terraform" = { name = "my-terraform[bot]", username = "kilianpaquier.terraform.bot" }
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
    #   name    = "kickr[bot]"
    #   scopes  = ["api", "self_rotate", "write_repository"]
    # }
    # "renovate" = {
    #   user_id = gitlab_group_service_account.service_accounts["renovate"].service_account_id
    #   name    = "renovate[bot]"
    #   scopes  = ["api", "self_rotate", "write_repository"]
    # }
    # "terraform" = {
    #   user_id = gitlab_group_service_account.service_accounts["terraform"].service_account_id
    #   name    = "terraform[bot]"
    #   scopes  = ["api", "self_rotate"]
    # }
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
      value       = data.sops_file.sops["gitlab"].data["codecov_token"]
    },
    {
      key         = "KICKR_TOKEN"
      description = gitlab_group_access_token.access_tokens["kickr"].description
      sensitive   = true
      protected   = true
      value       = gitlab_group_access_token.access_tokens["kickr"].token
    },
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

resource "gitlab_user_avatar" "tokens" {
  depends_on = [
    gitlab_group_access_token.access_tokens,
    gitlab_group_service_account.service_accounts
  ]
  for_each = merge([
    {
      for name, token in gitlab_group_access_token.access_tokens : name => {
        avatar  = "${name}.png"
        token   = token.token
        user_id = token.user_id
      }
    },
    {
      "terraform" = {
        avatar  = "terraform.png"
        token   = data.sops_file.sops["gitlab"].data["terraform_token"]
        user_id = gitlab_group_service_account.service_accounts["terraform"].service_account_id
      }
    }
  ]...)

  user_id     = each.value.user_id
  token       = each.value.token
  avatar      = "${path.module}/avatars/${each.value.avatar}"
  avatar_hash = filesha256("${path.module}/avatars/${each.value.avatar}")
}
