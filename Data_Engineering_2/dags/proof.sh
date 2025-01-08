#!/bin/bash

# Declare arrays for each feature
Age=()
AnyHealthcare=()
BMI=()
CholCheck=()
DiffWalk=()
Education=()
Fruits=()
GenHlth=()
HeartDiseaseorAttack=()
HighBP=()
HighChol=()
HvyAlcoholConsump=()
Income=()
MentHlth=()
NoDocbcCost=()
PhysActivity=()
PhysHlth=()
Sex=()
Smoker=()
Stroke=()
Veggies=()
class=()

# Loop through each record in the JSON file and extract feature values
while IFS= read -r record; do
  # Extract values for each feature using awk and append to corresponding arrays
  Age+=($(echo "$record" | awk -F'"Age":' '{print $2}' | awk -F',' '{print $1}' | tr -d ' '))
  AnyHealthcare+=($(echo "$record" | awk -F'"AnyHealthcare":' '{print $2}' | awk -F',' '{print $1}' | tr -d ' '))
  BMI+=($(echo "$record" | awk -F'"BMI":' '{print $2}' | awk -F',' '{print $1}' | tr -d ' '))
  CholCheck+=($(echo "$record" | awk -F'"CholCheck":' '{print $2}' | awk -F',' '{print $1}' | tr -d ' '))
  DiffWalk+=($(echo "$record" | awk -F'"DiffWalk":' '{print $2}' | awk -F',' '{print $1}' | tr -d ' '))
  Education+=($(echo "$record" | awk -F'"Education":' '{print $2}' | awk -F',' '{print $1}' | tr -d ' '))
  Fruits+=($(echo "$record" | awk -F'"Fruits":' '{print $2}' | awk -F',' '{print $1}' | tr -d ' '))
  GenHlth+=($(echo "$record" | awk -F'"GenHlth":' '{print $2}' | awk -F',' '{print $1}' | tr -d ' '))
  HeartDiseaseorAttack+=($(echo "$record" | awk -F'"HeartDiseaseorAttack":' '{print $2}' | awk -F',' '{print $1}' | tr -d ' '))
  HighBP+=($(echo "$record" | awk -F'"HighBP":' '{print $2}' | awk -F',' '{print $1}' | tr -d ' '))
  HighChol+=($(echo "$record" | awk -F'"HighChol":' '{print $2}' | awk -F',' '{print $1}' | tr -d ' '))
  HvyAlcoholConsump+=($(echo "$record" | awk -F'"HvyAlcoholConsump":' '{print $2}' | awk -F',' '{print $1}' | tr -d ' '))
  Income+=($(echo "$record" | awk -F'"Income":' '{print $2}' | awk -F',' '{print $1}' | tr -d ' '))
  MentHlth+=($(echo "$record" | awk -F'"MentHlth":' '{print $2}' | awk -F',' '{print $1}' | tr -d ' '))
  NoDocbcCost+=($(echo "$record" | awk -F'"NoDocbcCost":' '{print $2}' | awk -F',' '{print $1}' | tr -d ' '))
  PhysActivity+=($(echo "$record" | awk -F'"PhysActivity":' '{print $2}' | awk -F',' '{print $1}' | tr -d ' '))
  PhysHlth+=($(echo "$record" | awk -F'"PhysHlth":' '{print $2}' | awk -F',' '{print $1}' | tr -d ' '))
  Sex+=($(echo "$record" | awk -F'"Sex":' '{print $2}' | awk -F',' '{print $1}' | tr -d ' '))
  Smoker+=($(echo "$record" | awk -F'"Smoker":' '{print $2}' | awk -F',' '{print $1}' | tr -d ' '))
  Stroke+=($(echo "$record" | awk -F'"Stroke":' '{print $2}' | awk -F',' '{print $1}' | tr -d ' '))
  Veggies+=($(echo "$record" | awk -F'"Veggies":' '{print $2}' | awk -F',' '{print $1}' | tr -d ' '))
  class+=($(echo "$record" | awk -F'"class":' '{print $2}' | awk -F',' '{print $1}' | tr -d ' '))
done < <(jq -c '.[]' diabetes_records.json)

# Function to get min and max values from array
get_minmax() {
    local name=$1
    shift
    local arr=("$@")
    local min=${arr[0]}
    local max=${arr[0]}
    
    for value in "${arr[@]}"; do
        if (( $(echo "$value < $min" | bc -l) )); then
            min=$value
        fi
        if (( $(echo "$value > $max" | bc -l) )); then
            max=$value
        fi
    done
    
    echo "$name: min=$min, max=$max" >> mohammad_proof.txt
}

# Clear existing file
> mohammad_proof.txt

# Calculate and store min/max for each feature
echo "Feature Statistics:" >> mohammad_proof.txt
echo "==================" >> mohammad_proof.txt

# Process each feature
get_minmax "Age" "${Age[@]}"
get_minmax "BMI" "${BMI[@]}"
get_minmax "Education" "${Education[@]}"
get_minmax "GenHlth" "${GenHlth[@]}"
get_minmax "Income" "${Income[@]}"
get_minmax "MentHlth" "${MentHlth[@]}"
get_minmax "PhysHlth" "${PhysHlth[@]}"

echo "Statistics saved to mohammad_proof.txt"
cat mohammad_proof.txt
