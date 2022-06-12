data "aws_iam_policy_document" "assume_role_policy_trusted_ips_only" {
  statement {
    sid = "assumeFromOnlyAccount"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "AWS"
      identifiers = [var.arn_user]
    }
  }
}

data "aws_iam_policy_document" "terraform_user" {
  statement {
    sid = "ALL"
    actions = [
      "*",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "terraform_user" {
  name        = "tf-allow-terraform-user"
  description = "This policy gives most rights required by Terraform"
  path        = "/"
  policy      = data.aws_iam_policy_document.terraform_user.json
}

resource "aws_iam_role" "terraform_user" {
  name        = "tf-terraform-user"
  description = "This role grants most rights for terraform"

  max_session_duration = 3600

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_trusted_ips_only.json
}

resource "aws_iam_role_policy_attachment" "allow_terraform_user" {
  role       = aws_iam_role.terraform_user.name
  policy_arn = aws_iam_policy.terraform_user.arn
}
