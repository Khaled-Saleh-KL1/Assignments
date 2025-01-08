import pandas as pd
import json
from sqlalchemy import create_engine, inspect
import mysql.connector

def load_data():
    df = pd.read_json(r'/home/hadoop/airflow/dags/diabetes_records.json')
    df_unseen = pd.read_csv(r'/home/hadoop/airflow/dags/Diabetes_unseen.csv')
    
    connection = mysql.connector.connect(user='root', password='123', host='localhost')
    cursor = connection.cursor()
    cursor.execute("CREATE DATABASE IF NOT EXISTS airflow_assignment_db")
    cursor.close()
    connection.close()

    connection = mysql.connector.connect(user='root', password='123', host='localhost', database='airflow_assignment_db')
    cursor = connection.cursor()

    tables_query = {
        "DiabetesRecords": """
            CREATE TABLE IF NOT EXISTS DiabetesRecords (
                Age INT, AnyHealthcare INT, BMI FLOAT, CholCheck INT, DiffWalk INT,
                Education INT, Fruits INT, GenHlth INT, HeartDiseaseorAttack INT,
                HighBP INT, HighChol INT, HvyAlcoholConsump INT, Income INT,
                MentHlth INT, NoDocbcCost INT, PhysActivity INT, PhysHlth INT,
                Sex INT, Smoker INT, Stroke INT, Veggies INT, class INT
            );
        """,
        "unseen_data": """
            CREATE TABLE IF NOT EXISTS unseen_data (
                Age INT, AnyHealthcare INT, BMI FLOAT, CholCheck INT, DiffWalk INT,
                Education INT, Fruits INT, GenHlth INT, HeartDiseaseorAttack INT,
                HighBP INT, HighChol INT, HvyAlcoholConsump INT, Income INT,
                MentHlth INT, NoDocbcCost INT, PhysActivity INT, PhysHlth INT,
                Sex INT, Smoker INT, Stroke INT, Veggies INT, class INT
            );
        """
    }

    for query in tables_query.values():
        cursor.execute(query)

    insert_query = """
        INSERT INTO {} (
            Age, AnyHealthcare, BMI, CholCheck, DiffWalk, Education, Fruits, GenHlth, 
            HeartDiseaseorAttack, HighBP, HighChol, HvyAlcoholConsump, Income, MentHlth, 
            NoDocbcCost, PhysActivity, PhysHlth, Sex, Smoker, Stroke, Veggies, class
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);
    """

    for index, row in df.iterrows():
        data = (
            int(row['Age']), int(row['AnyHealthcare']), float(row['BMI']), 
            int(row['CholCheck']), int(row['DiffWalk']), int(row['Education']), 
            int(row['Fruits']), int(row['GenHlth']), int(row['HeartDiseaseorAttack']),
            int(row['HighBP']), int(row['HighChol']), int(row['HvyAlcoholConsump']), 
            int(row['Income']), int(row['MentHlth']), int(row['NoDocbcCost']), 
            int(row['PhysActivity']), int(row['PhysHlth']), int(row['Sex']), 
            int(row['Smoker']), int(row['Stroke']), int(row['Veggies']), int(row['class'])
        )
        cursor.execute(insert_query.format('DiabetesRecords'), data)

    for index, row in df_unseen.iterrows():
        data = (
            int(row['Age']), int(row['AnyHealthcare']), float(row['BMI']), 
            int(row['CholCheck']), int(row['DiffWalk']), int(row['Education']), 
            int(row['Fruits']), int(row['GenHlth']), int(row['HeartDiseaseorAttack']),
            int(row['HighBP']), int(row['HighChol']), int(row['HvyAlcoholConsump']), 
            int(row['Income']), int(row['MentHlth']), int(row['NoDocbcCost']), 
            int(row['PhysActivity']), int(row['PhysHlth']), int(row['Sex']), 
            int(row['Smoker']), int(row['Stroke']), int(row['Veggies']), int(row['class'])
        )
        cursor.execute(insert_query.format('unseen_data'), data)

    connection.commit()
    cursor.close()
    connection.close()