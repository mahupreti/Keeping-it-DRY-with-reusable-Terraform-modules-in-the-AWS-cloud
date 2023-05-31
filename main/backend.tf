terraform {
  backend "s3" {
    bucket  = "terraform-2tier-architecture"
    key     = "2tier-architecture.tfstate"
    region  = var.region
    profile = "default"

  }
}