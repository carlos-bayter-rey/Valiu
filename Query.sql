--This is the query that gets the date of customer first transaction in format year-month
WITH Customer AS
(
	SELECT customerId AS Customer, 
		   MIN(CAST(createdAt as VARCHAR(7))) AS FirstMonth,
		   1 as Ind,
		   COUNT(id) as Sales,
		   SUM(total) as totalSales
	FROM transfer
	GROUP BY customerId
),
--This is the query that gets all the datees of transactions by customer, group by year-month
Sales AS
(
	SELECT customerId AS Customer,
		   CAST(createdAt as VARCHAR(7)) AS month,
		   1 as Ind,
		   COUNT(id) as Sales,
		   SUM(total) as totalSales
	FROM TRANSFER
	GROUP BY customerId, CAST(createdAt as VARCHAR(7))
),
--This query gets the number of transactions group by month of first transaction 
--and month of current transaction
TOTAL AS
(
SELECT CUS.FirstMonth, 
	   SAL.Month, 
	   COUNT(DISTINCT CUS.CUSTOMER) AS CUST_PER_MONTH 
FROM Customer CUS
LEFT JOIN Sales SAL
ON CUS.customer = SAL.Customer AND CUS.FirstMonth <= SAL.Month
GROUP BY FirstMonth, Month
ORDER BY FirstMonth, Month
),
--This query gets the total number of customers in the first month and calculate the 
--percentage of retention per each year-month
RETENTION AS
(

SELECT T1.firstMonth, T1.month, T1.cust_per_month, T2.cust_first_month, round(t1.cust_per_month * 100 / T2.cust_first_month,2) AS Retention_Percentage
FROM TOTAL T1
INNER JOIN (SELECT firstMonth, SUM(CUST_PER_MONTH) AS CUST_FIRST_MONTH FROM TOTAL WHERE FirstMonth = Month GROUP BY firstMonth) T2
ON T1.firstMonth = T2.FirstMonth
)
--Shows the first month of transactions, current month, customer with transactions in 
--current month, customer with first transaction on first month
--and the retention percentage per month.
SELECT * FROM RETENTION
