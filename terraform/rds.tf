resource "aws_db_instance" "rds" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "14.1"
  instance_class         = "db.t3.micro"
  identifier             = var.project_name
  db_name                = var.postgres_dbname
  username               = var.postgres_username
  password               = var.postgres_password
  skip_final_snapshot    = true
  port                   = 5432
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.mwaa.id, aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  tags = {
    Name = var.project_name
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.project_name}-rds-subnet-group"
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]
  tags = {
    Name = var.project_name
  }
}
