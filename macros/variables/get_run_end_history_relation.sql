{%- macro get_run_end_history_relation() %}
    {{ return(adapter.dispatch('get_run_end_history_relation', 'dbt_run_metrics') ()) }}
{%- endmacro %}

{%- macro default__get_run_end_history_relation() %}
    {%- set relation = {
        'database': dbt_run_metrics.dbt_run_metrics_database(),
        'schema': dbt_run_metrics.dbt_run_metrics_schema(),
        'identifier': 'dbt_run_end_history',
    }
    %}
    {%- do relation.update(dbt_run_metrics.run_end_history_config()) %}
    {{ return(api.Relation.create(database=relation.database, schema=generate_schema_name(relation.schema, none), identifier=relation.identifier)) }}
{%- endmacro %}
