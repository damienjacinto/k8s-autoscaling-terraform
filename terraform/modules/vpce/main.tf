
data "aws_region" "current" {}

locals {
  services = ["ssm", "ec2messages", "ssmmessages"]
}

resource "aws_security_group" "vpce" {
  name        = "vpce allow all"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpce_vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpce_vpc_cidr]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "VPCE"
  }
}

resource "aws_vpc_endpoint" "vpce" {
  for_each            = toset(local.services)
  vpc_id              = var.vpce_vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${each.value}"
  private_dns_enabled = true
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.vpce_subnet_ids

  security_group_ids = [
    aws_security_group.vpce.id,
  ]

  tags = {
    Name = "VPCE"
  }
}