output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.mwaa.id
}

output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.rds.address
}

output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = aws_db_instance.rds.endpoint
}

output "db_instance_port" {
  description = "The database port"
  value       = aws_db_instance.rds.port
}

output "db_instance_name" {
  description = "The database name"
  value       = aws_db_instance.rds.name
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = aws_db_instance.rds.username
  sensitive   = true
}

output "db_instance_password" {
  description = "The database password (this password may be old, because Terraform doesn't track it after initial creation)"
  value       = aws_db_instance.rds.password
  sensitive   = true
}

output "redshift_cluster_id" {
  description = "The availability zone of the RDS instance"
  value       = aws_redshift_cluster.redshift.id
}

output "redshift_cluster_endpoint" {
  description = "Redshift endpoint"
  value       = aws_redshift_cluster.redshift.endpoint
}

output "redshift_cluster_port" {
  description = "Redshift port"
  value       = aws_redshift_cluster.redshift.port
}

output "redshift_dbname" {
  description = "Redshift databae name"
  value       = aws_redshift_cluster.redshift.database_name
}

output "s3_bucket_name_staging" {
  description = "S3 bucket name for staging"
  value       = aws_s3_bucket.staging_bucket.bucket
}

output "s3_bucket_name_mwaa" {
  description = "S3 bucket name for Airflow"
  value       = aws_s3_bucket.mwaa_bucket.bucket
}

output "airflow_webserver_url" {
  description = "S3 bucket name for Airflow"
  value       = aws_mwaa_environment.mwaa_env.webserver_url
}

output "airflow_version" {
  description = "S3 bucket name for Airflow"
  value       = aws_mwaa_environment.mwaa_env.airflow_version
}

output "ec2_bastion_host" {
  description = "EC2 bastion IP address"
  value       = aws_instance.bastion.public_ip
}
