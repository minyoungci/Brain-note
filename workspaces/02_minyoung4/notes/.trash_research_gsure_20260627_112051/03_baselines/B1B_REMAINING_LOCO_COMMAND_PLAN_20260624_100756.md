# B1B Remaining LOCO Command Plan - 2026-06-24 10:07 UTC

## Task

Extend the current B1B calibrated segmentation/reliability evidence from two
held-out folds (MU, UCSD) to the remaining held-out folds:

```text
UPENN-GBM
UTSW
```

This plan is a command preview only. It does not approve GPU execution.

## Research Question

Does the B1B reliability-calibration gate that passed on MU+UCSD remain valid
when UPENN and UTSW are added to the LOCO evaluation?

## Current Evidence

Two-fold B1B gate:

```text
V0 predicted volume AUROC: 0.735
C0 calibrated entropy AUROC: 0.822
C1 entropy+volume AUROC: 0.910
```

Controlling artifact:

```text
research_gsure/03_baselines/outputs/20260624_1115_reliability_calibration_gate/reliability_calibration_decision.md
```

## Preflight State

Workspace:

```text
/home/vlm/minyoung4
```

Branch:

```text
main
```

GPU requirement:

```text
CUDA_VISIBLE_DEVICES=4
```

GPU4 status at preflight:

```text
NVIDIA B200, 0 MiB used, 0% util
```

Prior B1B memory use:

```text
fit:     max_reserved ~= 5.5 GiB
predict: max_reserved ~= 2.5 GiB
```

## Dataset Counts

Official LOCO manifest:

```text
research_gsure/02_audits/outputs/loco_split_manifest.csv
```

| heldout fold | train rows | test rows | approx internal-val rows |
|---|---:|---:|---:|
| UPENN-GBM | 1003 | 611 | 100 |
| UTSW | 992 | 622 | 99 |

## Locked B1B Configuration

```text
Model: scratch 3D U-Net
Pretraining: none
Input: 4 MRI channels [T1, T1ce, T2, FLAIR]
Patch shape: 192,224,160
Architecture: unet3d
Base channels: 16
Depth: 4
Loss: dice_focal
Optimizer: AdamW
LR: 1e-4
Weight decay: 1e-4
Batch size: 1
Epochs: 20
Steps per epoch: 64
Validate every: 2
Max validation rows: 8
Val fraction: 0.10
Seed: 20260623
Device: cuda
AMP: bf16
GPU: 4 only
```

This is intentionally the same B1B regimen used for the valid MU and UCSD runs.

## Runtime Risk

Observed B1B fit time:

```text
MU:   ~55 min for 20 epochs
UCSD: ~63 min for 20 epochs
```

Expected per remaining fold:

```text
fit:                  ~60-90 min
internal-val predict: ~30-60 min
heldout test predict: ~2-4 h, because UPENN/UTSW have ~3.4x more test rows than MU/UCSD
CPU eval/threshold:   tens of minutes depending on NIfTI IO
```

Stop criteria:

- CUDA OOM,
- non-finite loss,
- checkpoint not written,
- prediction manifest validation error,
- probability artifact validation error,
- Dice sanity mismatch after evaluation.

How to stop:

```text
Ctrl+C in the running shell
```

or, if detached:

```bash
pkill -f "20260624_100756_b1b_unet3d_dice_focal"
```

## Commands

### 0. Required preflight before execution

Run immediately before any GPU command:

```bash
nvidia-smi
pwd
git status --short
git branch --show-current
```

Do not execute the GPU commands below until Min approves.

---

## UPENN-GBM

### 1. Fit

Writes:

```text
research_gsure/03_baselines/outputs/20260624_100756_b1b_unet3d_dice_focal_bc16_d4_fitprobe_UPENN-GBM_192x224x160_spe64/
```

```bash
CUDA_VISIBLE_DEVICES=4 python research_gsure/03_baselines/scripts/train_b1_segmentation.py \
  --mode fit \
  --manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --heldout-dataset UPENN-GBM \
  --patch-shape 192,224,160 \
  --overlap 0.50 \
  --batch-size 1 \
  --architecture unet3d \
  --base-channels 16 \
  --depth 4 \
  --loss dice_focal \
  --epochs 20 \
  --steps-per-epoch 64 \
  --validate-every 2 \
  --max-train-rows 0 \
  --max-val-rows 8 \
  --val-fraction 0.10 \
  --device cuda \
  --amp-dtype bf16 \
  --seed 20260623 \
  --output-dir research_gsure/03_baselines/outputs/20260624_100756_b1b_unet3d_dice_focal_bc16_d4_fitprobe_UPENN-GBM_192x224x160_spe64
```

