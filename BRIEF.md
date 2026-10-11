# BRIEF — refhealth-dbt-healthcare-checks

## What This Project Is

Open-source dbt package providing 7 standardized generic dbt data tests enforcing domain-specific healthcare constraints: bitemporal enrollment consistency, surrogate key grain uniqueness, CMS NPI formatting, ICD-10 validity, HCPCS/CPT code validity, midnight default timestamp auditing, and claims-to-member referential integrity.

Maintained by ref(health) Consulting as an open-source technical standard and lead magnet for healthcare analytics engineering and AI readiness.

## Current State

- Version 1.0.0 released with 7 generic test macros in `macros/`.
- Conforms to standard dbt package specifications (`dbt_project.yml`).
- MIT Licensed.
- Cross-linked with [refhealth.consulting](https://refhealth.consulting).
