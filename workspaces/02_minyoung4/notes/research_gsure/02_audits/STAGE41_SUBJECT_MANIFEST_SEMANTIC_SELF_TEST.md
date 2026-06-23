# Stage 41 - Subject Manifest Semantic Self-Test

## Task

Add a negative-control self-test for the subject-level manifest semantic checks
inside the pre-split readiness preflight.

## Research Question

Do the new subject-manifest semantic checks actually fail when target, unit
selection, mask source, mask burden, geometry flag, path presence, or
subject-level uniqueness is corrupted?

## Why This Matters

The official split will be created from the current subject-level manifest. A
green preflight is only useful if the validator catches plausible manifest drift,
not merely if it passes the current CSV.

## What Changed

`check_pre_split_readiness.py` now supports:

```bash
python research_gsure/02_audits/scripts/check_pre_split_readiness.py \
  --subject-manifest-self-test
```

The self-test:

- validates the current subject-level manifest as the baseline,
- clones rows in memory,
- applies one corruption at a time,
- confirms the semantic validator rejects each corrupted case,
- writes no files.

## Negative Controls

The self-test rejects:

- `target_definition` drift,
- `selection_policy` drift,
- dataset-specific `selected_mask_key` drift,
- nonpositive `mask_nonzero_voxels`,
- invalid `mask_nonzero_fraction`,
- `all_modalities_shape_affine_match_mask` drift,
- duplicate `dataset::subject_id` leakage group,
- missing selected mask path.

## Guardrails

- No official split artifacts are created.
- No NIfTI files are loaded.
- No GPU work is performed.
- No predictions, reliability labels, metrics, checkpoints, or preprocessing
  arrays are generated.

## Validation

Required validation:

```bash
python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py
python research_gsure/02_audits/scripts/check_pre_split_readiness.py --subject-manifest-self-test
python research_gsure/02_audits/scripts/check_pre_split_readiness.py
```

Expected self-test output includes:

```text
Subject manifest semantic self-test: PASS
Baseline manifest validation: PASS
Negative controls rejected: 8
```

## Interpretation

This strengthens the official split gate. It does not prove image quality,
segmentation performance, reliability generalization, novelty, or GPU
feasibility.

## Remaining Gate

Official LOCO split creation still requires explicit Min approval:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```
