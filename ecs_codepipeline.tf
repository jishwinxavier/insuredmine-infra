resource "aws_codepipeline" "nodejs_pipeline" {
  name     = "nodejs-app-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.source.id
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "GitHub_Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source"]

      configuration = {
        Owner      = "jishwinxavier"
        Repo       = "nodejsapp"
        Branch     = "main"
        OAuthToken = "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"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "CodeBuild"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source"]
      output_artifacts = ["nodejsapp_service"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.nodejsapp_build.id
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "DeployToECS"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["nodejsapp_service"]
      version         = "1"

      configuration = {
        ClusterName = aws_ecs_cluster.main.name
        ServiceName = aws_ecs_service.nodejsapp_service.name
        FileName    = "nodejsapp_service.json"
      }
    }
  }
}