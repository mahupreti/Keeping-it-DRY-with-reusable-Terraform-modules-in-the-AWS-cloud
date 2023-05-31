terraform {
  backend "s3" {
    bucket  = "terraform-3tier-architecture"
    key     = "3tier-architecture.tfstate"
    region  = "us-east-1"
    profile = "default"

  }
}