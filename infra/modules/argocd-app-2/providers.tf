# https://registry.terraform.io/providers/jojand/argocd/latest/docs
terraform {
  required_version = ">= 1.0"

  required_providers {
    argocd = {
      source  = "jojand/argocd"
      version = "~> 2.3.2"
    }
  }
}

provider "argocd" {
  server_addr = "localhost:8888" # kubectl port-forward service/argocd-server -n argocd 8888:443
  # username = (value set within env variable ARGOCD_AUTH_USERNAME)
  # password = (value set within env variable ARGOCD_AUTH_PASSWORD)
  # insecure = (value set within env variable ARGOCD_INSECURE)
  #            For testing purposes. Avoids "x509: certificate signed by unknown authority" error.
}
