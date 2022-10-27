{%- macro on_run_start() %}
    {% if execute and dbt_run_metrics_enabled() %}
    {%- do log('dbt_run_metrics.on_run_start: record history') %}
    {%- set rel = dbt_run_metrics.get_run_start_history_relation() %}
    {%- set sql = dbt_run_metrics.select_run_start_history_sql(selected_resources) %}
    {{ dbt_run_metrics.insert_into_dbt_run_history_rows(rel,sql) }}
    {% endif %}
{%- endmacro %}

{% macro on_run_end(results) %}
    {% if execute and dbt_run_metrics_enabled() %}
    {%- do log('dbt_run_metrics.on_run_end: record history') %}
    {%- set rel = dbt_run_metrics.get_run_end_history_relation() %}
    {%- set sql = dbt_run_metrics.select_run_end_history_sql(results) %}
    {{ dbt_run_metrics.insert_into_dbt_run_history_rows(rel,sql) }}
    {% endif %}
{% endmacro %}
