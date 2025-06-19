terraform {
  backend "s3" {
    bucket = "chrono-swarm-staging-tfstate"
    key    = "staging/terraform.tfstate"
    region = "us-west-2"
    encrypt = true
  }
}

provider "aws" {
  region = "us-west-2"
}
