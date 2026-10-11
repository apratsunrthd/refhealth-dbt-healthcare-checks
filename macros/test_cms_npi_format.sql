{#
  Generic dbt test: cms_npi_format
  Author: ref(health) Consulting (https://refhealth.consulting)
  Description:
    Validates National Provider Identifier (NPI) column format.
    CMS standard NPIs are exactly 10 digits long and begin with '1' or '2'.
    Flags records with invalid lengths, non-numeric characters, or invalid prefix digits.
#}

{% test cms_npi_format(model, column_name) %}

with invalid_npis as (
    select
        {{ column_name }} as npi,
        *
    from {{ model }}
    where
        {{ column_name }} is not null
        and (
            -- Must be exactly 10 characters
            length(trim(cast({{ column_name }} as {{ dbt.type_string() }}))) != 10
            -- Must contain only numeric digits
            or not regexp_like(trim(cast({{ column_name }} as {{ dbt.type_string() }})), '^[0-9]{10}$')
            -- Standard CMS individual/org NPIs begin with 1 or 2
            or not substring(trim(cast({{ column_name }} as {{ dbt.type_string() }})), 1, 1) in ('1', '2')
        )
)

select *
from invalid_npis

{% endtest %}
