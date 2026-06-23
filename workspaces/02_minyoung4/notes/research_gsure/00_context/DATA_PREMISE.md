# Data Premise for G-SURE

## What We Know

The currently preserved workspace contains raw-like data under:

```text
data/
  MU-Glioma-Post/
  UCSD-PTGBM/
  UPENN-GBM/
  UTSW/
  _tools/
```

The research premise is based on previously inspected EDA artifacts and current
filesystem structure:

- Four main glioma MRI sources: UTSW, MU-Glioma-Post, UCSD-PTGBM, UPENN-GBM.
- Common structural MRI core: T1, T1ce/T1-post, T2, FLAIR.
- High tumor segmentation mask availability across sources.
- Subject-level clinical/scanner metadata exists and should be used for
  reporting and confound auditing.
- Some sources contain multiple sessions/timepoints per subject.

## What Must Be Re-Audited

Because previous generated EDA artifacts were intentionally deleted, the next
formal step is to regenerate only the minimum EDA needed for this new research
direction:

1. Dataset inventory.
2. Structural MRI path manifest.
3. Segmentation file manifest.
4. Mask label taxonomy.
5. Image-mask geometry compatibility.
6. Subject/session/timepoint grouping.

## Non-Negotiable Data Rules

- Do not write, move, rename, or delete anything under `data/`.
- Do not split multiple sessions/timepoints from the same subject across
  train/validation/test.
- Do not treat UPENN NIfTI, DICOM, and histopath as independent subject pools.
- Do not assume that all segmentation files mean the same anatomical region
  until mask taxonomy is locked.