### 2. Validate fit

```bash
python research_gsure/03_baselines/scripts/validate_b1_fit_results.py \
  --fit-dir research_gsure/03_baselines/outputs/20260624_100756_b1b_unet3d_dice_focal_bc16_d4_fitprobe_UPENN-GBM_192x224x160_spe64 \
  --heldout UPENN-GBM \
  --expected-loss dice_focal \
  --expected-epochs 20 \
  --expected-steps-per-epoch 64 \
  --expected-validation-every 2 \
  --expected-base-channels 16 \
  --expected-depth 4 \
  --patch-shape 192,224,160
```

### 3. Predict outer-train internal validation

Writes:

```text
research_gsure/03_baselines/outputs/20260624_100756_b1b_unet3d_dice_focal_bc16_d4_internal_val_predict_UPENN-GBM_192x224x160_spe64/
```

```bash
CUDA_VISIBLE_DEVICES=4 python research_gsure/03_baselines/scripts/train_b1_segmentation.py \
  --mode predict \
  --predict-split internal_val \
  --manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --heldout-dataset UPENN-GBM \
  --checkpoint-path research_gsure/03_baselines/outputs/20260624_100756_b1b_unet3d_dice_focal_bc16_d4_fitprobe_UPENN-GBM_192x224x160_spe64/checkpoint_last.pt \
  --patch-shape 192,224,160 \
  --overlap 0.50 \
  --batch-size 1 \
  --architecture unet3d \
  --base-channels 16 \
  --depth 4 \
  --loss dice_focal \
  --max-infer-rows 0 \
  --val-fraction 0.10 \
  --device cuda \
  --amp-dtype bf16 \
  --seed 20260623 \
  --output-dir research_gsure/03_baselines/outputs/20260624_100756_b1b_unet3d_dice_focal_bc16_d4_internal_val_predict_UPENN-GBM_192x224x160_spe64
```

Validate internal-val artifacts:

```bash
python research_gsure/02_audits/scripts/validate_prediction_artifacts.py \
  --prediction-manifest research_gsure/03_baselines/outputs/20260624_100756_b1b_unet3d_dice_focal_bc16_d4_internal_val_predict_UPENN-GBM_192x224x160_spe64/prediction_manifest.csv
```

### 4. Predict held-out test

Writes:

```text
research_gsure/03_baselines/outputs/20260624_100756_b1b_unet3d_dice_focal_bc16_d4_fitprobe_predict_UPENN-GBM_192x224x160_spe64/
```

```bash
CUDA_VISIBLE_DEVICES=4 python research_gsure/03_baselines/scripts/train_b1_segmentation.py \
  --mode predict \
  --predict-split test \
  --manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --heldout-dataset UPENN-GBM \
  --checkpoint-path research_gsure/03_baselines/outputs/20260624_100756_b1b_unet3d_dice_focal_bc16_d4_fitprobe_UPENN-GBM_192x224x160_spe64/checkpoint_last.pt \
  --patch-shape 192,224,160 \
  --overlap 0.50 \
  --batch-size 1 \
  --architecture unet3d \
  --base-channels 16 \
  --depth 4 \
  --loss dice_focal \
  --max-infer-rows 0 \
  --device cuda \
  --amp-dtype bf16 \
  --seed 20260623 \
  --output-dir research_gsure/03_baselines/outputs/20260624_100756_b1b_unet3d_dice_focal_bc16_d4_fitprobe_predict_UPENN-GBM_192x224x160_spe64
```

Validate held-out OOF prediction:

```bash
python research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py \
  --prediction-manifest research_gsure/03_baselines/outputs/20260624_100756_b1b_unet3d_dice_focal_bc16_d4_fitprobe_predict_UPENN-GBM_192x224x160_spe64/prediction_manifest.csv \
  --heldout-dataset UPENN-GBM \
  --check-files

python research_gsure/02_audits/scripts/validate_prediction_artifacts.py \
  --prediction-manifest research_gsure/03_baselines/outputs/20260624_100756_b1b_unet3d_dice_focal_bc16_d4_fitprobe_predict_UPENN-GBM_192x224x160_spe64/prediction_manifest.csv
```

