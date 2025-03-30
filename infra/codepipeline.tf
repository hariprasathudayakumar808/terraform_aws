resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "flask-gpt-codepipeline-artifacts"
  force_destroy = true
}

resource "aws_codebuild_project" "flask_gpt_build" {
  name          = "flask-gpt-ec2-build"
  service_role  = aws_iam_role.codebuild_service_role.arn
  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"
    privileged_mode = true
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "pipeline/buildspec.yml"
  }
}

resource "aws_codebuild_project" "flask_gpt_deploy" {
  name         = "flask-gpt-ec2-deploy"
  service_role = aws_iam_role.codebuild_service_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
  }
}


resource "aws_codepipeline" "flask_gpt_pipeline" {
  name     = "flask-gpt-ec2-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        Owner  = var.github_owner
        Repo   = var.github_repo
        Branch = "main"
        OAuthToken = local.github_pat
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
        ProjectName = aws_codebuild_project.flask_gpt_build.name
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name             = "SSMDeploy"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["build_output"]
      output_artifacts = ["deploy_output"]
      version          = "1"
      configuration = {
        ProjectName = aws_codebuild_project.flask_gpt_deploy.name
      }
    }
  }
}

resource "aws_iam_role_policy" "codebuild_secrets_access" {
  name = "codebuild-secrets-access"
  role = aws_iam_role.codebuild_service_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = "*"
      }
    ]
  })
}

