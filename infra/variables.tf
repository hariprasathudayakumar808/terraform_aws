variable "region" {
  default = "eu-central-1"
}

variable "instance_type" {
  default = "t3.medium"
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
}

variable "github_repo" {
  type = string
}

variable "github_owner" {
  type = string
}

variable "github_oauth_secret_name" {
  type        = string
  description = "The name of the secret in AWS Secrets Manager that stores the GitHub OAuth token"
}

