select * from financial_loan limit 10;

-- Calculating the total applications received
select count(id) as total_loan_applications
from financial_loan; -- 38576

-- Calculating the MTD total loan applications
select count(id) as MTD_total_loan_applications
from financial_loan where month(issue_date) = 12 and year(issue_date) = 2021; -- 4314

-- Calculating the PMTD total loan applications
select count(id) as PMTD_total_loan_applications
from financial_loan where month(issue_date) = 11 and year(issue_date) = 2021; -- 4035

-- 	Calculating the MOM Total Loan Applications
With MTD_app as(
select count(id) as MTD_total_loan_applications
from financial_loan where month(issue_date) = 12 and year(issue_date) = 2021),
PMTD_app AS (
select count(id) as PMTD_total_loan_applications
from financial_loan where month(issue_date) = 11 and year(issue_date) = 2021)

SELECT 100*(MTD.MTD_total_loan_applications - PMTD.PMTD_total_loan_applications)/PMTD.PMTD_total_loan_applications
as MOM_total_loan_applications
from MTD_app MTD, PMTD_app PMTD;

-- calculating the toal funded amount
select sum(loan_amount) as total_loan_amount
from financial_loan; -- 435.757.075

-- calculating the mtd total funded amount
select sum(loan_amount) as MTD_total_loan_amount
from financial_loan 
where month(issue_date) = 12 and year(issue_date) = 2021 ; -- 53.981.425

-- calculating the pmtd total funded amount
select sum(loan_amount) as PMTD_total_loan_amount
from financial_loan 
where month(issue_date) = 11 and year(issue_date) = 2021 ; -- 47.754.825

-- 	Calculating the MOM Total Loan Funded
With MTD_funded as(
select sum(loan_amount) as MTD_total_loan_amount
from financial_loan 
where month(issue_date) = 12 and year(issue_date) = 2021),
PMTD_funded AS (
select sum(loan_amount) as PMTD_total_loan_amount
from financial_loan 
where month(issue_date) = 11 and year(issue_date) = 2021)

SELECT 100*(MTD.MTD_total_loan_amount - PMTD.PMTD_total_loan_amount)/PMTD.PMTD_total_loan_amount
as MOM_PTMD_total_loan_amount
from MTD_funded MTD, PMTD_funded PMTD;

-- calculating the total amount received
select sum(total_payment) as total_amount_received
from financial_loan; -- 473.070.933

-- calculating the mtd total amount received
select sum(total_payment) as MTD_total_amount_received
from financial_loan 
where month(issue_date) = 12 and year(issue_date) = 2021 ; -- 58.74.380

-- calculating the pmtd total amount received
select sum(total_payment) as PMTD_total_amount_received
from financial_loan 
where month(issue_date) = 11 and year(issue_date) = 2021 ; -- 50.132.030

-- 	Calculating the MOM Total Amount Received
With MTD_received as(
select sum(total_payment) as MTD_total_amount_received
from financial_loan 
where month(issue_date) = 12 and year(issue_date) = 2021),
PMTD_received AS (
select sum(total_payment) as PMTD_total_amount_received
from financial_loan 
where month(issue_date) = 11 and year(issue_date) = 2021 )

SELECT 100*(MTD.MTD_total_amount_received - PMTD.PMTD_total_amount_received)/PMTD.PMTD_total_amount_received
as MOM_total_amount_received
from MTD_received MTD, PMTD_received PMTD;

-- Calculating average interest rate
select avg(int_rate) as avg_int_rate from financial_loan; -- 0.120488

-- Calculating MTD average interest rate
select avg(int_rate) as MTD_avg_int_rate from financial_loan
where month(issue_date) = 12 and year(issue_date) = 2021; -- 0.12356

-- Calculating PMTD average interest rate
select avg(int_rate) as PMTD_avg_int_rate from financial_loan
where month(issue_date) = 11 and year(issue_date) = 2021; -- 0.119417

-- 	Calculating the MOM avg interest rate
With MTD_int as(
select avg(int_rate) as MTD_avg_int_rate from financial_loan
where month(issue_date) = 12 and year(issue_date) = 2021),
PMTD_int AS (
select avg(int_rate) as PMTD_avg_int_rate from financial_loan
where month(issue_date) = 11 and year(issue_date) = 2021 )

SELECT 100*(MTD.MTD_avg_int_rate - PMTD.PMTD_avg_int_rate)/PMTD.PMTD_avg_int_rate
as MOM_avg_int_rate
from MTD_int MTD, PMTD_int PMTD; -- 3.469545%

-- Calculating average debt-to-income ratio
select avg(dti)*100 as avg_DTI from financial_loan; -- 13.327%

