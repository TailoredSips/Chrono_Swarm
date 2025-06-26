terraform {
  required_version = ">= 1.6"
  
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 7.7"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    # OCI Object Storage S3 compatibility
    bucket                      = "chrono-swarm-tfstate"
    key                         = "global/chrono-swarm.tfstate"
    region                      = "us-ashburn-1"
    endpoint                    = "https://chrono-swarm.compat.objectstorage.us-ashburn-1.oraclecloud.com"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
    
    # State locking via DynamoDB-compatible table
    dynamodb_table = "chrono-swarm-tfstate-lock"
  }
}
