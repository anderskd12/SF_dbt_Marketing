{{ config(materialized='table') }}

SELECT 
    'ticket_sales_raw' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN is_invalid_amount THEN 1 END) as invalid_amounts,
    COUNT(CASE WHEN is_invalid_quantity THEN 1 END) as invalid_quantities,
    COUNT(CASE WHEN is_missing_customer_info THEN 1 END) as missing_customer_info,
    
    -- Completeness metrics
    COUNT(seller_id) / COUNT(*) as seller_id_completeness,
    COUNT(event_name) / COUNT(*) as event_name_completeness,
    COUNT(sales_channel) / COUNT(*) as sales_channel_completeness,
    
    CURRENT_TIMESTAMP as report_generated_at

FROM {{ ref('stg_ticket_sales') }}