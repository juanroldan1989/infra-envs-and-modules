resource "helm_release" "hello" {
  name = "hello"

  repository = "https://helm.github.io/examples"
  chart      = "hello-world"
  namespace  = "hello-ns"
  # values = [file("${path.module}/values/custom.yaml")]

  set {
    name  = "awsRegion"
    value = "us-east-1"
  }
}