### 5. Threshold selection and calibrated eval

```bash
python research_gsure/03_baselines/scripts/select_threshold_from_predictions.py \
  --calibration-prediction-manifest research_gsure/03_baselines/outputs/20260624_100756_b1b_unet3d_dice_focal_bc16_d4_internal_val_predict_UPENN-GBM_192x224x160_spe64/prediction_manifest.csv \
  --test-prediction-manifest research_gsure/03_baselines/outputs/20260624_100756_b1b_unet3d_dice_focal_bc16_d4_fitprobe_predict_UPENN-GBM_192x224x160_spe64/prediction_manifest.csv \
  --out-dir research_gsure/03_baselines/outputs/20260624_100756_b1b_upenn_internal_val_threshold_selection \
  --output-prefix b1b_upenn_internal_val \
  --threshold-grid 0.3,0.4,0.5,0.6,0.7,0.8,0.9
```

Then evaluate the selected adjusted manifest:

```bash
python research_gsure/03_baselines/scripts/evaluate_b1_segmentation_predictions.py \
  --prediction-manifest research_gsure/03_baselines/outputs/20260624_100756_b1b_upenn_internal_val_threshold_selection/b1b_upenn_internal_val_test_manifest_threshold_<SELECTED>.csv \
  --out-dir research_gsure/03_baselines/outputs/20260624_100756_b1b_unet3d_dice_focal_bc16_d4_fitprobe_eval_UPENN-GBM_internal_val_threshold_spe64 \
  --output-prefix b1b_fitprobe_upenn_internal_val_threshold_spe64
```

---

## UTSW

### 1. Fit

Writes:

```text
research_gsure/03_baselines/outputs/20260624_100756_b1b_unet3d_dice_focal_bc16_d4_fitprobe_UTSW_192x224x160_spe64/
```

```bash
CUDA_VISIBLE_DEVICES=4 python research_gsure/03_baselines/scripts/train_b1_segmentation.py \
  --mode fit \
  --manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --heldout-dataset UTSW \
  --patch-shape 192,224,160 \
  --overlap 0.50 \
  --batch-size 1 \
  --architecture unet3d \
  --base-channels 16 \
  --depth 4 \
  --loss dice_focal \
  --epochs 20 \
  --steps-per-epoch 64 \
  --validate-every 2 \
  --max-train-rows 0 \
  --max-val-rows 8 \
  --val-fraction 0.10 \
  --device cuda \
  --amp-dtype bf16 \
  --seed 20260623 \
  --output-dir research_gsure/03_baselines/outputs/20260624_100756_b1b_unet3d_dice_focal_bc16_d4_fitprobe_UTSW_192x224x160_spe64
```

### 2. Validate fit

```bash
python research_gsure/03_baselines/scripts/validate_b1_fit_results.py \
  --fit-dir research_gsure/03_baselines/outputs/20260624_100756_b1b_unet3d_dice_focal_bc16_d4_fitprobe_UTSW_192x224x160_spe64 \
  --heldout UTSW \
  --expected-loss dice_focal \
  --expected-epochs 20 \
  --expected-steps-per-epoch 64 \
  --expected-validation-every 2 \
  --expected-base-channels 16 \
  --expected-depth 4 \
  --patch-shape 192,224,160
```

### 3. Predict outer-train internal validation

```bash
CUDA_VISIBLE_DEVICES=4 python research_gsure/03_baselines/scripts/train_b1_segmentation.py \
  --mode predict \
  --predict-split internal_val \
  --manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --heldout-dataset UTSW \
  --checkpoint-path research_gsure/03_baselines/outputs/20260624_100756_b1b_unet3d_dice_focal_bc16_d4_fitprobe_UTSW_192x224x160_spe64/checkpoint_last.pt \
  --patch-shape 192,224,160 \
  --overlap 0.50 \
  --batch-size 1 \
  --architecture unet3d \
  --base-channels 16 \
  --depth 4 \
  --loss dice_focal \
  --max-infer-rows 0 \
  --val-fraction 0.10 \
  --device cuda \
  --amp-dtype bf16 \
  --seed 20260623 \
  --output-dir research_gsure/03_baselines/outputs/20260624_100756_b1b_unet3d_dice_focal_bc16_d4_internal_val_predict_UTSW_192x224x160_spe64
```

Validate internal-val artifacts:

