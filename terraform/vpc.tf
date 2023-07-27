data "aws_availability_zones" "available" {}

# Creation of the different Elastic IPs 
resource "aws_eip" "nat" {
  count = 2

  vpc = true
}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  # name = "${var.app_name}-ciroh-vpc"
  name = "${var.app_name}-${var.environment}-vpc"

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 2)

  private_subnets = ["10.0.1.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.2.0/24", "10.0.4.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true
  # if using existing elastic ip is needed:
  #https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest#external-nat-gateway-ips
  # reuse_nat_ips       = true             # <= Skip creation of EIPs for the NAT Gateways
  # external_nat_ip_ids = aws_eip.nat.*.id # <= IPs specified here as input to the module

  public_subnet_tags = {
    #https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.5/deploy/subnet_discovery/
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    #https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.5/deploy/subnet_discovery/
    "kubernetes.io/role/internal-elb" = 1
    # Tags subnets for Karpenter auto-discovery
    "karpenter.sh/discovery" = var.cluster_name
  }

}
