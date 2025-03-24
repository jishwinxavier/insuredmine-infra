terraform {
  backend "s3" {
    bucket         = "terraform-state-insuredmine"
    key            = "terraform"
    dynamodb_table = "insuredmine-terraform-state-lock"
    region         = "us-east-1"
  }
}