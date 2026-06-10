# Baseline sequence

## B00 manifest contract

Read-only validation and visualization. Completed in `results/baseline_00_manifest_contract/`.

## B01 dataloader smoke

CPU/small-GPU smoke: load N MRI rows, five ROI masks, create tensors, verify batch collation. No training.

## B02 ROI mean logistic regression CN vs AD

Completed in `results/baseline_02_roi_mean_logreg_cn_vs_ad/`.

Simplest ROI scalar baseline: mean z-scored voxel intensity per ROI only; CN vs AD logistic regression on a subject-disjoint split. MCI is excluded from this binary probe.

## B03 tiny 3D CNN image-only baseline

GPU gated. Requires `nvidia-smi`, command preview, and Min approval.

## B04 voxel-wise ROI-supervised encoder

GPU gated. Uses `candidate_mask_path` for ROI-local pooling/masked feature objectives.
