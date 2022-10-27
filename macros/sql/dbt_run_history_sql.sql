
{%- macro dbt_run_history_sql(results) %}
    {{ return(adapter.dispatch('dbt_run_history_sql', 'dbt_run_metrics') (results)) }}
{%- endmacro %}

{%- macro default__dbt_run_history_sql(results) %}
{%- set is_first_run = load_cached_relation(dbt_run_metrics.get_run_end_history_relation()) is none %}
with run_start_history as (
    select * from {{ dbt_run_metrics.get_run_start_history_relation() }}
)
{%- if not is_first_run %}
, run_end_history as (
    select * from {{ dbt_run_metrics.get_run_end_history_relation() }}
)
{%- endif %}
select
    s.*
    {%- if not is_first_run %}
    ,e.resource_type
    ,e.node_start_at
    ,e.node_completed_at
    ,e.dbt_run_ended_at
    ,e.status
    ,e.message
    ,e.rows_affected
    ,e.bytes_processed
    ,e.execution_time
    ,(max(case when status not in ('pass', 'success') then 1 else 0 end) over (partition by dbt_invocation_id,s.ref_node)) = 0 as ref_node_success
    ,(max(case when status not in ('pass', 'success') then 1 else 0 end) over (partition by dbt_invocation_id)) = 0 as dbt_run_success
    ,{{ dbt.datediff("s.dbt_run_started_at", "e.node_start_at", "microsecond") }} / 1000000.0 as landing_time
    {%- else %}
    ,{{- dbt.safe_cast("NULL",dbt.type_string()) }} as resource_type
    ,{{- dbt.safe_cast("NULL",dbt.type_timestamp()) }} as node_start_at
    ,{{- dbt.safe_cast("NULL",dbt.type_timestamp()) }} as node_completed_at
    ,{{- dbt.safe_cast("NULL",dbt.type_timestamp()) }} as dbt_run_ended_at
    ,{{- dbt.safe_cast("NULL",dbt.type_string()) }} as status
    ,{{- dbt.safe_cast("NULL",dbt.type_string()) }} as message
    ,{{- dbt.safe_cast("NULL",dbt.type_int()) }} as rows_affected
    ,{{- dbt.safe_cast("NULL",dbt.type_int()) }} as bytes_processed
    ,{{- dbt.safe_cast("NULL",dbt.type_float()) }} as execution_time
    ,NULL = true as ref_node_success
    ,NULL = true as dbt_run_success
    ,{{- dbt.safe_cast("NULL",dbt.type_float()) }} as landing_time
    {%- endif %}

from run_start_history s
{%- if not is_first_run %}
left join run_end_history e using(dbt_invocation_id,node_id)
{%- endif %}
{%- endmacro %}

