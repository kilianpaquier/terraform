#####################################################
#
# Server
#
#####################################################

resource "hcloud_server" "default" {
  lifecycle {
    ignore_changes = [ssh_keys, user_data]
  }

  image       = var.image
  location    = var.location
  name        = var.server_name
  server_type = var.server_type

  allow_deprecated_images  = false
  delete_protection        = var.protected
  rebuild_protection       = var.protected
  shutdown_before_deletion = true

  backups            = var.backups
  keep_disk          = true
  labels             = { for label in var.labels : label => "" }
  placement_group_id = var.placement_group_id

  ssh_keys  = var.public_keys
  user_data = var.user_data

  public_net {
    ipv4_enabled = var.public_net.ipv4_enabled
    ipv6_enabled = var.public_net.ipv6_enabled
  }

  dynamic "network" {
    for_each = { for network in var.networks : network.network_id => network }
    content {
      alias_ips  = network.value.alias_ips
      ip         = network.value.ip
      network_id = network.key
    }
  }
}

#####################################################
#
# Firewalls
#
#####################################################

resource "hcloud_firewall" "default" {
  count      = length(var.firewalls) > 0 ? 1 : 0
  depends_on = [hcloud_server.default]

  name = var.server_name
  apply_to {
    server = hcloud_server.default.id
  }

  dynamic "rule" {
    for_each = var.firewalls
    content {
      description     = rule.value.description
      destination_ips = rule.value.destination_ips
      direction       = rule.value.direction
      port            = rule.value.port
      protocol        = rule.value.protocol
      source_ips      = rule.value.source_ips
    }
  }
}

#####################################################
#
# DNS Reverses
#
#####################################################

resource "hcloud_rdns" "default" {
  depends_on = [hcloud_server.default]
  for_each = length(var.dns_records) > 0 ? {
    ipv4 = {
      ip_address = hcloud_server.default.ipv4_address
      server_id  = hcloud_server.default.id
      dns_ptr    = "${var.dns_records[0].subdomain}.${var.dns_records[0].domain}"
    }
    ipv6 = {
      ip_address = hcloud_server.default.ipv6_address
      server_id  = hcloud_server.default.id
      dns_ptr    = "${var.dns_records[0].subdomain}.${var.dns_records[0].domain}"
    }
  } : {}

  dns_ptr    = each.value.dns_ptr
  ip_address = each.value.ip_address
  server_id  = each.value.server_id
}

#####################################################
#
# DNS Records
#
#####################################################

resource "ovh_domain_zone_record" "default" {
  depends_on = [hcloud_server.default]
  for_each = merge([
    for record in var.dns_records : {
      "${record.subdomain}.${record.domain}-ipv4" = merge(record, {
        target = hcloud_server.default.ipv4_address
        type   = "A"
      })
      "${record.subdomain}.${record.domain}-ipv6" = merge(record, {
        target = hcloud_server.default.ipv6_address
        type   = "AAAA"
      })
    }
  ]...)

  zone      = each.value.domain
  subdomain = each.value.subdomain
  fieldtype = each.value.type
  target    = each.value.target
}
