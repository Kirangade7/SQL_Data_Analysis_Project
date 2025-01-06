use bank;
select * from transactions;

-- 1. Detecting recursive fraudulent transactions
with recursive fraud_chain as ( 
select nameOrig as initial_account,
nameDest as next_account,
step,
amount,
newbalanceOrig
from 
transactions
where isFraud = 1 and type = 'transfer'

union all 

select fc.initial_account,
t.nameDest,t.step,t.amount, t.newbalanceOrig
from fraud_chain fc
join transactions t 
on fc.next_account = t.nameorig and fc.step < t.step 
where t.isfraud = 1 and t.type = 'transfer')

select * from fraud_chain;

-- 2. Analysing fraudulent activity over Time

with fraud_rolling as ( select nameOrig, step, 
SUM(isfraud) over ( partition by nameOrig order by step rows between 4 preceding and current row) as fraud_rolling
from transactions limit 10000) 

select * from fraud_rolling
where fraud_rolling > 0;

-- 3. complex fraud detection using multiple CTEs
-- use multiple CTEs to identify accounts with suspicious activity, including large transfers, consecutive transactions without balance change and 
-- flagged transactions 

with large_transfer as ( 
select nameOrig, step, amount from transactions where type = 'transfer' and amount > 500000),
no_balance_change as (
select nameOrig, step, oldbalanceOrg, newbalanceOrig from transactions where oldbalanceOrg=newbalanceOrig),
flagged_transactions as (
select nameOrig,step from transactions where isFlaggedFraud =1 limit 10 )

select lt.nameOrig 
from large_transfer lt 
join no_balance_change nbc on lt.nameorig = nbc.nameorig and lt.step = nbc.step
join flagged_transactions ft on lt.nameorig = ft.nameorig and lt.step = ft.step;

-- 4. write a query that checks if the computed new_updated_balance is the same as actual newbalanceDest in the table if they are equal, it returns those rows.

with CTE as (
select amount,nameOrig,oldbalanceOrg,newbalanceOrig, (amount + oldbalanceOrg) as new_updated_balance 
from transactions )
select * from CTE where new_updated_balance = newbalanceOrig;

-- 5. Detect transactions with zero balance before and after 
-- Q. Find transactions where destination account has zero balance before and after the transaction
-- SQL prompt - write a query to list transactions where oldbalanceDest or newbalanceDest is zero

with ZeroBalanceTransactions AS ( 
SELECT step, type, amount, nameDest, oldbalanceDest, newbalanceDest, isFraud
from transactions 
where oldbalanceDest = 0 and newbalanceDest = 0 limit 1000)

select step, type , amount , nameDest, oldbalanceDest, newbalanceDest, isFraud 
from ZeroBalanceTransactions; 