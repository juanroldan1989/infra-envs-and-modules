# infra-envs-and-modules

## Project structure (resumed)

```ruby
├── infra
│   ├── envs
│   │   ├── dev
│   │   │   ...
│   │   │   ├── eks
│   │   │   │   ├── data.tf
│   │   │   │   ├── main.tf
│   │   │   │   ├── outputs.tf
│   │   │   │   └── .terraform.lock.hcl
│   │   │   ├── loadbalancer
│   │   │   │   ├── data.tf
│   │   │   │   ├── main.tf
│   │   │   │   └── .terraform.lock.hcl
│   │   │   └── networking
│   │   │       ├── main.tf
│   │   │       ├── outputs.tf
│   │   │       └── .terraform.lock.hcl
│   │   │   ...
│   │   └── prod
│   │       └── networking
│   │           └── main.tf
│   └── modules
│       ...
│       │  
│       ├── applications
│       │   ├── app-a
│       │   │   ├── README.md
│       │   │   └── main.tf
│       │   ├── app-b
│       │   │   ├── README.md
│       │   │   ├── main.tf
│       │   │   ├── outputs.tf
│       │   │   └── variables.tf
│       │   └── app-c
│       │       ├── README.md
│       │       ├── main.tf
│       │       └── variables.tf
│       ├── eks
│       │   ├── main.tf
│       │   ├── outputs.tf
│       │   └── variables.tf
│       ├── loadbalancer
│       │   ├── iam
│       │   │   └── AWSLoadBalancerController.json
│       │   ├── main.tf
│       │   └── variables.tf
│       ├── networking
│       │   ├── main.tf
│       │   ├── outputs.tf
│       │   ├── providers.tf
│       │   └── variables.tf
│       ...
```

The above structure allows engineers to:

1. Work on specific environments they are allowed to.
2. Each envs folder (`dev`, `prod`, etc) is associated with a specific `Terraform` workspace.
3. Add/Remove modules as they need in order to build their applications within their environments.
4. Deploy specific applications/modules (e.g.: `networking`, `addons`, `argocd-app-1`) within their specific environments.

Script below provisions `VPC`, spins up `EKS Cluster`, adds `networking`, `addons` and deploys `app-b` for showcasing purposes:

```ruby
$ cd infra/envs/dev

$ ./tf.sh apply
```

Same script can be used to remove infrastructure and apps:

```ruby
$ cd infra/envs/dev

$ ./tf.sh destroy
```

## EKS Cluster

Check user currently used to make calls via CLI:

```ruby
$ aws sts get-caller-identity
```

Update local kube config to connect with EKS Cluster in AWS:

```ruby
$ aws eks update-kubeconfig \
 --name sample-app-dev-sample-eks \
 --region us-east-1
```

Check for access:

```ruby
$ kubectl get nodes
```

## Argo CD Server

In order to access the server UI you have the following options:

1. `kubectl port-forward service/argocd-server -n argocd 8080:443`

and then open the browser on `http://localhost:8080` and accept the certificate

2. Enable ingress in the values file `server.ingress.enabled` and either

- Add the annotation for ssl passthrough:
  https://github.com/argoproj/argo-cd/blob/master/docs/operator-manual/ingress.md#option-1-ssl-passthrough

- Add the `--insecure` flag to `server.extraArgs` in the values file and terminate SSL at your ingress:
  https://github.com/argoproj/argo-cd/blob/master/docs/operator-manual/ingress.md#option-2-multiple-ingress-objects-and-hosts

After reaching the UI the first time you can login with `username: admin` and the `random password` generated during the installation. You can find the password by running:

```ruby
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# or using jq

kubectl -n argocd get secret argocd-initial-admin-secret -o json | jq .data.password -r | base64 -d
```

(You should delete the initial secret afterwards as suggested by the Getting Started Guide: https://github.com/argoproj/argo-cd/blob/master/docs/getting_started.md#4-login-using-the-cli)

3. (only for testing purposes) Adjust `argocd` helm configuration to place `LoadBalancer` within a `public subnet` to be reached through internet:

```ruby
resource "helm_release" "argocd" {
  depends_on = [var.eks_node_group_general]
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "4.5.2"

  namespace = "argocd"

  create_namespace = true

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "server.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "external"
  }

  set {
    name  = "server.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
    value = "internet-facing"
  }
}
```

### References

https://spacelift.io/blog/argocd-terraform

Terraform with GitOps: https://spacelift.io/blog/terraform-gitops

## Github Actions - Automation

1. Watch for changes within `dev` environment.
2. Watch for changes within `prod` environment.
3. Setup remote state and associate `dev` folder with `dev` workspace in Terraform.

## Monitoring

Integrate Graphana and Kibana

## Logs

## Backend `remote` implementation

### Setup S3 state storage

https://spacelift.io/blog/terraform-remote-state#benefits-of-using-terraform-remote-state

### Modules

- Have 1 sample application imported from a Github repo instead of a folder within `modules` folder.

## Tagging

All resources should be tagged properly:

```ruby
...

tags = {
  Name = "${var.app_name}-${var.env}-<resource-name>"
}
```

Example:

```
"payment-app-staging-ingress"
"frontend-app-production-vpc"
```
