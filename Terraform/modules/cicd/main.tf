resource "aws_codepipeline" "Task8-CICD-Pipeline-Zaeem" {
  name     = "Task8-CICD-Pipeline-Zaeem"
  role_arn = var.codepipeline_role_arn

  artifact_store {
    location = var.codepipeline_bucket
    type     = "S3"

  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.Task8-Codestar-Connection-Zaeem.arn
        FullRepositoryId = "zaeemattique/InnovationLab-Task7"
        BranchName       = "main"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.Task8-Build-Project-Zaeem.name
      }

      
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ServiceName    = "Task8-ECS-Service-Zaeem"
        ClusterName    = "Task8-ECS-Cluster-Zaeem"
        FileName       = "imagedefinitions.json"
      }
    }
  }
}

resource "aws_codestarconnections_connection" "Task8-Codestar-Connection-Zaeem" {
  name          = "Task8-Codestar-Connection-Zaeem"
  provider_type = "GitHub"
}

resource "aws_codebuild_project" "Task8-Build-Project-Zaeem" {
    name = "Task8-Build-Project-Zaeem"
    build_timeout = 15
    service_role = var.codebuild_role_arn
    artifacts {
      type = "CODEPIPELINE"
    }

    environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/standard:7.0"
    type = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
        name  = "ACCOUNT_ID"
        value = "880958245574"
      }

      environment_variable {
        name  = "AWS_DEFAULT_REGION"
        value = "us-west-2"
      }

      environment_variable {
        name  = "REPO_NAME"
        value = "task8/zaeem"
      }

      environment_variable {
        name  = "IMAGE_TAG"
        value = "latest"
      }
    }

    source {
    type = "CODEPIPELINE"
    }
}



