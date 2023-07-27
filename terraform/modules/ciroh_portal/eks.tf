module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.5.1"

  cluster_name    = var.cluster_name
  cluster_version = "1.24"

  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true
  # Shown just for connection between cluster and Karpenter sub-module below
  manage_aws_auth_configmap = true
  aws_auth_roles = [
    # We need to add in the Karpenter node IAM role for nodes launched by Karpenter
    {
      rolearn  = module.karpenter.role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = [
        "system:bootstrappers",
        "system:nodes",
      ]
    },
  ]
  eks_managed_node_group_defaults = {
    ami_type                   = "AL2_x86_64"
    iam_role_attach_cni_policy = true
    iam_role_additional_policies = {
      eks_node_efs = resource.aws_iam_policy.node_efs_policy.arn
    }
  }

  eks_managed_node_groups = {
    tethys-core = {
      name           = "tethys-core-group"
      instance_types = ["c5.xlarge"]
      desired_size   = 3
      min_size       = 3
      max_size       = 4
      # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
      # so we need to disable it to use the default template provided by the AWS EKS managed node group service
      use_custom_launch_template = false
      disk_size                  = 50

    }


  }

  tags = {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = var.cluster_name
  }
}
resource "aws_iam_policy" "node_efs_policy" {
  name        = "eks_node_efs-${var.app_name}-${var.environment}"
  path        = "/"
  description = "Policy for EFKS nodes to use EFS"

  policy = jsonencode({
    "Statement" : [
      {
        "Action" : [
          "elasticfilesystem:DescribeMountTargets",
          "elasticfilesystem:DescribeFileSystems",
          "elasticfilesystem:DescribeAccessPoints",
          "elasticfilesystem:CreateAccessPoint",
          "elasticfilesystem:DeleteAccessPoint",
          "ec2:DescribeAvailabilityZones"
        ],
        "Effect" : "Allow",
        "Resource" : "*",
        "Sid" : ""
      }
    ],
    "Version" : "2012-10-17"
    }
  )
}
