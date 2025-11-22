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
        port        = var.ssh_port
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

  apply_to {
    label_selector = each.value.name
  }
}
