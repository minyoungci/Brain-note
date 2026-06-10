# F04 ROI Evidence Model Code Review

Updated: 2026-06-01

## Scope

Reviewed:

- `scripts/train_f04_roi_evidence_smoke.py`
- `scripts/build_f04_roi_slab_cache.py`
- Active dataset: `results/f04_roi_evidence_encoder/20260531_235859_roi_evidence_dataset`

## Verdict

The ROI evidence training code is acceptable for feasibility experiments, but not yet publication-grade full training. The main scientific result from the smoke/medium runs is usable: multi-target anatomical evidence is learnable, especially ventricle-related targets. The next training run should use the slab cache and should report target-wise metrics, not only averaged validation RMSE.

## Strengths

- Image-only input: no clinical variables are fed into the ROI regression model.
- Subject split integrity comes from the active dataset; current subject overlap is zero.
- Targets are standardized using train sessions only.
- Evaluation reports session-level aggregation, avoiding inflated slab-level interpretation.
- Outputs are stored under the active `results/f04_roi_evidence_encoder/` namespace.
- The training script now writes `history.csv`, `latest_epoch.json`, and `checkpoint_best.pt` after every epoch.

## Methodology Risks

| issue | severity | consequence | action |
|---|---:|---|---|
| Direct NIfTI loading during training | high | slow, unstable medium/full runs | use `roi_evidence_slab_cache_full_v1` |
| Worker-local full-volume cache | high | RAM use can grow with dataset size | cache-first loader for full run |
| Validation checkpoint uses mean raw RMSE across targets | medium | larger-scale targets dominate model selection | add standardized RMSE or target-weighted score |
| All targets have equal loss weight | medium | weak hippocampus/MTL targets may be underfit | use primary/auxiliary target weighting |
| Tiny CNN is feasibility-only | medium | not a final representation model | replace with stronger 2.5D encoder after cache |
| Axial-only slabs | medium | hippocampus/MTL may be weak due view/coverage | later compare coronal/sagittal or 3-view |
| No augmentation | low/medium | robustness unknown | add light affine/intensity augmentation after baseline |
| Cohort shortcut not audited at ROI representation stage yet | high for claims | learned representation may still encode cohort/site | run cohort predictability and clinical-matched downstream probes |

## Current Interpretation

Do not claim that the model learns hippocampal atrophy precisely. Current evidence supports a narrower claim:

> Multi-target ROI evidence supervision can train a T1w image encoder to recover anatomical degeneration patterns, with the strongest signal in ventricular enlargement and ventricle-related ratios.

## Required Next Code Step

Use a cache-backed Dataset reading:

- `slab_images_float16.npy`
- `cache_manifest.csv`

The cache is row-aligned by `cache_index`; each row in `cache_manifest.csv` maps to `slab_images_float16.npy[cache_index]`.

## Required Next Experiment

Run a cache-backed multi-target encoder with:

- primary targets: `log1p_roi_ventricle_sum_vol`, `roi_ventricle_to_brain_proxy`, `roi_hippocampus_to_ventricle`
- auxiliary targets: `log1p_roi_mtl_sum_vol`, `log1p_roi_hippocampus_vol`, `roi_mtl_to_brain_proxy`
- target-wise session R2/Pearson/MAE gain
- early stopping by target-weighted standardized validation score
- representation export for downstream shortcut audit
