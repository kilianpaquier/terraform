locals {
  codespace = {
    userdata = "codespace.yml"
    hosts = [
      # "hcloud",
      "ovh"
    ]
    labels = ["dns", "ping", "ssh"]
  }

  coolify = {
    userdata = "coolify.yml"
    hosts    = [
      # "hcloud",
      # "ovh"
    ]
    labels   = ["dns", "https", "ping", "coolify"]
  }
}
