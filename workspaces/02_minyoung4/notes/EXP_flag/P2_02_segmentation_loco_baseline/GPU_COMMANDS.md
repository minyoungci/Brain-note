# P2.02 GPU Command Preview

Do not run these without Min approval under `AGENTS.md`.

Before launch:

```bash
cd /home/vlm/minyoung4
nvidia-smi
git status --short
git branch --show-current
```

Recommended first fold after approval:

```bash
cd /home/vlm/minyoung4
HELDOUT_DATASET=UCSD-PTGBM \
GPU=2 \
RUN_ID=seg_unet3d_loco_ucsd_full_v1 \
TARGET_SHAPE=64,96,96 \
EPOCHS=50 \
BATCH_SIZE=1 \
NUM_WORKERS=4 \
BASE_CH=24 \
EXP_flag/P2_02_segmentation_loco_baseline/scripts/launch_nohup_segmentation.sh
```

The launcher includes `--check-geometry` and `--validate-segmentation-in-record-build`. This is
required because manifest path existence alone admitted invalid tiny masks such as UTSW BT1258
with only 2 positive segmentation voxels.

Remaining LOCO folds:

```bash
cd /home/vlm/minyoung4
HELDOUT_DATASET=MU-Glioma-Post GPU=3 RUN_ID=seg_unet3d_loco_mu_full_v1 \
TARGET_SHAPE=64,96,96 EPOCHS=50 BATCH_SIZE=1 NUM_WORKERS=4 BASE_CH=24 \
EXP_flag/P2_02_segmentation_loco_baseline/scripts/launch_nohup_segmentation.sh

HELDOUT_DATASET=UPENN-GBM GPU=4 RUN_ID=seg_unet3d_loco_upenn_full_v1 \
TARGET_SHAPE=64,96,96 EPOCHS=50 BATCH_SIZE=1 NUM_WORKERS=4 BASE_CH=24 \
EXP_flag/P2_02_segmentation_loco_baseline/scripts/launch_nohup_segmentation.sh

HELDOUT_DATASET=UTSW GPU=2 RUN_ID=seg_unet3d_loco_utsw_full_v1 \
TARGET_SHAPE=64,96,96 EPOCHS=50 BATCH_SIZE=1 NUM_WORKERS=4 BASE_CH=24 \
EXP_flag/P2_02_segmentation_loco_baseline/scripts/launch_nohup_segmentation.sh
```

Monitor:

```bash
EXP_flag/P2_02_segmentation_loco_baseline/scripts/monitor_nohup_segmentation.sh \
  EXP_flag/P2_02_segmentation_loco_baseline/runs/seg_unet3d_loco_ucsd_full_v1
```

Summarize after folds finish:

```bash
python EXP_flag/P2_02_segmentation_loco_baseline/scripts/summarize_loco_segmentation.py \
  --runs-root EXP_flag/P2_02_segmentation_loco_baseline/runs \
  --out-dir EXP_flag/P2_02_segmentation_loco_baseline/reports/loco_full_v1
```

Current caution:

- GPU 2/3/4 currently have `P3_idh_strong` jobs running.
- P3 emits test-only IDH outputs and is not sufficient for the previously locked ceiling-probe
  protocol.
- Avoid launching P2.02 full folds on the same GPUs until P3 is stopped or finished.
