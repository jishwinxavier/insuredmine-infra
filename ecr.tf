# ECR repository for the applicaton

resource "aws_ecr_repository" "nodejsapp" {
  name                 = "nodejsapp"
  image_tag_mutability = "MUTABLE"
}