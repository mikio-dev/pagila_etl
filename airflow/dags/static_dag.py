from datetime import timedelta

from airflow.operators.dummy_operator import DummyOperator
from airflow.providers.postgres.operators.postgres import PostgresOperator

from airflow import DAG

default_args = {
    "owner": "Mikio Oba",
    "depends_on_past": False,
    "start_date": "2022-01-01",
    "email_on_retry": False,
    "retries": 3,
    "retry_delay": timedelta(minutes=5),
    "catchup": False,
    "catchup_by_default": False,
}

# Variables
extract_date = "{{ ds_nodash }}"
redshift_conn_id = "pagila_dw"

# List of tables
static_tables = [
    {"table_name": "dim_date", "start_date": "2020-01-01", "end_date": "2030-12-31"},
    {"table_name": "dim_time", "start_date": None, "end_date": None},
]

# Main

dag = DAG(
    dag_id="load_static",
    default_args=default_args,
    description="Load static tables",
    schedule_interval=None,
    catchup=True,
    max_active_runs=1,
)

start_task = DummyOperator(task_id="start_task", dag=dag)
end_task = DummyOperator(task_id="end_task", dag=dag)

# Load static tables
for table in static_tables:

    table_name = table["table_name"]
    start_date = table["start_date"]
    end_date = table["end_date"]

    # Load the table
    load_table_task = PostgresOperator(
        task_id=f"load_{table_name}",
        dag=dag,
        sql=f"sql/load_{table_name}.sql",
        params={"start_date": start_date, "end_date": end_date},
        postgres_conn_id=redshift_conn_id,
    )

    # Set the dependencies
    start_task >> load_table_task
    load_table_task >> end_task
