provider "aws" {
  region = "us-west-2"
}

variable "s3_state_bucket" {
  default = "iacdemo"
}

terraform {
  backend "s3" {
    key    = "hello-world.tfstate"
    region = "us-west-2"
  }
}

data "terraform_remote_state" "core" {
  backend = "s3"
  config {
    key    = "iacdemo.tfstate"
    region = "us-west-2"
    bucket = "${var.s3_state_bucket}"
  }
}



