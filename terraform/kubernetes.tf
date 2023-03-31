resource "kubernetes_namespace" "tethysportal" {
  metadata {
    name = var.app_name
  }
}

# resource "kubernetes_deployment" "tethysportal" {
#   metadata {
#     name      = var.app_name
#     namespace = kubernetes_namespace.tethysportal.id
#     labels = {
#       app = var.app_name
#     }
#   }

#   spec {
#     replicas = 3
#     selector {
#       match_labels = {
#         app = var.app_name
#       }
#     }
#     template {
#       metadata {
#         labels = {
#           app = var.app_name
#         }
#       }
#       spec {
#         container {
#           image = "awiciroh/tethysapp-ciroh"
#           name  = var.app_name
#         }
#       }
#     }
#   }
# }

# resource "kubernetes_service" "tethysportal" {
#   metadata {
#     name      = var.app_name
#     namespace = kubernetes_namespace.tethysportal.id
#   }
#   spec {
#     selector = {
#       app = kubernetes_deployment.tethysportal.metadata[0].labels.app
#     }
#     port {
#       port        = 8080
#       target_port = 80
#     }
#     type = "LoadBalancer"
#   }
# }
