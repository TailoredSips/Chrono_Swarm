resource "aws_secretsmanager_secret" "main" {
  name = "chrono-swarm-secrets"
}

resource "aws_security_group" "bastion" {
  name        = "bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  ami           = var.bastion_ami
  instance_type = var.bastion_type
  subnet_id     = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.bastion.id]
  key_name      = var.key_name
  tags = {
    Name = "chrono-swarm-bastion"
  }
}
