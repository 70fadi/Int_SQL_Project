SELECT 
	cohort_year, 
	count(DISTINCT customerkey) AS total_customers,
	sum(net_rev) AS total_revenue,
	sum(net_rev) / count(DISTINCT customerkey) AS customer_revenue
FROM
	cohort_analysis
WHERE ORDERdate =  first_purchase_date
GROUP BY 
	cohort_year