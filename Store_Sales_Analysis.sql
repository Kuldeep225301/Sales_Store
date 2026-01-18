
CREATE TABLE sales_store (
transaction_id VARCHAR(15),
customer_id VARCHAR(15),
customer_name VARCHAR(30),
customer_age INT,
gender VARCHAR(15),
product_id VARCHAR(15),
product_name VARCHAR(15),
product_category VARCHAR (15),
quantiy INT,
prce FLOAT,
payment_mode VARCHAR(15),
purchase_date DATE,
time_of_purchase TIME,
status VARCHAR(15)
);


SELECT * FROM sales_store;

-- IMPORT DATA USING BULK INSERT METHOD-- 

SET DATEFORMAT dmy
BULK INSERT sales_store 
FROM 'C:\Users\asus\Downloads\sales_store.csv'
	WITH(
		FIRSTROW =2,
		FIELDTERMINATOR=',',
		ROWTERMINATOR = '\n'
	);

-- NOTE: SQL only this -> YYYY-MM-DD

SELECT * FROM sales_store;

-- DATA CLEANING

SELECT * FROM sales_store;

-- Crating a copy of dataset -> sales table

SELECT * INTO sales from sales_store

select * from sales  -- this is my table(copy table) and original table is -> sales_store

-- Data Cleaning

-- Step 1: To Check For Duplicates

SELECT transaction_id, count(*)
from sales
group by transaction_id
having count(transaction_id)>1

-- OR
with cte as(
select *,
		row_number() over(partition by transaction_id order by transaction_id) as Row_Num
		From sales
)

-- DELETE FROM cte 
-- where Row_Num=2

select * from CTE
where transaction_id IN ('TXN240646',
'TXN342128',
'TXN855235',
'TXN981773')

-- Step-2 Correction of Headers

EXEC sp_rename'sales.quantiy','quantity','COLUMN' 

EXEC sp_rename'sales.prce','price', 'COLUMN'

select * from sales

-- Step-3 To Check Datatype

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'sales'

-- Step-4 To Check Null Values
-- 1st Method-> to Check null count

DECLARE @SQL NVARCHAR(MAX) = '';

