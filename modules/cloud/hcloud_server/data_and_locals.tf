#####################################################
#
# Locals
#
#####################################################

locals {
  userdata = var.cloudinit != null ? templatefile(var.cloudinit.file, merge(var.cloudinit.vars.raw, {
    for key in var.cloudinit.vars.sops_keys : replace(key, ".", "_") => data.sops_file.sops[0].data[key]
  })) : ""
}

#####################################################
#
# Sops
#
#####################################################

data "sops_file" "sops" {
  count = var.cloudinit != null ? 1 : 0

  source_file = var.cloudinit.sops_file
  input_type  = "yaml"
}
