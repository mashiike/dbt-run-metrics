{%- macro run_start_history_config() %}
    {{ return(adapter.dispatch('run_start_history_config', 'dbt_run_metrics') ()) }}
{%- endmacro %}

{%- macro default__run_start_history_config() %}
    {%- set cfg = dbt_run_metrics.dbt_run_metrics_config() %}
    {%- if 'run_start_history' in cfg and cfg['run_start_history'] is not none%}
        {{ return(cfg['run_start_history']) }}
    {%- endif %}
    {{ return({})}}
{%- endmacro %}
