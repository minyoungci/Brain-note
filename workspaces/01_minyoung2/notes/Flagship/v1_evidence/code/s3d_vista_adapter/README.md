# S3D-VistaAdapter

`S3D-VistaAdapter`는 기존 `ResEnc + S3D-style dense + InfoNCE-global` foundation checkpoint를 버리지 않고, segmentation branch만 few-shot lesion segmentation에 맞게 확장하는 Flagship 연구용 prototype이다.

이 모듈은 기존 `Flagship/v2_jepa/code/brain_jepa/`와 다르다.

| 모듈 | 목적 | 학습 성격 |
|---|---|---|
| `brain_jepa/` | Brain-JEPA 3D multimodal SSL foundation v2 후보 | 새 self-supervised pretraining |
| `s3d_vista_adapter/` | 현재 학습된 foundation 위의 prompt-conditioned segmentation adapter | supervised few-shot decoder/adapter training |

## 설계 의도

Task2 meningioma 실험에서 확인된 실패 원인을 decoder 설계에 직접 반영한다.

- n=23 few-shot: 큰 decoder 대신 zero-init residual adapter 사용
- 검출 실패: coarse lesion heatmap path 추가
- thick-slice FLAIR: original spacing token을 decoder FiLM으로 주입
- VISTA3D 아이디어: learnable lesion query를 사용하되, 대규모 prompt model은 만들지 않음
- S3D prior 유지: ResEnc/S3D feature pyramid와 skip decoder 구조를 유지
- global branch 보호: Task1/3/5용 global head는 건드리지 않음

## 구성

```text
S3DVistaAdapter
├── ResEncFeaturePyramid        # pretrained ResEnc stem/encoder load target
├── FeatureFusion               # mean or mean-initialized learned multimodal fusion
├── QuerySpacingConditioner     # lesion query + spacing token -> stage-wise FiLM
├── query_to_feature            # query_dim -> bottleneck channel projection for contrast
└── PromptedMaskDecoder
    ├── ConvTranspose3d U-Net up blocks
    ├── zero-init residual adapters
    ├── coarse lesion head
    └── final mask head
```

## 권장 full 설정

```python
from Flagship.v1_evidence.code.s3d_vista_adapter import S3DVistaConfig

cfg = S3DVistaConfig(
    modalities=("flair",),
    chans=(32, 64, 128, 256, 320),
    blocks=(1, 2, 2, 2, 2),
    adapter_bottleneck=64,
    query_dim=128,
    spacing_dim=64,
    fusion="mean",
    use_lesion_query=True,
    use_spacing_film=True,
    use_coarse_gate=True,
)
```

## 권장 학습 프로토콜

기준선은 기존 best `1mm-iso + full-FT + Tversky beta=0.8 + EMA`이다. adapter는 아래 순서로 ablation한다.

| 단계 | 설정 | 목적 |
|---|---|---|
| A0 | 기존 best 재현 | 비교 기준 고정 |
| A1 | encoder frozen, adapter/decoder only | adapter 단독 효과와 과적합 확인 |
| A2 | encoder low-LR(1e-5), adapter/decoder 1e-3 | Task2에서 frozen 실패를 반영한 현실 설정 |
| A3 | + coarse heatmap loss | 검출 실패 완화 |
| A4 | + lesion query contrast | foreground/background feature 분리 |
| A5 | + spacing FiLM | thick-slice domain 정보를 decoder에 제공 |
| A6 | + S3D feature distillation | small-n overfit 억제 |

권장 loss:

```text
L = L_Tversky(beta=0.8)
  + 0.25 * L_coarse_focal
  + 0.01~0.05 * L_voxel_query_contrast
  + 0.0~0.1 * L_feature_distill
```

권장 optimizer:

```text
AdamW
encoder_lr = 1e-5  # or 0 for frozen stage
adapter_decoder_lr = 1e-3
weight_decay = 1e-4
cosine schedule
EMA = 0.999 for evaluation weights, implemented in the trainer side
```

검증은 Task2 특성상 반드시 `4-fold subject-disjoint CV x 3 seeds`와 동일 protocol scratch/adapter 대조로 진행한다.

## 체크포인트 로딩

`load_resenc_encoder_from_ssl()`은 SSL checkpoint에서 `backbone.stem.*`, `backbone.enc.*`만 로드한다. decoder, query, coarse head, adapter는 새 supervised stage이므로 의도적으로 로드하지 않는다.

strict mode는 encoder key 누락/shape mismatch를 실패로 처리해 partial-load false success를 막는다.

## 테스트

```bash
python -m unittest Flagship.v1_evidence.code.tests.test_s3d_vista_adapter
python Flagship/v1_evidence/code/smoke_s3d_vista_adapter.py
```

테스트가 확인하는 항목:

- forward shape and spacing conditioning
- zero-init residual adapter identity
- loss finite/backward
- tiny lesion mask preservation for contrast
- query_dim != feature_dim projection
- SSL ResEnc encoder weight mapping
- learned fusion missing-modality fail-fast
- optimizer param group separation
