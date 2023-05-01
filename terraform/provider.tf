terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "> 2.0.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "> 2.0.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.47.0"
    }
  }

  required_version = "~> 1.3"
}

provider "aws" {
  region  = var.region
  profile = var.profile
}
