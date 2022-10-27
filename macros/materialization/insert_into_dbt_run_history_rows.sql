{%- macro insert_into_dbt_run_history_rows(rel, sql, on_schema_change = 'append_new_columns') %}
    {%- if execute %}
        {%- set exists_relation = load_cached_relation(rel) %}
        {%- if exists_relation is none %}
            {% do adapter.create_schema(api.Relation.create(database=rel.database, schema=rel.schema)) %}
            {%- do dbt_run_metrics.create_dbt_run_history_table_as(False, rel, sql) %}
        {%- else %}
            {%- set tmp_relation = make_temp_relation(rel) %}
            {%- do dbt_run_metrics.create_dbt_run_history_table_as(True, tmp_relation, sql) %}
            {%- do adapter.expand_target_column_types(
                    from_relation=tmp_relation,
                    to_relation=exists_relation) %}
            {%- set on_schema_change = incremental_validate_on_schema_change(on_schema_change) %}
            {%- set dest_columns = process_schema_changes(on_schema_change, tmp_relation, exists_relation) %}
            {%- if not dest_columns %}
                {% set dest_columns = adapter.get_columns_in_relation(exists_relation) %}
            {%- endif %}
            {%- set insert_into_rows_sql %}
                BEGIN;
                {{ get_delete_insert_merge_sql(exists_relation, tmp_relation, none, dest_columns) }};
                COMMIT;
            {%- endset %}
            {%- do run_query(insert_into_rows_sql) %}
        {%- endif %}
    {%- endif %}
{%- endmacro %}
