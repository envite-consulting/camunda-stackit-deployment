terraform {
  required_providers {
    stackit = {
      source  = "stackitcloud/stackit"
      version = "0.69.0"
    }
  }

  backend "s3" {

    # Secrets and config outsourced to config.s3.tfbackend file, which is included in .gitignore
    # See also: https://developer.hashicorp.com/terraform/language/backend#partial-configuration
    # terraform init --backend-config=./config.s3.tfbackend
    #bucket = "tfstate-bucket-SUFFIX"
    #key    = "scrumlr.tfstate"
    #secret_key                  = "SECRETKEY"
    #access_key                  = "ACCESSKEY"

    endpoints = {
      s3 = "https://object.storage.eu01.onstackit.cloud"
    }
    region = "eu01"

    # Also use remote locking
    use_lockfile = true

    # AWS specific checks must be skipped as they do not work on STACKIT.
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_s3_checksum            = true
    skip_requesting_account_id  = true
  }
}
provider "stackit" {
  default_region           = "eu01"
  service_account_key_path = "sa_key.json"
}