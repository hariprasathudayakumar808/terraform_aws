data "aws_secretsmanager_secret_version" "github_pat" {
  secret_id = var.github_oauth_secret_name
}

locals {
  github_pat = jsondecode(data.aws_secretsmanager_secret_version.github_pat.secret_string)["Token"]
}
