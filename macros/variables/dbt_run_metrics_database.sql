{%- macro dbt_run_metrics_database() %}
    {{ return(adapter.dispatch('dbt_run_metrics_database', 'dbt_run_metrics') ()) }}
{%- endmacro %}

{%- macro default__dbt_run_metrics_database() %}
    {%- set cfg = dbt_run_metrics.dbt_run_metrics_config() %}
    {%- if 'database' in cfg and cfg['database'] is not none%}
        {{ return(cfg['database']) }}
    {%- endif %}
    {{ return(target.database)}}
{%- endmacro %}
