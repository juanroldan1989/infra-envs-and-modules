output "load_balancer_dns_name" {
  value = kubernetes_ingress_v1.second_ingress.status.0.load_balancer.0.ingress.0.hostname
}
