provider "aws" {
  region = "us-west-2"
}

variable "aws_account_id" {}
variable "aws_region" {}

terraform {
  backend "s3" {
    key    = "modular-hello-world.tfstate"
    region = "us-west-2"
  }
}

variable "corebucket" {
  default = "iacdemo"
}

data "terraform_remote_state" "core" {
  backend = "s3"
  config {
    key    = "iacdemo.tfstate"
    region = "us-west-2"
    bucket = "${var.corebucket}"
  }
}

module "modular_hello_world" {
  source = "./microservice_module"
  service_name = "modular-hello-world"
  docker_image = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/helloworld:latest"
  core_bucket =  "iacdemo"
}


