
locals {
  karpenter                      = "tf-role-karpenter-${aws_eks_cluster.eks_cluster.name}"
  karpenter_launch_template_name = "karpenter-${aws_eks_cluster.eks_cluster.name}"
}

data "aws_iam_policy_document" "assume_role_policy_eks_karpenter" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_cluster.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:karpenter:karpenter"]
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

data "aws_iam_policy_document" "karpenter" {
  statement {
    sid    = "AccessEC2actions"
    effect = "Allow"
    actions = [
        "iam:PassRole",
        "ssm:GetParameter",
        "ec2:CreateLaunchTemplate",
        "ec2:CreateFleet",
        "ec2:CreateTags",
        "ec2:DescribeLaunchTemplates",
        "ec2:DescribeInstances",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeInstanceTypeOfferings",
        "ec2:DescribeAvailabilityZones",
        "ec2:RunInstances",
        "ec2:TerminateInstances"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "karpenter" {
  name        = "${local.karpenter}-policy"
  description = "This policy grants rights for karpenter"
  path        = "/"
  policy      = data.aws_iam_policy_document.karpenter.json
}

resource "aws_iam_role" "karpenter_role" {
  name                 = local.karpenter
  description          = "This role grants rights for karpenter"
  max_session_duration = 3600
  assume_role_policy   = data.aws_iam_policy_document.assume_role_policy_eks_karpenter.json
}

resource "aws_iam_role_policy_attachment" "karpenter_attachment" {
  role       = aws_iam_role.karpenter_role.name
  policy_arn = aws_iam_policy.karpenter.arn
}

resource "aws_launch_template" "eks_worker_karpenter_launch_template" {
  name                                 = local.karpenter_launch_template_name
  image_id                             = data.aws_ami.eks_worker_node_official_ami.id
  user_data                            = base64encode(local.eks_worker_node_userdata)
  vpc_security_group_ids               = [aws_security_group.eks_worker_node.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.eks_worker_node_role.name
  }

  lifecycle {
    create_before_destroy = true
  }

  dynamic "tag_specifications" {
    for_each = toset(["instance", "volume", "network-interface"])
    content {
      resource_type = tag_specifications.key
      tags          = merge(local.tags, { Name = local.karpenter_launch_template_name })
    }
  }

  tags = merge(
    local.tags,
    { Name = local.karpenter_launch_template_name }
  )
}
