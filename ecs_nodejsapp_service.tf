# ecs_nodejsapp_service.tf


data "template_file" "main" {
  template = file("./ecs/nodejsapp_service.json.tpl")

  vars = {
    app_name             = "nodejsapp_service"
    app_image            = "943897082161.dkr.ecr.us-east-1.amazonaws.com/nodejsapp:latest"
    app_port             = "80"
    fargate_cpu          = "256"
    fargate_memory       = "512"
    aws_region           = "us-east-1"
  }
}

resource "aws_ecs_task_definition" "nodejsapp_service" {
  family                   = "nodejsapp_service"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  container_definitions    = data.template_file.main.rendered
}

resource "aws_ecs_service" "nodejsapp_service" {
  name            = "nodejsapp_service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.nodejsapp_service.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  propagate_tags  = "SERVICE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_app_tg.id
    container_name   = "nodejsapp_service"
    container_port   = "80"
  }

  tags = {
    ecs_service_name = "nodejsapp_service"
  }

  lifecycle {
    ignore_changes = []
  }
  depends_on = [aws_lb_listener.ecs_http, aws_iam_role_policy_attachment.ecs_task_execution_role]
}