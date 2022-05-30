from airflow.plugins_manager import AirflowPlugin
from operators.postgres_to_s3 import PostgresToS3Operator
from operators.s3_to_redshift import S3ToRedshiftOperator


class PagilaPlugin(AirflowPlugin):

    name = "pagila_plugin"

    operators = [PostgresToS3Operator, S3ToRedshiftOperator]
