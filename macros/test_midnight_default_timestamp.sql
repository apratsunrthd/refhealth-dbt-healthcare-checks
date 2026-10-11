{#
  Generic dbt test: midnight_default_timestamp
  Author: ref(health) Consulting (https://refhealth.consulting)
  Description:
    Detects dropped timestamp precision where upstream systems defaulted time to midnight (00:00:00).
    Critical for identifying whether event-to-receipt latency or encounter durations are artificial artifacts.
    Can be configured with an optional error threshold (e.g. fail if midnight records exceed 20%).
#}

{% test midnight_default_timestamp(model, column_name, max_midnight_ratio=0.10) %}

with timestamp_metrics as (
    select
        count(*) as total_records,
        count(case 
            when extract(hour from {{ column_name }}) = 0 
             and extract(minute from {{ column_name }}) = 0 
             and extract(second from {{ column_name }}) = 0 
            then 1 
        end) as midnight_records
    from {{ model }}
    where {{ column_name }} is not null
),

calculated_ratio as (
    select
        total_records,
        midnight_records,
        case 
            when total_records > 0 then cast(midnight_records as {{ dbt.type_float() }}) / total_records 
            else 0 
        end as midnight_ratio
    from timestamp_metrics
)

-- Return failure rows if midnight ratio exceeds allowable threshold
select *
from calculated_ratio
where midnight_ratio > {{ max_midnight_ratio }}
  and total_records >= 10

{% endtest %}
