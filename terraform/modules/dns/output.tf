output "zone_dns_name" {
  value = aws_route53_zone.primary.name
}

output "zone_dns_id" {
  value = aws_route53_zone.primary.id
}
