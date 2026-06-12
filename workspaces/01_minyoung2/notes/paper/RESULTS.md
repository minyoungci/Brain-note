# ROI-token SSL for Structural Brain MRI — 최종 결과 (논문용)

> 모든 수치 = code-auditor 독립 감사 통과 + **inductive(subject-disjoint)** 평가 + multi-seed CV(±std). 갱신: 2026-06-11.
> 탐색/중간 산출물 제외, **최종 결과만** 수록.

## 0. 기여 (Contribution)
**95개 FreeSurfer DKT+aseg ROI를 *토큰*으로 하는 region-token transformer를 3D 구조 T1에 masked-region modeling SSL로 pretrain** — 구조(structural) MRI 최초의 ROI-as-unit SSL(fMRI엔 존재, 구조 T1엔 미점유). downstream = CDR-SB 인지 severity(위축이 정당한 인과).
- **핵심 주장**: region-tokenization이 SSL 표현의 전이를 결정한다 (whole-volume·generic SSL 대비 인과적으로 분리).

## 1. Task feasibility (왜 CDR-SB인가)
amyloid는 atrophy-staging confound(CN-stratified서 imaging<covariate)로 폐기. CDR-SB는 위축이 정당한 인과 → imaging이 covariate(age+sex)를 압도:
| cohort | covariate corr | ROI imaging corr |
|---|--:|--:|
| AJU | 0.045 | 0.433 |
| KDRC | 0.005 | 0.394 |
| ADNI | 0.194 | 0.482 |

## 2. Main result — CDR-SB (inductive, frozen-probe, 5-seed)
| 표현 | AJU | KDRC | ADNI | 추론 |
|---|--:|--:|--:|---|
| **ROI-token SSL (ours)** | **0.471±0.018** | **0.378±0.012** | **0.492±0.001** | T1+parc |
| whole-volume SSL (ablation) | 0.390±0.006 | 0.291±0.008 | 0.431±0.003 | T1 |
| Models-Genesis (generic SSL) | 0.417±0.007 | 0.359±0.014 | 0.440±0.008 | T1 |
| hand-crafted ROI | 0.433 | 0.394 | 0.482 | T1+parc(FreeSurfer) |
| covariate(age+sex) | 0.045 | 0.005 | 0.194 | — |

**판정(정직):**
- **ROI-token >> 학습 SSL baseline**(whole +0.06~0.09, Models-Genesis +0.02~0.05, 유의) → region-token이 이득 원인. 두 whole-vol SSL(anatomy/generic)은 서로 비슷 → tokenization이 차이.
- **vs hand-crafted = comparable**(AJU +0.038, ADNI tie, KDRC −0.016) — 압도 아님.

## 3. Ablation — region-token이 왜 작동하나
### 3.1 ROI-token vs whole-volume (같은 CNN·SSL·데이터, pooling만 차이)
ROI-token > whole 전 cohort +0.06~0.09 (§2). → tokenization이 핵심.
### 3.2 Positional (해부 정체성) — 동일 5-seed, 3180
| | with-pos | no-pos | drop |
|---|--:|--:|--:|
| AJU/KDRC/ADNI | 0.494/0.422/0.532 | 0.423/0.336/0.434 | **−0.07~−0.10 (유의)** |
+ SSL recon L1 0.467(with)→0.705(no-pos). → ROI 해부 *정체성*이 이득 원인(단순 pooling 아님).

## 4. 보조 task (multi-task 전이, inductive)
| task | ROI-token | whole | hand-crafted |
|---|--:|--:|--:|
| brain-age corr (ADNI) | 0.639 | 0.587 | 0.666 |
| brain-age corr (OASIS) | **0.707** | 0.614 | 0.653 |
| impaired-vs-CN AUROC (ADNI) | 0.665 | 0.664 | 0.661 |
→ ablation(ROI-token>whole) age서 유지. hand-crafted와는 comparable.

## 5. 정직한 한계 (논문 명시)
1. **vs hand-crafted comparable**(압도 아님) — inductive 보정 후 약화(transductive 착시였음).
2. **KDRC 약함**(n=534, hand-crafted 대비 marginal).
3. **frozen linear-probe**가 fine-tune보다 강함(소량 downstream).
4. **실제 DAMT Swin 미재현**(matched-backbone DAMT-style로 대체 — 인과엔 더 엄밀).
5. SSL은 subject-disjoint 5956로 pretrain(inductive).

## 6. Must-cite / baseline
DAMT(ACCV2024) · Swin-UNETR SSL(CVPR2022) · Models Genesis(MedIA2021) · BrainMass(fMRI ROI-token) · Reith(AJNR2025, T1 amyloid 천장 0.62).

## 7. 재현 (코드)
- 데이터: `experiments/data_roi.py`, `cache_img.py`, `cache_img13k.py`
- 모델/SSL: `experiments/roitoken.py` (`--exclude_ds` inductive, `--no_pos` ablation)
- baseline: `experiments/baselines.py` (Models Genesis)
- feasibility/aux: `experiments/r1_feasibility.py`, `r1b_task.py`, `aux_tasks.py`
- 탐색 phase 전체: git tag `exploratory-v1`
