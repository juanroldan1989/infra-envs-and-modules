module "roles" {
  source = "../../../modules/roles"

  eks_name = data.terraform_remote_state.eks.outputs.eks_name
}
