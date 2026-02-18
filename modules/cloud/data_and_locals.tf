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
        {
          description = "Allow known SSH port"
          port        = 22
          protocol    = "tcp"
          sequence    = 2
        }
      ]
    },
    {
      name = "https"
      rules = [
        {
          description = "Allow HTTP port"
          port        = 80
          protocol    = "tcp"
          sequence    = 3
        },
        {
          description = "Allow HTTPs port"
          port        = 443
          protocol    = "tcp"
          sequence    = 4
        }
      ]
    },
    # {
    #   name = "coolify"
    #   rules = [
    #     {
    #       description = "Allow specific coolify port on instance initialization"
    #       port        = 6001
    #       protocol    = "tcp"
    #       sequence    = 5
    #     },
    #     {
    #       description = "Allow specific coolify port on instance initialization"
    #       port        = 6002
    #       protocol    = "tcp"
    #       sequence    = 6
    #     },
    #     {
    #       description = "Allow specific coolify port on instance initialization"
    #       port        = 8000
    #       protocol    = "tcp"
    #       sequence    = 7
    #     }
    #   ]
    # },
    {
      name = "dns"
      rules = [
        {
          description = "Allow DNS check"
          port        = 53
          protocol    = "udp"
          sequence    = 15
        }
      ]
    },
    {
      name = "ping"
      rules = [
        {
          description = "Allow ping"
          protocol    = "icmp"
          sequence    = 16
        }
      ]
    }
  ]

  ovh-firewalls = [
    # allow TCP outgoing
    {
      action     = "permit"
      name       = "outgoing"
      protocol   = "tcp"
      sequence   = 0
      tcp_option = "established"
    },
    # close all other connections
    {
      action   = "deny"
      name     = "denyall"
      protocol = "ipv4"
      sequence = 17
    },
    {
      action   = "deny"
      name     = "denyall"
      protocol = "udp"
      sequence = 18
    },
    {
      action   = "deny"
      name     = "denyall"
      protocol = "tcp"
      sequence = 19
    }
  ]
}

#####################################################
#
# OVHcloud
#
#####################################################

data "ovh_me" "myaccount" {}

data "ovh_order_cart" "subsidiary" {
  ovh_subsidiary = data.ovh_me.myaccount.ovh_subsidiary
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
