resource "aws_iam_role" "mwaa-execution" {
  name = "${var.project_name}-mwaa-execution"

  assume_role_policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "airflow.amazonaws.com",
          "airflow-env.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOT
  tags = {
    Name = var.project_name
  }
}

resource "aws_iam_role_policy" "mwaa-exec-policy" {
  name = "${var.project_name}-mwaa-exec-policy"
  role = aws_iam_role.mwaa-execution.id

  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "airflow:PublishMetrics",
      "Resource": "arn:aws:airflow:${var.region}:${var.account_id}:environment/${var.project_name}"
    },
    { 
      "Effect": "Deny",
      "Action": [ 
        "s3:ListAllMyBuckets"
      ],
      "Resource": [
        "${aws_s3_bucket.mwaa_bucket.arn}",
        "${aws_s3_bucket.mwaa_bucket.arn}/*"
      ]
    },
    { 
      "Effect": "Allow",
      "Action": [ 
        "s3:GetObject*",
        "s3:GetBucket*",
        "s3:List*"
      ],
      "Resource": [
        "${aws_s3_bucket.mwaa_bucket.arn}",
        "${aws_s3_bucket.mwaa_bucket.arn}/*"
      ]
    },
    { 
      "Effect": "Allow",
      "Action": [ 
        "s3:GetObject*",
        "s3:GetBucket*",
        "s3:List*"
      ],
      "Resource": [
        "${aws_s3_bucket.staging_bucket.arn}",
        "${aws_s3_bucket.staging_bucket.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:CreateLogGroup",
        "logs:PutLogEvents",
        "logs:GetLogEvents",
        "logs:GetLogRecord",
        "logs:GetLogGroupFields",
        "logs:GetQueryResults"
      ],
      "Resource": [
        "arn:aws:logs:${var.region}:${var.account_id}:log-group:airflow-${var.project_name}-*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:DescribeLogGroups"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": "cloudwatch:PutMetricData",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "sqs:ChangeMessageVisibility",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl",
        "sqs:ReceiveMessage",
        "sqs:SendMessage"
      ],
      "Resource": "arn:aws:sqs:${var.region}:*:airflow-celery-*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt",
        "kms:DescribeKey",
        "kms:GenerateDataKey*",
        "kms:Encrypt"
      ],
      "NotResource": "arn:aws:kms:*:${var.account_id}:key/*",
      "Condition": {
        "StringLike": {
          "kms:ViaService": [
            "sqs.${var.region}.amazonaws.com"
          ]
        }
      }
    },
    {
        "Sid": "DataAPIPermissions",
        "Effect": "Allow",
        "Action": [
            "redshift-data:BatchExecuteStatement",
            "redshift-data:ExecuteStatement",
            "redshift-data:CancelStatement",
            "redshift-data:ListStatements",
            "redshift-data:GetStatementResult",
            "redshift-data:DescribeStatement",
            "redshift-data:ListDatabases",
            "redshift-data:ListSchemas",
            "redshift-data:ListTables",
            "redshift-data:DescribeTable"
        ],
        "Resource": "*"
    },
    {
        "Sid": "SecretsManagerPermissions",
        "Effect": "Allow",
        "Action": [
            "secretsmanager:GetSecretValue"
        ],
        "Resource": "*",
        "Condition": {
            "StringLike": {
                "secretsmanager:ResourceTag/RedshiftDataFullAccess": "*"
            }
        }
    },
    {
        "Sid": "GetCredentialsForAPIUser",
        "Effect": "Allow",
        "Action": "redshift:GetClusterCredentials",
        "Resource": [
            "arn:aws:redshift:*:*:dbname:*/*",
            "arn:aws:redshift:*:*:dbuser:*/redshift_data_api_user"
        ]
    },
    {
        "Sid": "DenyCreateAPIUser",
        "Effect": "Deny",
        "Action": "redshift:CreateClusterUser",
        "Resource": [
            "arn:aws:redshift:*:*:dbuser:*/redshift_data_api_user"
        ]
    },
    {
        "Sid": "ServiceLinkedRole",
        "Effect": "Allow",
        "Action": "iam:CreateServiceLinkedRole",
        "Resource": "arn:aws:iam::*:role/aws-service-role/redshift-data.amazonaws.com/AWSServiceRoleForRedshift",
        "Condition": {
            "StringLike": {
                "iam:AWSServiceName": "redshift-data.amazonaws.com"
            }
        }
    }

  ]
}
EOT
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_role" {
  name               = "${var.project_name}-ec2-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role" "redshift_role" {
  name               = "redshift_role"
  assume_role_policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "redshift.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOT
  tags = {
    Name = var.project_name
  }
}

resource "aws_iam_role_policy" "s3_full_access_policy" {
  name   = "redshift_s3_policy"
  role   = aws_iam_role.redshift_role.id
  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": [
        "${aws_s3_bucket.staging_bucket.arn}",
        "${aws_s3_bucket.staging_bucket.arn}/*"
      ]
    }
  ]
}
EOT
}
