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
  region = var.region
  profile = var.profile
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}
