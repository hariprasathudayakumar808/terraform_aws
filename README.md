# Flask GPT Terraform Infrastructure

This project provisions infrastructure for deploying a Flask app using Docker on an EC2 instance, triggered by AWS CodePipeline and CodeBuild.

## Infrastructure Overview
- EC2 (t3.medium, Ubuntu 22.04)
- IAM roles for EC2, CodeBuild, CodePipeline
- Security Group: port 5001 open
- Docker & SSM Agent installed via user data
- GitHub → CodePipeline → CodeBuild → Docker → ECR
- Final deployment via SSM to EC2

## Deployment

```bash
cd infra
terraform init
terraform plan
terraform apply