```bash
python research_gsure/02_audits/scripts/validate_prediction_artifacts.py \
  --prediction-manifest research_gsure/03_baselines/outputs/20260624_100756_b1b_unet3d_dice_focal_bc16_d4_internal_val_predict_UTSW_192x224x160_spe64/prediction_manifest.csv
```

### 4. Predict held-out test

```bash
CUDA_VISIBLE_DEVICES=4 python research_gsure/03_baselines/scripts/train_b1_segmentation.py \
  --mode predict \
  --predict-split test \
  --manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --heldout-dataset UTSW \
  --checkpoint-path research_gsure/03_baselines/outputs/20260624_100756_b1b_unet3d_dice_focal_bc16_d4_fitprobe_UTSW_192x224x160_spe64/checkpoint_last.pt \
  --patch-shape 192,224,160 \
  --overlap 0.50 \
  --batch-size 1 \
  --architecture unet3d \
  --base-channels 16 \
  --depth 4 \
  --loss dice_focal \
  --max-infer-rows 0 \
  --device cuda \
  --amp-dtype bf16 \
  --seed 20260623 \
  --output-dir research_gsure/03_baselines/outputs/20260624_100756_b1b_unet3d_dice_focal_bc16_d4_fitprobe_predict_UTSW_192x224x160_spe64
```

Validate held-out OOF prediction:

```bash
python research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py \
  --prediction-manifest research_gsure/03_baselines/outputs/20260624_100756_b1b_unet3d_dice_focal_bc16_d4_fitprobe_predict_UTSW_192x224x160_spe64/prediction_manifest.csv \
  --heldout-dataset UTSW \
  --check-files

python research_gsure/02_audits/scripts/validate_prediction_artifacts.py \
  --prediction-manifest research_gsure/03_baselines/outputs/20260624_100756_b1b_unet3d_dice_focal_bc16_d4_fitprobe_predict_UTSW_192x224x160_spe64/prediction_manifest.csv
```

### 5. Threshold selection and calibrated eval

```bash
python research_gsure/03_baselines/scripts/select_threshold_from_predictions.py \
  --calibration-prediction-manifest research_gsure/03_baselines/outputs/20260624_100756_b1b_unet3d_dice_focal_bc16_d4_internal_val_predict_UTSW_192x224x160_spe64/prediction_manifest.csv \
  --test-prediction-manifest research_gsure/03_baselines/outputs/20260624_100756_b1b_unet3d_dice_focal_bc16_d4_fitprobe_predict_UTSW_192x224x160_spe64/prediction_manifest.csv \
  --out-dir research_gsure/03_baselines/outputs/20260624_100756_b1b_utsw_internal_val_threshold_selection \
  --output-prefix b1b_utsw_internal_val \
  --threshold-grid 0.3,0.4,0.5,0.6,0.7,0.8,0.9
```

Then evaluate the selected adjusted manifest:

```bash
python research_gsure/03_baselines/scripts/evaluate_b1_segmentation_predictions.py \
  --prediction-manifest research_gsure/03_baselines/outputs/20260624_100756_b1b_utsw_internal_val_threshold_selection/b1b_utsw_internal_val_test_manifest_threshold_<SELECTED>.csv \
  --out-dir research_gsure/03_baselines/outputs/20260624_100756_b1b_unet3d_dice_focal_bc16_d4_fitprobe_eval_UTSW_internal_val_threshold_spe64 \
  --output-prefix b1b_fitprobe_utsw_internal_val_threshold_spe64
```

---

## Four-Fold Reliability Gate After Both Folds Finish

After UPENN and UTSW threshold-selected manifests exist, create a case config
JSON that includes MU, UCSD, UPENN, and UTSW, then run:

```bash
python research_gsure/03_baselines/scripts/evaluate_reliability_calibration_gate.py \
  --case-config-json research_gsure/03_baselines/outputs/20260624_100756_b1b_fourfold_reliability_case_config.json \
  --out-dir research_gsure/03_baselines/outputs/20260624_100756_b1b_fourfold_reliability_calibration_gate
```

Then run fold-stratified subject bootstrap against V0 predicted volume.

## Approval Needed

Min approval is required before running the first GPU command.

Recommended first execution unit after approval:

```text
UPENN fit only
```

Rationale:

- It is the smallest GPU step that creates a checkpoint for the first missing
  large fold.
- It does not write prediction maps yet.
- It can be validated immediately with the fit validator.

