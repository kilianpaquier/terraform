resource "hcloud_rdns" "reverses" {
  depends_on = [
    hcloud_server.instances,
    ovh_domain_name.dev
  ]
  for_each = merge([
    # codespace
    # {},
    # instances
    merge([
      for name, instance in hcloud_server.instances : {
        "${name}-ipv4" = {
          ip_address = instance.ipv4_address
          server_id  = instance.id
          subdomain  = name
        }
        # "${name}-ipv6" = {
        #   ip_address = instance.ipv6_address
        #   server_id  = instance.id
        #   subdomain  = name
        # }
      }
    ]...)
  ]...)

  dns_ptr    = "${each.value.subdomain}.${ovh_domain_name.dev.domain_name}"
  ip_address = each.value.ip_address
  server_id  = each.value.server_id
}
