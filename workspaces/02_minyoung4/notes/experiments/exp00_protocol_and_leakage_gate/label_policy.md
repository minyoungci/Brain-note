# Label Policy Draft

Status: draft.

This policy defines how IDH labels are consumed by experiment code.
It must be approved before any split generation or model training.

## Outcome

Binary IDH status:

- positive: `mutant`
- negative: `wildtype`

## Approved Source Artifacts

Subject-level modeling code must consume IDH labels from:

```text
docs/context/research_cohort_membership.csv
```

Approved subject-level column:

```text
idh_subject
```

Supporting audit artifacts:

```text
docs/context/label_harmonization_audit.csv
docs/context/label_harmonization_counts.csv
docs/context/label_harmonization_subject_conflicts.csv
```

## Cohort Flag

Primary IDH cohort flag:

```text
eligible_T1_structural_idh
```

Rows are eligible only when this flag is true and `idh_subject` is one of the approved
binary values.

## Value Mapping

| Raw subject value | Binary label | Numeric target |
|---|---|---:|
| `mutant` | positive | 1 |
| `wildtype` | negative | 0 |

Any other value is excluded from supervised IDH training unless a later approved policy
explicitly maps it.

## Conflict Policy

If `any_subject_label_conflict_audit` is true for a subject, that subject must be excluded
from official supervised training until the conflict is reviewed and resolved.

## Required Label Audit Before Training

Before any model consumes labels, produce an experiment-local label audit containing:

- total eligible subjects;
- positive and negative counts;
- counts by consortium;
- counts by age bin;
- counts by sex;
- counts by scanner/vendor and field strength;
- conflict-excluded subject count;
- unknown/ambiguous excluded subject count.

## Forbidden

- Inferring IDH label from dataset, scanner, mask availability, diagnosis text, or filename.
- Re-harmonizing labels inside model-training scripts.
- Silently dropping ambiguous labels without reporting the count.

