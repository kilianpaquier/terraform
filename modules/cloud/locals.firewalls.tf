locals {
  firewalls = [
    {
      description = "Allow private SSH port"
      name        = "ssh"
      port        = data.sops_file.sops["hcloud"].data["ssh_port"]
      protocol    = "tcp"
    },
    {
      description = "Allow HTTP port"
      name        = "http"
      port        = 80
      protocol    = "tcp"
    },
    {
      description = "Allow HTTPS port"
      name        = "https"
      port        = 443
      protocol    = "tcp"
    },
    {
      description = "Allow DNS check"
      name        = "dns"
      port        = 53
      protocol    = "udp"
    },
    {
      description = "Allow ping"
      name        = "ping"
      protocol    = "icmp"
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
