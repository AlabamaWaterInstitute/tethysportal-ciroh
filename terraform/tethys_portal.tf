# resource "helm_release" "tethysportal_helm_release" {
#   name              = "${var.app_name}-${var.environment}"
#   chart             = var.helm_chart
#   repository        = var.helm_repo
#   namespace         = var.app_name
#   timeout           = 900
#   dependency_update = true
#   values = [
#     file(var.helm_values_file)
#   ]

#   set {
#     name  = "storageClass.parameters.fileSystemId"
#     value = aws_efs_file_system.efs.id
#   }

#   # Should we make the subnets autodiscoverable with tags: 
#   # https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.5/deploy/subnet_discovery/
#   set {
#     name  = "ingresses.external.annotations.alb\\.ingress\\.kubernetes\\.io/subnets"
#     value = join("\\,", module.vpc.public_subnets)
#   }
#   set {
#     name = "ingresses.internal.annotations.alb\\.ingress\\.kubernetes\\.io/subnets"
#     # value = jsonencode(module.vpc.public_subnets)
#     value = join("\\,", module.vpc.public_subnets)
#   }
# }
