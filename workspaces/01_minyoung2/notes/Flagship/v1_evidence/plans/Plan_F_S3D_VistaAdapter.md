# Plan F. S3D-VistaAdapter: Prompt-Conditioned Few-Shot Lesion Decoder

## 목적

Wave-C/E/F까지의 Task2 meningioma 실험은 전처리, loss, frozen/low-LR, multimodal fusion만으로는 Dice가 크게 오르지 않는다는 점을 보여줬다. Plan F는 기존 foundation을 버리지 않고, dense segmentation branch만 재설계해 few-shot lesion detection에 맞춘다.

이 계획은 `Brain-JEPA 3D Multimodal`과 별개다.

- Brain-JEPA: foundation pretraining objective 자체를 바꾸는 장기 후보
- S3D-VistaAdapter: 현재 foundation checkpoint 위에 붙이는 supervised segmentation adapter

## 핵심 가설

```text
Meningioma 실패는 dense feature 부재가 아니라 few-shot lesion detector 부재와 thick-slice domain mismatch가 만든 문제다.
따라서 encoder 전체 재학습보다, S3D dense feature를 보존한 작은 prompt-conditioned decoder가 더 효율적이다.
```

## 구조

```text
pretrained ResEnc encoder
    -> multi-scale S3D feature pyramid
    -> prompted mask decoder
         + zero-init residual adapters
         + meningioma lesion query
         + spacing-aware FiLM
         + coarse lesion heatmap gate
    -> binary mask
```

## 실험 순서

| 단계 | 변경점 | 성공 기준 |
|---|---|---|
| F0 | 기존 best 재현: 1mm iso, full-FT, Tversky beta=0.8, EMA | Dice 0.159 부근 재현 |
| F1 | S3D-VistaAdapter, encoder frozen | adapter가 crash 없이 학습되고 overfit 양상 확인 |
| F2 | encoder low-LR 1e-5, adapter 1e-3 | F1보다 Dice/NSD 개선 또는 안정화 |
| F3 | coarse heatmap loss on | false negative 감소, recall 개선 |
| F4 | voxel-query contrast on | foreground/background feature separation 개선 |
| F5 | spacing-aware FiLM ablation | thick-slice subject에서 성능 하락 완화 |
| F6 | feature distillation on | fold/seed variance 감소 |

## 권장 학습 세부값

```text
preprocess: 기존 1mm-iso Yucca 유지
crop: 128 or anisotropic 128,128,48 only as ablation
optimizer: AdamW
encoder_lr: 0 for frozen stage, 1e-5 for main stage
adapter_decoder_lr: 1e-3
weight_decay: 1e-4
scheduler: cosine
amp: bf16
ema: 0.999 trainer-side weight EMA
max epochs: 200
selection: subject-disjoint CV mean Dice + NSD, not training loss
```

Loss 기본값:

```text
Tversky alpha=0.2 beta=0.8
coarse_weight=0.25
contrast_weight=0.01 first, 0.05 second
feature_distill_weight=0.0 first, 0.05~0.1 if overfit/variance appears
```

## 최적화 주의

1. `learned fusion`은 모든 모달이 있을 때만 쓴다. 누락 모달 fallback은 silent confound라 금지한다.
2. contrast query는 bottleneck channel로 projection한 뒤 사용한다. `query_dim`과 feature channel이 같다는 가정은 금지한다.
3. tiny lesion mask는 bottleneck downsampling에서 사라질 수 있으므로 foreground-preserving target resize를 쓴다.
4. coarse head는 final logits와 별도 loss를 가져야 한다. gate 초기값 0이어도 coarse head는 coarse loss로 gradient를 받는다.
5. Task1/3/5 global branch는 재학습하지 않는다. encoder를 low-LR로 열 경우에는 regression check만 수행한다.

## 산출물

- `Flagship/v1_evidence/code/s3d_vista_adapter/`: research prototype
- `Flagship/v1_evidence/code/tests/test_s3d_vista_adapter.py`: static and gradient tests
- `Flagship/v1_evidence/code/smoke_s3d_vista_adapter.py`: one-step optimization smoke
- `Flagship/v1_evidence/code/train_task2_s3d_vista_adapter.py`: Task2 CV runner for decoder-replacement experiments
- 향후 추가: real Task2 result table, ablation figure

## 현재 실행 상태

JEPA 실험은 보류한다. 현재 실행 가능한 decoder-only path는 다음이다.

```bash
# dependency-light runner smoke
.venv-train/bin/python Flagship/v1_evidence/code/train_task2_s3d_vista_adapter.py \
  --synthetic_smoke --epochs 1 --k 2 --n_seed 1 --crop 32 --num_workers 0 --weight_ema 0

# real Task2 F1: frozen encoder, single FLAIR
.venv-train/bin/python Flagship/v1_evidence/code/train_task2_s3d_vista_adapter.py \
  --task task2_meningioma --modalities flair --encoder_mode frozen \
  --target_spacing 1.0 --crop 128 --epochs 200 --k 4 --n_seed 3 \
  --weight_ema 0.999 \
  --out Flagship/v1_evidence/results/task2_s3d_vista_f1_frozen_flair.json

# real Task2 F2: low-LR encoder, learned multimodal fusion
.venv-train/bin/python Flagship/v1_evidence/code/train_task2_s3d_vista_adapter.py \
  --task task2_meningioma --modalities flair,dwi_b1000,t2star \
  --learned_fusion --encoder_mode lowlr \
  --target_spacing 1.0 --crop 128 --epochs 200 --k 4 --n_seed 3 \
  --weight_ema 0.999 --coarse_weight 0.25 --contrast_weight 0.01 \
  --out Flagship/v1_evidence/results/task2_s3d_vista_f2_lowlr_multimodal.json
```

## 논문 novelty 문장

```text
We introduce a prompt-conditioned S3D adapter that converts a self-supervised dense MRI foundation model into a few-shot lesion segmenter by combining zero-initialized residual decoder adapters, a learnable lesion query, spacing-aware FiLM conditioning, and a coarse-to-fine detection path.
```
