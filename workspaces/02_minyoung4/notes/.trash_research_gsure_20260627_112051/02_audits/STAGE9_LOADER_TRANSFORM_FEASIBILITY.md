# Stage 9 Loader Transform Feasibility Audit

## Scope

CPU-only, read-only sample audit for baseline loader orientation and candidate
crop/pad feasibility.

This audit did not create an official split, did not preprocess data, did not
cache tensors, and did not run GPU training.

## Research Goal Reminder

G-SURE requires out-of-fold segmentation predictions and error maps. Therefore,
the first loader must preserve tumor masks and avoid geometry artifacts before
any reliability/grounding method is implemented.

## Command

```bash
python research_gsure/02_audits/scripts/audit_loader_transform_feasibility.py --max-per-dataset 5
```

## Sampling

The script samples lesion-fraction quantiles per dataset from the subject-level
draft manifest:

```text
manifest rows: 1,614
sampled subject rows: 20
sampled rows per dataset: 5
```

This is not a full-cohort proof. It is a pre-loader feasibility check.

## Outputs

- `outputs/loader_transform_feasibility_sample.csv`
- `outputs/loader_transform_feasibility_summary.csv`
- `outputs/loader_transform_feasibility_report.md`
- `outputs/loader_transform_feasibility_quantile20.csv`
- `outputs/loader_transform_feasibility_quantile20_summary.csv`
- `outputs/loader_transform_feasibility_quantile20_report.md`

## Observed Result: 20-Subject Audit

Execution result:

```text
Manifest rows: 1614
Sampled subject rows: 20
Candidate shapes: 128x160x128,160x192x160,192x224x160,224x224x160
Detailed candidate rows: 80
Errors: 0
```

After canonical orientation:

| dataset | canonical channel shape | canonical orientation | mask canonical shape | mask orientation |
|---|---|---|---|---|
| MU-Glioma-Post | 240x240x155 | RAS | 240x240x155 | RAS |
| UCSD-PTGBM | 256x256x256 | RAS | 256x256x256 | RAS |
| UPENN-GBM | 240x240x155 | RAS | 240x240x155 | RAS |
| UTSW | 240x240x155 | RAS | 240x240x155 | RAS |

Candidate bbox containment:

| candidate shape | bbox-by-extent result | fixed-center crop result |
|---|---|
| 128x160x128 | failed 1 / 20 sampled subjects | failed 7 / 20 sampled subjects |
| 160x192x160 | passed 20 / 20 | passed 20 / 20 |
| 192x224x160 | passed 20 / 20 | passed 20 / 20 |
| 224x224x160 | passed 20 / 20 | passed 20 / 20 |

The extent-failed case for `128x160x128` was:

```text
MU-Glioma-Post::PatientID_0047
bbox extent: 134x164x84
```

Sampled maximum bbox extents:

| dataset | max sampled bbox extent |
|---|---|
| MU-Glioma-Post | 134x164x84 |
| UCSD-PTGBM | 96x135x89 |
| UPENN-GBM | 68x135x99 |
| UTSW | 105x135x116 |

## Interpretation

- Canonical orientation to RAS appears feasible on the sampled rows.
- `128x160x128` should not be used as the first baseline input shape because it
  can crop sampled lesions.
- `160x192x160` is the smallest sampled candidate that preserved all sampled
  lesion bounding boxes under both extent and fixed-center crop checks.
- GT-mask-centered crops are not allowed at inference. If the baseline uses
  patches, test-time inference must use sliding-window or another reviewed
  full-volume coverage path.

## Expanded 80-Subject Quantile Audit

Command:

```bash
python research_gsure/02_audits/scripts/audit_loader_transform_feasibility.py \
  --max-per-dataset 20 \
  --output-prefix loader_transform_feasibility_quantile20
```

Execution result:

```text
Manifest rows: 1614
Selection mode: quantile_max_per_dataset_20
Sampled subject rows: 80
Candidate shapes: 128x160x128,160x192x160,192x224x160,224x224x160
Detailed candidate rows: 320
Errors: 0
```

Expanded audit candidate result:

| candidate shape | bbox-by-extent result | fixed-center crop result |
|---|---:|---:|
| 128x160x128 | passed 79 / 80 | passed 54 / 80 |
| 160x192x160 | passed 80 / 80 | passed 79 / 80 |
| 192x224x160 | passed 80 / 80 | passed 79 / 80 |
| 224x224x160 | passed 80 / 80 | passed 80 / 80 |

The fixed-center failure for `160x192x160` and `192x224x160` was:

```text
UCSD-PTGBM::UCSD-PTGBM-0127
bbox min/max: 126x50x79 / 232x184x153
bbox extent: 107x135x75
```

Expanded sampled maximum bbox extents:

| dataset | max sampled bbox extent |
|---|---|
| MU-Glioma-Post | 134x164x93 |
| UCSD-PTGBM | 107x135x92 |
| UPENN-GBM | 106x137x99 |
| UTSW | 105x135x116 |

Updated interpretation:

- `160x192x160` is still plausible for patch-based training/inference only if
  inference uses sliding-window or another full-coverage method.
- `160x192x160` should not be locked as a simple fixed-center full input.
- `224x224x160` is the smallest tested candidate that passed fixed-center
  containment in the expanded 80-subject sample.
- Full-cohort transform feasibility remains unverified.

## Guardrails

- Do not treat `160x192x160` as locked.
- Do not train until the official split exists and the post-split loader smoke
  test passes.
- A full-cohort or split-aware loader check is still needed before GPU training.
- Do not treat fixed-center crop containment as sufficient for segmentation
  inference unless full-volume coverage is also implemented.
- This audit does not validate GPU memory, normalization, augmentation, Dice, or
  reliability performance.

## Next Action

After Min approves official split creation:

1. Write the official LOCO split manifest.
2. Run the post-split loader smoke.
3. Add a split-aware transform check for the chosen candidate shape.
4. Preview GPU memory/runtime before any training.
