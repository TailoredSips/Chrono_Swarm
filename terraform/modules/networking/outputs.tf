output "vcn_id" {
  description = "The VCN ID"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "The public subnet ID"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "The private subnet ID"
  value       = aws_subnet.private.id
}
