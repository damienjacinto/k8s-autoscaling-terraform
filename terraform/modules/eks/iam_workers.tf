resource "aws_iam_role" "eks_worker_node_role" {
  name = "tf-eks-${var.eks_cluster_name}-worker-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

}

resource "aws_iam_role_policy_attachment" "eks_worker_node_role-amazoneks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_role_amazoneks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_role_amazonec2_containerregistry_readonly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_worker_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_role_amazon_ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eks_worker_node_role.name
}

resource "aws_iam_instance_profile" "eks_worker_node_role" {
  name = "tf-eks-${var.eks_cluster_name}-worker"
  role = aws_iam_role.eks_worker_node_role.name
}

resource "aws_iam_policy" "eks_route53_policy" {
  name        = "tf-write-route53-worker-policy-${var.eks_cluster_name}"
  path        = "/"
  description = "Allow eks workers to update route53 for traefik's dns challenges"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "route53:GetChange",
            "Resource": "arn:aws:route53:::change/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "route53:ChangeResourceRecordSets",
                "route53:ListResourceRecordSets"
            ],
            "Resource": "arn:aws:route53:::hostedzone/*"
        },
        {
            "Effect": "Allow",
            "Action": "route53:ListHostedZonesByName",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eks_route53_policy_attachement" {
  role       = aws_iam_role.eks_worker_node_role.name
  policy_arn = aws_iam_policy.eks_route53_policy.arn
}

# iam for cloudwatch
resource "aws_iam_policy" "policy" {
  name        = "tf-cloudwatch-worker-policy-${var.eks_cluster_name}"
  path        = "/"
  description = "my cloudwatch policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cloudwatch-policy-attachment" {
  role       = aws_iam_role.eks_worker_node_role.name
  policy_arn = aws_iam_policy.policy.arn
}