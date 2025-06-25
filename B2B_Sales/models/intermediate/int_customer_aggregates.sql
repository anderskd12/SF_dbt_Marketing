{{ config(materialized='table') }}

SELECT 
    customer_first_name_clean,
    customer_last_name_clean,
    CONCAT(customer_first_name_clean, ' ', customer_last_name_clean) as full_name,
    
    COUNT(DISTINCT transaction_id) as total_transactions,
    SUM(number_of_purchased_tickets) as total_tickets_purchased,
    SUM(total_amount) as total_spent,
    AVG(total_amount) as avg_transaction_value,
    MAX(total_amount) as highest_transaction,
    MIN(created_date) as first_purchase_date,
    MAX(created_date) as last_purchase_date,
    
    -- Customer segmentation
    CASE 
        WHEN COUNT(DISTINCT transaction_id) = 1 THEN 'One-time Buyer'
        WHEN COUNT(DISTINCT transaction_id) <= 3 THEN 'Occasional Buyer'
        WHEN COUNT(DISTINCT transaction_id) <= 10 THEN 'Regular Customer'
        ELSE 'VIP Customer'
    END as customer_segment,
    
    COUNT(DISTINCT event_name) as events_attended,
    COUNT(DISTINCT sales_channel) as channels_used

FROM {{ ref('int_sales_metrics') }}
GROUP BY 1, 2, 3