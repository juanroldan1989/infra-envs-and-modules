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
2. Add/Remove modules as they need in order to build their applications within their environments.
3. Deploy specific applications (e.g.: app-a, app-b or app-c) within their specific environments.

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
