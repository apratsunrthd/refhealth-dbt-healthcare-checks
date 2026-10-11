{#
  Generic dbt test: surrogate_key_grain
  Author: ref(health) Consulting (https://refhealth.consulting)
  Description:
    Validates that a declared composite grain or surrogate key has zero duplicates and zero nulls.
    Essential for claims line items, encounter grains, and billing transactions.
#}

{% test surrogate_key_grain(model, grain_columns) %}

with grain_counts as (
    select
        {% for col in grain_columns %}
        {{ col }}{% if not loop.last %}, {% endif %}
        {% endfor %},
        count(*) as row_count
    from {{ model }}
    where
        {% for col in grain_columns %}
        {{ col }} is null{% if not loop.last %} or {% endif %}
        {% endfor %}
    group by
        {% for col in grain_columns %}
        {{ col }}{% if not loop.last %}, {% endif %}
        {% endfor %}
    having count(*) > 1
)

select *
from grain_counts

{% endtest %}
