/*
Purpose:
Identify customer churn by cohort year based on purchase activity.

Customers are classified as:
- Churned: No purchase within the last 6 months.
- Active: Made a purchase within the last 6 months.

The analysis calculates:
- Number of churned and active customers per cohort.
- Total eligible customers per cohort.
- Percentage distribution of customer status.
*/


WITH customer_last_purchase AS (

    /*
    Step 1: Identify each customer's most recent purchase.

    ROW_NUMBER() ranks purchases for each customer:
    - Most recent purchase receives rank 1.
    - Older purchases receive progressively higher ranks.

    This allows us to isolate each customer's latest transaction.
    */

    SELECT
        cohort_year,
        customerkey,
        clean_name,
        orderdate,

        ROW_NUMBER() OVER (
            PARTITION BY customerkey
            ORDER BY orderdate DESC
        ) AS rn,

        first_purchase_date

    FROM cohort_analysis

),

churned_customers AS (

    /*
    Step 2: Determine customer status using a 6-month inactivity threshold.

    Customers whose first purchase occurred more than 6 months
    before the latest available sales date are included in the analysis.

    Customer classification:
    - Churned: Last purchase was more than 6 months ago.
    - Active: Last purchase was within the last 6 months.

    rn = 1 ensures only each customer's latest purchase is considered.
    */

    SELECT
        cohort_year,
        customerkey,
        clean_name,
        orderdate AS last_purchase_date,

        CASE
            WHEN orderdate < (
                SELECT MAX(orderdate) FROM sales
            ) - INTERVAL '6 months'
            THEN 'churned'
            ELSE 'active'
        END AS customer_status

    FROM customer_last_purchase

    WHERE rn = 1

    /*
    Exclude customers acquired within the last 6 months.

    This ensures customers have had sufficient time
    to meet the 6-month inactivity threshold.
    */

    AND first_purchase_date < (
        SELECT MAX(orderdate) FROM sales
    ) - INTERVAL '6 months'

)

/*
Step 3: Aggregate customer status by cohort year.

Metrics:
- Number of Customers: Customers classified as active or churned.
- Total Customers: Total eligible customers within each cohort.
- Status Percentage: Proportion of customers belonging to each status.

The window function calculates the cohort total without
requiring a separate aggregation CTE.
*/

SELECT
    cohort_year,
    customer_status,

    COUNT(customerkey) AS num_customer,

    SUM(COUNT(customerkey)) OVER (
        PARTITION BY cohort_year
    ) AS total_customers,

    ROUND(
        COUNT(customerkey)::NUMERIC /
        SUM(COUNT(customerkey)) OVER (
            PARTITION BY cohort_year
        ),
        2
    ) AS status_percentage

FROM churned_customers

GROUP BY
    cohort_year,
    customer_status;
