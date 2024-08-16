#!/bin/bash

apply () {
  cd networking
  terraform init
  terraform apply --auto-approve
  cd ../eks
  terraform init
  terraform apply --auto-approve
  cd ../roles
  terraform init
  terraform apply --auto-approve
  cd ../addons
  terraform init
  terraform apply --auto-approve
  cd ../autoscaler
  terraform init
  terraform apply --auto-approve
  cd ../loadbalancer
  terraform init
  terraform apply --auto-approve
  cd ../app-b
  terraform init
  terraform apply --auto-approve
}

destroy () {
  cd app-b
  terraform destroy --auto-approve
  cd ../loadbalancer
  terraform destroy --auto-approve
  cd ../autoscaler
  terraform destroy --auto-approve
  cd ../addons
  terraform destroy --auto-approve
  cd ../roles
  terraform destroy --auto-approve
  cd ../eks
  terraform destroy --auto-approve
  cd ../networking
  terraform destroy --auto-approve
}

case "$1" in
  "apply") apply
  ;;
  "destroy") destroy
  ;;
esac
