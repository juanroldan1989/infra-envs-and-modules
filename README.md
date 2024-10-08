<img src="https://github.com/juanroldan1989/terra-ops/blob/main/terra-ops-logo.png" alt="juanroldan1989 terra-ops">

<h4 align="center">Folders Structure | Multiple environments | Infrastructure by Terraform </h4>

<p align="center">
  <a href="https://github.com/juanroldan1989/terra-ops/commits/main">
  <img src="https://img.shields.io/github/last-commit/juanroldan1989/terra-ops.svg?style=flat-square&logo=github&logoColor=white" alt="GitHub last commit">
  <a href="https://github.com/juanroldan1989/terra-ops/issues">
  <img src="https://img.shields.io/github/issues-raw/juanroldan1989/terra-ops.svg?style=flat-square&logo=github&logoColor=white" alt="GitHub issues">
  <a href="https://github.com/juanroldan1989/terra-ops/pulls">
  <img src="https://img.shields.io/github/issues-pr-raw/juanroldan1989/terra-ops.svg?style=flat-square&logo=github&logoColor=white" alt="GitHub pull requests">
  <a href="https://github.com/juanroldan1989/terra-ops/blob/main/LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-brightgreen.svg">
  </a>
</p>

<p align="center">
  <a href="#terra-ops">Terra Ops</a> •
  <a href="#project-structure-resumed">Project Structure</a> •
  <a href="#terraform">Terraform</a> •
  <a href="#configuration-details">Configuration Details</a> •
  <a href="#github-actions">Github Actions</a> •
  <a href="#references">References</a> •
  <a href="#contribute">Contribute</a>
</p>

# Terra Ops

This project structure allows engineers to:

1. Work on **specific** environments they are allowed to.
2. **Add/Remove** modules as they need in order to build their applications within their environments.
3. Deploy specific applications/modules (e.g.: **networking**, **addons**, **argocd-app-1**) within their specific environments.

Each envs folder (**dev**, **prod**, etc) is associated with a specific Terraform **workspace**.

# Project structure (resumed)

```ruby
├── infra
│   ├── envs
│   │   ├── dev
│   │   │   ...
│   │   │   ├── app-a
│   │   │   │   ├── data.tf
│   │   │   │   ├── main.tf
│   │   │   │   ├── outputs.tf
│   │   │   │   └── .terraform.lock.hcl
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

# How it works

1. Repository is cloned within local machine.
2. Terraform workspace is setup within a specific local environment folder, e.g.: **dev**, **feature-7890**.
3. Engineer adds modules/apps as neededd within that folder and pushes changes to repo.
4. Github Actions pipeline triggers validations and Terraform provisioning/deployment based on changes pushed.

# Provisioning script

**tf.sh** script is available on each `environment` to facilitate quick validations, tests and can be customized by engineers as needed.

Script by default provides below capabilities:

- Provisioning `VPC`, `Subnets` and `EKS Cluster`.
- Application deployment through Kubernetes `Ingress`, `Service` and `Deployment` resources.

## Provisioning infrastructure within `DEV` environment

```ruby
$ cd infra/envs/dev

$ ./tf.sh apply
```

## Removing infrastructure within `DEV` environment

Same script can be used to remove infrastructure and any apps within specific environment:

```ruby
$ cd infra/envs/dev

$ ./tf.sh destroy
```

# Ready-to-use modules included in repo

## AWS VPC, Networking and LoadBalancer

- Located at: `infra/modules/networking`
- Located at: `infra/modules/loadbalancer`

## Helm Standard App provisioner

Located at: `infra/modules/applications/app-helm-installer-example`

```ruby
resource "helm_release" "hello" {
  name = "hello"

  repository = "https://helm.github.io/examples"
  chart      = "hello-world"
  namespace  = "hello-ns"
  values = [file("${path.module}/values/custom.yaml")]

  set {
    name  = "awsRegion"
    value = "us-east-1"
  }
}
```

## EKS Cluster

Located at: `infra/modules/eks`

```ruby
resource "aws_eks_cluster" "eks" {
  name     = "${var.app_name}-${var.env}-${var.eks_name}"
  version  = var.eks_version
  role_arn = aws_iam_role.eks.arn

  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true

    subnet_ids = [
      var.private_zone1,
      var.private_zone2
    ]
  }

