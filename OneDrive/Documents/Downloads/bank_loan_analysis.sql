use financial_data;
ALTER TABLE financial_loan MODIFY installment DECIMAL(10, 2);
select * from financial_loan;
select count(*) from financial_loan;
ALTER TABLE financial_loan ADD COLUMN con_issue_date DATE;

-- converting the date values in the 'issue_date' column to a valid date format and adding the values into the column 'con_issue_date'

UPDATE financial_loan 
SET con_issue_date = CASE 
	WHEN issue_date LIKE '__/__/____' THEN str_to_date(issue_date, '%d/%m/%Y')
    WHEN issue_date LIKE '__-__-____' THEN str_to_date(issue_date, '%d-%m-%Y')
    WHEN issue_date LIKE '____-__-__' THEN str_to_date(issue_date, '%Y-%m-%d')
    ELSE NULL
END;

select count(id) as total_loan_applications from financial_loan;

-- calculating total MTD loan applications

select count(id) as MTD_total_loan_applications
from financial_loan where month(issue_date) = 12 and year(issue_date) = 2021;  -- 4858 applications were received

SET SQL_SAFE_UPDATES = 0;

ALTER TABLE financial_loan
DROP COLUMN issue_date;

ALTER TABLE financial_loan 
CHANGE COLUMN con_issue_date issue_date DATE;

select count(*) as PMTD_total_loan_applications
from financial_loan where month(issue_date) = 11 and year(issue_date)=2021; -- 4391 applications received in previous month

-- calculating the MOM Total Loan applications

with MTD_app as (
select count(id) as MTD_total_loan_applications
from financial_loan where month(issue_date)=12 and year(issue_date)=2021),
PMTD_app as (
select count(id) as PMTD_total_loan_applications
from financial_loan where month(issue_date)= 11 and year(issue_date)=2021)

select ((MTD.MTD_total_loan_applications - PMTD.PMTD_total_loan_applications)/PMTD.PMTD_total_loan_applications * 100) as MOM_total_loan_applications
from MTD_app MTD, PMTD_app PMTD;

-- Calculating the total funded amount
select sum(loan_amount) as Total_Loan_Amount
FROM financial_loan;

-- calculating the avg Int Rate 

SELECT AVG(int_rate)*100 as MTD_avg_interest_rate from financial_loan
where month(issue_date)=12 and year(issue_date)=2021;

-- Calculating the PMTD avg int rate 
select avg(int_rate)*100 as PMTD_avg_interest_rate from financial_loan 
where month(issue_date) = 12 and year(issue_date) = 2021;

-- calculating the MoM avg int rate 
with MTD_avg_int as (
select avg(int_rate)*100 as MTD_Avg_interest_rate from financial_loan 
where month(issue_date)= 12 and year(issue_date)= 2021),
PMTD_avg_int as (
select avg(int_rate)*100 as PMTD_Avg_interest_rate from financial_loan
where month(issue_date) = 11 and year(issue_date)= 2021)

select ((MTD.MTD_Avg_interest_rate - PMTD.PMTD_Avg_interest_rate)/PMTD.PMTD_Avg_interest_rate*100) as MOM_Avg_interest_rate
from MTD_avg_int MTD, PMTD_avg_int PMTD;

-- calculating the avg debt to oncome ratio

select avg(dti)*100 as MTD_avg_DTI from financial_loan

-- calculating MTD DTI 

select avg(dti)* 100 as MTD_avg_DTI from financial_loan
where month(issue_date) =12 and year(issue_date) = 2021;

-- calculating the PMTD DTI

select avg(dti)* 100 as PMTD_avg_DTI from financial_loan
where month(issue_date) = 11 and year(issue_date)= 2021;

-- calculating the MOM DTI

with MTD_DTI AS (
SELECT AVG(dti) as MTD_avg_DTI 
from financial_loan
where month(issue_date) = 12 and year(issue_date) = 2021),
PMTD_DTI AS (
SELECT AVG(dti) as PMTD_avg_DTI 
FROM financial_loan
where month(issue_date) = 11 and year(issue_date) = 2021)

