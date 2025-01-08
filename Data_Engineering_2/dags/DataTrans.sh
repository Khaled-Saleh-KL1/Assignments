#!/bin/bash

# Initialize files
input_file="/home/hadoop/diabetes_records.json"
outliers_removed="step1_outliers.json"
duplicates_removed="step2_duplicates.json"
final_cleaned="step3_cleaned.json"

echo "Starting data cleaning process..."

# Check if input file exists
if [ ! -f "$input_file" ]; then
    echo "Error: Input file '$input_file' not found!"
    exit 1
fi

# Step 1: Handle outliers

echo "[" > "$outliers_removed"
echo "Step 1: Checking for outliers..."
jq -c '.[]' "$input_file" | while read -r line; do
    age=$(echo "$line" | jq '.Age // empty')
    bmi=$(echo "$line" | jq '.BMI // empty')
    
    # Validate age and BMI
    if [[ "$age" =~ ^[0-9]+$ ]] && [ "$age" -ge 0 ] && [ "$age" -le 120 ] && [ "$bmi" -ge 10 ] && [ "$bmi" -le 60 ]; then
        echo "$line," >> "$outliers_removed"
    else
        echo "Outlier found: $line"
    fi
done

sed -i '$ s/,$//' "$outliers_removed"
echo "]" >> "$outliers_removed"
echo "Outliers processed. Results:"




# Step 2: Remove duplicates
echo "[" > "$duplicates_removed"
echo -e "\nStep 2: Removing duplicates..."
declare -A seen_records
jq -c '.[]' "$outliers_removed" | while read -r line; do
    features=$(echo "$line" | jq -c '{
        Age,
        AnyHealthcare,
        BMI,
        CholCheck,
        DiffWalk,
        Education,
        Fruits,
        GenHlth,
        HeartDiseaseorAttack,
        HighBP,
        HighChol,
        HvyAlcoholConsump,
        Income,
        MentHlth,
        NoDocbcCost,
        PhysActivity,
        PhysHlth,
        Sex,
        Smoker,
        Stroke,
        Veggies,
        class
    }' | tr -d '[:space:]')
    
    if [ -z "${seen_records[$features]}" ]; then # -z: to check if it is empty or not.
        seen_records[$features]=1
        echo "$line," >> "$duplicates_removed"
    else
        echo "Duplicate record found with features: $features"
    fi
done
sed -i '$ s/,$//' "$duplicates_removed"
echo "]" >> "$duplicates_removed"



# Step 3: Normalize BMI

echo "[" > "$final_cleaned"
echo -e "\nStep 3: Normalizing BMI column..."

# Calculate min and max BMI values
min_bmi=$(jq -r '[.[].BMI] | min' "$duplicates_removed")
max_bmi=$(jq -r '[.[].BMI] | max' "$duplicates_removed")

echo "Min BMI: $min_bmi, Max BMI: $max_bmi"

jq -c '.[]' "$duplicates_removed" | while read -r line; do
    bmi=$(echo "$line" | jq '.BMI // empty')
    
    if [[ -n "$bmi" ]]; then
        normalized_bmi=$(awk -v bmi="$bmi" -v min_bmi="$min_bmi" -v max_bmi="$max_bmi" 'BEGIN { print (bmi - min_bmi) / (max_bmi - min_bmi) }')
        # Replace the BMI field with the normalized value
        line=$(echo "$line" | jq --arg normalized_bmi "$normalized_bmi" '.BMI = ($normalized_bmi | tonumber)')
    fi
    
    echo "$line," >> "$final_cleaned"
done

# Remove the trailing comma from the last line and close the JSON array
sed -i '$ s/,$//' "$final_cleaned"
echo "]" >> "$final_cleaned"

