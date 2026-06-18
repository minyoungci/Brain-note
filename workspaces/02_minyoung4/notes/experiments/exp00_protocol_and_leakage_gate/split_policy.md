# Split Policy Draft

Status: draft.

## Primary Policy

Use leave-one-consortium-out evaluation.

For each fold:

- one consortium is held out as test;
- remaining consortia are used for train/validation only;
- validation is drawn only from non-held-out consortia;
- all rows for a `dataset::subject_id` stay in exactly one split.

## Validation Selection Mechanics

Within each LOCO fold:

- create validation groups from training consortia only;
- preserve subject grouping;
- use a fixed seed recorded in the split artifact;
- target validation fraction is 20% of training subjects;
- validation selection is stratified by `(dataset, idh_label)` where feasible;
- each `(dataset, idh_label)` stratum contributes `round(0.20 * n)` subjects, clamped to
  at least 1 and at most `n - 1` when `n >= 2`;
- strata with `n == 1` stay in training;
- deterministic shuffle key is `sha256(stable_split_id | seed | dataset | subject_id)`;
- ties are broken by lexical `(dataset, subject_id)`;
- report validation class counts by consortium.

If the resulting validation split has fewer than 5 mutant subjects:

- mark `valid_for_threshold_selection = false`;
- do not use that validation split for threshold selection, calibration, or early stopping
  criteria requiring positive-class stability;
- use predefined hyperparameters from the locked config only;
- still allow the split for loader and loss debugging if clearly marked diagnostic.

Default seed for draft split generation:

```text
20260618
```

This seed is a draft default. Final split files still require Min approval.

Default validation fraction for draft split generation:

```text
0.20
```

## Fold Artifact Schema

Approved split files must include:

- `stable_split_id`;
- `cohort_id`;
- `fold_id`;
- `heldout_dataset`;
- `dataset`;
- `subject_id`;
- `leakage_group_id`;
- `split`;
- `idh_label`;
- `age_bin`;
- `sex_subject`;
- `scanner_vendor_bin`;
- `field_strength_bin`;
- `has_segmentation`;
- `seed`;
- `validation_fraction`;
- `valid_for_threshold_selection`;
- `created_at_utc`;
- `source_manifest_sha256`.

## Forbidden

- random file-level split;
- random NIfTI-unit split;
- random visit/session split without subject grouping;
- using held-out consortium for early stopping;
- choosing thresholds on held-out consortium;
- fitting normalization/scalers on held-out consortium.

## Required Split Checks

- Every subject group appears in one split only.
- Every held-out fold contains exactly one held-out consortium.
- Class counts are reported by split and consortium.
- Multi-unit subjects do not cross splits.
- Every split artifact has a source manifest hash.
- Validation mutant counts are sufficient for the intended model-selection procedure.

## Diagnostic-Only Splits

Pooled grouped random splits may be used only as diagnostics.
They cannot be the main result.
