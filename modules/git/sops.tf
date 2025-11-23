data "sops_file" "sops" {
  for_each = toset(["github", "gitlab"])

  source_file = "sops.${each.value}.enc.yml"
  input_type  = "yaml"
}
