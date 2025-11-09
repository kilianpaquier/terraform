terraform {
  backend "s3" {
    bucket = "selfhosted-terraform"
    endpoints = {
      s3 = "https://s3.gra.io.cloud.ovh.net/"
    }
    key     = "terraform.github.tfstate"
    region  = "gra"
    encrypt = true

    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}
