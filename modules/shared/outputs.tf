output "domain" {
  value = "kilianpaquier.dev"
}

output "public_keys" {
  value = {
    desktop     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA4gpcZXGcMfKMZyRvLzuav955wMV7FPjdRboPKxvuLf desktop.9th-gen.ryzen"
    laptop      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBtbXuVKV/wwO8q2CRsAGqftaiqOKe0NpZUnMA+Zn1+w laptop.12th-gen.intel-core"
    terraform   = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPtbMiGU2iLV8Zt2DnKoyqzCWGL0Q8wzfTGaDT1vnmXd terraform"
    work-laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGvMWuZwu1mAj2Ffd6nD8dc7+UtsVWHzQ9geSWMXtbTS laptop.200-series.ryzen"
  }
}
