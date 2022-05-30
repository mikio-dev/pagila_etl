resource "aws_mwaa_environment" "mwaa_env" {
  name                  = var.project_name
  dag_s3_path           = aws_s3_bucket_object.mwaa_dags.key
  plugins_s3_path       = aws_s3_bucket_object.mwaa_plugins.key
  execution_role_arn    = aws_iam_role.mwaa-execution.arn
  source_bucket_arn     = aws_s3_bucket.mwaa_bucket.arn
  max_workers           = 2
  webserver_access_mode = "PUBLIC_ONLY"

  network_configuration {
    security_group_ids = [aws_security_group.mwaa.id]
    subnet_ids         = [aws_subnet.private1.id, aws_subnet.private2.id]
  }

  logging_configuration {
    task_logs {
      enabled   = true
      log_level = "INFO"
    }
    webserver_logs {
      enabled   = true
      log_level = "INFO"
    }
    scheduler_logs {
      enabled   = true
      log_level = "INFO"
    }
    worker_logs {
      enabled   = true
      log_level = "INFO"
    }
    dag_processing_logs {
      enabled   = true
      log_level = "INFO"
    }
  }
  tags = {
    Name = var.project_name
  }
}
