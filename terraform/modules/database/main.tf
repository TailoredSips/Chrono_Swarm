resource "aws_db_instance" "main" {
  identifier        = "chrono-swarm-db"
  engine            = "postgres"
  instance_class    = var.db_instance_class
  allocated_storage = 20
  username          = var.db_username
  password          = var.db_password
  db_name           = var.db_name
  vpc_security_group_ids = [var.db_security_group_id]
  db_subnet_group_name   = var.db_subnet_group
  multi_az          = true
  storage_encrypted = true
  backup_retention_period = 7
  skip_final_snapshot    = false
}

resource "aws_db_instance" "replica" {
  identifier        = "chrono-swarm-db-replica"
  engine            = "postgres"
  instance_class    = var.db_instance_class
  replicate_source_db = aws_db_instance.main.identifier
  vpc_security_group_ids = [var.db_security_group_id]
  db_subnet_group_name   = var.db_subnet_group
  storage_encrypted = true
}