SELECT @SQL = STRING_AGG(
    'SELECT ''' + COLUMN_NAME + ''' AS Column_Name,
       COUNT(*) AS NullCount
     FROM ' + QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME) + '
     WHERE ' + QUOTENAME(COLUMN_NAME) + ' IS NULL',
    ' UNION ALL '
)
WITHIN GROUP (ORDER BY COLUMN_NAME)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'sales';

-- Execute the dynamic SQL
EXEC sp_executesql @SQL;


-- Step-2 Treating Null Values

select * 
from sales
Where transaction_id is Null
or 
customer_id is null
or customer_name is null
or customer_age is null
or gender is null
or
payment_mode is null
or
price is null
or
product_category is null
or 
product_id is null
or
product_name is null
or
purchase_date is null
or
quantity is null


-- Deleting the first row because he represting outlier(Null)

Delete from sales
where transaction_id is null

select * from sales;

select * from sales
where customer_name = 'Ehsaan Ram'

Update sales
set customer_id= 'CUST9494'
where transaction_id = 'TXN977900'


select * from sales 
where customer_name = 'Damini Raju'

update sales
set customer_id = 'CUST1401'
where transaction_id = 'TXN985663'

select * from sales
where customer_id = 'CUST1003'

update sales
set customer_name='Mahika Saini', customer_age='35', gender='Male'
where transaction_id = 'TXN432798'

-- now we can see
select * from sales
where customer_id = 'CUST1003'  -- Now No null value is present in table


select * from sales;

-- Step-5 Data Cleaning For Gender & Payment_Mode

select distinct gender
from sales;


update sales
set gender = 'M'
where gender = 'Male'

Update sales
set gender = 'F'
where gender = 'Female'

select * from sales

-- Now we in payment_mode

select Distinct payment_mode from sales

update sales
set payment_mode = 'Credit Card'
where payment_mode = 'cc'

select  * from sales
select Distinct payment_mode from sales

-- Data Analysis

-- Solving Business Insights Questions

--Question 1 ->  What are the top 5 most selling product by quantity ?

select * from sales;

SELECT TOP 5 
product_name, sum(quantity) as total_quantity_sold
from sales
WHERE status = 'delivered'
group by  product_name
order by total_quantity_sold DESC;

-- Business problem: We don't know which products are most in demond.

-- Business Impact: helps prioritize stcck and boost sales through targeted promotions.



-- Question 2 -> Which products are most frequently canceled ?

select * from sales


select top 5 product_name,
count(*) as total_canceled
from sales
WHERE status = 'cancelled'
group by product_name
oRder by total_canceled DESC 

-- Business problem:Frequent cancelletions affect revenue and customer trust.

-- Bussiness Impact: Identify poor-performing products to improve quality or remove from catalog.


-- Question 3 -> What time of the day has the highest number of purchases ?

select * from sales

select 
	CASE
		WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
		WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
		WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
		WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
		END AS time_of_day,
		COUNT(*) total_order

from sales
group by
	case
		WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
		WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
		WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
		WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
		END 
order by total_order DESC

-- Business problem: Find peak sales times.
-- Business Impact: Optimize staffing, promotions and server loads.


-- Question 4 -> Who are the top 5 Highest spending customers?

select * from sales

select top 5 customer_name,
FORMAT(SUM(price*quantity), 'C0', 'en-IN') as total_spend
from sales
group by customer_name
order by SUM(price*quantity) DESC;

-- Business problem: identify VIP  customers.
-- Business Impact: Personalized offers, loyalty rewards, and retention.

-- Question 5 -> Which product categories generate the highest revene.

select * from sales

select
product_category,
FORMAT(sum(price*quantity),'C0', 'en-IN')as total_revenue
FROM sales
group by product_category
order by sum(price*quantity) DESC

-- Business problem: identify Top-performing product categories.
-- Business Impact: Refine product strategy, supply chain, and promotions
-- allowing the business to invest more in high-margin or high-demond categories.

-- Question 6 -> What is the return/ cancellation rate per product category?

select * from sales

-- cancellation Rate

select product_category,
		FORMAT(COUNT(CASE WHEN status ='cancelled' THEN 1 end)*100.0/count(*), 'N3') + ' %' as cancelled_percent

from sales
group by product_category
order by cancelled_percent DESC

-- Returned Rate

select product_category,
		format(count(case when status = 'returned' then 1 end)*100.0/count(*), 'N3')+ ' %' as total_returned
from sales
group by product_category
order by total_returned DESC

-- Business Problem: Monitor dissatisfication trends per cancellation and returned.
-- Business Impact: Reduce Returns, improve Products descriptions/Expectations.
-- Help identify and fix product or logistics issues.

-- Question 7- What is the most preferred payment mode.

select * from sales

select payment_mode, COUNT(payment_mode) as total_count
from sales
group by payment_mode
order by total_count DESC

-- Business Problem: Identify know which payment options customers prefer.

-- Business Impact: Streamline Payment processing, prioritize popular modes.

-----------------------------------------------------------------------------------------

-- Question 8 -> How Does age group affect purchasing behaviour ?

select * from sales

select min(customer_age) , max(customer_age) from sales


SELECT
		CASE	
			WHEN customer_age BETWEEN 18 AND 25 THEN '18-25' 
			WHEN customer_age BETWEEN 26 AND 35 THEN '26-35' 
			WHEN customer_age BETWEEN 36 AND 50 THEN '36-50' 
			WHEN customer_age BETWEEN 26 AND 35 THEN '26-35' 
			else '51+'
		END AS customer_age,

FORMAT(sum(price*quantity), 'C0', 'en-IN') as total_purchase
FROM sales
group by CASE	
			WHEN customer_age BETWEEN 18 AND 25 THEN '18-25' 
			WHEN customer_age BETWEEN 26 AND 35 THEN '26-35' 
			WHEN customer_age BETWEEN 36 AND 50 THEN '36-50' 
			WHEN customer_age BETWEEN 26 AND 35 THEN '26-35' 
			else '51+'
		END
order by total_purchase DESC

-- Business Problem: Understand customer demographics.
-- Business Impact:Targeted marketung and product recommendations by age group.

---------------------------------------------------------------------------

-- Question 10 -> What's the monthly sales trend ?

select * from sales

-- Method 1: Using Format

select 
	format(purchase_date, 'yyyy-MM') as Month_Year,
	FORMAT(SUM(price*quantity), 'C0', 'en-IN' )as total_sales,
	SUM(quantity) as total_quantity

from sales
group by FORMAT(purchase_date, 'yyyy-MM')

-- Method 2: Using year_month

SELECT 
	YEAR(purchase_date) AS Years,
	MONTH(purchase_date) AS Months,
	format(Sum(price*quantity),'C0','en-IN') as total_sales,
	sum(quantity) as total_quantity

FROM sales
group by YEAR(purchase_date), MONTH(purchase_date)
order by Months
		
-- Business Problem: Sales fluctuations go unnoticed.
-- Business Impact:Plan Inventory and marketing according to seasonal trends.

---------------------------------------------------------------------------

-- Question 10 -> Are certain genders buying more specific product categories?

select * from sales

-- Method 1

select gender,
product_category,
count(product_category) as total_purchase
from sales
group by gender, product_category
order by gender

-- Method 2 same ouput ko Pivot me convert karte hai.

select  *
from (
		select gender, product_category from sales
) AS source_table
PIVOT(
	count(gender)
	for gender IN ([M], [F])
	) as pivot_table
order by product_category

	
-- Business Problem: Gender Based product performances:
-- Business Impact: Personalized ads, gender-focused campaigns.


