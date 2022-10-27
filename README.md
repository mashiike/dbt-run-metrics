# dbt-run-metrics

a dbt Package for execution monitoring

This package will automatically plant hooks in on-run-start and on-run-end and output logs of the start of the run and the end of the run to the DWH.
The output logs are then used to provide various dbt execution metrics.

## Installation

### as DBT package 

Add to your packages.yml
```yaml
packages:
  - git: "https://github.com/mashiike/dbt-run-metrics"
    revision: v0.0.0
  - package: dbt-labs/metrics
    version: [">=1.3.0", "<1.4.0"]
```

For example, if you want the daily execution slo metrics, do the following
```sql
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
```

## dbt run history

You can access the raw logs by using the `ref('dbt_run_history')`.
Log storage location can be defined similar to dbt_project.yml

They are as follows:
```yaml
vars:
  run_metrics:
    database: prod
    schema: dbt_run_metrics
    additional_infomation:
      git_version: "{{ env_var('GIT_VER','') }}"
```
The log looks like this

```
postgres=# select * from dbt_run_history limit 1;
-[ RECORD 1 ]------+------------------------------------------------------------------------------------------------------
dbt_invocation_id  | 0ae77d37-ae0d-468d-86dd-bebda8c22e8a
node_id            | model.dbt_run_metrics.dbt_run_history
ref_node           | model.dbt_run_metrics.dbt_run_history
package_name       | dbt_run_metrics
dbt_run_started_at | 2022-10-27 06:59:41.616952
dbt_version        | 1.3.0
git_version        | eb884911a0ade2a7
resource_type      | model
node_start_at      | 2022-10-27 06:59:41.616952
node_completed_at  | 2022-10-27 06:59:45.136473+00
status             | success
message            | CREATE VIEW
rows_affected      | 
bytes_processed    | 
execution_time     | 0.33487510681152344
ref_node_success   | t
dbt_run_success    | t
```

## LICENSE

MIT 

