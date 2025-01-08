from airflow.models import DAG 
from datetime import datetime

from airflow.contrib.sensors.file_sensor import FileSensor 
from airflow.operators.bash_operator import BashOperator 
from DataLoading import load_data
from ml import MLModel
from airflow.operators.python_operator import PythonOperator
from DataExtraction import getting_data

default_arguments = { 'owner': 'Khaled', 'email': 'khaledsalehkl1@gmail.com', 'start_date': datetime(2025, 1, 1)}

data_pipeline = DAG( dag_id='etl_workflow', default_args=default_arguments, schedule_interval="*/10 * * * *") 

data_extraction = PythonOperator(task_id='data_extraction', python_callable=getting_data, dag=data_pipeline) 

file_sensor = FileSensor(task_id='file_sensor', filepath='/home/hadoop/airflow_assignment/diabetes_records.json', poke_interval=10, timeout=60, dag=data_pipeline) 

data_transformation = BashOperator(task_id='data_transformation', bash_command="/home/hadoop/airflow/dags/DataTrans.sh ", dag=data_pipeline) 

data_loading = PythonOperator(task_id='data_loading', python_callable=load_data, dag=data_pipeline)

ml_model = PythonOperator(task_id='ml_model', python_callable=MLModel, dag=data_pipeline)

data_extraction >> file_sensor >> data_transformation >> data_loading >> ml_model
