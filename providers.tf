terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.32.1"
    }
    google = {
      source = "hashicorp/google"
      version = "5.12.0"
    }
    hcp = {
      source = "hashicorp/hcp"
      version = "0.80.0"
    }
  }
}

provider "aws" {
  region = var.vpc_region
}

provider "hcp" {
  # Configure your local environment variables:
  # HCP_CLIENT_ID
  # HCP_CLIENT_SECRET
}
provider "google" {
  region = var.gcp_region
  project = var.gcp_project
}