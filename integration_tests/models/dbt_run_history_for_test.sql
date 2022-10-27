{{
    config(
        materialized='ephemeral'
    )
}}

select * from {{ ref('dbt_run_history') }}
