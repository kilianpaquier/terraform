resource "hcloud_firewall" "http" {
  name = "http"

  rule {
    description = "Allow HTTP port"
    direction   = "in"
    port        = "80"
    protocol    = "tcp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  apply_to {
    label_selector = "http"
  }
}

resource "hcloud_firewall" "https" {
  name = "https"

  rule {
    description = "Allow HTTPS port"
    direction   = "in"
    port        = "443"
    protocol    = "tcp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  apply_to {
    label_selector = "https"
  }
}

resource "hcloud_firewall" "ssh" {
  name = "ssh"

  rule {
    description = "Allow private SSH port"
    direction   = "in"
    port        = var.ssh_port
    protocol    = "tcp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  apply_to {
    label_selector = "ssh"
  }
}
