
resource "aws_codebuild_project" "nodejsapp_build" {
  name          = "nodejsapp-codebuild"
  build_timeout = "60"

  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_CUSTOM_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"

    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "DOCKER_BUILDKIT"
      value = "1"
      type  = "PLAINTEXT"
    }
  }

  source {
    type = "CODEPIPELINE"
    git_clone_depth = 1
  }
}