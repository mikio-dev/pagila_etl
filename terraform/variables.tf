variable "account_id" {
  description = "Account ID"
  type        = string
  sensitive   = true
}

variable "project_name" {
  type = string
}

variable "env" {
  type = string
}

variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "region_az1" {
  type    = string
  default = "eu-west-1a"
}
variable "region_az2" {
  type    = string
  default = "eu-west-1b"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet1_cidr" {
  type    = string
  default = "10.0.10.0/24"
}

variable "public_subnet2_cidr" {
  type    = string
  default = "10.0.20.0/24"
}

variable "private_subnet1_cidr" {
  type    = string
  default = "10.0.30.0/24"
}

variable "private_subnet2_cidr" {
  type    = string
  default = "10.0.40.0/24"
}

variable "postgres_dbname" {
  description = "RDS database name"
  type        = string
}

variable "postgres_username" {
  description = "RDS root user name"
  type        = string
  default     = "postgres"
  sensitive   = true
}

variable "postgres_password" {
  description = "RDS root user password"
  type        = string
  sensitive   = true
}

variable "redshift_dbname" {
  description = "Redshift database name"
  type        = string
}

variable "redshift_username" {
  description = "Redshift user name"
  type        = string
  default     = "redshift"
  sensitive   = true
}

variable "redshift_password" {
  description = "Redshift user password"
  type        = string
  sensitive   = true
}

variable "s3_staging_bucket_name" {
  description = "S3 bucket name for the staging area"
  type        = string
}

variable "s3_airflow_bucket_name" {
  description = "S3 bucket name for MWAA"
  type        = string
}

variable "ec2_key_name" {
  description = "Keypair name to access bastion"
  type        = string
  default     = "id_ed25519"
}


