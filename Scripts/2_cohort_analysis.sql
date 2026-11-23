/*
Purpose:
Analyse customer acquisition performance by cohort year.

The query focuses on revenue generated on each customer's first purchase date,
providing an overview of newly acquired customers across different cohorts.

Metrics:
- Total Customers: Number of unique customers acquired in each cohort year.
- Total Revenue: Revenue generated from customers' first purchases.
- Customer Revenue: Average first-purchase revenue per customer.
*/

SELECT
    cohort_year,

    /*
    Count unique customers to avoid double-counting
    customers within each cohort year.
    */
    COUNT(DISTINCT customerkey) AS total_customers,

    /*
    Calculate the total revenue generated
    from customers' first purchases.
    */
    SUM(net_rev) AS total_revenue,

    /*
    Calculate average first-purchase revenue
    per customer within each cohort.
    */
    SUM(net_rev) / COUNT(DISTINCT customerkey) AS customer_revenue

FROM cohort_analysis

/*
Filter the dataset to include only transactions
where the order date matches the customer's
first purchase date.
*/
WHERE orderdate = first_purchase_date

/*
Group results by cohort year to compare
customer acquisition performance over time.
*/
GROUP BY cohort_year;
