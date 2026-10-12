{#
  Generic dbt test: bitemporal_enrollment_consistency
  Author: ref(health) Consulting (https://refhealth.consulting)
  Description:
    Validates bitemporal and multitemporal logic in member eligibility spans.
    Flags records where:
    - effective_date is after end_date / termination_date
    - enrollment_date is after updated_date (when updated_date is populated)
    - date spans indicate chronologically impossible member states
#}

{% test bitemporal_enrollment_consistency(model, effective_date='effective_date', end_date='end_date', enrollment_date=none, updated_date=none) %}

with validation_errors as (
    select
        *
    from {{ model }}
    where
        -- Effective date cannot be after end date
        {% if end_date is not none %}
        ({{ effective_date }} is not null and {{ end_date }} is not null and {{ effective_date }} > {{ end_date }})
        {% endif %}

        -- Enrollment date cannot be after last updated date
        {% if enrollment_date is not none and updated_date is not none %}
        or ({{ enrollment_date }} is not null and {{ updated_date }} is not null and {{ enrollment_date }} > {{ updated_date }})
        {% endif %}
)

select *
from validation_errors

{% endtest %}

