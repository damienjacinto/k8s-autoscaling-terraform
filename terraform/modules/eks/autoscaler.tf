
data "http" "aws_lb_controller_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.0/docs/install/iam_policy.json"
  request_headers = {
    Accept = "application/json"
  }
}

resource "aws_iam_policy" "aws_lb_controller_policy" {
  name        = "tf-awsloadbalancercontroller-${var.eks_cluster_name}"
  policy      = tostring(data.http.aws_lb_controller_policy.body)
  description = "Load Balancer Controller add-on for EKS"
}

resource "aws_iam_role" "aws_lb_controller" {
  name               = "tf-aws-lb-controller-${var.eks_cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.aws_lb_controller_policy_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "aws_lb_controller_policy" {
  role       = aws_iam_role.aws_lb_controller.name
  policy_arn = aws_iam_policy.aws_lb_controller_policy.arn
}

data "aws_iam_policy_document" "aws_lb_controller_policy_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_cluster.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks_cluster.arn]
      type        = "Federated"
    }
  }
}