data "aws_eks_cluster" "default" {
  name = var.eks_name
}

data "aws_eks_cluster_auth" "default" {
  name = var.eks_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.default.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.default.token

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.default.id]
    command     = "aws"
  }
}

resource "kubernetes_namespace" "second" {
  metadata {
    name = "second-ns"
  }
}

resource "kubernetes_deployment" "second" {
  metadata {
    name      = "second"
    namespace = "second-ns"
    labels = {
      App = "second"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "second"
      }
    }
    template {
      metadata {
        labels = {
          App = "second"
        }
      }
      spec {
        container {
          image = "k8s.gcr.io/e2e-test-images/echoserver:2.5"
          name  = "second"

          port {
            container_port = 8080
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "second" {
  metadata {
    name      = "second-service"
    namespace = "second-ns"
  }

  spec {
    selector = {
      App = kubernetes_deployment.second.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 8080
      target_port = 8080
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "second_ingress" {
  wait_for_load_balancer = true

  metadata {
    name      = "second-ingress"
    namespace = "second-ns"
    annotations = {
      "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"      = "ip"
      "alb.ingress.kubernetes.io/healthcheck-path" = "/health"
    }
  }

  spec {
    ingress_class_name = "alb"

    default_backend {
      service {
        name = kubernetes_service.second.metadata.0.name
        port {
          number = kubernetes_service.second.spec.0.port.0.port
        }
      }
    }

    rule {
      http {
        path {
          backend {
            service {
              name = kubernetes_service.second.metadata.0.name
              port {
                number = kubernetes_service.second.spec.0.port.0.port
              }
            }
          }
          path      = "/second"
          path_type = "Prefix"
        }
      }
    }
  }
}
