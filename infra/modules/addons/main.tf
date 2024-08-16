data "aws_eks_cluster" "eks" {
  name = var.eks_name
}

data "aws_eks_cluster_auth" "eks" {
  name = var.eks_name
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

resource "helm_release" "metrics_server" {
  name = "metrics-server"

  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.12.1"

  values = [file("${path.module}/values/metrics-server.yaml")]

  depends_on = [var.eks_node_group_general]
}

resource "aws_eks_addon" "pod_identity" {
  cluster_name  = var.eks_name
  addon_name    = "eks-pod-identity-agent"
  addon_version = "v1.2.0-eksbuild.1"
}
