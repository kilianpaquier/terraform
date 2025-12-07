data "sops_file" "sops" {
  for_each = toset(["hcloud", "ovh"])

  source_file = "sops.${each.value}.enc.yml"
  input_type  = "yaml"
}
