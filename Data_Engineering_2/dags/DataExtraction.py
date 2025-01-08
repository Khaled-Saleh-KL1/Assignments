import requests
import json

def getting_data():

	response = requests.get('http://87.236.232.200:5000/data')
	response.raise_for_status()
	
	with open('/home/hadoop/diabetes_records.json', 'w') as file:
		json.dump(response.json(), file)