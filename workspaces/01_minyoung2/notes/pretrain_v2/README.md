# pretrain_v2 — Foundation 모델 v2 (다른 학습 패러다임)

> v1(official, 확정)은 `pretrain/`·`experiments/phase_b/resenc_s3d_wg0.5`에 **보존**. 여기는 *대안 패러다임* 탐색.
> v1을 건드리지 않는다(코드·ckpt 별도). 공용 자산만 재사용(아래).

## v1 vs v2
| | v1 (official, 확정) | v2 (탐색) |
|---|---|---|
| 위치 | `pretrain/`, ckpt `experiments/phase_b/resenc_s3d_wg0.5/latest.pt` | `pretrain_v2/`, 결과 `experiments_v2/` |
| dense 목적함수 | **S3D MAE**(pixel recon, submanifold masked-conv) | **JEPA**(masked *latent* prediction — recon 없음) |
| global | InfoNCE (EMA-teacher 대조) | (JEPA의 target-encoder가 흡수 가능, 또는 병행) |
| 백본 | ResEnc-L CNN U-Net | 후보(ResEnc 재사용 or ViT-3D) — 실험서 결정 |

## v2 = JEPA 패러다임 (1차 방향)
**I-JEPA(Assran et al., CVPR 2023)** 식: 픽셀 복원 대신 *표현 공간*서 예측.
- **context encoder** f_θ: 보이는 패치 → context 표현
- **target encoder** f_θ̄ (EMA, gradient 0): 전체(또는 타깃블록) → target latent
- **predictor** g_φ: context + 위치쿼리 → target latent 예측 → **L = ‖pred − sg(target)‖²** (stop-grad)
- MAE(pixel recon)의 약점(저수준 텍스처 편향)을 피하고 *의미적* 표현 학습 의도.

**왜 v2로 JEPA인가 (가설)**: v1 검증 결과 = foundation 가치가 global/few-shot엔 강하나 dense seg는 scratch 동급([[fomo26-downstream-results]]). JEPA의 latent-prediction이 dense-판별 표현을 더 줄지 *가설* 검증. (단 [VERIFY] — 3D 의료 JEPA seg 우월 선례 약함, 실험으로만.)

## 공용 재사용 (v1과 공유, 복사 금지)
- **코퍼스 로더**: `pretrain/data.py` (226,793 / 221,376 filelist, 동일 코퍼스).
- **모니터**: `pretrain/monitor.py` (collapse/STOP).
- **전처리**: 동일 yucca 4-step 산출물 `/home/vlm/data/FOMO300K_preprocessed`.
- **eval**: downstream 파이프라인 `downstream/`(core·eval_*·seg_v3) 그대로 — v2 ckpt도 `load_backbone(ckpt=...)`로 평가.

## 구조
```
pretrain_v2/
  README.md          ← 이 파일
  models/            ← v2 모델(JEPA: context/target encoder + predictor)
  configs/           ← v2 학습 config(.toml/인자)
  train_jepa.py      ← (예정) JEPA 학습 루프
experiments_v2/
  jepa/              ← v2 실험 결과(ckpt·로그·SUMMARY)
docs/v2/             ← v2 설계 문서
```

## 다음 (v1 작업 완료 후 착수)
1. JEPA 설계 문서 `docs/v2/jepa_design.md` (gradient 흐름·구조 확정).
2. `pretrain_v2/models/` JEPA 모듈 (백본 재사용 여부 결정).
3. `train_jepa.py` (data.py·monitor 재사용) → smoke → 본학습.
4. v1 downstream 파이프라인으로 **동일 잣대 평가**(v1 vs v2 비교).
