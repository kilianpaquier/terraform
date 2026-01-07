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

module "codespace_vps" {
  depends_on = [ovh_domain_name.dev]

  source      = "./ovh_vps"
  server_name = "codespace"

  # ovh_subsidiary = data.ovh_order_cart.subsidiary.ovh_subsidiary
  # plan = {
  #   datacenter   = "GRA"
  #   duration     = "P1M"
  #   os           = "Debian 13"
  #   plan_code    = "vps-2025-model1"
  # }

  # image_id   = "6d9a26f9-3226-46f1-b145-4d87aea9e53f"
  public_key = module.shared.public_keys.terraform

  # cloudinit = {
  #   file                 = "${path.module}/cloudinit/codespace.sh"
  #   sops_file            = "${path.module}/sops.cloudinit.enc.yml"
  #   sops_ssh_port        = "terraform_data.ssh_port"
  #   sops_ssh_private_key = "terraform_data.ssh_private_key"
  #   sops_ssh_user        = "terraform_data.ssh_user"
  #   vars = {
  #     sops_keys = ["ssh_port"]
  #     raw       = { public_keys = [for key, value in module.shared.public_keys : value] }
  #   }
  # }

  dns_records = [
    {
      subdomain = "codespace"
      domain    = ovh_domain_name.dev.domain_name
    }
  ]

  firewalls = concat(flatten([
    for firewall in local.firewalls : [
      for rule in firewall.rules : {
        action     = "permit"
        name       = firewall.name
        port       = lookup(rule, "port", null)
        protocol   = rule.protocol
        sequence   = rule.sequence
        tcp_option = lookup(rule, "tcp_option", null)
      } if contains(["dns", "ping", "ssh"], firewall.name)
  ]]), local.ovh-firewalls)
}

module "coolify_vps" {
  depends_on = [ovh_domain_name.dev]

  source      = "./ovh_vps"
  server_name = "coolify"

  ovh_subsidiary = data.ovh_order_cart.subsidiary.ovh_subsidiary
  plan = {
    datacenter = "GRA"
    duration   = "P1M"
    os         = "Ubuntu 24.04"
    plan_code  = "vps-2025-model1"
  }

  image_id   = "0da8c70b-7945-4728-a6db-108f28076590"
  public_key = module.shared.public_keys.terraform

  cloudinit = {
    file             = "${path.module}/cloudinit/coolify.sh"
    sops_file        = "${path.module}/sops.cloudinit.enc.yml"
    sops_private_key = "terraform_private_key"
    user             = "ubuntu"
    vars = {
      sops_keys = ["coolify.email", "coolify.password", "coolify.username", "ssh_port"]
      raw       = { public_keys = [for key, value in module.shared.public_keys : value] }
    }
  }

  dns_records = [
    {
      subdomain = "coolify"
      domain    = ovh_domain_name.dev.domain_name
    },
    {
      subdomain = "*"
      domain    = ovh_domain_name.dev.domain_name
    }
  ]

  firewalls = concat(flatten([
    for firewall in local.firewalls : [
      for rule in firewall.rules : {
        action     = "permit"
        name       = firewall.name
        port       = lookup(rule, "port", null)
        protocol   = rule.protocol
        sequence   = rule.sequence
        tcp_option = lookup(rule, "tcp_option", null)
      } if contains(["dns", "https", "ping", "ssh"], firewall.name)
  ]]), local.ovh-firewalls)
}

# module "coolify_server" {
#   depends_on = [
#     ovh_domain_name.dev,
#     hcloud_firewall.firewalls,
#     hcloud_placement_group.default,
#     hcloud_ssh_key.ssh_keys
#   ]

#   source      = "./hcloud_server"
#   server_name = "coolify"

#   image       = "ubuntu-24.04"
#   location    = "nbg1-dc3"
#   server_type = "cx23"

#   labels             = ["dns", "https", "ping", "ssh"]
#   placement_group_id = hcloud_placement_group.default.id
#   public_keys        = [for key, value in module.shared.public_keys : key]

#   cloudinit = {
#     file      = "${path.module}/cloudinit/coolify.yml"
#     sops_file = "${path.module}/sops.cloudinit.enc.yml"
#     vars = {
#       sops_keys = ["coolify.email", "coolify.password", "coolify.username", "ssh_port"]
#       raw       = { public_keys = [for key, value in module.shared.public_keys : value] }
#     }
#   }

#   dns_records = [
#     # {
#     #   subdomain = "coolify"
#     #   domain    = ovh_domain_name.dev.domain_name
#     # },
#     # {
#     #   subdomain = "*"
#     #   domain    = ovh_domain_name.dev.domain_name
#     # }
#   ]
# }
