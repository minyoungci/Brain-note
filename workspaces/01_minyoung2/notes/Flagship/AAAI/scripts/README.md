# AAAI Ablation Scripts

This folder contains execution utilities for the AAAI ablation package.

## 1. Build registry from existing results

```bash
python Flagship/AAAI/scripts/build_ablation_registry.py
```

Output:

```text
Flagship/AAAI/results/ablation_registry.csv
```

## 2. Run anti-leakage diagnostic

Fast CPU smoke:

```bash
python Flagship/AAAI/scripts/leakage_probe.py --device cpu --crop 32 --mask-block 8
```

Paper run with default checkpoints:

```bash
python Flagship/AAAI/scripts/leakage_probe.py \
  --device cuda \
  --crop 96 \
  --mask-block 16 \
  --out Flagship/AAAI/results/leakage_probe.json
```

## 3. Aggregate collapse diagnostics

```bash
python Flagship/AAAI/scripts/collapse_diagnostics.py --window 1000
```

Outputs:

```text
Flagship/AAAI/results/collapse_diagnostics.csv
Flagship/AAAI/results/collapse_diagnostics.json
```

## 4. Matched seg_v3 run with JSON capture

Example Task4 dense-transfer run:

```bash
python Flagship/AAAI/scripts/run_seg_v3_json.py \
  --variant s3d_balanced_wg0.5_task4_lowlr \
  --ckpt experiments/phase_b/resenc_s3d_wg0.5/latest.pt \
  --out-json Flagship/AAAI/results/seg_v3_task4_wg0.5.json \
  -- \
  --task task4_trigeminal \
  --loss dicecldice \
  --encoder_mode lowlr \
  --weight_ema 0.999 \
  --epochs 200 \
  --n_seed 3
```

Then include it in the registry:

```bash
python Flagship/AAAI/scripts/build_ablation_registry.py \
  --seg-v3-json Flagship/AAAI/results/seg_v3_task4_wg0.5.json
```
