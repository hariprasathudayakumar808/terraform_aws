#######################################
# CODEBUILD ROLE
#######################################

resource "aws_iam_role" "codebuild_service_role" {
  name = "codebuild_flask_gpt_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "codebuild.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_ecr_attach" {
  role       = aws_iam_role.codebuild_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy" "codebuild_additional_permissions" {
  name = "codebuild-additional-access"
  role = aws_iam_role.codebuild_service_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:*",
          "s3:*",
          "secretsmanager:GetSecretValue",
          "ssm:SendCommand",
          "ec2:DescribeInstances"
        ],
        Resource = "*"
      }
    ]
  })
}

#######################################
# CODEPIPELINE ROLE
#######################################

resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline_flask_gpt_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "codepipeline.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_admin_attach" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"
}

resource "aws_iam_role_policy" "codepipeline_additional_permissions" {
  name = "codepipeline-secrets-ssm-access"
  role = aws_iam_role.codepipeline_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "iam:PassRole",
          "codebuild:*",
          "s3:*",
          "ssm:SendCommand"
        ],
        Resource = "*"
      }
    ]
  })
}
