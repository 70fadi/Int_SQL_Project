WITH customer_ltv AS (
SELECT
	customerkey, 
	clean_name, 
	sum(net_rev) AS total_ltv
FROM 
cohort_analysis
GROUP BY 
	customerkey, 
	clean_name
), customer_segmentation AS (
SELECT 
	PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_ltv) AS ltv_25th_percentile,
	PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_ltv) AS ltv_75th_percentile
FROM 
	customer_ltv
), segment_values AS (
	select 
	c.*, 
	CASE 
		WHEN c.total_ltv < cs.ltv_25th_percentile THEN '1-low-value'
		WHEN c.total_ltv <= cs.ltv_75th_percentile THEN '2-mid-value'
		ELSE '3-high-value'
	END AS customer_segment
	
	FROM 
	customer_ltv c, 
	customer_segmentation cs
)
SELECT 
	customer_segment,
	sum(total_ltv) AS total_ltv, 
	count(customerkey) AS customer_count, 
	sum(total_ltv) / count(customerkey) AS avg_ltv
	
FROM 
	segment_values
GROUP BY 
	customer_segment
ORDER BY 
	customer_segment DESC 