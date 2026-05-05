terraform {
  backend "s3" {
    bucket = "chapstick0367siva-terraform-state-105959917336"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}
