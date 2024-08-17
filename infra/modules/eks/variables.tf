variable "app_name" {
  type    = string
  default = "sample-app"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "eks_name" {
  type    = string
  default = "sample-eks"
}

variable "eks_version" {
  type    = string
  default = "1.29"
}

variable "private_zone1" {
  type = string
}

variable "private_zone2" {
  type = string
}
