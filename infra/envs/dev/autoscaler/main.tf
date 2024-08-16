module "autoscaler" {
  source = "../../../modules/autoscaler"

  eks_name       = data.terraform_remote_state.eks.outputs.eks_name
  metrics_server = data.terraform_remote_state.addons.outputs.metrics_server
}