select ((MTD.MTD_avg_DTI - PMTD.PMTD_avg_DTI)/PMTD.PMTD_avg_DTI * 100 ) as MOM_avg_DTI
from MTD_DTI MTD, PMTD_DTI PMTD;

-- Calculating the good loan application percentage

select (count( case when loan_status = 'Fully paid' or loan_status = 'current' then id end)*100)/
count(id) as good_loan_percentage
from financial_loan;

-- calculating the total good loan applications 

select count(id) as Good_loan_applications 
from financial_loan
where loan_status = 'Fully_Paid' or loan_status ='current';

-- Calculating the good loan funded amount

select sum(loan_amount) as Good_Loan_Funded_Amount
from financial_loan where loan_status = 'Fully paid' or loan_status = 'current';

-- calculating the good loan amount received 

select sum(total_payment) as Good_Loan_Amount_Received
from financial_loan 
where loan_status = 'Fully paid' or loan_status = 'current';

-- Bad loan issued 
-- Bad loan percentage

select (count(case when loan_status = 'Charged off' then id end)*100)/
count(id) as Bad_loan_percentage
from financial_loan;

-- calculating the total count of bad loan applications

select count(id) as bad_loan_applications
from financial_loan
where loan_status = 'Charged off';

-- calculating the bad loan funded amount

select sum(loan_amount) as Bad_loan_funded_amount
from financial_loan
where loan_status = 'Charged off';

-- calculating the loan_count, Total_amount_received, Total_funded_amount, Interest_rate, DTI on the basis of the loan status

select loan_status, 
	count(id) as loan_count,
    sum(total_payment) as Total_Amount_Received,
    sum(loan_amount) as Total_Funded_Amount,
    avg(int_rate * 100) as interest_rate,
    avg(dti * 100) as DTI
from financial_loan
group by loan_status;

-- calculating the MTD_Total_Amount_Received, MTD_Total_Funded_Amount on the basis of loan_status

select loan_status, 
	sum(total_payment) as MTD_Total_Amount_Received,
    sum(loan_amount) as MTD_Total_Funded_Amount
from financial_loan 
where month(issue_date) = 12 and year(issue_date) = 2021
group by loan_status;

-- Calculating monthly Total_Loan_Applications, Total_Funded_Amount and Total_Amount_Received

select month(issue_date) as month_number,
	   monthname(issue_date) as month_name,
       count(id) as total_loan_applications,
       sum(loan_amount) as total_funded_amount,
       sum(total_payment) as total_amount_received
from financial_loan
group by month(issue_date), monthname(issue_date)
order by month(issue_date);

-- Bank loan report | overview - state

select address_state as state,
       count(id) as Total_Loan_Applications,
       sum(loan_amount) as Total_Funded_Amount,
       sum(total_payment) as Total_Amount_Received 
from financial_loan
group by address_state
order by address_state;

-- Bank Loan Report | overview - Term 
select term as term,
		count(id) as Total_Loan_Applications,
        sum(loan_amount) as Total_Funded_Amount,
        sum(total_payment) as Total_Amount_Received
from financial_loan
group by term
order by term;

-- BANK LOAN REPORT | OVERVIEW - EMPLOYEE LENGTH 
select emp_length as Employee_length,
	   count(id) as Total_Loan_Applications,
       sum(loan_amount) as Total_Funded_Amount,
       sum(Total_payment) as Total_Amount_Received
from financial_loan
group by emp_length
order by emp_length;

-- BANK LOAN REPORT | OVERVIEW - PURPOSE
select purpose as loan_purpose,
	   count(id) as Total_Loan_Applications,
       sum(loan_amount) as Total_Funded_Amount,
       sum(total_payment) as Total_Amount_Received
from financial_loan
group by purpose
order by purpose;

-- BANK LOAN REPORT | OVERVIEW - HOME OWNERSHIP 
select home_ownership as ownership_of_home,
	   count(id) as Total_Loan_Applications,
       sum(loan_amount) as Total_Funded_Amount,
       sum(total_payment) as Total_Amount_Received
from financial_loan
group by home_ownership
order by home_ownership;



