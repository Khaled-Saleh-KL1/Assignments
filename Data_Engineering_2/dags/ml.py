import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, confusion_matrix
import mysql.connector
import joblib

def get_data_from_mysql():

    conn = mysql.connector.connect(
        host="localhost",
        user="root",
        password="123",
        database="airflow_assignment_db")

    query = "SELECT * FROM DiabetesRecords;"
    df = pd.read_sql(query, conn)
    conn.close()
    
    return df
    
    
def train_model():

    df = get_data_from_mysql()
    
    X = df.drop('class', axis=1)
    y = df['class']
    
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42)
    
    rf_model = RandomForestClassifier(
        n_estimators=100,
        random_state=42)
    rf_model.fit(X_train, y_train)
    
    y_pred = rf_model.predict(X_test)
    
    joblib.dump(rf_model, 'diabetes_model.joblib')
    
    return rf_model
    

def predict_new_data():

    model = joblib.load('diabetes_model.joblib')
    
    conn = mysql.connector.connect(
        host="localhost",
        user="root",
        password="123",
        database="airflow_assignment_db")
        
    query = "SELECT * FROM unseen_data;"
    new_data = pd.read_sql(query, conn)
    conn.close()
    
    y_true = new_data['class']
    new_data = new_data.drop('class', axis=1) 
    predictions = model.predict(new_data)
    
    return predictions, y_true
    
    
    
def MLModel():

    model = train_model()
    
    predictions, y_true = predict_new_data()
    
    report = classification_report(y_true, predictions)
    matrix = confusion_matrix(y_true, predictions)
    
    print("Classification Report:\n", report)
    print("Confusion Matrix:\n", matrix)
