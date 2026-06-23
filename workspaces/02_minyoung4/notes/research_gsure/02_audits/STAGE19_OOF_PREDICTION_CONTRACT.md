# Stage 19 OOF Prediction Contract

## Scope

Define the artifact contract for future full-volume out-of-fold segmentation
predictions and downstream reliability/error labels. This stage did not create
official split files, generate predictions, run inference, run GPU, preprocess
data, or train a model.

## Goal Reminder

G-SURE depends on reliable OOF prediction maps. If later reliability labels are
generated from in-sample predictions, patch-only outputs, or predictions without
provenance, the core research claim becomes invalid.

## Inputs Reviewed

- `research_gsure/03_baselines/BASELINE_CONTRACT.md`
- `research_gsure/03_baselines/SEGMENTATION_BASELINE_PROTOCOL.md`
- `research_gsure/04_method/GSURE_METHOD_SKETCH.md`
- `research_gsure/05_reports/REPORT_TEMPLATE.md`
- existing protocol references to OOF predictions and reliability labels

## Decision / Action

Added:

```text
research_gsure/01_protocol/OOF_PREDICTION_RELIABILITY_CONTRACT.md
```

The contract defines:

- required OOF prediction manifest schema,
- hard invariants for held-out full-volume predictions,
- forbidden prediction sources,
- binary threshold policy,
- FN/FP/ERR and optional boundary/soft-error label definitions,
- required reliability label manifest schema,
- minimum validation before reliability label generation.

## Key Guardrail

A prediction is eligible for reliability/error labels only if it is:

```text
full-volume + held-out/out-of-fold + provenance-recorded + shape-validated
```

## Interpretation

This fills the gap between "train a segmentation baseline" and "use errors as
G-SURE supervision." It makes leakage and artifact risks auditable before any
actual prediction maps exist.

## Remaining Work

- Metadata-only prediction-manifest validator is now added in
  `research_gsure/02_audits/STAGE20_OOF_PREDICTION_VALIDATOR.md`.
- Lock the probability-map file format.
- Lock threshold policy.
- Lock boundary radius and morphology connectivity.
- Implement artifact-level probability map value-range and geometry validation
  after the file format is locked.
- Generate predictions only after official split, loader smoke, tile-grid
  dry-run, GPU preview, and GPU approval.
