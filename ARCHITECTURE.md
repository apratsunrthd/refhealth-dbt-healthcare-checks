# ARCHITECTURE — refhealth-dbt-healthcare-checks

## Architecture Overview

`refhealth_dbt_healthcare_checks` defines SQL macros adhering to dbt Core generic test conventions. Each test accepts a `model` and target column arguments, returning rows that fail the validation criteria.

```mermaid
flowchart TD
    MODEL["Healthcare Data Model (dim_members / fct_claims)"] --> TESTS["dbt test execution"]
    TESTS --> T1["bitemporal_enrollment_consistency"]
    TESTS --> T2["surrogate_key_grain"]
    TESTS --> T3["cms_npi_format"]
    TESTS --> T4["icd10_code_validity"]
    TESTS --> T5["hcpcs_cpt_code_validity"]
    TESTS --> T6["midnight_default_timestamp"]
    TESTS --> T7["claim_member_referential_integrity"]
    T1 & T2 & T3 & T4 & T5 & T6 & T7 --> PASS["Pass (0 rows) -> Deploy to Warehouse & LLM Agent"]
    T1 & T2 & T3 & T4 & T5 & T6 & T7 --> FAIL["Fail (>0 rows) -> Break CI/CD Pipeline"]
```

