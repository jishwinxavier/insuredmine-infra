# ECS task execution role data
data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# ECS task execution role
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "nodejsapp-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

# ECS task execution role policy attachment
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  for_each = toset([
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/CloudWatchFullAccessV2",
    "arn:aws:iam::aws:policy/AWSXrayFullAccess",
    "arn:aws:iam::aws:policy/AWSAppMeshEnvoyAccess",
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
  ])
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = each.value
}