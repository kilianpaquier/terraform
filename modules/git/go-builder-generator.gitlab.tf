resource "gitlab_project" "go-builder-generator" {
  namespace_id = gitlab_group.kilianpaquier.id
  name         = "go-builder-generator"

  default_branch   = "main"
  description      = "Easily generate builders for golang structs"
  visibility_level = "public"

  archive_on_destroy      = true
  keep_latest_artifact    = true
  merge_pipelines_enabled = false
  merge_trains_enabled    = false
  packages_enabled        = false
  public_jobs             = false

  import_url                          = "https://github.com/kilianpaquier/go-builder-generator.git"
  mirror                              = true
  mirror_overwrites_diverged_branches = true
  mirror_trigger_builds               = true

  analytics_access_level               = "disabled"
  builds_access_level                  = "enabled"
  container_registry_access_level      = "disabled"
  environments_access_level            = "disabled"
  feature_flags_access_level           = "disabled"
  forking_access_level                 = "enabled"
  infrastructure_access_level          = "disabled"
  issues_access_level                  = "enabled"
  merge_requests_access_level          = "enabled"
  model_experiments_access_level       = "disabled"
  model_registry_access_level          = "disabled"
  monitor_access_level                 = "disabled"
  pages_access_level                   = "disabled"
  releases_access_level                = "enabled"
  repository_access_level              = "enabled"
  requirements_access_level            = "disabled"
  security_and_compliance_access_level = "enabled"
  snippets_access_level                = "disabled"
  wiki_access_level                    = "disabled"

  allow_merge_on_skipped_pipeline                  = true
  auto_cancel_pending_pipelines                    = "enabled"
  autoclose_referenced_issues                      = true
  merge_method                                     = "ff"
  only_allow_merge_if_all_discussions_are_resolved = true
  only_allow_merge_if_pipeline_succeeds            = true
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
  ci_pipeline_variables_minimum_override_role = "maintainer"
  ci_push_repository_for_job_token_allowed    = false
  ci_restrict_pipeline_cancellation_role      = "developer"
  ci_separated_caches                         = true

  resolve_outdated_diff_discussions = false
}

module "gitlab_go-builder-generator" {
  depends_on = [
    github_repository.go-builder-generator,
    gitlab_project.go-builder-generator
  ]
  source = "./gitlab"

  owner   = local.owner
  project = gitlab_project.go-builder-generator.id

  # mirror = {
  #   token = sensitive(var.github_mirror_token)
  #   url   = github_repository.go-builder-generator.http_clone_url
  # }
}
