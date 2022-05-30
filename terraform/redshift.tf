resource "aws_redshift_cluster" "redshift" {
  cluster_identifier        = "${var.project_name}-redshift"
  database_name             = var.redshift_dbname
  master_username           = var.redshift_username
  master_password           = var.redshift_password
  node_type                 = "dc2.large"
  cluster_type              = "single-node"
  cluster_subnet_group_name = aws_redshift_subnet_group.redshift_subnet_group.name
  skip_final_snapshot       = true
  publicly_accessible       = false
  vpc_security_group_ids    = [aws_security_group.mwaa.id, aws_security_group.redshift.id]
  iam_roles                 = [aws_iam_role.redshift_role.arn]
  tags = {
    Name = var.project_name
  }
}

resource "aws_redshift_subnet_group" "redshift_subnet_group" {
  name       = "${var.project_name}-redshift-subnet-group"
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]
  tags = {
    Name = var.project_name
  }
}
