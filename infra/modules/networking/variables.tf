variable "app_name" {
  type    = string
  default = "sample-app"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "zone1" {
  type    = string
  default = "us-east-1a"
}

variable "zone2" {
  type    = string
  default = "us-east-1b"
}

variable "eks_name" {
  type    = string
  default = "sample-eks"
}

variable "eks_version" {
  type    = string
  default = "1.29"
}
