{%- macro run_end_history_config() %}
    {{ return(adapter.dispatch('run_end_history_config', 'dbt_run_metrics') ()) }}
{%- endmacro %}

{%- macro default__run_end_history_config() %}
    {%- set cfg = dbt_run_metrics.dbt_run_metrics_config() %}
    {%- if 'run_end_history' in cfg and cfg['run_end_history'] is not none%}
        {{ return(cfg['run_end_history']) }}
    {%- endif %}
    {{ return({})}}
{%- endmacro %}
