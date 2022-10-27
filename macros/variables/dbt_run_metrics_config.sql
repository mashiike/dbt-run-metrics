{%- macro dbt_run_metrics_config() %}
    {{ return(adapter.dispatch('dbt_run_metrics_config', 'dbt_run_metrics') ()) }}
{%- endmacro %}

{%- macro default__dbt_run_metrics_config() %}
    {%- set config = var('run_metrics','') %}
    {%- if (config is not defined) or (config is none) or (config == '') %}
        {{ return({}) }}
    {%- endif %}
    {{ return(config) }}
{%- endmacro %}
