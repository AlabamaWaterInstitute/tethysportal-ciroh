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
}

# data "aws_subnet_ids" "public" {
#   vpc_id = data.aws_vpc.selected.id
# }

resource "aws_eip" "nlb" {
  count = length(module.vpc.public_subnets)
  vpc   = true
}
resource "time_sleep" "wait_15_seconds" {
  create_duration = "15s"
  depends_on      = [helm_release.tethysportal_helm_release]
}

# It is a must in order to have the load balancer type application that the ALB AWS creates when the chart is deployed
#https://discuss.hashicorp.com/t/how-to-extract-the-arn-of-a-aws-lb-using-a-tag-that-has-in-it/45277/4
data "aws_lb" "alb_listener_details" {
  name = "k8s-cirohpor-cirohpor-3c71a8d9df"
  tags = {
    #for some reason the cluster name does not work
    # "elbv2.k8.aws/cluster"     = module.eks.cluster_name
    "ingress.k8s.aws/resource" = "LoadBalancer"
    "ingress.k8s.aws/stack"    = "${var.app_name}/${var.app_name}-${var.environment}"
  }
  ## First the helm chart of the portal needs to be deployed
  # For some reason we need some sleeping time for the data tag to get the aws_lb created by the helm realease
  # more details here https://github.com/hashicorp/terraform-provider-aws/issues/20489#issuecomment-1578428056
  depends_on = [
    helm_release.tethysportal_helm_release,
    time_sleep.wait_15_seconds
  ]

}
# if the above does not work the following below can work:
# More info here: https://github.com/hashicorp/terraform-provider-aws/issues/12265#issuecomment-833361834
# data "aws_resourcegroupstaggingapi_resources" "load_balancer" {

#   resource_type_filters = ["elasticloadbalancing:loadbalancer"]

#   #for some reason the cluster name does not work
#   #   tag_filter {
#   #     key    = "elbv2.k8.aws/cluster"
#   #     values = ["${var.cluster_name}"]
#   #   }

#   tag_filter {
#     key    = "ingress.k8s.aws/resource"
#     values = ["LoadBalancer"]
#   }
#   tag_filter {
#     key    = "ingress.k8s.aws/stack"
#     values = ["${var.app_name}/${var.app_name}-${var.environment}"]
#   }
#   depends_on = [
#     helm_release.tethysportal_helm_release,
#     time_sleep.wait_15_seconds
#   ]
# }


# Create ALB target group
# resource "aws_lb_target_group" "alb_tg" {
#   name       = "${var.app_name}-${var.environment}-alb"
#   port       = 80
#   protocol   = "HTTP"
#   vpc_id     = module.vpc.vpc_id
#   depends_on = [helm_release.tethysportal_helm_release, time_sleep.wait_15_seconds]


# }

# Create NLB
resource "aws_lb" "nlb" {
  name               = "${var.app_name}-${var.environment}-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = module.vpc.public_subnets
  subnet_mapping {
    subnet_id     = module.vpc.private_subnets[0]
    allocation_id = aws_eip.nlb[0].id
  }

  subnet_mapping {
    subnet_id     = module.vpc.private_subnets[1]
    allocation_id = aws_eip.nlb[1].id
  }

  depends_on = [helm_release.tethysportal_helm_release, time_sleep.wait_15_seconds
  ]

}

# Create NLB target group that forwards traffic to alb
# https://docs.aws.amazon.com/elasticloadbalancing/latest/APIReference/API_CreateTargetGroup.html
resource "aws_lb_target_group" "nlb_tg" {
  name        = "${var.app_name}-${var.environment}-alb"
  port        = 80
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
  target_type = "alb"
  depends_on = [helm_release.tethysportal_helm_release, time_sleep.wait_15_seconds
  ]
  health_check {
    timeout             = "10"
    interval            = "20"
    path                = "/"
    unhealthy_threshold = "2"
    healthy_threshold   = "3"
  }
}

# Create target group attachment
# More details: https://docs.aws.amazon.com/elasticloadbalancing/latest/APIReference/API_TargetDescription.html
# https://docs.aws.amazon.com/elasticloadbalancing/latest/APIReference/API_RegisterTargets.html
resource "aws_lb_target_group_attachment" "tg_attachment" {
  target_group_arn = aws_lb_target_group.nlb_tg.arn
  # attach the ALB to this target group
  target_id = data.aws_lb.alb_listener_details.arn
  #   target_id = data.aws_resourcegroupstaggingapi_resources.load_balancer.resource_tag_mapping_list[0].resource_arn
  #  If the target type is alb, the targeted Application Load Balancer must have at least one listener whose port matches the target group port.
  port       = 80
  depends_on = [helm_release.tethysportal_helm_release, time_sleep.wait_15_seconds]

}



# Listener rule for HTTP traffic on each of the ALBs
# It might help:https://medium.com/@sampark02/application-load-balancer-and-target-group-attachment-using-terraform-d212ce8a38a0
resource "aws_lb_listener" "nlb" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_tg.arn
  }
}