...
```

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

## K8S Health Metrics Server

Located at: `infra/addons/main.tf`

```ruby
resource "helm_release" "metrics_server" {
  name = "metrics-server"

  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.12.1"

  values = [file("${path.module}/values/metrics-server.yaml")]

  depends_on = [var.eks_node_group_general]
}
```

## K8S Ingress + Service + Deployment resources

Located at: `infra/modules/external-lb-with-cluster-ip-service`

```ruby
...

resource "kubernetes_deployment" "second" {
  metadata {
    name      = "second"
    namespace = "second-ns"
    labels = {
      App = "second"
    }
  }

  spec {
    replicas = 2
    ...

resource "kubernetes_service" "second" {
  metadata {
    name      = "second-service"
    namespace = "second-ns"
  }

  spec {
    selector = {
...

resource "kubernetes_ingress_v1" "second_ingress" {
  wait_for_load_balancer = true

  metadata {
    name      = "second-ingress"
    namespace = "second-ns"
    annotations = {
      "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"      = "ip"
      "alb.ingress.kubernetes.io/healthcheck-path" = "/health"
    }
  }

  spec {
    ingress_class_name = "alb"
...
```

# Terraform workspaces

Useful CLI commands:
https://developer.hashicorp.com/terraform/cli/workspaces

# Configuration details

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

# or when attribute to extract data from contains a "." in its name -> "tls.crt"
# Eg.: extracting certificate key from sealed-secrets-124234 secret after installing `kubeseal` CLI

kubectl get secrets sealed-secrets-keyr4vzg -n kube-system -o json | jq .data'."tls.crt"' -r | base64 -d
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

# Github Actions

1. Watches for changes within `dev` environment/folder and triggers provisioning/deployment.
2. Watches for changes within `prod` environment/folder and triggers provisioning/deployment.
3. [WIP] Configs remote state and associate `dev` folder with `dev` workspace in Terraform.

# Monitoring

[WIP] - Prometheus & cAdvisor & Grafana

# Remote state management

[WIP] https://github.com/kunduso/add-aws-ecr-ecs-fargate/blob/main/deploy/backend.tf

```ruby
terraform {
  backend "s3" {
    bucket  = "ecs-app-XXX"
    encrypt = true
    key     = "terraform-state/terraform.tfstate"
    region  = "us-east-1"
  }
}
```

# Modules

[WIP] Showcase 1 sample application imported from another `Github` repo instead of a folder within `modules` folder.

# References

- https://spacelift.io/blog/argocd-terraform
- https://spacelift.io/blog/terraform-gitops
- https://spacelift.io/blog/terraform-remote-state#benefits-of-using-terraform-remote-state

# Contribute

Got **something interesting** you'd like to **add or change**? Please feel free to [Open a Pull Request](https://github.com/juanroldan1989/terra-ops/pulls)

If you want to say **thank you** and/or support the active development of `Terra Ops`:

1. Add a [GitHub Star](https://github.com/juanroldan1989/terra-ops/stargazers) to the project.
2. Tweet about the project [on your Twitter](https://twitter.com/intent/tweet?text=Hey%20I've%20just%20discovered%20this%20cool%20app%20on%20Github%20by%20@JhonnyDaNiro%20-%20Deploy%20Terra%20Ops&url=https://github.com/juanroldan1989/terra-ops/&via=Github).
3. Write a review or tutorial on [Medium](https://medium.com), [Dev.to](https://dev.to) or personal blog.
