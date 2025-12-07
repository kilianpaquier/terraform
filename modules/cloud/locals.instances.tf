locals {
  codespace = {
    userdata = "codespace.yml"
    hosts = [
      # "hcloud",
      "ovh"
    ]
    labels = ["dns", "ping", "ssh"]
  }

  instances = [
    # {
    #   userdata = "nginx-based.yml"
    #   hosts = [
    #     "hcloud",
    #     # "ovh"
    #   ]
    #   labels = ["dns", "http", "https", "ping"]
    #   name   = "bentopdf"
    #   image  = "docker.io/bentopdf/bentopdf:latest"
    #   port   = 8080
    # },
    # {
    #   userdata = "" # see https://github.com/dgtlmoon/changedetection.io/blob/master/docker-compose.yml
    #   hosts = [
    #     "hcloud",
    #     "ovh"
    #   ]
    #   labels = ["dns", "http", "https", "ping"]
    #   name   = "changedetection"
    #   image  = "ghcr.io/dgtlmoon/changedetection.io:latest"
    # },
    # {
    #   userdata = "nginx-based.yml"
    #   hosts = [
    #     "hcloud",
    #     # "ovh"
    #   ]
    #   labels = ["dns", "http", "https", "ping"]
    #   name   = "cyberchef"
    #   image  = "ghcr.io/gchq/cyberchef:latest"
    # },
    # {
    #   userdata = "nginx-based.yml"
    #   hosts = [
    #     "hcloud",
    #     # "ovh"
    #   ]
    #   labels = ["dns", "http", "https", "ping"]
    #   name   = "excalidraw"
    #   image  = "docker.io/excalidraw/excalidraw:latest"
    # },
    # {
    #   userdata = "nginx-based.yml"
    #   hosts = [
    #     "hcloud",
    #     # "ovh"
    #   ]
    #   labels = ["dns", "http", "https", "ping"]
    #   name   = "it-tools"
    #   image  = "ghcr.io/corentinth/it-tools:latest"
    # },
    # {
    #   userdata = "nginx-based.yml"
    #   hosts = [
    #     "hcloud",
    #     # "ovh"
    #   ]
    #   labels = ["dns", "http", "https", "ping"]
    #   name   = "omni-tools"
    #   image  = "docker.io/iib0011/omni-tools:latest"
    # },
    # {
    #   userdata = "stirling-pdf.yml"
    #   hosts = [
    #     "hcloud",
    #     # "ovh"
    #   ]
    #   labels = ["dns", "http", "https", "ping"]
    #   name   = "stirling-pdf"
    #   image  = "docker.stirlingpdf.com/stirlingtools/stirling-pdf:latest-ultra-lite"
    # },
    # {
    #   userdata = "nginx-based.yml"
    #   hosts = [
    #     "hcloud",
    #     # "ovh"
    #   ]
    #   labels = ["dns", "http", "https", "ping"]
    #   name   = "vert"
    #   image  = "ghcr.io/vert-sh/vert:latest"
    # }
  ]
}
