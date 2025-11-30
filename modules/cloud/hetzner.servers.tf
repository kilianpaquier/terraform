# resource "hcloud_server" "codespace" {
#   depends_on = [
#     hcloud_ssh_key.ssh_keys,
#     hcloud_placement_group.default,
#   ]

#   lifecycle {
#     ignore_changes = [ssh_keys]
#   }

#   name        = "codespace"
#   datacenter  = "nbg1-dc3"
#   image       = "debian-13"
#   server_type = "cx43"

#   allow_deprecated_images  = false
#   delete_protection        = false
#   rebuild_protection       = false
#   shutdown_before_deletion = true

#   backups            = false
#   keep_disk          = true
#   labels             = { "ssh" = "" }
#   placement_group_id = hcloud_placement_group.default.id

#   ssh_keys = [for key, value in module.shared.public_keys : key]

#   user_data = templatefile("${path.module}/cloud-init/codespace.yml", {
#     ssh_port    = data.sops_file.sops["hetzner"].data["ssh_port"]
#     public_keys = [for key, value in module.shared.public_keys : value]
#   })

#   public_net {
#     ipv4_enabled = true
#     ipv6_enabled = true
#   }
# }

resource "hcloud_server" "instances" {
  depends_on = [
    hcloud_ssh_key.ssh_keys,
    hcloud_placement_group.default,
  ]
  for_each = tomap({
    # bentopdf = {
    #   file  = "nginx-based.yml"
    #   image = "docker.io/bentopdf/bentopdf:latest"
    # }
    # changedetection = { # FIXME not working yet
    #   file  = "" # see https://github.com/dgtlmoon/changedetection.io/blob/master/docker-compose.yml
    #   image = "ghcr.io/dgtlmoon/changedetection.io:latest"
    # }
    # cyberchef = {
    #   file  = "nginx-based.yml"
    #   image = "ghcr.io/gchq/cyberchef:latest"
    # }
    # it-tools = {
    #   file  = "nginx-based.yml"
    #   image = "ghcr.io/corentinth/it-tools:latest"
    # }
    # omni-tools = {
    #   file  = "nginx-based.yml"
    #   image = "docker.io/iib0011/omni-tools:latest"
    # }
    # stirling-pdf = {
    #   file  = "stirling-pdf.yml"
    #   image = "docker.stirlingpdf.com/stirlingtools/stirling-pdf:latest-ultra-lite"
    # }
    # vert = {
    #   debug = true
    #   file  = "nginx-based.yml"
    #   image = "ghcr.io/vert-sh/vert:latest"
    # }
  })

  lifecycle {
    ignore_changes = [ssh_keys]
  }

  name        = each.key
  datacenter  = "nbg1-dc3"
  image       = "docker-ce"
  server_type = "cx23"

  allow_deprecated_images  = false
  delete_protection        = false
  rebuild_protection       = false
  shutdown_before_deletion = true

  backups            = false
  keep_disk          = true
  labels             = { "http" = "", "https" = "", "ssh" = "" }
  placement_group_id = hcloud_placement_group.default.id

  ssh_keys = [for key, value in module.shared.public_keys : key]

  user_data = templatefile("${path.module}/cloud-init/${each.value.file}", {
    domain   = ovh_domain_name.dev.domain_name
    image    = each.value.image
    instance = each.key

    debug       = lookup(each.value, "debug", false)
    ssh_port    = data.sops_file.sops["ovh"].data["ssh_port"]
    public_keys = [for key, value in module.shared.public_keys : value]

    ovh_application_key    = data.sops_file.sops["ovh"].data["dns_application_key"]
    ovh_application_secret = data.sops_file.sops["ovh"].data["dns_application_secret"]
    ovh_consumer_key       = data.sops_file.sops["ovh"].data["dns_consumer_key"]
    ovh_endpoint           = local.ovh_endpoint
  })

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}
