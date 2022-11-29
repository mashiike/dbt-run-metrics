{%- macro select_run_end_history_sql(results) %}
    {{ return(adapter.dispatch('select_run_end_history_sql', 'dbt_run_metrics') (results)) }}
{%- endmacro %}

{%- macro default__select_run_end_history_sql(results) %}
    {%- for res in results %}
        {%- for timing in res.timing -%}
            {%- if timing.name == 'execute' -%}
                {%- set node_start_at = dbt.safe_cast("'"~timing.start_at~"'",dbt.type_timestamp()) -%}
                {%- set node_completed_at = dbt.safe_cast("'"~timing.completed_at~"'",dbt.type_timestamp()) -%}
            {%- endif -%}
        {%- endfor -%}
        {%- if node_start_at is not defined -%}
            {%- set node_start_at = dbt.safe_cast("'"~run_started_at~"'",dbt.type_timestamp())  -%}
        {%- endif %}
        {%- if node_completed_at is not defined -%}
            {%- set node_completed_at = dbt.current_timestamp()  -%}
        {%- endif %}

    select
        {{- dbt.safe_cast("'"~invocation_id~"'",dbt.type_string()) }} as dbt_invocation_id
        ,{{- dbt.safe_cast("'"~res.node.unique_id ~"'",dbt.type_string()) }} as node_id
        ,{{- dbt.safe_cast(dbt.current_timestamp(),dbt.type_timestamp()) }} as dbt_run_ended_at
        ,{{- dbt.safe_cast("'"~dbt_version~"'",dbt.type_string()) }} as dbt_version
        ,{{- dbt.safe_cast("'"~res.node.resource_type~"'",dbt.type_string()) }} as resource_type
        ,{{- node_start_at}} as node_start_at
        ,{{- node_completed_at }} node_completed_at
        ,{{- dbt.safe_cast("'"~res.status~"'",dbt.type_string()) }} as status
        ,{%- if res.message is defined and res.message is not none -%}
            {{- dbt.safe_cast("'"~(res.message |  replace("\n", "\\n") | replace("'", "''")) ~"'",dbt.type_string()) }} as message
        {%- else -%}
            {{- dbt.safe_cast("NULL",dbt.type_string()) }} as message
        {%- endif %}
        ,{%- if res.adapter_response.rows_affected is defined and res.adapter_response.rows_affected >= 0 -%}
            {{- dbt.safe_cast("'"~res.adapter_response.rows_affected~"'",dbt.type_int()) }} as rows_affected
        {%- else -%}
            {{- dbt.safe_cast("NULL",dbt.type_int()) }} as rows_affected
        {%- endif %}
        ,{%- if res.adapter_response.bytes_processed is defined -%}
            {{- dbt.safe_cast("'"~res.adapter_response.bytes_processed~"'",dbt.type_int()) }} as bytes_processed
        {%- else -%}
            {{- dbt.safe_cast("NULL",dbt.type_int()) }} as bytes_processed
        {%- endif %}
        ,{%- if res.execution_time is defined -%}
            {{- dbt.safe_cast("'"~res.execution_time~"'",dbt.type_float()) }} as execution_time
        {%- else %}
            {{- dbt.safe_cast("NULL",dbt.type_float()) }} as execution_time
        {%- endif %}
    {%- if not loop.last %}
    union all
    {%- endif %}
    {%- endfor %}
{%- endmacro %}
