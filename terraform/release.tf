## Commenting out this file has the same effect as targeting module.eks (see READMED.md)

# data "aws_eks_cluster" "cluster" {
#   name = module.eks.cluster_name
# }

# data "aws_eks_cluster_auth" "cluster" {
#   name = module.eks.cluster_name
# }

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }

}

# provider "kubernetes" {
#   host                   = module.eks.cluster_endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
#   token                  = data.aws_eks_cluster_auth.cluster.token
# }

# provider "helm" {
#   kubernetes {
#     host                   = module.eks.cluster_endpoint
#     cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
#     token                  = data.aws_eks_cluster_auth.cluster.token
#   }

# }

resource "kubernetes_namespace" "tethysportal" {
  for_each = toset([var.app_name])
  metadata {
    name = each.key
  }
  provisioner "local-exec" {
    when    = destroy
    command = "nohup ${path.module}/scripts/namespace-finalizer.sh ${each.key} 2>&1 &"
  }
}

# resource "kubernetes_namespace" "tethysportal" {
#   metadata {
#     name = var.app_name
#   }
#   provisioner "local-exec" {
#     when    = destroy
#     command = "nohup scripts/namespace-finalizer.sh ${var.app_name} 2>&1 &"
#   }
# }

# resource "kubernetes_namespace" "tethysportal" {
#   metadata {
#     name = var.app_name
#   }
# }


resource "helm_release" "tethysportal_helm_release" {
  name              = "${var.app_name}-${var.environment}"
  chart             = var.helm_chart
  repository        = var.helm_repo
  namespace         = var.app_name
  timeout           = 900
  dependency_update = true
  values = [
    file(var.helm_values_file)
  ]

  set {
    name  = "storageClass.parameters.fileSystemId"
    value = aws_efs_file_system.efs.id
  }

  # Should we make the subnets autodiscoverable with tags: 
  # https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.5/deploy/subnet_discovery/
  set {
    name  = "ingresses.external.annotations.alb\\.ingress\\.kubernetes\\.io/subnets"
    value = join("\\,", module.vpc.public_subnets)
  }
  set {
    name = "ingresses.internal.annotations.alb\\.ingress\\.kubernetes\\.io/subnets"
    # value = jsonencode(module.vpc.public_subnets)
    value = join("\\,", module.vpc.public_subnets)
  }
}

resource "aws_iam_policy" "worker_policy" {
  name        = "worker-policy-${var.environment}"
  description = "Worker policy for the ALB Ingress"

  policy = file("iam-policy.json")
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = module.eks.eks_managed_node_groups

  policy_arn = aws_iam_policy.worker_policy.arn
  role       = each.value.iam_role_name
}

resource "helm_release" "ingress" {
  name       = "ingress-${var.environment}"
  chart      = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  namespace  = var.app_name
  version    = "1.4.6"

  set {
    name  = "autoDiscoverAwsRegion"
    value = "true"
  }
  set {
    name  = "autoDiscoverAwsVpcID"
    value = "true"
  }
  set {
    name  = "clusterName"
    value = var.cluster_name
  }
}

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