resource "helm_release" "tethysportal_helm_release" {
  name       = "tethysportal-release"
  chart      = "./ciroh-0.1.0.tgz"
  namespace  = var.app_name
  timeout    = 900

  values = [
    file("${path.module}/tethysportal-values.yaml")
  ]
}

resource "helm_release" "ingress" {
  name       = "ingress"
  chart      = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
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
