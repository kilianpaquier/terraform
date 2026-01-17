resource "gitlab_project" "default" {
  namespace_id = var.namespace_id
  name         = var.name

  default_branch   = var.default_branch
  description      = var.description
  visibility_level = var.visibility_level

  archive_on_destroy      = true
  keep_latest_artifact    = true
  merge_pipelines_enabled = var.merge_pipelines_enabled
  merge_trains_enabled    = var.merge_trains_enabled
  packages_enabled        = var.packages_enabled
  public_jobs             = var.public_jobs

  import_url                          = var.mirror
  mirror                              = var.mirror != ""
  mirror_overwrites_diverged_branches = var.mirror != ""
  mirror_trigger_builds               = var.mirror != ""
  only_mirror_protected_branches      = var.mirror != ""

  analytics_access_level               = var.analytics_access_level
  builds_access_level                  = var.builds_access_level
  container_registry_access_level      = var.container_registry_access_level
  environments_access_level            = var.environments_access_level
  feature_flags_access_level           = var.feature_flags_access_level
  forking_access_level                 = var.forking_access_level
  infrastructure_access_level          = var.infrastructure_access_level
  issues_access_level                  = var.issues_access_level
  merge_requests_access_level          = var.merge_requests_access_level
  model_experiments_access_level       = var.model_experiments_access_level
  model_registry_access_level          = var.model_registry_access_level
  monitor_access_level                 = var.monitor_access_level
  pages_access_level                   = var.pages_access_level
  releases_access_level                = var.releases_access_level
  repository_access_level              = var.repository_access_level
  requirements_access_level            = var.requirements_access_level
  security_and_compliance_access_level = var.security_and_compliance_access_level
  snippets_access_level                = var.snippets_access_level
  wiki_access_level                    = var.wiki_access_level

  allow_merge_on_skipped_pipeline                  = true
  auto_cancel_pending_pipelines                    = "enabled"
  autoclose_referenced_issues                      = true
  merge_method                                     = "ff"
  only_allow_merge_if_all_discussions_are_resolved = true
  only_allow_merge_if_pipeline_succeeds            = var.only_allow_merge_if_pipeline_succeeds
  pre_receive_secret_detection_enabled             = true
  printing_merge_request_link_enabled              = true
  remove_source_branch_after_merge                 = true
  squash_option                                    = "never"
  suggestion_commit_message                        = "chore(review): apply suggestion"

  build_git_strategy                          = "fetch"
  build_timeout                               = 900
  ci_delete_pipelines_in_seconds              = 1296000 # 15d
  ci_forward_deployment_enabled               = true
  ci_forward_deployment_rollback_allowed      = true
  ci_pipeline_variables_minimum_override_role = "developer"
  ci_push_repository_for_job_token_allowed    = false
  ci_restrict_pipeline_cancellation_role      = "developer"
  ci_separated_caches                         = true

  resolve_outdated_diff_discussions = false

  push_rules {
    branch_name_regex    = var.branch_name_regex
    commit_message_regex = var.commit_message_regex

    deny_delete_tag         = true
    max_file_size           = 25
    prevent_secrets         = true
    reject_non_dco_commits  = true
    reject_unsigned_commits = false
  }
}
