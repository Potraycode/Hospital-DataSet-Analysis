-- Patient Insights (WHO are the customers?)
use hospital_;
-- 1. Total number of patients

SELECT count(*) as Patients_Count
FROM patients;

-- 2. Gender distribution

SELECT 
	Gender,
    count(*)
FROM patients
GROUP BY 1;

-- 3. Age group analysis (0–18, 19–35, 36–50, 50+)

UPDATE patients
SET date_of_birth = STR_TO_DATE(date_of_birth, '%Y-%m-%d');

WITH CTE_1 as (
	SELECT 
		*,
		round(datediff(now(), date_of_birth) / 365) as Age,
		case WHEN round(datediff(now(), date_of_birth) / 365) <= 18 THEN "0-18"
			WHEN round(datediff(now(), date_of_birth) / 365) <=35 THEN "19-35"
			WHEN round(datediff(now(), date_of_birth) / 365) <= 50 THEN "36-50"
			ELSE "50+"
		END as Age_Distribution
	FROM patients)

SELECT 
	Age_Distribution,
    count(*) as Patients
FROM CTE_1
GROUP BY 1;

-- 4. Patients with highest number of visits

SELECT 
	P.PATIENT_ID,
    concat(FIRST_NAME,' ', LAST_NAME) AS NAME,
    COUNT(APPOINTMENT_ID) AS NUMBER_OF_VISIT
FROM patients as p
LEFT JOIN appointments as a
ON a.patient_id = p.patient_id
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 5;

-- 5. Patients with highest medical spending

SELECT 
	P.PATIENT_ID,
    concat(FIRST_NAME,' ', LAST_NAME) AS PATIENT_NAME,
    ROUND(SUM(AMOUNT)) AS TOTAL_AMOUNT
FROM PATIENTS AS P
INNER JOIN BILLING AS B
ON P.PATIENT_ID = B.PATIENT_ID
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 3;

-- Doctor Performance Insights (WHO generates value?)

-- 1. Number of doctors by specialization

SELECT 
	SPECIALIZATION, 
    COUNT(*) AS TOTAL_DOCTORS
FROM DOCTORS
GROUP BY SPECIALIZATION;

-- 2. Appointments handled by each doctor

SELECT
	a.Doctor_id,
    concat(first_name,' ',last_name) as Doctor_Name,
    count(appointment_id) AS Appointment 
FROM doctors as d
INNER JOIN appointments as a
ON d.doctor_id = a.doctor_id
GROUP BY 1,2
ORDER BY 3 DESC;

-- 3. Revenue generated per doctor

SELECT 
	d.doctor_id,
	concat(first_name,' ',last_name) as Doctor_Name,
	round(sum(amount)) as Total_Revenue
FROM appointments as a
LEFT JOIN billing as b
ON a.patient_id = b.patient_id
LEFT JOIN doctors as d
ON d.doctor_id = a.doctor_id
GROUP BY 1,2
ORDER BY 3;

-- Appointment Analysis (HOW operations run)

-- 1. Appointments by month

WITH app_mon as (
SELECT *,
	monthname(appointment_date) as Month_
FROM appointments)

SELECT 
	Month_,
    count(*)
FROM app_mon
GROUP BY Month_;

-- 2. Appointment status (completed, cancelled, no-show)

SELECT
	Status,
    count(*) as Patients
FROM appointments
GROUP BY 1;

-- Patient no-show rate

WITH no_show as (
SELECT
	Status,
    count(*) as Patients
FROM appointments
GROUP BY 1)

SELECT
	*,
    patients * 100 / 200 as Contribution
FROM no_show
WHERE status = 'No-show';

-- Treatment Insights (WHAT services are used?)

-- 1. Most Common Treatment

SELECT 
	Treatment_Type,
    count(*) as Count
FROM treatments
GROUP BY treatment_type;

-- 2. Treatments by specialization

SELECT 
	d.specialization as Specialiazation,
    t.Treatment_type as Treatment,
    count(*) as Count
FROM appointments as a
LEFT JOIN doctors as d
ON a.doctor_id = d.doctor_id
LEFT JOIN treatments as t 
ON t.appointment_id = a.appointment_id
GROUP BY 1,2
ORDER BY 1,3 DESC;

-- Billing & Revenue Insights (WHERE money comes from.)

-- Total revenue

SELECT 
	round(sum(amount),1) as Total_Revenue
FROM billing;

-- Revenue by treatment type

SELECT 
	Treatment_Type,
    round(sum(Cost)) as Total_Revenue
FROM treatments
GROUP BY 1;

-- Top 10 highest paying patients

SELECT 
	p.Patient_Id,
    concat(first_name,' ',last_name) as Patient_Name,
    round(sum(amount)) Total_Revenue
FROM patients as p
LEFT JOIN billing as b
ON p.patient_id = b.patient_id
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 10;

-- Revenue per doctor per day

SELECT 
	a.appointment_date Appoint_Date,
    a.doctor_id as Doctor_ID,
    round(sum(Amount),2) as Per_day_Revenue
FROM appointments as a
INNER JOIN billing as b
ON a.patient_id = b.patient_id
GROUP BY 1,2;

-- Which age group generates the highest revenue?

WITH Age_group as (
SELECT
	*,
    round(datediff(now(),date_of_birth)/365) AS Age,
    CASE WHEN round(datediff(now(),date_of_birth)/365) <=18 THEN "<18"
		WHEN round(datediff(now(),date_of_birth)/365) <= 35 THEN "19-35"
        WHEN round(datediff(now(),date_of_birth)/365) <=50 THEN "36-50"
        ELSE ">50"
	END as Age_Distribution
FROM patients)

SELECT
	Age_Distribution,
    round(sum(amount)) as Total_Revenue
FROM Age_group as ag
LEFT JOIN billing as b
ON ag.patient_id = b.patient_id
GROUP BY 1
ORDER BY 2;

-- Which doctor specialization is most profitable?

SELECT
	Specialization,
    round(sum(Amount)) as Total_Amount 
FROM doctors d 
LEFT JOIN appointments as a
ON d.doctor_id = a.doctor_id
LEFT JOIN billing as b
ON a.patient_id = b.patient_id
GROUP BY 1;

-- Patient lifetime value (total spend per patient)

SELECT 
	p.Patient_ID,
	concat(p.first_name,' ',p.last_name) as Name,
    round(sum(Amount)) as Total_Spent
FROM patients as p
LEFT JOIN billing as b
ON p.patient_id = b.patient_id
GROUP BY 1,2;



select * from patients;
select * from appointments;
select * from billing;
select * from doctors;
select * from treatments;
