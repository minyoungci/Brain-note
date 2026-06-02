# minyoung2 — findings

_갱신: 2026-06-02 (커밋 bb9b29f). 표기: ✅확정 / ❌반증 / 🟡잠정. 추측은 [VERIFY]._

## 실험 라인 흐름

```
라인 A (discrete tokenizer / SSL)  ──❌ NO-GO── (token이 형태엔 민감하나 nuisance 너머 disease 증분 없음)
        │
라인 B (ROI 2.5D supervised amyloid, OASIS Centiloid) ──❌ NO-GO── (3개 핵심 가설 falsified)
        │  병목 진단: OASIS-only T1 + 약한 molecular amyloid 신호 + 외부 supervision 부재
        ▼
EXP01 (shortcut-controlled incremental-value, CDR multi-cohort, LOCO) ◀── 현재 active
        │  control battery → 표준 레시피 → seed/안정화 method → regional baseline → 3D CNN
```

### 라인 A — discrete tokenizer (5/25~5/26) ❌
FSQ-VAE collapse 반복 → Simplex VAE는 recon gate 통과(val SSIM 0.631)했으나 ROI residual disease 신호 음성
(multicohort 291 residual R² mean −0.099, perm p≈0.363). 849-case 확장은 10/50 epoch에서 중단, 동일 결론.
출처: `docs/context/DECISION_LOG.md`.

### 라인 B — ROI 2.5D supervised amyloid (5/30~5/31) ❌
| 실험 | 질문 | 결과 | 판정 |
|---|---|---|---|
| AMY-ALIGN-005 | ROI-guided T1+mask가 covariate/ROI-count baseline 이김? | image AUPRC 0.504 vs covariate AUROC 0.674 — 증분 음수 | ❌ NO-GO |
| WB-001 | whole-brain 2.5D가 ROI cropping 손실 복구? | WB AUPRC 0.407 < ROI-guided 0.504 | ❌ 가설 기각 |
| ROI-PRETRAIN-003 | QC-pass 2-stage pretrain transfer? | seed0 AUROC 0.575 < warm-start 0.647 | ❌ NO-GO |

출처: `docs/context/DECISION_LOG.md`, 각 ledger.

---

## EXP01 핵심 수치 (IMG-001~022)

### control battery & 표준 레시피
| ID | 핵심 | 수치 | 판정 | 출처 |
|---|---|---|---|---|
| NUISANCE-001 | nuisance metadata LOCO transport? | consortium/provenance AUROC≈0.50; 뇌용적만 약신호 0.524–0.563 → **bar≈0.56** | ✅ shortcut은 transport 안 됨 | `...exp01-nuisance-001-loco-baseline.md` |
| IMG-001 | ADNI 첫 image arm | full 0.544 / mask 0.540 / shuffled 0.495 — 셋 다 bar 미달, underfitting | 🟡 보류 | `...img-001-adni-control-battery.md` |
| IMG-002/003/004 | 백본 trap + 양성 전이 | ConvNeXt-ImageNet 학습 사망(val 0.50); **resnet18 image-full이 5/6 fold에서 bar를 CI 비겹침 초과** | ✅ 첫 양성 | `...img-003-004-resnet18-positive-transport.md` |
| IMG-005/006/007 | 누수·seed·intensity aug | shuffled 모두 ~0.49(누수無); seed 불안정(ADNI s2=0.522, OASIS 0.511↔0.810); intensity aug=양날의 검 | ✅/🟡 | `...img-005-006...`, `...img-007-intensity-augmentation.md` |
| IMG-008~012 | grad-accum8 표준 레시피 | resnet18+ga8+lr5e-4+12ep+best=val_auprc 확정; 3-seed mean 6/6 fold가 bar 초과 | ✅ | `EXP01_OVERVIEW.md` F3 |

**F3 — image-full 3-seed mean±sd vs bar (✅ 6/6 fold 초과):**
| held-out | imgfull ga8 | mask-only | shuffled | bar | Δbar |
|---|---|---|---|---|---|
| KDRC | 0.820±0.007 | 0.671 | 0.49 | 0.533 | +0.287 |
| OASIS | 0.797±0.003 | 0.678 | 0.51 | 0.548 | +0.249 |
| AIBL | 0.698±0.070 | 0.646 | 0.48 | 0.563 | +0.136 |
| ADNI | 0.683±0.006 | 0.610 | 0.49 | 0.559 | +0.123 |
| NACC | 0.648±0.094 | 0.633 | 0.51 | 0.561 | +0.088 |
| A4 | 0.611±0.006 | 0.613 | — | 0.524 | +0.087 |

출처: `reports/EXP01_OVERVIEW.md` (커밋 7fcd9cc).

