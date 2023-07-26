# 1- Create EFS that Pods of the cluster will use
resource "aws_efs_file_system" "efs" {
  creation_token   = "${var.app_name}-data-efs"
  performance_mode = "generalPurpose"

  lifecycle_policy {
    transition_to_ia = "AFTER_60_DAYS"
  }

}

# 2- Set security groups for EFS
resource "aws_security_group" "efs" {
  name        = "${var.app_name}-efs-sg"
  description = "Allow inbound efs traffic from Kubernetes Subnet"
  vpc_id      = module.vpc.vpc_id

  ingress {
    cidr_blocks = [module.vpc.vpc_cidr_block]
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
  }
  egress {
    cidr_blocks = [module.vpc.vpc_cidr_block]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  # depends_on = [
  #   module.vpc
  # ]
}

# 3- Set EFS mount target
resource "aws_efs_mount_target" "mount" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = module.vpc.private_subnets[0]
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "mount1" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = module.vpc.private_subnets[1]
  security_groups = [aws_security_group.efs.id]
}

module "attach_efs_csi_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "efs-csi-${var.environment}"
  attach_efs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }
}

# 4- Set aws_efs_csi_driver
resource "helm_release" "aws_efs_csi_driver" {
  chart      = "aws-efs-csi-driver"
  name       = "aws-efs-csi-driver"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"

  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.eu-west-3.amazonaws.com/eks/aws-efs-csi-driver"
  }

  set {
    name  = "controller.serviceAccount.create"
    value = true
  }

  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.attach_efs_csi_role.iam_role_arn
  }

  set {
    name  = "controller.serviceAccount.name"
    value = "efs-csi-controller-sa"
  }
}
