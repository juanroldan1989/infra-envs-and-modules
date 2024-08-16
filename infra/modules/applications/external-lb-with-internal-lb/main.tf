# EXTERNAL LOAD BALANCER (INGRESS)
# WITH INTERNAL LOAD BALANCER (SERVICE)

# Related Docs
# Explanation on EC2 instances (in private AZ)
# being accessed by Load Balancer (in public AZ)

resource "kubernetes_namespace" "hello" {
  metadata {
    name = "hello-ns"
  }
}

resource "kubernetes_deployment" "hello" {
  metadata {
    name      = "hello"
    namespace = "hello-ns"
    labels = {
      App = "hello"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "hello"
      }
    }
    template {
      metadata {
        labels = {
          App = "hello"
        }
      }
      spec {
        container {
          image = "nginx:1.14.2" # TODO: also try with echoserver instead
          name  = "hello"

          port {
            container_port = 80
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

resource "kubernetes_service" "hello" {
  metadata {
    name      = "hello-service"
    namespace = "hello-ns"
    annotations = {
      # Try with this config OFF -> # "service.beta.kubernetes.io/aws-load-balancer-type"             = "nlb-ip" # https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/guide/service/annotations/#lb-type
      "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type"  = "ip"
      "service.beta.kubernetes.io/aws-load-balancer-scheme"           = "internal" # load balancer created in private subnets
      "service.beta.kubernetes.io/aws-load-balancer-healthcheck-path" = "/health"
    }
  }

  spec {
    selector = {
      App = kubernetes_deployment.hello.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP" # for annotations to work this has to be LoadBalancer
  }
}

resource "kubernetes_ingress_v1" "hello_ingress" {
  metadata {
    name      = "hello-ingress"
    namespace = "hello-ns" # MUST mutch namespace for service, otherwise we get "Backend service does not exist" error
    annotations = {
      "alb.ingress.kubernetes.io/scheme"           = "internet-facing" # load balancer created in public subnets
      "alb.ingress.kubernetes.io/target-type"      = "ip"
      "alb.ingress.kubernetes.io/healthcheck-path" = "/health"
    }
  }

  spec {
    ingress_class_name = "alb"

    default_backend {
      service {
        name = kubernetes_service.hello.metadata.0.name
        port {
          number = kubernetes_service.hello.spec.0.port.0.port
        }
      }
    }

    rule {
      http {
        path {
          backend {
            service {
              name = kubernetes_service.hello.metadata.0.name
              port {
                number = kubernetes_service.hello.spec.0.port.0.port
              }
            }
          }
          path      = "/hello"
          path_type = "Prefix"
        }
      }
    }
  }
}

