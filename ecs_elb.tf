resource "aws_lb" "ecs_app_lb" {
  name               = "nodejs-ecs-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_lb.id]
  subnets           = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
}

resource "aws_lb_target_group" "ecs_app_tg" {
  name     = "nodejs-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id
  target_type = "ip"
}

resource "aws_lb_listener" "ecs_http" {
  load_balancer_arn = aws_lb.ecs_app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_app_tg.arn
  }
}