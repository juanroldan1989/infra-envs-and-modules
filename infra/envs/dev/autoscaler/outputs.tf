output "cluster_autoscaler" {
  value     = module.autoscaler.cluster_autoscaler
  sensitive = true
}
