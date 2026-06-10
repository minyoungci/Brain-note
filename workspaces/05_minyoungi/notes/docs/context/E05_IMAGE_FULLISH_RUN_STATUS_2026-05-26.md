# E05 Image Full-ish Run Status - 2026-05-26

## Current status
- Status: completed successfully (`exit_code=0`).
- Hermes session id: `proc_c2546f5cd97e`
- PID: `642145`
- Planned GPU / CUDA_VISIBLE_DEVICES: physical GPU 1 via `CUDA_VISIBLE_DEVICES=1`.
- Run dir: `/home/vlm/minyoungi/manifests/v2_integrated/audits/pet_amyloid_e05_decision_gate_v0/image_fullish_debug_training_20260526_0934_gpu1_seed20260526`
- Script: `/home/vlm/minyoungi/manifests/v2_integrated/audits/pet_amyloid_e05_decision_gate_v0/e05_image_fullish_debug_training_image_fullish_debug_training_20260526_0934_gpu1_seed20260526.py`
- Command:

```bash
CUDA_VISIBLE_DEVICES=1 python manifests/v2_integrated/audits/pet_amyloid_e05_decision_gate_v0/e05_image_fullish_debug_training_image_fullish_debug_training_20260526_0934_gpu1_seed20260526.py \
  --epochs 5 --train-n 3032 --val-n 966 --batch-size 16 --num-workers 8 --downsample 64 --lr 1e-3
```

## Gate evidence before launch
- `pwd`: `/home/vlm/minyoungi`
- branch: `main`
- GPU0 has an existing unrelated Python job: PID 624521, `vlm_gate_03_teacher_logit_latent_distillation_v0.py`, physical GPU0.
- GPU5 has two existing Python jobs.
- GPU1 looked free in `nvidia-smi` preflight.
- Previous interrupted E05 image run had `metrics.jsonl` size 0 and must not be interpreted as completed.

## Next action when complete
- Inspect `summary.json`, `metrics.jsonl`, `val_predictions_final.csv`, and `REPORT.md`.
- Compare image-only final/best validation metrics against E05 CPU baselines:
  - `allowed_age_sex`: val MAE 32.7942, val AUC 0.6459
  - `proxy_age_sex_diagnosis`: val MAE 30.9950, val AUC 0.7020
- If image-only cannot beat age+sex and remains collapsed, recommend shifting away from direct T1w→PET amyloid headline.


## Completion triage
- Completed UTC: `2026-05-26T09:38:51.938456+00:00` from run summary.
- Hard failures recorded by script: `[]`.
- Best image-only val MAE: `33.9242`.
- Final image-only val MAE: `34.3081`.
- Best image-only val AUC CL>=20: `0.4850`.
- Final image-only val AUC CL>=20: `0.4947`.
- Balanced accuracy stayed `0.5`; predicted positive rate @0.5 stayed `0.0`.
- Decision report: `/home/vlm/minyoungi/manifests/v2_integrated/audits/pet_amyloid_e05_decision_gate_v0/E05_IMAGE_VS_BASELINE_DECISION_REPORT.md`.
- Decision: shift headline away from direct T1w→PET amyloid prediction; keep PET as probing/validation unless fusion/residual later beats clinical baselines.