### 공식 H1 — incremental over full nuisance battery (✅ 6/6, 단 이후 무력화)
| held-out | nuisance | nuis+image | ΔAUROC [CI95] |
|---|---|---|---|
| KDRC | 0.533 | 0.810 | +0.277 [+0.230, +0.323] |
| OASIS | 0.551 | 0.792 | +0.242 [+0.194, +0.289] |
| NACC | 0.561 | 0.717 | +0.156 [+0.119, +0.195] |
| ADNI | 0.558 | 0.685 | +0.127 [+0.090, +0.163] |
| A4 | 0.524 | 0.619 | +0.095 [+0.037, +0.149] |
| AIBL | 0.563 | 0.636 | +0.073 [+0.014, +0.130] |

✅ 6/6 CI 하한>0 → 사전등록 H1 채택. **그러나 baseline이 전뇌 용적 하나뿐이라 F9에서 무력화됨.**
출처: `reports/EXP01_OVERVIEW.md` F3b, `scripts/exp01_incremental_value.py`.

### 안정화 method 라인 (전부 falsified 또는 cohort-의존)
| ID | 시도 | 결과 | 판정 |
|---|---|---|---|
| IMG-011 | warmup으로 seed 붕괴 해결 | 효과 없음 | ❌ |
| IMG-013 | brain-MRI 사전학습 안정화 | peak↓ stability↑로 보였으나 IMG-014에서 귀인 정정 | 🟡→❌ |
| IMG-014 | backbone×pretrain 2×2 | 안정성=아키텍처(ConvNeXt 안정·저peak / resnet18 고peak·붕괴). pretraining 아님 | ✅ (귀인) |
| IMG-015 | OOD-aware checkpoint selection | 음성 | ❌ |
| IMG-016/017 | group-DRO 안정화 (3-seed) | NACC/AIBL 붕괴 제거하는 듯 (양성으로 보고) | 🟡 |
| **IMG-019** | ERM vs gDRO **5-seed** | **NACC는 안정화(sd0.102→0.010), AIBL은 gDRO도 새 붕괴(0.444), sd 더 큼** → F8 하향 | ❌ 보편성 반증 |

출처: `reports/EXP01_OVERVIEW.md` F7/F8, `...img-019-erm-vs-gdro-5seed-qualifies-f8.md`.

### 🔴 중대 negative — regional-volume baseline (F9, 2026-06-01)
5-ROI 위축(hippocampus/amygdala/thalamus/lat-ventricle/parahippocampal) + 전뇌용적 → LogisticRegression, 동일 covered subset paired bootstrap:
| fold | n | regional-vol | image-full | Δ(img−reg) [CI95] | 판정 |
|---|---|---|---|---|---|
| ADNI | 1441 | 0.692 | 0.693 | [−0.026, +0.025] | 무승부 |
| NACC | 1334 | 0.707 | 0.713 | [−0.019, +0.031] | 무승부 |
| OASIS | 710 | 0.786 | 0.799 | [−0.022, +0.049] | 무승부 |
| KDRC | 885 | 0.836 | 0.816 | [−0.044, +0.005] | 무승부(regional↑) |
| AIBL | 596 | 0.769 | 0.610 | [−0.221, −0.101] | regional 우세(image 붕괴seed) |

❌ **5/5 evaluable fold에서 deep 2.5D MIL이 regional-volume logistic을 유의하게 못 이김.** (A4는 ROI ID 미매칭으로 skip.)
이전 "image>nuisance bar"는 bar가 전뇌 용적 하나였던 탓. Bron 2021 "deep≈conventional" 일치.
출처: `...2026-06-01-exp01-regional-volume-baseline-critical.md`.

### 🟡 deep 우위 = 작지만 존재 (F10, 2026-06-01)
| probe | 결과 | 결론 |
|---|---|---|
| incremental over regional, per-fold | 5/5 ΔAUROC CI 0 포함 (+0.01~0.014) | per-fold 유의 X (underpowered) |
| CN(0) vs MCI(0.5) 경계, per-fold | 5/5 CI 0 포함 | 경계서도 유의 X |
| **incremental over regional, POOLED (n=4966)** | **+0.018 [+0.011, +0.026]** | 🟡 유의 (검정력↑) |

⇒ transportable 신호의 거의 전부 = 5-ROI regional 위축, deep은 그 위 얇은 +0.018 잔차만.
[VERIFY] pooled bootstrap은 fold별 다른 cohort/combiner를 concat → exchangeability 과대가정. random-effects meta가 정석(미수행).
출처: `...2026-06-01-exp01-deep-advantage-probes.md`.

### 🟡 strong-deep 3D CNN (IMG-020/021/022) — 결과 없음
full-volume(T1+mask) 3D resnet(MONAI, bf16), LOCO, smoke만 통과. full-res가 >28분/epoch → ds96 옵션·full-res 재투입.
[VERIFY] 산출 디렉토리(`results/.../runs/EXP01-IMG-022-*`)가 비어 있고 로그는 startup만 — **6-fold LOCO 결과 미생성**.
반복 집단사망 원인 = nohup/setsid 미분리로 SIGHUP 사망(코드는 정상). setsid 분리 + RAM 90% 캡으로 막 재실행.
출처: 커밋 f1b65d1/bb9b29f, `docs/EXP01_REVIEWER2_CRITIQUE.md`, run 디렉토리 직접 확인.
