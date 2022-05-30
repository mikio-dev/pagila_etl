from tempfile import NamedTemporaryFile

from airflow.hooks.postgres_hook import PostgresHook
from airflow.hooks.S3_hook import S3Hook
from airflow.models import BaseOperator
from airflow.utils.decorators import apply_defaults


class PostgresToS3Operator(BaseOperator):
    """
    Postgres to S3 Operator

    Extract a table from Postgres database to S3 bucket as a CSV file.

    :param postgres_conn_id:      Airflow connection name for PostgreSQL database
    :param s3_conn_id:            Airflow connection name for S3
    :param table_name:            Table name to export (e.g. customer)
    :param table_prefix:          Prefix for the table name
    :param extract_type:          Extract type (full or delta)
    :param extract_date:          Date of the extract (e.g. 20220525)
    :param extract_column:        Column name for the extract range (e.g. last_update)
    :param s3_bucket:             Target S3 bucket name
    :param s3_key:                Key name (file name) in the S3 bucket
    """

    template_fields = ("s3_bucket", "extract_date")

    @apply_defaults
    def __init__(
        self,
        postgres_conn_id="",
        s3_conn_id="",
        table_name="",
        table_prefix="",
        extract_type="",
        extract_date="",
        extract_column="",
        s3_bucket="",
        s3_key="",
        *args,
        **kwargs,
    ):
        super().__init__(*args, **kwargs)
        self.postgres_conn_id = postgres_conn_id
        self.s3_conn_id = s3_conn_id
        self.table_name = table_prefix + table_name
        self.extract_type = extract_type
        self.extract_date = extract_date
        self.extract_column = extract_column
        self.s3_bucket = s3_bucket
        self.s3_key = s3_key

    def execute(self, context):
        pg_hook = PostgresHook(postgres_conn_id=self.postgres_conn_id)
        s3_hook = S3Hook(self.s3_conn_id)

        # Write a temporary file to store output file
        with NamedTemporaryFile("w") as tmp:

            # SQL statement for the extract the table as CSV
            copy_stmt = f"""
                COPY (
                    SELECT * 
                      FROM {self.table_name} 
            """

            if self.extract_type == "delta":
                copy_stmt += f"""
                        WHERE to_timestamp('{self.extract_date}', 'YYYYMMDD') <= {self.extract_column}
                        AND {self.extract_column} < to_timestamp('{self.extract_date}', 'YYYYMMDD') + interval '1 day'
                """

            copy_stmt += " ) TO STDOUT (FORMAT CSV, HEADER true)"

            self.log.info(
                f"Extracting data from the table {self.table_name} to {tmp.name}"
            )
            pg_hook.copy_expert(copy_stmt, filename=tmp.name)
            tmp.flush()

            if self.s3_key == "":
                _s3_key = f"{self.extract_date}/{self.table_name}.csv"
            else:
                _s3_key = self.s3_key

            self.log.info(
                f"Uploading the file {tmp.name} to the S3 bucket {self.s3_bucket}/{_s3_key}"
            )
            s3_hook.load_file(
                filename=tmp.name, key=_s3_key, bucket_name=self.s3_bucket, replace=True
            )
