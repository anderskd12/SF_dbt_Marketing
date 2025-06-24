
{{ config(materialized='view') }}

SELECT 
    seller_id,
    seller_type,
    transaction_id,
    event_name,
    number_of_purchased_tickets,
    total_amount,
    sales_channel,
    TRIM(UPPER(customer_first_name)) as customer_first_name_clean,
    TRIM(UPPER(customer_last_name)) as customer_last_name_clean,
    office_location,
    created_date,
    DATE(created_date) as transaction_date,
    
    -- Data quality flags
    CASE WHEN total_amount <= 0 THEN TRUE ELSE FALSE END as is_invalid_amount,
    CASE WHEN number_of_purchased_tickets <= 0 THEN TRUE ELSE FALSE END as is_invalid_quantity,
    CASE WHEN customer_first_name IS NULL OR customer_last_name IS NULL THEN TRUE ELSE FALSE END as is_missing_customer_info
    
FROM {{ source('raw', 'ticket_sales_raw') }}
WHERE transaction_id IS NOT NULL