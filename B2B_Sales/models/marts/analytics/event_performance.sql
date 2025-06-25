{{ config(materialized='table') }}

SELECT 
    event_name,
    COUNT(DISTINCT transaction_id) as total_transactions,
    SUM(number_of_purchased_tickets) as total_tickets_sold,
    SUM(total_amount) as total_revenue,
    AVG(avg_price_per_ticket) as avg_ticket_price,
    COUNT(DISTINCT CONCAT(customer_first_name_clean, customer_last_name_clean)) as unique_attendees,
    
    -- Channel performance for this event
    COUNT(DISTINCT sales_channel) as channels_used,
    MAX(CASE WHEN sales_channel = 'Online' THEN total_amount ELSE 0 END) as highest_online_sale,
    
    -- Seller performance
    COUNT(DISTINCT seller_id) as sellers_involved,
    
    -- Time analysis
    MIN(transaction_date) as first_sale_date,
    MAX(transaction_date) as last_sale_date,
    DATEDIFF('day', MIN(transaction_date), MAX(transaction_date)) + 1 as selling_period_days

FROM {{ ref('int_sales_metrics') }}
GROUP BY event_name
ORDER BY total_revenue DESC
