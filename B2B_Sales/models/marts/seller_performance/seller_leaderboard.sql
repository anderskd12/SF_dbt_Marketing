{{ config(materialized='table') }}

WITH seller_metrics AS (
    SELECT 
        seller_id,
        seller_type,
        office_location,
        
        COUNT(DISTINCT transaction_id) as total_sales,
        SUM(total_amount) as total_revenue,
        SUM(number_of_purchased_tickets) as total_tickets_sold,
        AVG(total_amount) as avg_deal_size,
        COUNT(DISTINCT CONCAT(customer_first_name_clean, customer_last_name_clean)) as unique_customers,
        
        -- Time-based metrics
        MIN(transaction_date) as first_sale_date,
        MAX(transaction_date) as last_sale_date,
        DATEDIFF('day', MIN(transaction_date), MAX(transaction_date)) + 1 as active_days,
        
        -- Performance indicators
        SUM(CASE WHEN is_bulk_purchase THEN 1 ELSE 0 END) as bulk_sales_count,
        SUM(CASE WHEN revenue_tier IN ('High Value', 'Premium') THEN total_amount ELSE 0 END) as high_value_revenue
        
    FROM {{ ref('int_sales_metrics') }}
    GROUP BY 1, 2, 3
)

SELECT 
    *,
    total_revenue / NULLIF(active_days, 0) as daily_revenue_rate,
    total_sales / NULLIF(active_days, 0) as daily_sales_rate,
    
    -- Rankings
    ROW_NUMBER() OVER (ORDER BY total_revenue DESC) as revenue_rank,
    ROW_NUMBER() OVER (ORDER BY total_sales DESC) as sales_count_rank,
    ROW_NUMBER() OVER (ORDER BY avg_deal_size DESC) as avg_deal_size_rank,
    
    -- Performance tiers
    CASE 
        WHEN total_revenue >= 50000 THEN 'Top Performer'
        WHEN total_revenue >= 25000 THEN 'High Performer' 
        WHEN total_revenue >= 10000 THEN 'Good Performer'
        ELSE 'Developing'
    END as performance_tier

FROM seller_metrics
ORDER BY total_revenue DESC