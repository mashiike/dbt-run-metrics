{{
    config(
        materialized='view'
    )
}}

{%- set success_rate_slo = 0.80 %}
{%- set current = modules.datetime.datetime.now(modules.pytz.timezone('Asia/Tokyo')) %}
with base as (
select
    *
    ,1.0 - {{ success_rate_slo }} as error_budget
    ,case when total_dbt_run_count_rolling28days > 0 then (total_successful_dbt_run_count_rolling28days * 1.00 / total_dbt_run_count_rolling28days) end as dbt_run_success_rate_rolling28days
from {{ metrics.calculate(
    [
        metric('dbt_run_metrics','dbt_run_success_rate'),
        metric('dbt_run_metrics','total_dbt_run_count'),
        metric('dbt_run_metrics','total_successful_dbt_run_count'),
    ] ,
    grain='day',
    secondary_calculations=[
        metrics.rolling(aggregate="sum",
            interval=28,
            metric_list=[
                metric('dbt_run_metrics','total_dbt_run_count'),
                metric('dbt_run_metrics','total_successful_dbt_run_count'),
            ],
            alias='rolling28days'
        ),
    ],
    start_date=(current - modules.datetime.timedelta(days=90)).strftime('%Y-%m-%d'),
    end_date=current.strftime('%Y-%m-%d'),
    dimensions=[
        'package_name',
        'resource_type',
        'node_id',
    ],
) }}
)
select
    *
    , (1.0 - dbt_run_success_rate_rolling28days) / error_budget as error_budget_consumption_rate
from base
