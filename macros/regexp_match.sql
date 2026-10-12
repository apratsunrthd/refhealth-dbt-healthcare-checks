{#
  Cross-adapter regex matching macro.
  Supports DuckDB, Snowflake, BigQuery, PostgreSQL, Databricks, and Redshift.
#}

{% macro regexp_match(val, pattern) %}
  {{ return(adapter.dispatch('regexp_match', 'refhealth_dbt_healthcare_checks')(val, pattern)) }}
{% endmacro %}

{% macro default__regexp_match(val, pattern) %}
  regexp_like({{ val }}, '{{ pattern }}')
{% endmacro %}

{% macro duckdb__regexp_match(val, pattern) %}
  regexp_matches({{ val }}, '{{ pattern }}')
{% endmacro %}

{% macro postgres__regexp_match(val, pattern) %}
  {{ val }} ~ '{{ pattern }}'
{% endmacro %}

{% macro bigquery__regexp_match(val, pattern) %}
  regexp_contains({{ val }}, r'{{ pattern }}')
{% endmacro %}
