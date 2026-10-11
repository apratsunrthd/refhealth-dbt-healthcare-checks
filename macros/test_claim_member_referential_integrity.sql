{#
  Generic dbt test: claim_member_referential_integrity
  Author: ref(health) Consulting (https://refhealth.consulting)
  Description:
    Enforces referential integrity between claims models and member enrollment spans.
    Checks that every claim's member_id exists in the member dimension AND that the
    claim date of service falls within the member's active coverage window.
#}

{% test claim_member_referential_integrity(model, member_model, claim_member_id='member_id', service_date='service_date', member_id='member_id', effective_date='effective_date', end_date='end_date') %}

with claims as (
    select
        {{ claim_member_id }} as member_id,
        {{ service_date }} as service_date,
        *
    from {{ model }}
    where {{ claim_member_id }} is not null
      and {{ service_date }} is not null
),

members as (
    select
        {{ member_id }} as member_id,
        {{ effective_date }} as effective_date,
        coalesce({{ end_date }}, cast('2099-12-31' as date)) as end_date
    from {{ member_model }}
),

orphaned_claims as (
    select
        c.member_id,
        c.service_date
    from claims c
    left join members m
        on c.member_id = m.member_id
       and c.service_date >= m.effective_date
       and c.service_date <= m.end_date
    where m.member_id is null
)

select *
from orphaned_claims

{% endtest %}
