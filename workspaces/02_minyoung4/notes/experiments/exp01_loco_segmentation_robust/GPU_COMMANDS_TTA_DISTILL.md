# GPU Command Preview: ResUNet-DS TTA Distillation

Purpose: test whether the positive all-flip TTA behavior can be distilled into a
single-pass ResUNet-DS training method without the degradation seen from bidirectional
flip-consistency.

Run name:

```bash
RUN_NAME=resunet_ds_tta_distill_loco_full_v1_sharedcache
```

Full GPU launch:

```bash
CONFIRM_LONG_GPU_RUN=yes \
GPU_UCSD=2 GPU_MU=3 GPU_UPENN=4 GPU_UTSW=2 \
CACHE_DIR=/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/standard_dice_bce_loco_full_v1_sharedcache/shared_cache \
CONSISTENCY_WEIGHT=0.10 \
CONSISTENCY_WARMUP_EPOCHS=5 \
bash experiments/exp01_loco_segmentation_robust/scripts/launch_all_nohup_resunet_ds_tta_distill.sh \
  "${RUN_NAME}"
```

Watcher:

```bash
POLL_SEC=120 bash experiments/exp01_loco_segmentation_robust/scripts/launch_nohup_watcher.sh \
  "${RUN_NAME}"
```

Paired comparisons:

```bash
POLL_SEC=180 bash experiments/exp01_loco_segmentation_robust/scripts/launch_nohup_compare_watcher.sh \
  standard_dice_bce_loco_full_v1_sharedcache \
  "${RUN_NAME}" \
  standard_vs_resunet_ds_tta_distill_v1

POLL_SEC=180 bash experiments/exp01_loco_segmentation_robust/scripts/launch_nohup_compare_watcher.sh \
  resunet_ds_dice_bce_loco_full_v1_sharedcache \
  "${RUN_NAME}" \
  resunet_ds_vs_resunet_ds_tta_distill_v1

POLL_SEC=180 bash experiments/exp01_loco_segmentation_robust/scripts/launch_nohup_compare_watcher.sh \
  resunet_ds_tta_all_v1 \
  "${RUN_NAME}" \
  resunet_ds_tta_vs_resunet_ds_tta_distill_v1
```

Pre-launch checks already performed:

- `pwd`: `/home/vlm/minyoung4`
- branch: `main`
- `nvidia-smi`: GPUs 2/3/4 were free of exp01 processes after the previous run ended.
- `python -m py_compile train_segmentation_loco.py`: passed.
- `bash -n launch_all_nohup_resunet_ds_tta_distill.sh`: passed.
- CPU real-data smoke: `runs/smoke_resunet_ds_tta_distill_cpu_v1/outer_UCSD-PTGBM`.

Do not treat this as launched until the commands above are explicitly executed.
