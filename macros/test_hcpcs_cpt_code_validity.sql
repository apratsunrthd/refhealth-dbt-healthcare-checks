{#
  Generic dbt test: hcpcs_cpt_code_validity
  Author: ref(health) Consulting (https://refhealth.consulting)
  Description:
    Validates procedure code formatting against CPT Category I/II/III and HCPCS Level II standards.
    Valid formats:
    - 5 numeric digits (CPT Category I, e.g. '99213')
    - 1 letter followed by 4 digits (HCPCS Level II, e.g. 'J0129', 'A0428')
    - 4 digits followed by 'F' or 'T' or 'U' (CPT Category II/III)
#}

{% test hcpcs_cpt_code_validity(model, column_name) %}

with invalid_procedure_codes as (
    select
        {{ column_name }} as proc_code,
        *
    from {{ model }}
    where
        {{ column_name }} is not null
        and (
            -- Exactly 5 characters
            length(trim(cast({{ column_name }} as {{ dbt.type_string() }}))) != 5
            -- Must match CPT or HCPCS regex pattern
            or not {{ refhealth_dbt_healthcare_checks.regexp_match("upper(trim(cast(" ~ column_name ~ " as " ~ dbt.type_string() ~ ")))", "^[0-9]{5}$|^[A-Z][0-9]{4}$|^[0-9]{4}[A-Z]$") }}
        )
)

select *
from invalid_procedure_codes

{% endtest %}

