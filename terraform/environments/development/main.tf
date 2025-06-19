terraform {
  backend "s3" {
    bucket = "chrono-swarm-dev-tfstate"
    key    = "development/terraform.tfstate"
    region = "us-west-2"
    encrypt = true
  }
}

provider "aws" {
  region = "us-west-2"
}
