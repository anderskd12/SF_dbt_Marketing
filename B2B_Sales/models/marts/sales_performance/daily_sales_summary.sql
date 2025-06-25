{{ config(materialized='table') }}

SELECT 
    transaction_date,
    transaction_year,
    transaction_month,
    transaction_quarter,
    day_of_week,
    
    COUNT(DISTINCT transaction_id) as total_transactions,
    COUNT(DISTINCT CONCAT(customer_first_name_clean, customer_last_name_clean)) as unique_customers,
    SUM(number_of_purchased_tickets) as total_tickets_sold,
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as avg_transaction_value,
    AVG(avg_price_per_ticket) as avg_ticket_price,
    
    -- Channel breakdown
    SUM(CASE WHEN sales_channel = 'Online' THEN total_amount ELSE 0 END) as online_revenue,
    SUM(CASE WHEN sales_channel = 'Phone' THEN total_amount ELSE 0 END) as phone_revenue,
    SUM(CASE WHEN sales_channel = 'In-Person' THEN total_amount ELSE 0 END) as in_person_revenue,
    
    -- Performance flags
    SUM(CASE WHEN is_bulk_purchase THEN 1 ELSE 0 END) as bulk_purchase_count,
    SUM(CASE WHEN revenue_tier = 'Premium' THEN total_amount ELSE 0 END) as premium_revenue

FROM {{ ref('int_sales_metrics') }}
GROUP BY 1, 2, 3, 4, 5
ORDER BY transaction_date