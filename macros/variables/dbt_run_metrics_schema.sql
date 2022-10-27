{%- macro dbt_run_metrics_schema() %}
    {{ return(adapter.dispatch('dbt_run_metrics_schema', 'dbt_run_metrics') ()) }}
{%- endmacro %}

{%- macro default__dbt_run_metrics_schema() %}
    {%- set cfg = dbt_run_metrics.dbt_run_metrics_config() %}
    {%- if 'schema' in cfg and cfg['schema'] is not none%}
        {{ return(cfg['schema']) }}
    {%- endif %}
    {{ return(none)}}
{%- endmacro %}
