# UPENN B1B Held-Out Prediction Result - 2026-06-25

## Scope

UPENN-GBM B1B held-out test prediction and thresholded evaluation.

This is one additional LOCO held-out fold, not a completed four-fold benchmark.
Do not generalize the MU+UCSD two-fold calibration claim until UTSW and the
four-fold C0/C1/E2/E3 analyses are complete.

## GPU Policy Change

`train_b1_segmentation.py` was updated to allow approved physical GPUs 3 or 4
instead of only GPU4. This run used physical GPU3:

```text
CUDA_VISIBLE_DEVICES=3
```

## Prediction Command

```bash
CUDA_VISIBLE_DEVICES=3 python research_gsure/03_baselines/scripts/train_b1_segmentation.py   --mode predict   --predict-split test   --manifest research_gsure/02_audits/outputs/loco_split_manifest.csv   --heldout-dataset UPENN-GBM   --checkpoint-path research_gsure/03_baselines/outputs/20260624_100756_b1b_unet3d_dice_focal_bc16_d4_fitprobe_UPENN-GBM_192x224x160_spe64/checkpoint_last.pt   --patch-shape 192,224,160   --overlap 0.50   --batch-size 1   --architecture unet3d   --base-channels 16   --depth 4   --loss dice_focal   --max-infer-rows 0   --device cuda   --amp-dtype bf16   --seed 20260623   --output-dir research_gsure/03_baselines/outputs/20260624_100756_b1b_unet3d_dice_focal_bc16_d4_fitprobe_predict_UPENN-GBM_192x224x160_spe64
```

## Prediction Outputs

- `prediction_manifest.csv`
- `prediction_summary.json`
- `prediction_config.json`
- `prediction_command.json`
- `probability_maps/*.nii.gz`

## Prediction Result

- Prediction rows: 611.
- Inference scope: `heldout_test`.
- Heldout dataset: `UPENN-GBM`.
- GPU: physical GPU3 via `CUDA_VISIBLE_DEVICES=3`.
- Max allocated GPU memory: 1689.680 MiB.
- Max reserved GPU memory: 2472.000 MiB.

## Artifact Validation

- OOF prediction rows: 611.
- OOF manifest validation errors: 0.
- Artifact rows checked: 611.
- Artifact validation errors: 0.

## Train-Only Threshold Selection

- Selected threshold: 0.8.
- Selection source: UPENN outer-train internal-val prediction manifest only.
- Test metrics were not read for threshold selection.
- Adjusted test manifest:
  `research_gsure/03_baselines/outputs/20260624_100756_b1b_upenn_internal_val_threshold_selection/b1b_upenn_internal_val_test_manifest_threshold_0.8.csv`

## Thresholded Held-Out Evaluation

Output:

```text
research_gsure/03_baselines/outputs/20260624_100756_b1b_unet3d_dice_focal_bc16_d4_fitprobe_eval_UPENN-GBM_internal_val_threshold_spe64/
```

Overall UPENN held-out metrics at threshold 0.8:

- Rows evaluated: 611.
- Mean Dice: 0.8492609183656702.
- Median Dice: 0.8735477284328739.
- Pooled Dice: 0.8713742930736292.
- Dice <= 0.8 failure rate: 0.18003273322422259.
- Pooled pred/GT volume ratio: 1.0154373772412357.

Size-stratified failure rates:

- Large: 0.04411764705882353.
- Medium: 0.07389162561576355.
- Small: 0.4215686274509804.

Evaluation validation:

- `valid=true`.
- `rows_evaluated=611`.
- `errors=[]`.

## Interpretation

The UPENN fold now has valid held-out prediction, train-only threshold
selection, and thresholded segmentation evaluation artifacts. This supports
continuing the four-fold reproduction, but it is not yet the four-fold
reliability/calibration result.

## Next Action

Run UTSW B1B fit/predict/eval, then rerun the four-fold C0/C1 reliability gate
and E2/E3 threshold/site/size controls.
