output "public_subnets" {
  value = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id,
  ]
  description = "Public subnet IDs"
}

output "private_subnets" {
  value = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id,
  ]
  description = "Private subnet IDs"
}