provider "aws" {
  region              = var.aws_region
  allowed_account_ids = var.aws_allowed_account_ids

  assume_role {
    role_arn = var.aws_assume_role
  }
}