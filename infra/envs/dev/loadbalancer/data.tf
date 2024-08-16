data "terraform_remote_state" "eks" {
  backend = "local"
  config = {
    path = "../eks/terraform.tfstate"
  }
}

data "terraform_remote_state" "autoscaler" {
  backend = "local"
  config = {
    path = "../autoscaler/terraform.tfstate"
  }
}
