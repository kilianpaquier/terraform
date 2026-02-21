#####################################################
#
# Locals
#
#####################################################

locals {
  firewalls = [
    {
      name = "known-ssh"
      rules = [
        { description = "Allow known SSH port", port = 22, protocol = "tcp", sequence = 2 }
      ]
    },
    {
      name = "https"
      rules = [
        { description = "Allow HTTP port", port = 80, protocol = "tcp", sequence = 3 },
        { description = "Allow HTTPs port", port = 443, protocol = "tcp", sequence = 4 }
      ]
    },
    {
      name = "dns"
      rules = [
        { description = "Allow DNS check", port = 53, protocol = "udp", sequence = 15 }
      ]
    },
    {
      name = "ping"
      rules = [
        { description = "Allow ping", protocol = "icmp", sequence = 16 }
      ]
    }
  ]
}

#####################################################
#
# Sops
#
#####################################################

data "sops_file" "sops" {
  for_each = toset(["providers", "cloudinit"])

  source_file = "sops.${each.value}.enc.yml"
  input_type  = "yaml"
}
