CREATE DATABASE LOAN_DB;
USE LOAN_DB;

# DATA EXPLORATION
-- Count the number of records: Total number of records in the dataset. 
SELECT COUNT(*) AS total_records FROM loan;
-- Data types of columns: Overview of data types
DESCRIBE loan;
-- Sample records: Example records from the dataset
SELECT * FROM loan LIMIT 5;
-- Statistical Summary of data
SELECT
	CONCAT(FORMAT(COUNT(id)/1000,2)," K") AS TOTAL_LOAN_APPLICATION,
    CONCAT("₹ ",FORMAT(SUM(loan_amnt)/1000000,2)," M") AS TOTAL_LOAN_AMOUNT,
    CONCAT("₹ ",FORMAT(SUM(funded_amnt)/1000000,2)," M") AS TOTAL_FUNDED_AMOUNT,
    CONCAT("₹ ",FORMAT(SUM(total_pymnt)/1000000,2)," M") AS TOTAL_PAYMENT,
    CONCAT(FORMAT(AVG(int_rate)*100,2)," %") AS AVERAGE_INTEREST_RATE,
	FORMAT(AVG(dti),2) AS AVERAGE_DTI
FROM loan;

#DATA CLEANING
-- Handle Missing Values
SELECT * FROM loan
WHERE COALESCE(id, member_id, loan_amnt, funded_amnt, funded_amnt_inv,term,
				int_rate, installment, grade, sub_grade, home_ownership, annual_inc,
                verification_status, issue_d, loan_status, purpose, zip_code, addr_state,
                dti, earliest_cr_line, open_acc, revol_bal, total_acc, total_pymnt,
                total_pymnt_inv, total_rec_prncp, total_rec_int, total_rec_late_fee,
                recoveries, collection_recovery_fee, last_pymnt_d, last_pymnt_amnt,
                next_pymnt_d, last_credit_pull_d) IS NULL;

-- Check for Duplicates: Identifying and removing duplicate records
SELECT id, member_id, loan_amnt, funded_amnt, funded_amnt_inv,term,
				int_rate, installment, grade, sub_grade, home_ownership, annual_inc,
                verification_status, issue_d, loan_status, purpose, zip_code, addr_state,
                dti, earliest_cr_line, open_acc, revol_bal, total_acc, total_pymnt,
                total_pymnt_inv, total_rec_prncp, total_rec_int, total_rec_late_fee,
                recoveries, collection_recovery_fee, last_pymnt_d, last_pymnt_amnt,
                next_pymnt_d, last_credit_pull_d, 
COUNT(*) AS duplicate_count
FROM loan
GROUP BY id, member_id, loan_amnt, funded_amnt, funded_amnt_inv,term,
				int_rate, installment, grade, sub_grade, home_ownership, annual_inc,
                verification_status, issue_d, loan_status, purpose, zip_code, addr_state,
                dti, earliest_cr_line, open_acc, revol_bal, total_acc, total_pymnt,
                total_pymnt_inv, total_rec_prncp, total_rec_int, total_rec_late_fee,
                recoveries, collection_recovery_fee, last_pymnt_d, last_pymnt_amnt,
                next_pymnt_d, last_credit_pull_d
HAVING COUNT(*) > 1;

-- Data Type Conversion: Converting fields to appropriate data types
-- Create a New Backup Table
-- To preserve the original data, a backup table is created with the same structure as the original table.
CREATE TABLE loan_backup LIKE loan;
-- Copy Subset of Data from Original Table to Backup Table
-- A subset of the original data is copied to the backup table for testing the changes.
INSERT INTO loan_backup SELECT * FROM loan LIMIT 100;
desc loan_backup;

-- Data Type Conversion
-- Change data type of addr_state from TEXT to VARCHAR
ALTER TABLE loan_backup
MODIFY COLUMN addr_state VARCHAR(50);

-- Change data type of grade from TEXT to ENUM
ALTER TABLE loan_backup
MODIFY COLUMN grade ENUM('A', 'B', 'C', 'D', 'E', 'F', 'G');

-- Change data type of home_ownership from TEXT to ENUM
ALTER TABLE loan_backup
MODIFY COLUMN home_ownership ENUM('MORTGAGE', 'RENT', 'OWN', 'OTHER', 'NONE');

