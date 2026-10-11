{#
  Generic dbt test: icd10_code_validity
  Author: ref(health) Consulting (https://refhealth.consulting)
  Description:
    Validates diagnosis code structure against standard ICD-10-CM formatting.
    ICD-10-CM codes start with a letter (A-Z), followed by a number, followed by alphanumeric characters.
    Supports both formatted (with dot: 'E11.9') and unformatted (without dot: 'E119') codes.
#}

{% test icd10_code_validity(model, column_name) %}

with invalid_icd10 as (
    select
        {{ column_name }} as icd_code,
        *
    from {{ model }}
    where
        {{ column_name }} is not null
        and (
            -- Length must be between 3 and 8 characters
            length(trim(cast({{ column_name }} as {{ dbt.type_string() }}))) < 3
            or length(trim(cast({{ column_name }} as {{ dbt.type_string() }}))) > 8
            -- Must match ICD-10 alphanumeric pattern
            or not regexp_like(
                upper(trim(cast({{ column_name }} as {{ dbt.type_string() }}))),
                '^[A-Z][0-9][A-Z0-9](\\.[A-Z0-9]{1,4})?$|^[A-Z][0-9][A-Z0-9]{1,5}$'
            )
        )
)

select *
from invalid_icd10

{% endtest %}
