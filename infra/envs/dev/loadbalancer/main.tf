module "loadbalancer" {
  source = "../../../modules/loadbalancer"

  eks_name           = data.terraform_remote_state.eks.outputs.eks_name
  cluster_autoscaler = data.terraform_remote_state.autoscaler.outputs.cluster_autoscaler
}
