terraform {
  backend "s3" {
    bucket = "chrono-swarm-prod-tfstate"
    key    = "production/terraform.tfstate"
    region = "us-west-2"
    encrypt = true
  }
}

provider "aws" {
  region = "us-west-2"
}
