module "eks" {
  source = "../../../modules/eks"

  private_zone1 = data.terraform_remote_state.networking.outputs.private_zone1
  private_zone2 = data.terraform_remote_state.networking.outputs.private_zone2
}