-- Change data type of issue_date, last_credit_pull_date, last_payment_date, next_payment_date from TEXT to DATE
-- Step 1: Add a new column with the desired data type
ALTER TABLE loan_backup ADD issue_date DATE;
ALTER TABLE loan_backup ADD last_pymnt_date DATE;
ALTER TABLE loan_backup ADD next_pymnt_date DATE;
ALTER TABLE loan_backup ADD last_credit_pull_date DATE;
-- Step 2: Update the new column with the converted values
-- Update the new column with converted values
UPDATE loan_backup
SET issue_date = STR_TO_DATE(issue_d, '%d-%m-%Y');
UPDATE loan_backup
SET last_pymnt_date = STR_TO_DATE(last_pymnt_d, '%d-%m-%Y');
UPDATE loan_backup
SET next_pymnt_date = STR_TO_DATE(next_pymnt_d, '%d-%m-%Y')
WHERE next_pymnt_d IS NOT NULL;
UPDATE loan_backup
SET last_credit_pull_date = STR_TO_DATE(last_credit_pull_d, '%d-%m-%Y');
-- Removing old column
ALTER TABLE loan_backup DROP COLUMN issue_d;
ALTER TABLE loan_backup DROP COLUMN last_pymnt_d;
ALTER TABLE loan_backup DROP COLUMN last_credit_pull_d;
-- Rename the new column to the original column name
ALTER TABLE loan_backup CHANGE COLUMN issue_date issue_d DATE;
ALTER TABLE loan_backup CHANGE COLUMN last_pymnt_date last_pymnt_d DATE;
ALTER TABLE loan_backup CHANGE COLUMN last_credit_pull_date last_credit_pull_d DATE;

-- Change data type of loan_status from TEXT to ENUM
ALTER TABLE loan_backup
MODIFY COLUMN loan_status ENUM('Fully Paid', 'Charged Off', 'Current');

-- Change data type of purpose, sub_grade from TEXT to VARCHAR
ALTER TABLE loan_backup
MODIFY COLUMN purpose VARCHAR(255),
MODIFY COLUMN sub_grade VARCHAR(5); -- adjust length if needed

-- Change data type of term from TEXT to ENUM
ALTER TABLE loan_backup
MODIFY COLUMN term ENUM('36 months', '60 months');

-- Change data type of verification_status from TEXT to ENUM
ALTER TABLE loan_backup
MODIFY COLUMN verification_status ENUM('Verified', 'Not Verified', 'Source Verified');

-- Change data type of dti, installment, int_rate from double to DECIMAL
ALTER TABLE loan_backup
MODIFY COLUMN dti DECIMAL(10, 4), -- adjust precision and scale as needed
MODIFY COLUMN installment DECIMAL(10, 2), -- adjust precision and scale as needed
MODIFY COLUMN int_rate DECIMAL(6, 4); -- adjust precision and scale as needed

 -- appling the changes to table loan
 ALTER TABLE loan
MODIFY COLUMN addr_state VARCHAR(50);

-- Change data type of grade from TEXT to ENUM
ALTER TABLE loan
MODIFY COLUMN grade ENUM('A', 'B', 'C', 'D', 'E', 'F', 'G');

-- Change data type of home_ownership from TEXT to ENUM
ALTER TABLE loan
MODIFY COLUMN home_ownership ENUM('MORTGAGE', 'RENT', 'OWN', 'OTHER', 'NONE');

-- Change data type of issue_date, last_credit_pull_date, last_payment_date, next_payment_date from TEXT to DATE
-- Step 1: Add a new column with the desired data type
ALTER TABLE loan ADD issue_date DATE;
ALTER TABLE loan ADD last_pymnt_date DATE;
ALTER TABLE loan ADD next_pymnt_date DATE;
ALTER TABLE loan ADD last_credit_pull_date DATE;
-- Step 2: Update the new column with the converted values
-- Update the new column with converted values
UPDATE loan SET issue_date = STR_TO_DATE(issue_d, '%d-%m-%Y');
UPDATE loan SET last_pymnt_date = STR_TO_DATE(last_pymnt_d, '%d-%m-%Y');
UPDATE loan SET next_pymnt_date = STR_TO_DATE(next_pymnt_d, '%d-%m-%Y') WHERE next_pymnt_d IS NOT NULL;
UPDATE loan SET last_credit_pull_date = STR_TO_DATE(last_credit_pull_d, '%d-%m-%Y');
-- Removing old column
ALTER TABLE loan DROP COLUMN issue_d;
ALTER TABLE loan DROP COLUMN last_pymnt_d;
ALTER TABLE loan DROP COLUMN next_pymnt_d;
ALTER TABLE loan DROP COLUMN last_credit_pull_d;
-- Rename the new column to the original column name
ALTER TABLE loan CHANGE COLUMN issue_date issue_d DATE;
ALTER TABLE loan CHANGE COLUMN last_pymnt_date last_pymnt_d DATE;
ALTER TABLE loan CHANGE COLUMN next_pymnt_date next_pymnt_d DATE;
ALTER TABLE loan_backup CHANGE COLUMN last_credit_pull_date last_credit_pull_d DATE;

-- Change data type of loan_status from TEXT to ENUM
ALTER TABLE loan
MODIFY COLUMN loan_status ENUM('Fully Paid', 'Charged Off', 'Current');

-- Change data type of purpose, sub_grade from TEXT to VARCHAR
ALTER TABLE loan
MODIFY COLUMN purpose VARCHAR(255),
MODIFY COLUMN sub_grade VARCHAR(5); -- adjust length if needed

