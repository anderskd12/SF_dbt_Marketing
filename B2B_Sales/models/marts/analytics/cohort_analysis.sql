{{ config(materialized='table') }}

WITH customer_cohorts AS (
    SELECT 
        CONCAT(customer_first_name_clean, ' ', customer_last_name_clean) as customer_name,
        DATE_TRUNC('month', MIN(transaction_date)) as cohort_month,
        transaction_date,
        total_amount
    FROM {{ ref('int_sales_metrics') }}
    GROUP BY 1, 3, 4
),

cohort_data AS (
    SELECT 
        cohort_month,
        DATE_TRUNC('month', transaction_date) as transaction_month,
        DATEDIFF('month', cohort_month, DATE_TRUNC('month', transaction_date)) as months_since_first_purchase,
        COUNT(DISTINCT customer_name) as customers,
        SUM(total_amount) as revenue
    FROM customer_cohorts
    GROUP BY 1, 2, 3
)

SELECT 
    cohort_month,
    transaction_month, 
    months_since_first_purchase,
    customers,
    revenue,
    customers / FIRST_VALUE(customers) OVER (
        PARTITION BY cohort_month 
        ORDER BY months_since_first_purchase 
        ROWS UNBOUNDED PRECEDING
    ) as retention_rate

FROM cohort_data
ORDER BY cohort_month, months_since_first_purchase
