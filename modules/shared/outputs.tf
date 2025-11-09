output "public_keys" {
  value = {
    codespace = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICLCIWB4RSVIqR1oKQVAhAth83yTEcewlDrNIylO9etC"
    framework = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBtbXuVKV/wwO8q2CRsAGqftaiqOKe0NpZUnMA+Zn1+w laptop.12th-gen.intel-core"
    hp        = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIONZytSCpwTrg7RkQ/RnvNzMRj7zOB94NWMxXlAaYLRA laptop.200-series.ryzen"
    xtia      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA4gpcZXGcMfKMZyRvLzuav955wMV7FPjdRboPKxvuLf desktop.9th-gen.ryzen"
  }
}

output "domain" {
  value = "kilianpaquier.dev"
}
