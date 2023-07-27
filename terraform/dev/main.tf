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
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }

  required_version = "~> 1.3"
}


module "ciroh_portal" {
  source = "../modules/ciroh_portal"
  # Input Varibles
  region              = "us-east-1"
  profile             = "456531024327"
  cluster_name        = "ciroh-portal-dev"
  app_name            = "cirohportal"
  helm_chart          = "ciroh"
  helm_repo           = "https://alabamawaterinstitute.github.io/tethysportal-ciroh"
  helm_values_file    = "../../charts/ciroh/ci/dev_aws_values.yaml"
  environment         = "dev"
  use_elastic_ips  = false
  single_nat_gate_way = true
  eips = ["eipalloc-00e2c8d0238d62783","eipalloc-0f705f3b233b1d294"]
}
