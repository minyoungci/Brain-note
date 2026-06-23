# Stage 22 Reliability Label Policy

## Scope

Define the first reliability/error label policy for future G-SURE labels. This
stage did not create official split files, generate predictions, generate
reliability labels, run inference, run GPU, preprocess data, or train a model.

## Goal Reminder

G-SURE needs reliability labels that reflect actual segmentation failure from
full-volume OOF predictions. Thresholds and boundary definitions must be fixed
before labels are generated to avoid post-hoc tuning.

## Decision / Action

Added:

```text
research_gsure/01_protocol/RELIABILITY_LABEL_POLICY_DRAFT.md
```

The draft policy sets the first label semantics:

- primary threshold: `fixed_0.5`,
- binary prediction: `B = P >= 0.5`,
- primary maps: `FN`, `FP`, `ERR`, `SOFT_ERROR`,
- first binary reliability target: `ERR`,
- boundary labels: not primary; `boundary_radius = 0` and
  `boundary_map_path` empty until separately approved,
- subject failure label: `Dice(B, GT) <= 0.8`.

## Rationale

The policy favors reproducibility and leakage control over post-hoc optimization.
It deliberately avoids boundary labels as a primary first target because boundary
radius/connectivity are easy to tune after seeing held-out failures.

## Guardrails

- No held-out test threshold tuning.
- No in-sample prediction labels for reliability-head training.
- No label generation before OOF metadata and artifact validators pass.
- No boundary supervision until radius/connectivity/role are separately locked.

## Remaining Work

- Implement label generator after OOF prediction files exist.
- Implement label manifest validator.
- Decide whether train-fold validation thresholds are worth adding later.
- Decide whether `SOFT_ERROR` is diagnostic or a training target.
