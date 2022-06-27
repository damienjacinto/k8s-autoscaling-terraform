locals {
  external_dns = "tf-role-external-dns"
}

data "aws_iam_policy_document" "assume_role_policy_eks" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_cluster.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:external-dns:external-dns"]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_cluster.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
    principals {
      identifiers = [aws_iam_openid_connect_provider.eks_cluster.arn]
      type        = "Federated"
    }
  }

}

data "aws_iam_policy_document" "external_dns" {
  statement {
    sid    = "AccessRecordSets"
    effect = "Allow"

    actions = [
      "route53:ChangeResourceRecordSets"
    ]

    resources = ["arn:aws:route53:::hostedzone/*"]
  }

  statement {
    sid    = "ListZones"
    effect = "Allow"

    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "external_dns" {
  name        = "${local.external_dns}-policy"
  description = "This policy grants rights for external dns"
  path        = "/"
  policy      = data.aws_iam_policy_document.external_dns.json
}

resource "aws_iam_role" "external_dns_role" {
  name                 = local.external_dns
  description          = "Thos role grants rights for external dns"
  max_session_duration = 3600
  assume_role_policy   = data.aws_iam_policy_document.assume_role_policy_eks.json
}

resource "aws_iam_role_policy_attachment" "external_dns_attachment" {
  role       = aws_iam_role.external_dns_role.name
  policy_arn = aws_iam_policy.external_dns.arn
}
