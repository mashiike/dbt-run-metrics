{%- macro dbt_run_metrics_enabled() %}
    {{ return(adapter.dispatch('dbt_run_metrics_enabled', 'dbt_run_metrics') ()) }}
{%- endmacro %}

{%- macro default__dbt_run_metrics_enabled() %}
    {%- set cfg = dbt_run_metrics.dbt_run_metrics_config() %}
    {%- if 'enabled' in cfg and cfg['enabled'] is not none%}
        {{ return(cfg['enabled']) }}
    {%- endif %}
    {{ return(true)}}
{%- endmacro %}
