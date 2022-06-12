variable "aws_region" {
  description = "The AWS region to deploy to (e.g. eu-central-1)"
  type        = string
  default     = "eu-central-1"
}

variable "aws_assume_role" {
  description = "The AWS role to use"
  type        = string
}

variable "aws_allowed_account_ids" {
  description = "the allowed accounts ids"
  type        = list(string)
}