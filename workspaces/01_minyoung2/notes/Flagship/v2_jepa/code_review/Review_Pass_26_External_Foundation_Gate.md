# Review Pass 26 — External Foundation Gate

Date: 2026-07-01 UTC

Reviewed file:

- `Flagship/v2_jepa/code/eval_external_foundation_probe.py`

## Scope

The script is a fast external gate for comparing frozen S3D and Brain-JEPA representations on A4/AIBL/AJU Yucca4 data. It is not the final pre-registered TC3 evaluation.

## Checks Performed

- Syntax:
  - `python -m py_compile Flagship/v2_jepa/code/eval_external_foundation_probe.py`
- Smoke:
  - JEPA A17 `shared_plus_morph`, 4 per cohort, CUDA, 2 folds.
  - S3D wg0.5, 4 per cohort, CUDA, 2 folds.
  - Cache-fingerprint regression smoke after code fix, JEPA shared, 2 per cohort.
- Functional gate:
  - A17 `shared_plus_morph`, 128 per cohort.
  - S3D wg0.5, 128 per cohort.
  - A10 JEPA shared, 128 per cohort.
  - A17 morphology only, 128 per cohort.

## Findings

### Fixed: unsafe feature-cache key

Initial implementation keyed cached features by:

```text
encoder + feature_space + crop + window_mode + n + seed
```

This was insufficient. A different checkpoint or different record set with the same `n` and `seed` could silently reuse the wrong features.

Fix:

- Added a SHA1 fingerprint from:
  - model/checkpoint identity;
  - morphology-head path when applicable;
  - ordered cohort/subject/session/scan/out path records.

### Accepted limitation: gate, not final TC3

This script intentionally does not implement:

- CN-only fit;
- nested A2 site-subspace removal;
- matched random seeds;
- morphometry baseline;
- BCa CI and Holm correction;
- ADNI/NACC/KDRC cross-cohort primary endpoint.

Those belong to the locked AAAI TC3 protocol, not this fast JEPA stop/go gate.

### Accepted limitation: center-crop shortcut sensitivity

The current gate uses deterministic center `96^3` crops. This is useful for fast relative comparison, but it can expose FOV/acquisition differences. Any positive claim must be rechecked with the full TC3 protocol and stronger augmentation/covariate controls.

## Verdict

The script is suitable for its intended use: a fast, provenance-explicit external stop/go gate for JEPA architecture search.

It should not be used as final paper evidence without the pre-registered TC3 evaluation stack.
