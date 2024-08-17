module "app-a" {
  source = "../../../modules/applications/external-lb-with-cluster-ip-service"

  eks_name = data.terraform_remote_state.eks.outputs.eks_name
}
