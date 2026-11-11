DROP VIEW cohort_analysis;
CREATE OR REPLACE VIEW cohort_analysis AS
WITH customer_revenue AS(
	SELECT 
		s.customerkey,
		s.orderdate,
		SUM(s.quantity * s.netprice * s.exchangerate) AS total_net_revenue,
		COUNT(s.orderkey) AS num_orders,
		MAX(c.countryfull) AS countryfull,
		MAX(c.age) AS age,
		MAX(c.givenname) AS givenname,
		MAX(c.surname) AS surname
	FROM sales s
	LEFT JOIN customer c 
		ON s.customerkey = c.customerkey 
	GROUP BY 
		s.customerkey,
		s.orderdate
)

SELECT
	customerkey,
	orderdate,
	total_net_revenue,
	num_orders,
	countryfull,
	age,
	CONCAT(TRIM(BOTH FROM givenname), ' ', TRIM(BOTH FROM surname)) AS full_name,
	MIN(orderdate) OVER(PARTITION BY customerkey) AS first_purchased_date,
	EXTRACT(YEAR FROM MIN(orderdate) OVER(PARTITION BY customerkey)) AS cohort_year
FROM customer_revenue
