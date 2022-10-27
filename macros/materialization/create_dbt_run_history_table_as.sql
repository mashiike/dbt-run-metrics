{%- macro create_dbt_run_history_table_as(temporary, relation, sql)  %}
    {{ return(adapter.dispatch('create_dbt_run_history_table_as', 'dbt_run_metrics') (temporary, relation, sql) ) }}
{%- endmacro %}

{%- macro default__create_dbt_run_history_table_as(temporary, relation, sql)  %}
    {%- do run_query(dbt_run_metrics.get_create_dbt_run_history_table_as_sql(temporary, relation, sql)) -%}
{%- endmacro %}

{%- macro get_create_dbt_run_history_table_as_sql(temporary, relation, sql)  %}
    {{ return(adapter.dispatch('get_create_dbt_run_history_table_as_sql', 'dbt_run_metrics') (temporary, relation, sql) ) }}
{%- endmacro %}

{%- macro default__get_create_dbt_run_history_table_as_sql(temporary, relation, sql)  %}
    create {% if temporary -%}temporary{%- endif %} table
        {{ relation.include(database=(not temporary), schema=(not temporary)) }}
    as (
        {{ sql }}
    );
{%- endmacro %}
