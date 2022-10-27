{%- macro select_run_start_history_sql(selected_resourcess) %}
    {{ return(adapter.dispatch('select_run_start_history_sql', 'dbt_run_metrics') (selected_resources)) }}
{%- endmacro %}

{%- macro default__select_run_start_history_sql(selected_resources) %}
    {%- set cfg = dbt_run_metrics.dbt_run_metrics_config() %}
    {%- set additional_infomation = {} %}
    {%- if cfg['additional_infomation'] is not none and cfg['additional_infomation'] is mapping %}
        {%- set additional_infomation = cfg['additional_infomation'] %}
    {%- endif %}
    {%- for selected_resource in selected_resources %}
        {%- set node = graph.nodes.values() | selectattr('unique_id', 'equalto', selected_resource) | first %}
        {%- set related_resouce = 'NULL' %}
        {%- set package_name = 'NULL' %}
        {%- if node is not none %}
            {%- if node.resource_type == 'test' %}
                {%- set related_model_name = (node.refs | last) | last %}
                {%- if related_model_name is not none %}
                    {%- set model_node = graph.nodes.values() | selectattr('name', 'equalto', related_model_name ) | first %}
                    {%- if model_node is not none %}
                        {%- set related_resouce = model_node.unique_id %}
                    {%- endif %}
                {%- endif %}
            {%- else %}
                {%- set related_resouce = selected_resource %}
            {%- endif %}
            {%- set package_name = node.package_name %}
        {%- endif %}
    select
        {{- dbt.safe_cast("'"~invocation_id~"'",dbt.type_string()) }} as dbt_invocation_id
        ,{{- dbt.safe_cast("'"~selected_resource~"'",dbt.type_string()) }} as node_id
        ,{{- dbt.safe_cast("'"~related_resouce~"'",dbt.type_string()) }} as ref_node
        ,{{- dbt.safe_cast("'"~package_name~"'",dbt.type_string()) }} as package_name
        ,{{- dbt.safe_cast("'"~run_started_at~"'",dbt.type_timestamp()) }} as dbt_run_started_at
        ,{{- dbt.safe_cast("'"~dbt_version~"'",dbt.type_string()) }} as dbt_version
        {%- for key, value in additional_infomation.items() %}
            {%- set rendered_value = render(value) %}
            ,{%- if rendered_value is string %}
                {{- dbt.safe_cast("'"~rendered_value~"'",dbt.type_string()) }}
            {%- elif rendered_value is integer %}
                {{- dbt.safe_cast(value,dbt.type_bigint()) }}
            {%- elif rendered_value is float %}
                {{- dbt.safe_cast(value,dbt.type_float()) }}
            {%- elif rendered_value is boolean %}
                {%- if rendered_value -%}TRUE{%- else -%}FALSE{%- endif -%}
            {%- elif rendered_value is undefined %}
                NULL
            {%- else %}
                {{- dbt.safe_cast("'"~tojson(value)~"'",dbt.type_string()) }}
            {%- endif %} as {{ key }}
        {%- endfor %}
    {%- if not loop.last %}
    union all
    {%- endif %}
    {%- endfor %}
{%- endmacro %}