-- Calculating MTD debt-to-income ratio
select avg(dti)*100 as MTD_DTI from financial_loan
where month(issue_date) = 12 and year(issue_date) = 2021; -- 13.6655%

-- Calculating PMTD debt-to-income ratio
select avg(dti)*100 as PMTD_DTI from financial_loan
where month(issue_date) = 11 and year(issue_date) = 2021; -- 13.3027%

-- 	Calculating the MOM debt-to-income ratio
With MTD_DTI as(
select avg(dti)*100 as MTD_DTI from financial_loan
where month(issue_date) = 12 and year(issue_date) = 2021),
PMTD_DTI AS (
select avg(dti)*100 as PMTD_DTI from financial_loan
where month(issue_date) = 11 and year(issue_date) = 2021)

SELECT 100*(MTD.MTD_DTI  - PMTD.PMTD_DTI)/PMTD.PMTD_DTI 
as MOM_DTI 
from MTD_DTI  MTD, PMTD_DTI  PMTD; -- 2.72729%

-- GOOD LOAN ISSUED
-- Good loan percentage
select 
(count( case when loan_status = 'Fully Paid' or loan_status = 'Current' then id end)*100)/
count(id) as Good_loan_Percentage
from financial_loan; -- 86.1753%

-- Good loan applications
select count(id) as Good_Loan_Applications
from financial_loan
where loan_status = 'Fully Paid' or loan_status = 'Current'; -- 33243

-- Good loan funded amount
select sum(loan_amount) as Good_Funded_Amount
from financial_loan
where loan_status = 'Fully Paid' or loan_status = 'Current'; -- 370.224.850

-- Good loan amount received
select sum(total_payment) as Good_Loan_Amount_Received
from financial_loan
where loan_status = 'Fully Paid' or loan_status = 'Current'; -- 435.786.170

-- BAD LOAN ISSUED
-- Bad loan percentage
select 
(count( case when loan_status = 'Charged off' then id end)*100)/
count(id) as Bad_loan_Percentage
from financial_loan; -- 13.8247%

-- Bad loan applications
select count(id) as Bad_Loan_Applications
from financial_loan
where loan_status = 'Charged off'; -- 5333

-- Bad loan funded amount
select sum(loan_amount) as Bad_Funded_Amount
from financial_loan
where loan_status = 'Charged off'; -- 65.532.225

-- Bad loan amount received
select sum(total_payment) as Bad_Loan_Amount_Received
from financial_loan
where loan_status = 'Charged off'; -- 37.284.763

-- LOAN STATUS
select 
loan_status,
count(id) as LoanCount,
sum(total_payment) as Total_Amount_Received,
sum(loan_amount) as Total_Funded_Amount,
concat(round(avg(int_rate *100),4),'%') as Interest_Rate,
concat(round(avg(dti*100),4),'%') as DTI
from financial_loan
group by loan_status;

-- MTD loan status
select 
loan_status,
sum(total_payment) as Total_Amount_Received,
sum(loan_amount) as Total_Funded_Amount
from 
financial_loan
where month(issue_date) = 12
group by loan_status;

-- BANK LOAN REPORT | OVERVIEW

-- Month
select 
month(issue_date) as month_number,
monthname(issue_date) as month_name,
count(id) as total_loan_applications,
sum(loan_amount) as Total_Funded_Amount,
sum(total_payment) as Total_Amount_Received
from financial_loan
group by month(issue_date), monthname(issue_date)
order by month(issue_date);

-- State
select 
address_state as state,
count(id) as total_loan_applications,
sum(loan_amount) as Total_Funded_Amount,
sum(total_payment) as Total_Amount_Received
from financial_loan
group by address_state
order by address_state;

-- Term
select 
term,
count(id) as total_loan_applications,
sum(loan_amount) as Total_Funded_Amount,
sum(total_payment) as Total_Amount_Received
from financial_loan
group by term
order by term;

-- Employee length
select
emp_length as employee_length,
count(id) as total_loan_applications,
sum(loan_amount) as Total_Funded_Amount,
sum(total_payment) as Total_Amount_Received
from financial_loan
group by emp_length;

-- Purpose
select
purpose,
count(id) as total_loan_applications,
sum(loan_amount) as Total_Funded_Amount,
sum(total_payment) as Total_Amount_Received
from financial_loan
group by purpose;

-- Home ownership
select
home_ownership,
count(id) as total_loan_applications,
sum(loan_amount) as Total_Funded_Amount,
sum(total_payment) as Total_Amount_Received
from financial_loan
group by home_ownership;




