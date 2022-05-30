from datetime import timedelta

from airflow.operators.dummy_operator import DummyOperator
from airflow.providers.amazon.aws.transfers.s3_to_redshift import S3ToRedshiftOperator
from airflow.providers.postgres.operators.postgres import PostgresOperator
from operators.postgres_to_s3 import PostgresToS3Operator

from airflow import DAG

default_args = {
    "owner": "Mikio Oba",
    "depends_on_past": False,
    "start_date": "2022-01-01",
    "end_date": "2022-04-03",
    "email_on_retry": False,
    "retries": 3,
    "retry_delay": timedelta(minutes=5),
    "catchup": False,
    "catchup_by_default": False,
}

# Variables
S3_BUCKET = "pagila-staging1"
extract_date = "{{ ds_nodash }}"

s3_conn_id = "pagila_staging"
postgres_conn_id = "pagila_db"
redshift_conn_id = "pagila_dw"

# List of tables
src_prefix = "src_"
src_tables = [
    {"table_name": "actor", "extract_column": "last_update", "extract_type": "full"},
    {"table_name": "address", "extract_column": "last_update", "extract_type": "full"},
    {
        "table_name": "category",
        "extract_column": "last_update",
        "extract_type": "full",
    },
    {"table_name": "city", "extract_column": "last_update", "extract_type": "full"},
    {"table_name": "country", "extract_column": "last_update", "extract_type": "full"},
    {
        "table_name": "customer",
        "extract_column": "last_update",
        "extract_type": "full",
    },
    {"table_name": "film", "extract_column": "last_update", "extract_type": "full"},
    {
        "table_name": "film_actor",
        "extract_column": "last_update",
        "extract_type": "full",
    },
    {
        "table_name": "film_category",
        "extract_column": "last_update",
        "extract_type": "full",
    },
    {
        "table_name": "inventory",
        "extract_column": "last_update",
        "extract_type": "full",
    },
    {
        "table_name": "language",
        "extract_column": "last_update",
        "extract_type": "full",
    },
    {"table_name": "staff", "extract_column": "last_update", "extract_type": "full"},
    {"table_name": "store", "extract_column": "last_update", "extract_type": "full"},
    {"table_name": "rental", "extract_column": "last_update", "extract_type": "delta"},
    {
        "table_name": "payment",
        "extract_column": "payment_date",
        "extract_type": "delta",
    },
]

stg_prefix = "stg_"
dim_prefix = "dim_"
dim_tables = [
    {"table_name": "actor"},
    {"table_name": "customer"},
    {"table_name": "film"},
    {"table_name": "staff"},
    {"table_name": "store"},
]

bridge_tables = [
    {"table_name": "film_actor"},
]

fact_tables = [
    {"table_name": "fact_rental"},
]


# Main

dag = DAG(
    dag_id="pagila_etl",
    default_args=default_args,
    description="Extract the pagila database and load the star schema in Redshift via S3",
    schedule_interval="@daily",
    catchup=True,
    max_active_runs=1,
)

start_extract = DummyOperator(task_id="start_extract", dag=dag)
end_extract_task = DummyOperator(task_id="end_extract", dag=dag)
end_load_dim_task = DummyOperator(task_id="end_load_dim", dag=dag)
end_load_task = DummyOperator(task_id="end_load_fact", dag=dag)

# Copy from PostgreSQL to Redshift
for table in src_tables:

    table_name = table["table_name"]

    # Copy from PostgreSQL to S3
    sql_to_s3_task = PostgresToS3Operator(
        task_id=f"pg_to_s3_{table_name}",
        dag=dag,
        postgres_conn_id=postgres_conn_id,
        s3_conn_id=s3_conn_id,
        extract_date="{{ ds_nodash }}",
        s3_bucket=S3_BUCKET,
        **table,
    )

    # Copy from S3 to Redshift
    s3_to_redshift_task = S3ToRedshiftOperator(
        task_id=f"s3_to_redshift_{table_name}",
        dag=dag,
        redshift_conn_id=redshift_conn_id,
        aws_conn_id=s3_conn_id,
        s3_bucket=S3_BUCKET,
        s3_key=f"{{{{ ds_nodash }}}}/{table_name}.csv",
        schema="PUBLIC",
        table=f"{src_prefix}{table_name}",
        copy_options=["csv", "IGNOREHEADER 1"],
        verify=False,
        method="REPLACE",
    )

    # Dependencies
    start_extract >> sql_to_s3_task
    sql_to_s3_task >> s3_to_redshift_task
    s3_to_redshift_task >> end_extract_task

# Load into the dim tables
for table in dim_tables:

    stg_table_name = f"{stg_prefix}{table['table_name']}"
    dim_table_name = f"{dim_prefix}{table['table_name']}"

    # Delete the dim table
    delete_dim_table_task = PostgresOperator(
        task_id=f"delete_{dim_table_name}",
        dag=dag,
        sql=f"sql/delete_dim_table.sql",
        params={"table_name": dim_table_name},
        postgres_conn_id=redshift_conn_id,
    )

    # Load into the stg table
    load_stg_table_task = PostgresOperator(
        task_id=f"load_{stg_table_name}",
        dag=dag,
        sql=f"sql/load_{stg_table_name}.sql",
        postgres_conn_id=redshift_conn_id,
    )

    # Load into the dim table
    load_dim_table_task = PostgresOperator(
        task_id=f"load_{dim_table_name}",
        dag=dag,
        sql=f"sql/load_{dim_table_name}.sql",
        postgres_conn_id=redshift_conn_id,
    )

    # Dependencies
    end_extract_task >> delete_dim_table_task
    delete_dim_table_task >> load_stg_table_task
    load_stg_table_task >> load_dim_table_task
    load_dim_table_task >> end_load_dim_task

# Load into the dim bridge tables
for table in bridge_tables:

    stg_table_name = f"{stg_prefix}{table['table_name']}"
    dim_table_name = f"{dim_prefix}{table['table_name']}"

    # Delete the dim table
    delete_dim_table_task = PostgresOperator(
        task_id=f"delete_{dim_table_name}",
        dag=dag,
        sql=f"sql/delete_dim_table.sql",
        params={"table_name": dim_table_name},
        postgres_conn_id=redshift_conn_id,
    )

    # Load into the stg table
    load_stg_table_task = PostgresOperator(
        task_id=f"load_{stg_table_name}",
        dag=dag,
        sql=f"sql/load_{stg_table_name}.sql",
        postgres_conn_id=redshift_conn_id,
    )

    # Load into the dim table
    load_dim_table_task = PostgresOperator(
        task_id=f"load_{dim_table_name}",
        dag=dag,
        sql=f"sql/load_{dim_table_name}.sql",
        postgres_conn_id=redshift_conn_id,
    )

    # Dependencies
    end_load_dim_task >> delete_dim_table_task
    delete_dim_table_task >> load_stg_table_task
    load_stg_table_task >> load_dim_table_task
    load_dim_table_task >> end_load_task


# Load into the fact tables
for table in fact_tables:

    fact_table_name = table["table_name"]

    # Delete the dim table
    load_fact_table_task = PostgresOperator(
        task_id=f"load_{fact_table_name}",
        dag=dag,
        sql=f"sql/load_{fact_table_name}.sql",
        postgres_conn_id=redshift_conn_id,
    )

    # Dependencies
    end_load_dim_task >> load_fact_table_task
    load_fact_table_task >> end_load_task
