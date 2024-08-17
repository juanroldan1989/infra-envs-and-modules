output "app-a-endpoint" {
  value = module.app-a.load_balancer_dns_name
}
