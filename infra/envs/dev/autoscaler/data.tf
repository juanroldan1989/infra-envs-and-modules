data "terraform_remote_state" "addons" {
  backend = "local"
  config = {
    path = "../addons/terraform.tfstate"
  }
}

data "terraform_remote_state" "eks" {
  backend = "local"
  config = {
    path = "../eks/terraform.tfstate"
  }
}
