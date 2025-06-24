{{ config(materialized='table') }}

SELECT 
    *,
    total_amount / NULLIF(number_of_purchased_tickets, 0) as avg_price_per_ticket,
    
    -- Revenue categorization
    CASE 
        WHEN total_amount < 100 THEN 'Low Value'
        WHEN total_amount < 500 THEN 'Medium Value'
        WHEN total_amount < 1000 THEN 'High Value'
        ELSE 'Premium'
    END as revenue_tier,
    
    -- Bulk purchase flag
    CASE WHEN number_of_purchased_tickets >= 10 THEN TRUE ELSE FALSE END as is_bulk_purchase,
    
    -- Time dimensions
    EXTRACT(YEAR FROM transaction_date) as transaction_year,
    EXTRACT(MONTH FROM transaction_date) as transaction_month,
    EXTRACT(QUARTER FROM transaction_date) as transaction_quarter,
    DATE_TRUNC('week', transaction_date) as transaction_week,
    DAYNAME(transaction_date) as day_of_week

FROM {{ ref('stg_ticket_sales') }}
WHERE NOT is_invalid_amount 
  AND NOT is_invalid_quantity