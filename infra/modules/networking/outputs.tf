output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_zone1" {
  value = aws_subnet.private_zone1.id
}

output "private_zone2" {
  value = aws_subnet.private_zone2.id
}