-- Change data type of term from TEXT to ENUM
ALTER TABLE loan
MODIFY COLUMN term ENUM('36 months', '60 months');

-- Change data type of verification_status from TEXT to ENUM
ALTER TABLE loan
MODIFY COLUMN verification_status ENUM('Verified', 'Not Verified', 'Source Verified');

-- Change data type of dti, installment, int_rate from double to DECIMAL
ALTER TABLE loan
MODIFY COLUMN dti DECIMAL(10, 4), -- adjust precision and scale as needed
MODIFY COLUMN installment DECIMAL(10, 2), -- adjust precision and scale as needed
 MODIFY COLUMN int_rate DECIMAL(6, 4); -- adjust precision and scale as needed

-- BUILDING KPI's
SELECT * FROM loan LIMIT 5;
-- TOTAL LOAN APPLICATIONS
SELECT CONCAT(FORMAT(COUNT(id)/1000,2)," K") AS TOTAL_LOAN_APPLICATION FROM LOAN;
-- MTD
SELECT CONCAT(FORMAT(count(id)/1000,2)," K") as MTD_loan_applications from loan
WHERE MONTH(issue_d) = 12 AND YEAR(issue_d) = 2023;
-- PMTD
SELECT CONCAT(FORMAT(count(id)/1000,2)," K") as PMTD_loan_applications from loan
WHERE MONTH(issue_d) = 11 AND YEAR(issue_d) = 2023;
-- TOTAL LOAN AMOUNT
SELECT CONCAT(FORMAT(SUM(loan_amnt)/1000000,2)," M") AS Total_loan_amount
FROM loan;
-- TOTAL FUNDED AMOUNT
SELECT CONCAT(FORMAT(SUM(funded_amnt)/1000000,2)," M") AS Total_funded_amount
FROM loan;
-- TOTAL PAYMENT
SELECT CONCAT(FORMAT(SUM(total_pymnt)/1000000,2)," M") AS Total_payment
FROM loan;
--  Average Interest Rate
SELECT CONCAT(FORMAT(AVG(int_rate)*100,2)," %") as Average_interest_rate
FROM loan WHERE YEAR(issue_d) = 2023;
-- Average dti
SELECT FORMAT(AVG(dti),2) as Average_dti
FROM loan WHERE YEAR(issue_d) = 2023;
-- Month to date total amount
SELECT YEAR(issue_d) as Year, MONTH(issue_d) as Month,
CONCAT(" ₹ ",FORMAT(SUM(total_pymnt)/1000000,2)," M") as Total_Amount_Received 
    FROM loan WHERE YEAR(issue_d) = 2023
GROUP BY YEAR(issue_d),MONTH(issue_d)
ORDER BY Month;

-- Year wise Loan Amount Status 
SELECT YEAR(issue_d) AS loan_year, loan_status,
    CONCAT(" ₹ ",FORMAT(SUM(loan_amnt)/1000000,2)," M") AS total_loan_amount,
    CONCAT("₹ ",FORMAT(COUNT(*)/1000,2)," K") AS total_loans
FROM loan GROUP BY YEAR(issue_d), loan_status
ORDER BY loan_year, loan_status;

-- Grade and sub grade wise revol_bal
SELECT grade, sub_grade,
    CONCAT("₹ ",FORMAT(SUM(revol_bal)/1000000,2)," M") AS Total_revol_bal,
    CONCAT("₹ ",FORMAT(AVG(revol_bal)/1000,2)," K") AS Average_revol_bal,
    CONCAT("₹ ",MIN(revol_bal)) AS Minimum_revol_bal,
    CONCAT("₹ ",FORMAT(MAX(revol_bal)/1000,2)," K") AS Maximum_revol_bal
FROM loan GROUP BY grade, sub_grade 
ORDER BY grade, sub_grade;

-- Total Payment for Verified Status Vs Total Payment for Non Verified Status 
SELECT 
    CASE 
WHEN verification_status IN ('Verified', 'Source Verified') THEN 'Verified'
 ELSE 'Non Verified' END AS verification_status,
CONCAT("₹ ",FORMAT(SUM(total_pymnt)/1000000,2)," M") AS Total_payment
FROM loan 
GROUP BY 
    CASE WHEN verification_status IN ('Verified', 'Source Verified') THEN 'Verified' ELSE 'Non Verified' END;
-- State wise and last_credit_pull_d wise loan status
SELECT addr_state, last_credit_pull_d, loan_status,
		COUNT(*) AS loan_count
FROM loan
GROUP BY addr_state, last_credit_pull_d, loan_status
ORDER BY addr_state, last_credit_pull_d, loan_status;

-- Home ownership Vs last payment date stats    
SELECT 
    home_ownership,
    last_pymnt_d,
    loan_status,
    COUNT(*) AS loan_count
FROM 
    loan
GROUP BY 
    home_ownership, 
    last_pymnt_d, 
    loan_status
ORDER BY 
    home_ownership, 
    last_pymnt_d, 
    loan_status;
