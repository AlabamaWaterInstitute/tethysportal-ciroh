# Tethys portal 
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
  depends_on = [kubernetes_annotations.default-storageclass, helm_release.ingress]
}


# data "aws_eip" "nlb" {
#   # The following for_each line: https://discuss.hashicorp.com/t/the-for-each-value-depends-on-resource-attributes-that-cannot-be-determined-until-apply/25016/4
#   for_each   = { for i, val in module.vpc.nat_public_ips : i => val }
#   public_ip  = each.value
#   depends_on = [helm_release.tethysportal_helm_release, module.vpc]
# }
# output "aws_eip" {
#   #   value = data.aws_eip.nlb.public_ip
#   value = { for k, v in data.aws_eip.nlb : k => v.public_ip }
# }

# resource "time_sleep" "wait_15_seconds" {
#   create_duration = "15s"
#   depends_on      = [helm_release.tethysportal_helm_release]
# }

# # It is a must in order to have the load balancer type application that the ALB AWS creates when the chart is deployed
# #https://discuss.hashicorp.com/t/how-to-extract-the-arn-of-a-aws-lb-using-a-tag-that-has-in-it/45277/4
# data "aws_lb" "alb_listener_details" {
#   tags = {
#     #for some reason the cluster name does not work
#     # "elbv2.k8.aws/cluster"     = module.eks.cluster_name
#     "ingress.k8s.aws/resource" = "LoadBalancer"
#     "ingress.k8s.aws/stack"    = "${var.app_name}/${var.app_name}-${var.environment}"
#   }
#   ## First the helm chart of the portal needs to be deployed
#   # For some reason we need some sleeping time for the data tag to get the aws_lb created by the helm realease
#   # more details here https://github.com/hashicorp/terraform-provider-aws/issues/20489#issuecomment-1578428056
#   depends_on = [helm_release.tethysportal_helm_release]

# }
# if the above does not work the following below can work:
# More info here: https://github.com/hashicorp/terraform-provider-aws/issues/12265#issuecomment-833361834



# # Create NLB
# resource "aws_lb" "nlb" {
#   name               = "${var.app_name}-${var.environment}-nlb"
#   internal           = false
#   load_balancer_type = "network"


#   dynamic "subnet_mapping" {
#     for_each = [for i in range(length(module.vpc.public_subnets)) : {
#       subnet_id = module.vpc.public_subnets[i]
#       # allocation_id = data.aws_eip.nlb[i].id
#       allocation_id = aws_eip.nat[i].id

#     }]
#     content {
#       subnet_id     = subnet_mapping.value.subnet_id
#       allocation_id = subnet_mapping.value.allocation_id
#     }
#   }

#   depends_on = [helm_release.tethysportal_helm_release]

# }

# # Create NLB target group that forwards traffic to alb
# # https://docs.aws.amazon.com/elasticloadbalancing/latest/APIReference/API_CreateTargetGroup.html
# resource "aws_lb_target_group" "nlb_tg" {
#   name        = "${var.app_name}-${var.environment}-alb"
#   port        = 80
#   protocol    = "TCP"
#   vpc_id      = module.vpc.vpc_id
#   target_type = "alb"
#   depends_on  = [helm_release.tethysportal_helm_release]
#   health_check {
#     timeout             = "10"
#     interval            = "20"
#     path                = "/"
#     unhealthy_threshold = "2"
#     healthy_threshold   = "3"
#   }
# }

# # Create target group attachment
# # More details: https://docs.aws.amazon.com/elasticloadbalancing/latest/APIReference/API_TargetDescription.html
# # https://docs.aws.amazon.com/elasticloadbalancing/latest/APIReference/API_RegisterTargets.html
# resource "aws_lb_target_group_attachment" "tg_attachment" {
#   target_group_arn = aws_lb_target_group.nlb_tg.arn
#   # attach the ALB to this target group
#   target_id = data.aws_lb.alb_listener_details.arn
#   #   target_id = data.aws_resourcegroupstaggingapi_resources.load_balancer.resource_tag_mapping_list[0].resource_arn
#   #  If the target type is alb, the targeted Application Load Balancer must have at least one listener whose port matches the target group port.
#   port       = 80
#   depends_on = [helm_release.tethysportal_helm_release]

# }



# # Listener rule for HTTP traffic on each of the ALBs
# # It might help:https://medium.com/@sampark02/application-load-balancer-and-target-group-attachment-using-terraform-d212ce8a38a0
# resource "aws_lb_listener" "nlb" {
#   load_balancer_arn = aws_lb.nlb.arn
#   port              = "80"
#   protocol          = "TCP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.nlb_tg.arn
#   }
#   depends_on = [helm_release.tethysportal_helm_release]
# }
