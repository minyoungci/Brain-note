# Review Pass 23: A18 Paired-Modality JEPA

Date: 2026-07-01 UTC

Scope:

```text
Flagship/v2_jepa/code/source_balanced_data.py
Flagship/v2_jepa/code/train_brain_jepa.py
Flagship/v2_jepa/code/tests/test_brain_jepa.py
Flagship/v2_jepa/runs/RUNNING_JEPA_PILOTS.md
```

## Reason

A17 is the best current JEPA research branch, but the protocol/FOV group-heldout gate showed it is essentially tied with S3D on Task1/Task5. That means source-probe improvement alone is not enough.

A18 therefore adds true cross-modality anatomy pressure:

```text
context crop: one MRI sequence
target crop:  another MRI sequence from the same subject/session and same shape
main loss:    JEPA latent prediction across modalities
auxiliary:    A10 S3D dense/local distillation + source adversary
```

This directly targets modality-invariant anatomy rather than only suppressing source labels.

## Data Feasibility

Manifest grouping by `(pt, subject, session, shape)` found:

| Pair | Same-shape usable pairs | Sources with >=8 pairs | Decision |
|---|---:|---:|---|
| T1-FLAIR | 4,170 | 6 | run A18 branch |
| T1-T2 | 11,931 | 11 | run A18 branch |
| T1-DWI | 45 | 1 | too sparse |
| FLAIR-DWI | 3 | 0 | too sparse |

The same-shape constraint is intentional. It avoids assuming registration when only preprocessed NPY arrays are available.

## Implementation

Added:

```text
PairedSourceRecord
PairedModalityMultiCrop
build_paired_source_records()
infinite_paired_batches()
```

New training args:

```text
--paired_modality
--paired_pair t1_flair|t1_t2|t1_dwi|flair_dwi
--paired_random_swap
```

Training guard:

```text
--paired_modality requires --target_view second_crop
```

This prevents accidentally training same-modality JEPA while believing the paired target is active.

## Validation

Static validation:

```text
python -m py_compile \
  Flagship/v2_jepa/code/source_balanced_data.py \
  Flagship/v2_jepa/code/train_brain_jepa.py \
  Flagship/v2_jepa/code/tests/test_brain_jepa.py
```

Unit tests:

```text
python Flagship/v2_jepa/code/tests/test_brain_jepa.py
Ran 17 tests OK
```

New unit coverage:

```text
test_paired_modality_records_and_dataset
```

GPU smoke:

```text
smoke_a18_paired_t1flair_gpu0
  steps=5
  finite loss
  non-collapsed rank/std
  ckpt_step5.pt written
```

## Launched Pilots

| GPU | PID | Run | Pair | Seed | Status |
|---|---:|---|---|---:|---|
| 0 | 2318768 | `pilot_a18_paired_t1flair_s3ddense005_seed4700_gpu0_20260701` | T1-FLAIR | 4700 | stopped after 5k gate |
| 1 | 2318787 | `pilot_a18_paired_t1t2_s3ddense005_seed4701_gpu1_20260701` | T1-T2 | 4701 | stopped after 5k gate |

Initial health at step ~261:

| Branch | Loss | JEPA loss | S3D dense loss | Source acc | Pred std | Pred rank |
|---|---:|---:|---:|---:|---:|---:|
| T1-FLAIR | 2.4037 | 0.1781 | 1.5232 | 0.000 | 0.2053 | 64.85 |
| T1-T2 | 2.6057 | 0.1616 | 1.5400 | 0.000 | 0.2109 | 57.77 |

No collapse or startup error observed.

## Gate

A18 must pass a stronger gate than A17:

```text
source-probe <= 0.17
random downstream Task1 >= 0.80
random downstream Task5 >= 0.88
protocol-group Task1/Task5 must beat or match S3D
brain-age should improve over A17 or at least stay above A10
```

If A18 only improves source-probe but fails protocol-group downstream, it is not promoted.

## Step5000 Gate Result

| Branch | Source-probe acc | Random Task1 AUROC | Random brain-age r | Random Task5 AUROC | Protocol Task1 AUROC | Protocol Task5 AUROC | Verdict |
|---|---:|---:|---:|---:|---:|---:|---|
| T1-FLAIR | 0.0981 | 0.6827 | 0.7568 | 0.9774 | 0.4423 | 0.9045 | reject; not protocol-robust |
| T1-T2 | 0.1056 | 0.4231 | 0.7568 | 0.8715 | not run | not run | reject early |

Reference:

| Model | Source-probe acc | Random Task1 | Random brain-age | Random Task5 | Protocol Task1 | Protocol Task5 |
|---|---:|---:|---:|---:|---:|---:|
| A17 adv `0.10` | 0.1130 mean | 0.8654 | 0.7122 | 0.9080 | 0.8173 | 0.8976 |
| S3D+InfoNCE wg0.5 | 0.3105 mean | 0.7212 | 0.7924 | 0.9566 | 0.8269 | 0.9010 |

Decision:

- A18 is not continued to 10k/20k as-is.
- The useful finding is narrow but important: paired-modality anatomy consistency improves brain-age while preserving source robustness.
- The failure is also clear: using the paired-modality target directly on the shared representation damages pathology-sensitive/multi-modal classification, especially under protocol/FOV group holdout.
- The next design should move paired-modality prediction into a separate anatomy/modality-invariant branch while keeping a separate pathology/global branch.
