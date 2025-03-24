terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    mongodbatlas = {
      source = "terraform-providers/mongodbatlas"
    }
  }
  required_version = ">= 0.14"
}