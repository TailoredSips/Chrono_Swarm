output "db_instance_endpoint" {
  description = "The endpoint of the main DB instance"
  value       = aws_db_instance.main.endpoint
}

output "db_replica_endpoint" {
  description = "The endpoint of the replica DB instance"
  value       = aws_db_instance.replica.endpoint
}
