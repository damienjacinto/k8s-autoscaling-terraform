locals {
  tags = merge(
    var.tags,
    {
      "Name" = format("%s", var.zone_name)
    },
  )
}

resource "aws_route53_zone" "primary" {
  name = var.zone_name
  tags = local.tags
}
