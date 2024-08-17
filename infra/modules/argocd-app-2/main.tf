# ArgoCD application created through Terraform resource

# https://registry.terraform.io/providers/jojand/argocd/latest/docs/resources/application
resource "argocd_application" "k8s-service-app" {
  metadata {
    name      = "k8s-service-app"
    namespace = "argocd"
  }

  spec {
    project = "default"

    source {
      repo_url        = "https://github.com/juanroldan1989/infra-envs-and-modules"
      path            = "infra/modules/applications/k8s-service-app"
      target_revision = "HEAD"
    }

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "service-app"
    }

    sync_policy {
      automated = {
        prune     = true
        self_heal = true
      }

      sync_options = ["Validate=false", "CreateNamespace=true"]
    }
  }
}
