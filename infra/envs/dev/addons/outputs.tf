output "metrics_server" {
  value     = module.addons.metrics_server
  sensitive = true
}
