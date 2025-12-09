locals {
  firewalls = [
    {
      name = "ssh"
      rules = [
        {
          description = "Allow private SSH port"
          port        = data.sops_file.sops["base"].data["ssh_port"]
          protocol    = "tcp"
        }
      ]
    },
    {
      name = "known-ssh"
      rules = [
        {
          description = "Allow known SSH port"
          port        = 22
          protocol    = "tcp"
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
        },
        {
          description = "Allow HTTPs port"
          port        = 443
          protocol    = "tcp"
        }
      ]
    },
    {
      name = "coolify"
      rules = [
        {
          description = "Allow specific coolify port on instance initialization"
          port        = 6001
          protocol    = "tcp"
        },
        {
          description = "Allow specific coolify port on instance initialization"
          port        = 6002
          protocol    = "tcp"
        },
        {
          description = "Allow specific coolify port on instance initialization"
          port        = 8000
          protocol    = "tcp"
        }
      ]
    },
    {
      name = "dns"
      rules = [
        {
          description = "Allow DNS check"
          port        = 53
          protocol    = "udp"
        }
      ]
    },
    {
      name = "ping"
      rules = [
        {
          description = "Allow ping"
          protocol    = "icmp"
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
    # close all TCP connection
    {
      action   = "deny"
      name     = "denyall"
      protocol = "tcp"
      sequence = 19
    }
  ]
}
