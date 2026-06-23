# Stage 15 Loader Smoke Hardening

## Scope

Strengthen the CPU loader smoke test before official split creation. This stage
did not create official split files, cache tensors, preprocess data, or run GPU.

## Goal Reminder

G-SURE requires reliable full-volume OOF segmentation predictions. A loader that
silently accepts affine/orientation mismatches would corrupt segmentation and
therefore corrupt downstream reliability labels.

## Change

`smoke_load_manifest_sample.py` now checks:

- T1/T1ce/T2/FLAIR and mask load,
- matching shape,
- matching affine,
- matching orientation,
- matching voxel spacing,
- finite array values,
- non-empty binary target,
- optional `--dataset` filter for pre-split bounded development smoke.

## Validation Performed

Compile:

```bash
python -m py_compile research_gsure/02_audits/scripts/smoke_load_manifest_sample.py
```

MU pre-split development smoke:

```bash
python research_gsure/02_audits/scripts/smoke_load_manifest_sample.py \
  --manifest research_gsure/02_audits/outputs/subject_level_cohort_manifest_draft.csv \
  --max-rows 2
```

Observed:

```text
Smoke-loaded rows: 2
```

UCSD pre-split development smoke:

```bash
python research_gsure/02_audits/scripts/smoke_load_manifest_sample.py \
  --manifest research_gsure/02_audits/outputs/subject_level_cohort_manifest_draft.csv \
  --dataset UCSD-PTGBM \
  --max-rows 2
```

Observed:

```text
Smoke-loaded rows: 2
```

The sampled UCSD rows showed `256x256x256`, `ILA`, `1x1x1` geometry across all
four MRI channels and mask.

## Guardrails

- Pre-split subject-manifest smoke is development validation only.
- It does not replace the required post-split smoke on
  `loco_split_manifest.csv`.
- It does not validate canonical orientation transforms, patch extraction,
  sliding-window inference, or GPU memory.

## Next Action

After official split approval, run the required post-split smoke command from:

```text
research_gsure/01_protocol/POST_SPLIT_LOADER_SMOKE_CONTRACT.md
```
