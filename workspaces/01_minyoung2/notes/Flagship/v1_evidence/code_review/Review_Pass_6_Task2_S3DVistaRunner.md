# Review Pass 6. Task2 S3D-VistaAdapter Runner

Date: 2026-06-29
Scope: `Flagship/v1_evidence/code/train_task2_s3d_vista_adapter.py`

## Verdict

Pass for experiment-launch readiness. The runner is suitable for Task2 decoder-replacement experiments, but no real Task2 performance has been claimed yet.

## What It Tests

- current `wg0.5` foundation encoder loaded into `S3DVistaAdapter`
- pretrained vs scratch under the same adapter protocol
- frozen encoder and low-LR encoder modes
- single-modality FLAIR and multimodal `flair,dwi_b1000,t2star`
- learned fusion
- Tversky + coarse focal + voxel-query contrast
- sliding-window validation with Dice and NSD
- JSON result output

## Critical Findings Fixed

### C1. Synthetic smoke was blocked by Yucca import

Problem: top-level import of `downstream/core.py` required `yucca`, so even dependency-light smoke validation failed outside the downstream training environment.

Fix: downstream/Yucca imports are now delayed until real Task2 data loading. `--synthetic_smoke` validates model/training/eval logic without Yucca.

### C2. CPU path accidentally disabled gradients

Problem: the CPU branch used `torch.no_grad()` as the fallback context where CUDA autocast was unavailable.

Fix: replaced the CPU fallback with `nullcontext()`.

### C3. Sliding-window spacing batch could mismatch window batch

Problem: MONAI sliding-window may batch several windows together. A single subject spacing tensor shaped `(1,3)` would not match the window batch size.

Fix: added `_expand_spacing()` and applied it in training and sliding-window inference.

## Commands Run

```bash
python -m py_compile Flagship/v1_evidence/code/train_task2_s3d_vista_adapter.py
python -m unittest Flagship.v1_evidence.code.tests.test_s3d_vista_adapter
python Flagship/v1_evidence/code/train_task2_s3d_vista_adapter.py --synthetic_smoke --epochs 1 --k 2 --n_seed 1 --crop 32 --num_workers 0 --device cuda --weight_ema 0 --out Flagship/v1_evidence/results/smoke_task2_s3d_vista_adapter.json
python Flagship/v1_evidence/code/train_task2_s3d_vista_adapter.py --synthetic_smoke --modalities flair,dwi_b1000,t2star --learned_fusion --encoder_mode lowlr --epochs 1 --k 2 --n_seed 1 --crop 32 --num_workers 0 --device cuda --weight_ema 0 --out Flagship/v1_evidence/results/smoke_task2_s3d_vista_adapter_multimodal.json
.venv-train/bin/python -c "import torch, yucca; print(torch.__version__, torch.cuda.is_available())"
.venv-train/bin/python Flagship/v1_evidence/code/train_task2_s3d_vista_adapter.py --synthetic_smoke --epochs 1 --k 2 --n_seed 1 --crop 32 --num_workers 0 --device cuda --weight_ema 0 --out Flagship/v1_evidence/results/smoke_task2_s3d_vista_adapter_venv_train.json
```

## Residual Risks Before Real Claims

- Real Task2 loading still requires the downstream/Yucca environment.
- Synthetic smoke validates code flow only; its Dice/NSD numbers are meaningless.
- Real runs need comparison against the existing best `1mm-iso full-FT Tversky beta=0.8 + EMA` result.
- Threshold/postprocess sweep is not included yet.
- `distill_weight > 0` is implemented but not yet smoke-tested in real data.
