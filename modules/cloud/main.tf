#####################################################
#
# Hetzner
#
#####################################################

resource "hcloud_firewall" "firewalls" {
  for_each = { for firewall in local.firewalls : firewall.name => firewall }

  name = each.value.name

  dynamic "rule" {
    for_each = each.value.rules
    content {
      description = rule.value.description
      direction   = "in"
      port        = lookup(rule.value, "port", null)
      protocol    = rule.value.protocol
      source_ips = lookup(rule.value, "source_ips", [
        "0.0.0.0/0",
        "::/0"
      ])
    }
  }

  apply_to {
    label_selector = each.value.name
  }
}

resource "hcloud_network" "codespace" {
  name     = "codespace"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "codespace" {
  ip_range     = "10.0.0.0/16"
  network_id   = hcloud_network.codespace.id
  network_zone = "eu-central"
  type         = "cloud"
}

resource "hcloud_placement_group" "default" {
  name = "default"
  type = "spread"
}

resource "hcloud_ssh_key" "ssh_keys" {
  for_each   = module.shared.public_keys
  name       = each.key
  public_key = each.value
}

#####################################################
#
# OVHcloud
#
#####################################################

resource "ovh_cloud_project" "selfhosted" {
  # subsidiary and plan configuration are not present on imported resources
}

resource "ovh_cloud_project_ssh_key" "public_keys" {
  depends_on = [ovh_cloud_project.selfhosted]
  for_each   = { for key, value in module.shared.public_keys : key => value }

  public_key   = each.value
  service_name = ovh_cloud_project.selfhosted.project_id
  name         = each.key
}

resource "ovh_domain_name" "dev" {
  domain_name = module.shared.domain

  target_spec = {
    dns_configuration = {
      name_servers = [
        {
          name_server = "ns200.anycast.me"
        },
        {
          name_server = "dns200.anycast.me"
        }
      ]
    }
  }
}

resource "ovh_domain_zone_record" "storageshare" {
  depends_on = [ovh_domain_name.dev]

  zone      = ovh_domain_name.dev.domain_name
  subdomain = "storageshare"
  fieldtype = "CNAME"
  target    = "nx84000.your-storageshare.de."
}

#####################################################
#
# Servers
#
#####################################################

module "codespace_server" {
  depends_on = [
    hcloud_network_subnet.codespace,
    hcloud_network.codespace,
    hcloud_placement_group.default,
    hcloud_ssh_key.ssh_keys
  ]

  source      = "./hcloud_server"
  server_name = "codespace"

  image       = "debian-13"
  location    = "fsn1"
  server_type = "cx33"

  placement_group_id = hcloud_placement_group.default.id
  public_keys        = [for key, value in module.shared.public_keys : key]

  networks = [{ subnet_id = hcloud_network_subnet.codespace.id }]
  firewalls = [
    {
      description = "Allow private SSH port"
      direction   = "in"
      port        = data.sops_file.sops["cloudinit"].data["codespace.ssh_port"]
      protocol    = "tcp"
      source_ips  = ["0.0.0.0/0", "::/0"]
    }
  ]

  user_data = templatefile("${path.module}/cloudinit/codespace.yml", {
    public_keys = [for key, value in module.shared.public_keys : value]
    ssh_port    = data.sops_file.sops["cloudinit"].data["codespace.ssh_port"]
    ssh_user    = data.sops_file.sops["cloudinit"].data["codespace.ssh_user"]
  })
}
