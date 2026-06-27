# UPENN B1B Internal-Val Prediction Result - 2026-06-25

## Scope

UPENN-GBM B1B outer-train internal-validation prediction only.

This is not UPENN held-out test performance and must not be interpreted as
four-fold benchmark evidence.

## Command

```bash
CUDA_VISIBLE_DEVICES=4 python research_gsure/03_baselines/scripts/train_b1_segmentation.py   --mode predict   --predict-split internal_val   --manifest research_gsure/02_audits/outputs/loco_split_manifest.csv   --heldout-dataset UPENN-GBM   --checkpoint-path research_gsure/03_baselines/outputs/20260624_100756_b1b_unet3d_dice_focal_bc16_d4_fitprobe_UPENN-GBM_192x224x160_spe64/checkpoint_last.pt   --patch-shape 192,224,160   --overlap 0.50   --batch-size 1   --architecture unet3d   --base-channels 16   --depth 4   --loss dice_focal   --max-infer-rows 0   --val-fraction 0.10   --device cuda   --amp-dtype bf16   --seed 20260623   --output-dir research_gsure/03_baselines/outputs/20260624_100756_b1b_unet3d_dice_focal_bc16_d4_internal_val_predict_UPENN-GBM_192x224x160_spe64
```

## Outputs

- `prediction_manifest.csv`
- `prediction_summary.json`
- `prediction_config.json`
- `prediction_command.json`
- `probability_maps/*.nii.gz`

## Result

- Prediction rows: 100.
- Inference scope: `outer_train_internal_validation`.
- Heldout dataset: `UPENN-GBM`.
- GPU: physical GPU4 via `CUDA_VISIBLE_DEVICES=4`.
- Max allocated GPU memory: 1689.680 MiB.
- Max reserved GPU memory: 2472.000 MiB.
- Artifact rows checked: 100.
- Artifact validation errors: 0.

## Interpretation

The UPENN internal-val prediction artifact is valid for train-only threshold
selection. It does not evaluate UPENN held-out test performance.

## Next Action

Run train-only threshold selection only after confirming the held-out UPENN test
prediction plan, because threshold selection requires both calibration and test
prediction manifests.
