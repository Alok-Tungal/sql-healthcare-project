show tables;
select * from diabetes_patient_health_data;

SHOW DATABASES;
USE diabetes;

SHOW TABLES;

RENAME TABLE diabetes_patient_health_data TO diabetes_data;

-- Total Diabetic vs Non-Diabetic Patients?
SELECT 
  Diabetes,
  COUNT(*) AS patient_count
FROM diabetes_data
GROUP BY Diabetes;

-- Average Glucose, BMI, and BP by Diabetes Status?
SELECT 
  Diabetes,
  ROUND(AVG(Glucose), 2) AS avg_glucose,
  ROUND(AVG(BMI), 2) AS avg_bmi,
  ROUND(AVG(BloodPressure), 2) AS avg_bp
FROM diabetes_data
GROUP BY Diabetes;

-- Age Group-Based Diabetes Rate?
SELECT 
  CASE
    WHEN Age < 30 THEN 'Under 30'
    WHEN Age BETWEEN 30 AND 50 THEN '30-50'
    ELSE 'Above 50'
  END AS age_group,
  COUNT(*) AS total,
  SUM(CASE WHEN Diabetes = 1 THEN 1 ELSE 0 END) AS diabetics,
  ROUND(100.0 * SUM(CASE WHEN Diabetes = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS diabetes_rate_pct
FROM diabetes_data
GROUP BY age_group;

-- High-Risk Patients (Glucose > 140 and BMI > 30)?
SELECT *
FROM diabetes_data
WHERE Glucose > 140 AND BMI > 30;

--  Zero Insulin but High Glucose Patients?
SELECT *
FROM diabetes_data
WHERE Insulin = 0 AND Glucose > 150;

--  Diabetes vs Pregnancy Count?
SELECT 
  Pregnancies,
  COUNT(*) AS total,
  SUM(CASE WHEN Diabetes = 1 THEN 1 ELSE 0 END) AS diabetic_cases
FROM diabetes_data
GROUP BY Pregnancies
ORDER BY Pregnancies;

-- BMI Risk Category Summary?
SELECT 
  CASE 
    WHEN BMI < 18.5 THEN 'Underweight'
    WHEN BMI BETWEEN 18.5 AND 24.9 THEN 'Normal'
    WHEN BMI BETWEEN 25 AND 29.9 THEN 'Overweight'
    ELSE 'Obese'
  END AS bmi_group,
  COUNT(*) AS total
FROM diabetes_data
GROUP BY bmi_group;

-- Glucose Risk Level Classification?
SELECT 
  CASE 
    WHEN Glucose < 100 THEN 'Normal'
    WHEN Glucose BETWEEN 100 AND 140 THEN 'Pre-Diabetic'
    ELSE 'Diabetic'
  END AS glucose_category,
  COUNT(*) AS patient_count
FROM diabetes_data
GROUP BY glucose_category;

-- Patients Over Age 50 With Diabetes?
SELECT *
FROM diabetes_data
WHERE Age > 50 AND Diabetes = 1;

-- Sort by Highest Diabetes Risk Score?
SELECT *
FROM diabetes_data
ORDER BY DiabetesPedigreeFunction DESC
LIMIT 10;

-- Identify Outliers in Glucose, BMI, and Insulin?
SELECT *
FROM diabetes_data
WHERE glucose > 200 OR bmi > 50 OR insulin > 300;

-- Flag Patients with Multiple Risk Factors?
SELECT *,
  CASE 
    WHEN glucose > 140 AND bmi > 30 AND age > 45 THEN 'High Risk'
    WHEN glucose BETWEEN 100 AND 140 OR bmi BETWEEN 25 AND 30 THEN 'Moderate Risk'
    ELSE 'Low Risk'
  END AS risk_level
FROM diabetes_data;

-- Diabetes Likelihood by BMI Category?

SELECT 
  CASE 
    WHEN bmi < 18.5 THEN 'Underweight'
    WHEN bmi BETWEEN 18.5 AND 24.9 THEN 'Normal'
    WHEN bmi BETWEEN 25 AND 29.9 THEN 'Overweight'
    ELSE 'Obese'
  END AS bmi_category,
  COUNT(*) AS total_patients,
  SUM(CASE WHEN diabetes = 1 THEN 1 ELSE 0 END) AS diabetics,
  ROUND(100.0 * SUM(CASE WHEN diabetes = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS diabetes_percent
FROM diabetes_data
GROUP BY bmi_category;

--  Distribution of Insulin Levels (Grouped Buckets)?
SELECT 
  CASE 
    WHEN insulin = 0 THEN 'Missing'
    WHEN insulin < 100 THEN '<100'
    WHEN insulin BETWEEN 100 AND 200 THEN '100–200'
    ELSE '>200'
  END AS insulin_range,
  COUNT(*) AS patients
FROM diabetes_data
GROUP BY insulin_range;

-- Average Diabetes Pedigree Score by Age Group?
SELECT    
  CASE     
    WHEN age < 30 THEN 'Under 30'     
    WHEN age BETWEEN 30 AND 50 THEN '30-50'     
    ELSE 'Above 50'   
  END AS age_group,   
  diabetes,   
  ROUND(AVG(DiabetesPedigreeFunction), 3) AS avg_risk_score 
FROM diabetes_data 
GROUP BY age_group, diabetes 
LIMIT 0, 1000;


-- Patients Needing Follow-Up (Custom Rules)?
SELECT *
FROM diabetes_data
WHERE 
  (glucose > 150 AND insulin = 0)
  OR (bmi > 35 AND diabetes = 1)
  OR (age > 60 AND BloodPressure > 90)
LIMIT 0, 1000;

--  Rank Patients by Highest Risk (Score = Glucose + BMI + Age)?
SELECT *,
  (glucose + bmi + age) AS risk_score
FROM diabetes_data
ORDER BY risk_score DESC
LIMIT 10;

-- Summary: Total Patients, Average Age, Diabetic % (All in One)?
SELECT 
  COUNT(*) AS total_patients,
  ROUND(AVG(age), 1) AS avg_age,
  ROUND(100.0 * SUM(CASE WHEN diabetes = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS diabetes_percent
FROM diabetes_data;

-- Time-Ready Table for Monthly Reporting (with category flags)?
SELECT 
  age,
  glucose,
  bmi,
  BloodPressure,
  CASE 
    WHEN bmi >= 30 THEN 'Obese'
    WHEN bmi BETWEEN 25 AND 29.9 THEN 'Overweight'
    ELSE 'Normal'
  END AS bmi_category,
  CASE 
    WHEN glucose >= 140 THEN 'High Glucose'
    ELSE 'Normal Glucose'
  END AS glucose_flag,
  diabetes
FROM diabetes_data
LIMIT 0, 1000;

-- Null or Missing Value Checker?
SELECT COUNT(*) AS total_rows,
  SUM(CASE WHEN glucose = 0 THEN 1 ELSE 0 END) AS missing_glucose,
  SUM(CASE WHEN insulin = 0 THEN 1 ELSE 0 END) AS missing_insulin,
  SUM(CASE WHEN bmi = 0 THEN 1 ELSE 0 END) AS missing_bmi
FROM diabetes_data;
