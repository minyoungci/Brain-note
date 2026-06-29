# v1_evidence: Current Foundation Evidence + Decoder Replacement

`v1_evidence`는 현재 이미 학습된 foundation model을 중심으로 한다.

```text
Foundation v1 = ResEnc + S3D-style dense branch + InfoNCE-global
checkpoint = experiments/phase_b/resenc_s3d_wg0.5/latest.pt
```

## Scope

- 기존 foundation architecture novelty 증거 정리
- S3D anti-leakage dense branch 검증
- InfoNCE-global collapse 방지 검증
- dense/global objective balance 분석
- 현재 foundation의 segmentation branch/decoder 교체 실험

## Decoder Replacement Track

Task2 meningioma 실험에서 나온 결론:

- 일반 fine-tuning recipe만으로는 Dice가 크게 오르지 않음
- few-shot n=23, thick-slice FLAIR, lesion detection failure가 병목
- foundation 전체 재학습보다 decoder/head 재설계가 다음 레버

그래서 `S3D-VistaAdapter`를 v1 evidence 하위에 둔다.

```text
v1_evidence/code/s3d_vista_adapter/
```

이 adapter는 다음을 수행한다.

- pretrained ResEnc encoder reuse
- S3D dense feature pyramid reuse
- VISTA3D-style learnable lesion query
- spacing-aware FiLM
- coarse lesion detector
- zero-init residual decoder adapter
- Tversky + coarse focal + voxel-query contrast + feature distill

## Important Boundary

`v1_evidence`는 Brain-JEPA를 구현하지 않는다. JEPA는 `Flagship/v2_jepa/`에서만 다룬다.
현재 활성 실험은 이 폴더의 decoder replacement만이다. `v2_jepa`는 명시적으로 재개하기 전까지 보류한다.

## Key Files

```text
plans/Plan_F_S3D_VistaAdapter.md
code/s3d_vista_adapter/README.md
code/train_task2_s3d_vista_adapter.py
code/tests/test_s3d_vista_adapter.py
code_review/Review_Pass_5_S3D_VistaAdapter.md
code_review/Review_Pass_6_Task2_S3DVistaRunner.md
experiments/Foundation_Novelty_Matrix.md
figures/Figure_Plan.md
tables/Table_Plan.md
```

## Tests

```bash
.venv-train/bin/python -m unittest Flagship.v1_evidence.code.tests.test_s3d_vista_adapter
.venv-train/bin/python Flagship/v1_evidence/code/smoke_s3d_vista_adapter.py
.venv-train/bin/python Flagship/v1_evidence/code/train_task2_s3d_vista_adapter.py --synthetic_smoke --epochs 1 --k 2 --n_seed 1 --crop 32 --num_workers 0 --weight_ema 0
```

## Real Task2 Runner

`code/train_task2_s3d_vista_adapter.py` is the active runner for decoder-replacement experiments. It compares pretrained encoder reuse against scratch under the same adapter/CV protocol and writes JSON results.

Initial real-data command:

```bash
.venv-train/bin/python Flagship/v1_evidence/code/train_task2_s3d_vista_adapter.py \
  --task task2_meningioma \
  --modalities flair \
  --encoder_mode frozen \
  --target_spacing 1.0 \
  --crop 128 \
  --epochs 200 \
  --k 4 \
  --n_seed 3 \
  --weight_ema 0.999 \
  --out Flagship/v1_evidence/results/task2_s3d_vista_f1_frozen_flair.json
```

Then run the main candidate:

```bash
.venv-train/bin/python Flagship/v1_evidence/code/train_task2_s3d_vista_adapter.py \
  --task task2_meningioma \
  --modalities flair,dwi_b1000,t2star \
  --learned_fusion \
  --encoder_mode lowlr \
  --target_spacing 1.0 \
  --crop 128 \
  --epochs 200 \
  --k 4 \
  --n_seed 3 \
  --weight_ema 0.999 \
  --coarse_weight 0.25 \
  --contrast_weight 0.01 \
  --out Flagship/v1_evidence/results/task2_s3d_vista_f2_lowlr_multimodal.json
```
