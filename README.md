# SF_dbt_Marketing

This is an example project to consume marketing data and consolidate it using dbt.  

Dataset - I generated a P2P_Sales table with raw ticket sales data that will be used in Snowflake and transformed using DBT.

Key DBT Features Demonstrated:

Layered Architecture: Raw → Staging → Intermediate → Marts
Reusable Models: Building on top of previous transformations
Data Quality: Validation and cleansing at the staging layer
Business Logic: Calculations, categorizations, and derived metrics
Analytics: Cohort analysis, performance metrics, and KPIs
Testing: Data quality validation
Documentation: Clear model purposes and dependencies
