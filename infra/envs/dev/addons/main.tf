module "addons" {
  source = "../../../modules/addons"

  eks_name               = data.terraform_remote_state.eks.outputs.eks_name
  eks_node_group_general = data.terraform_remote_state.eks.outputs.eks_node_group_general
}
