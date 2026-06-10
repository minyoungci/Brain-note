# image_only_smoke_v0

First image-only smoke baseline for the `/home/vlm/minyoungi` VLM/T1w integrated manifest.

## Purpose

Verify that the canonical T1w image paths, subject-disjoint split, labels, and a tiny 3D image-only training loop work end-to-end before any larger VLM/image-text training.

## Scope

- Workspace: `/home/vlm/minyoungi` only.
- Input manifest: `manifests/v2_integrated/canonical/vlm_ready_manifest_v2_integrated_oasis_included_v0.csv`
- Split: `manifests/v2_integrated/splits/subject_disjoint_split_v0.csv`
- Image input: `t1w_preproc_path` only, optionally masked with `brain_mask_path`.
- Target: `diagnosis_3class` in `CN`, `MCI`, `AD`.
- No captions, ROI scalar features, CDR, biomarker, cohort/site/scanner fields, or PET-derived information are used as model inputs.

## Smoke design

This is not a final performance experiment. It trains a tiny 3D CNN on a deterministic class-balanced subset, after downsampling volumes to a small grid, then reports train/val/internal_test metrics.

Outputs are written under `runs/<run_id>/`:

- `config.json`
- `sampled_rows.csv`
- `metrics.json`
- `predictions.csv`
- `model.pt`
- `REPORT.md`

## Example

```bash
python experiments/image_only_smoke_v0/run_image_only_smoke_v0.py \
  --device cuda:7 \
  --max-train-per-class 40 \
  --max-eval-per-class 20 \
  --epochs 4
```
