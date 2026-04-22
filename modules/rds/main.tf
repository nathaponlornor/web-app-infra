resource "aws_security_group" "rds" {
  name_prefix = "${var.project_name}-${var.environment}-rds-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.ecs_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-${var.environment}-rds-sg" }
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet"
  subnet_ids = var.private_db_subnet_ids

  tags = { Name = "${var.project_name}-${var.environment}-db-subnet-group" }
}

resource "aws_rds_cluster" "main" {
  cluster_identifier          = "${var.project_name}-${var.environment}-db"
  engine                      = "aurora-postgresql"
  engine_mode                 = "provisioned"
  database_name               = var.db_name
  master_username             = var.db_username
  manage_master_user_password = true
  db_subnet_group_name        = aws_db_subnet_group.main.name
  vpc_security_group_ids      = [aws_security_group.rds.id]
  storage_encrypted           = true
  deletion_protection         = true
  skip_final_snapshot         = false
  final_snapshot_identifier   = "${var.project_name}-${var.environment}-db-final"

  tags = { Name = "${var.project_name}-${var.environment}-db" }
}

resource "aws_rds_cluster_instance" "main" {
  identifier          = "${var.project_name}-${var.environment}-db-instance"
  cluster_identifier  = aws_rds_cluster.main.id
  instance_class      = var.db_instance_class
  engine              = aws_rds_cluster.main.engine
  publicly_accessible = false

  tags = { Name = "${var.project_name}-${var.environment}-db-instance" }
}
