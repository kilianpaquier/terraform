resource "hcloud_firewall" "incomings" {
  for_each = {
    for firewall in [
      {
        description = "Allow HTTP port"
        name        = "http"
        port        = 80
      },
      {
        description = "Allow HTTPS port"
        name        = "https"
        port        = 443
      },
      {
        description = "Allow private SSH port"
        name        = "ssh"
        port        = data.sops_file.sops["hetzner"].data["ssh_port"]
      }
    ] : firewall.name => firewall
  }

  name = each.value.name

  rule {
    description = each.value.description
    direction   = "in"
    port        = each.value.port
    protocol    = "tcp"
    source_ips = lookup(each.value, "source_ips", [
      "0.0.0.0/0",
      "::/0"
    ])
  }

  rule {
    description = "Allow ping"
    direction   = "in"
    protocol    = "icmp"
    source_ips = lookup(each.value, "source_ips", [
      "0.0.0.0/0",
      "::/0"
    ])
  }

  rule {
    description = "Allow DNS check"
    direction   = "in"
    port        = 53
    protocol    = "udp"
    source_ips = lookup(each.value, "source_ips", [
      "0.0.0.0/0",
      "::/0"
    ])
  }

  apply_to {
    label_selector = each.value.name
  }
}
