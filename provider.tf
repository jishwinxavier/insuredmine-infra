# Specify the provider and access details
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      "creator"     = "Jishwin Jude"
      "function"    = "application-server"
      "application" = "insuredmine"
      "environment" = "dev"
      "os"          = "Fargate"
      "project"     = "insuredmine"
    }
  }
}