output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_backend_subnet_ids" {
  value = aws_subnet.private_backend[*].id
}

output "private_db_subnet_ids" {
  value = aws_subnet.private_db[*].id
}
