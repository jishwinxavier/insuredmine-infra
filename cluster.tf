resource "aws_ecs_cluster" "main" {
  name = "nodejsapp-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  capacity_providers = ["FARGATE_SPOT", "FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
  }
}