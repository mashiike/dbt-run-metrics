{{-
    config(
        materialized='view',
        database= dbt_run_metrics.dbt_run_metrics_database(),
        schema= dbt_run_metrics.dbt_run_metrics_schema(),
        enabled=dbt_run_metrics_enabled(),
    )
}}
{{ dbt_run_metrics.dbt_run_history_sql() }}
