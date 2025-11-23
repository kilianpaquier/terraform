# resource "hcloud_server" "codespace" {
#   depends_on = [hcloud_ssh_key.ssh_keys]

#   lifecycle {
#     ignore_changes = [ssh_keys]
#   }

#   name        = "codespace"
#   datacenter  = "nbg1-dc3"
#   image       = "debian-13"
#   server_type = "cx43"

#   backups   = false
#   keep_disk = true
#   labels    = { "ssh" = "" }

#   ssh_keys = [for key in module.shared.public_keys : key]

#   user_data = templatefile("${path.module}/cloud-init/codespace.yml", {
#     ssh_port    = data.sops_file.sops["hetzner"].data["ssh_port"]
#     public_keys = [for key, value in module.shared.public_keys : value]
#   })

#   public_net {
#     ipv4_enabled = false
#     ipv6_enabled = true
#   }
# }
