# refhealth-dbt-healthcare-checks

> Non-negotiable dbt data tests and integrity checks for healthcare analytics engineering, claims pipelines, and AI readiness.

Maintained by [ref(health) Consulting](https://refhealth.consulting/) — Senior healthcare data strategy, dbt analytics engineering, and Company Data AI Operating Systems.

---

## Overview

General web analytics can tolerate minor duplicate records or deduplication lag. Healthcare pipelines cannot. When claims data, enrollment spans, or clinical feeds are wired into executive dashboards or LLM agent context windows, data defects trigger real-world failure modes: miscalculated risk scores, erroneous member bills, audit failures, and retrospective hallucinations.

`refhealth-dbt-healthcare-checks` provides a standardized collection of generic dbt tests enforcing domain-specific healthcare constraints:

1. **Bitemporal Enrollment Consistency (`bitemporal_enrollment_consistency`)**: Detects desynchronization between effective dates, enrollment dates, and updated dates to flag retro-enrollment, coverage churn, and chronological contradictions.
2. **Surrogate Key & Grain Uniqueness (`surrogate_key_grain`)**: Enforces strict grain uniqueness across composite keys on claims lines and encounters.
3. **CMS NPI Format Validation (`cms_npi_format`)**: Validates 10-digit format and prefix rules for National Provider Identifier (NPI) registry compliance.
4. **ICD-10 Code Validity (`icd10_code_validity`)**: Enforces ICD-10-CM / ICD-10-PCS structural formatting rules.
5. **HCPCS & CPT Code Validity (`hcpcs_cpt_code_validity`)**: Validates 5-character CPT Category I/II/III and HCPCS Level II code formats.
6. **Midnight Default Timestamp Auditing (`midnight_default_timestamp`)**: Audits timestamps to flag where upstream systems dropped true timestamps and defaulted to `00:00:00`.
7. **Claims-to-Member Referential Integrity (`claim_member_referential_integrity`)**: Verifies that claims match active member enrollment spans covering the date of service.

---

## Installation

Add this package to your dbt project's `packages.yml`:

```yaml
packages:
  - git: "https://github.com/apratsunrthd/refhealth-dbt-healthcare-checks.git"
    revision: v1.0.0
```

Run `dbt deps` to install.

---

## Test Usage Examples

### 1. Bitemporal Enrollment Consistency

```yaml
version: 2

models:
  - name: dim_member_eligibility
    tests:
      - refhealth_dbt_healthcare_checks.bitemporal_enrollment_consistency:
          effective_date: coverage_start_date
          end_date: coverage_end_date
          enrollment_date: transaction_date
          updated_date: last_updated_at
```

### 2. CMS NPI Format Validation

```yaml
version: 2

models:
  - name: fct_medical_claims
    columns:
      - name: billing_npi
        tests:
          - refhealth_dbt_healthcare_checks.cms_npi_format
      - name: rendering_npi
        tests:
          - refhealth_dbt_healthcare_checks.cms_npi_format
```

### 3. ICD-10 & HCPCS/CPT Procedure Validity

```yaml
version: 2

models:
  - name: fct_claim_lines
    columns:
      - name: primary_diagnosis_code
        tests:
          - refhealth_dbt_healthcare_checks.icd10_code_validity
      - name: procedure_code
        tests:
          - refhealth_dbt_healthcare_checks.hcpcs_cpt_code_validity
```

### 4. Midnight Default Timestamp Audit

```yaml
version: 2

models:
  - name: stg_clinical_events
    columns:
      - name: encounter_start_timestamp
        tests:
          - refhealth_dbt_healthcare_checks.midnight_default_timestamp:
              max_midnight_ratio: 0.05 # Alert if >5% of timestamps are exactly 00:00:00
```

### 5. Claims-to-Member Referential Integrity

```yaml
version: 2

models:
  - name: fct_medical_claims
    tests:
      - refhealth_dbt_healthcare_checks.claim_member_referential_integrity:
          member_model: ref('dim_members')
          claim_member_id: member_id
          service_date: date_of_service
          member_id: member_id
          effective_date: effective_date
          end_date: term_date
```

---

## Architectural Context

Read the full technical analysis on why claims lag breaks naive AI agents and how bitemporal data modeling works in practice:
* [Bitemporal Healthcare Data, dbt Testing Standards, and the LLM Trap](https://refhealth.consulting/blog-bitemporal-healthcare-data-ai)
* [Why We Build Healthcare Data Stacks with dbt](https://refhealth.consulting/blog-why-we-build-with-dbt)
* [Healthcare AI Readiness Diagnostic](https://refhealth.consulting/ai-readiness-assessment)

---

## License

MIT © [ref(health) Consulting](https://refhealth.consulting)
