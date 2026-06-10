# Harmonization & Scanner/Site-Bias Experiments

_멀티컨소시엄(ADNI/NACC/AIBL/OASIS/A4/AJU/KDRC) 뇌 T1 MRI에서 scanner·site bias를 **측정하고 줄이는** 실험 모음._
_원본(manifest/raw/v2·N4 텐서)은 전부 READ-ONLY. 각 실험은 자기 폴더의 `out/` 에만 기록._
_생성: 2026-06-04. 상위 인덱스: `/home/vlm/minyoungi/docs/INDEX.md`._

## 🧭 START HERE — 용도별 진입점
| 당신이 원하는 것 | 읽을 파일 |
|---|---|
| **"학습을 잘 시키려면 scanner/bias를 어떻게 다루나"** (모델링 결정) | ⭐ **[`SCANNER_BIAS_PLAYBOOK.md`](SCANNER_BIAS_PLAYBOOK.md)** ← 규칙(DO/DON'T)+증거표, 다른 실험/에이전트는 이거 먼저 |
| harmonization 연구를 논문화할 수 있나 (process·metric·feasibility) | [`06_feasibility_and_protocol.md`](06_feasibility_and_protocol.md) + [`PAPER_PLANNING.md`](PAPER_PLANNING.md) |
| 개별 실험의 증거·수치 | 아래 실험 인덱스 `0{1..9}_*/RESULTS.md` |
| **데이터 자체를 이해하려면** (어느 노트북이 어떤 인사이트를) | [`../../../Clinical/INSIGHTS.md`](../../../Clinical/INSIGHTS.md) ← 인사이트→ipynb 지도 |

## 왜 이 폴더가 있나 (문제)

모델이 해부학(AD 신호)이 아니라 **scanner/protocol shortcut**을 먼저 학습한다.
site bias는 데이터의 여러 축에 새겨져 있고, 축마다 제거 가능성이 다르다:

| 축 | 정체 | 제거 레버 |
|---|---|---|
| intensity bias field | 코일 불균일 | **N4** (적용 완료, upstream) |
| intensity scale/histogram | 벤더 재구성 | z-score(적용) / **ComBat**(특징단) |
| voxel/해상도·텍스처 | sub-mm GE vs 1mm Siemens | (이미지 후처리로 거의 불가) |
| **모집단(한국 vs 서구)** | 진짜 뇌 차이 | **제거 대상 아님** — 연구 변수로 보존 |

핵심 제약: **site == 모집단 교란**. 따라서 목표는 "site를 0으로"가 아니라
**"scanner 잡음만 줄이고 생물학(age/sex/dx)은 보존"**.

## 실험 인덱스

| # | 실험 | 무엇을 | 상태 | 결과 |
|---|---|---|---|---|
| 00 | **N4 production** (upstream) | 13,022 전수 N4 bias correction + 방법비교(N4 vs WhiteStripe/Nyúl/blur) | ✅ 완료 | `roi_qc/scripts/n4_reprocess_*.py`, `research_notes/daily/2026-06-02.md` |
| 01 | **scanner_site_bias_check** | 7-컨소시엄 site 식별 가능성을 3축(metadata/appearance/N4전후)으로 정량화 | ✅ | [`01_scanner_site_bias_check/RESULTS.md`](01_scanner_site_bias_check/RESULTS.md) |
| 02 | **combat_fsvol** | fs_vol ROI 부피에 ComBat → site↓ biology보존 (비순환·null 검증) | ✅ | [`02_combat_fsvol/RESULTS.md`](02_combat_fsvol/RESULTS.md) |
| 03 | **n4_variant_comparison** | original/N4/blur/WhiteStripe/Nyúl 중 site appearance를 가장 줄이는 변형 | ✅ | [`03_n4_variant_comparison/RESULTS.md`](03_n4_variant_comparison/RESULTS.md) |
| 04 | **loco_generalization** | leave-one-consortium-out CN/AD AUC — morphometry는 site-robust인가 | ✅ | [`04_loco_generalization/RESULTS.md`](04_loco_generalization/RESULTS.md) |
| 05 | **combat_gam** | ComBat-GAM(age smooth) vs 선형 ComBat — 비선형 age가 harmonization을 개선하는가 | ✅ | [`05_combat_gam/RESULTS.md`](05_combat_gam/RESULTS.md) |
| 06 | **feasibility & protocol** | 문헌(deep-research) + 우리 결과 → harmonization 연구 과정·metric·성공가능성 | ✅ | [`06_feasibility_and_protocol.md`](06_feasibility_and_protocol.md) |
| 07 | **deep_mixstyle** (GPU) | MixStyle domain-randomization 3D CNN(CN/AD, LOCO) — 강한 image harmonization이 morphometry를 이기나/site 줄이나 | ✅ | [`07_deep_mixstyle/RESULTS.md`](07_deep_mixstyle/RESULTS.md) |
| 08 | **cn_mci_harmonization** | 약한 task(CN/MCI)에서 harmonization이 unmask(Saponaro)하나 — weak vs strong 경계 | ✅ | [`08_cn_mci_harmonization/RESULTS.md`](08_cn_mci_harmonization/RESULTS.md) |
| 09 | **modeling_path_comparison** | CN/AD LOCO로 feature 전처리 줄세우기(raw/icv/train-z/ComBat) — 학습 바닥+이미지 방법이 넘을 바 | ✅ | [`09_modeling_path_comparison/RESULTS.md`](09_modeling_path_comparison/RESULTS.md) |

**핵심 결과 한 줄씩:** 01 site는 metadata(0.761)>appearance(0.556)에 박힘 · 03 N4가 image harmonizer 중 최선이나 이득 작고 probe-의존 · 02 ComBat은 feature단 site↓+biology보존 · 05 ComBat-GAM은 선형 대비 이득 無(차이 노이즈 내) → feature-level 천장 재확인 · **04 morphometry CN/AD는 held-cohort로 거의 완벽 일반화(AUC 0.92, site-shift 비용 ~0) → harmonization이 일반화엔 불필요** · **07 강한 image harmonization(MixStyle)도 morphometry를 못 이기고(Δ −0.03~−0.08, 전 seed) site shortcut도 못 줄임(오히려 +0.026) → negative result reviewer-proof화** · **08 약한 task(CN/MCI)에서도 harmonization이 unmask 못 함(within-ADNI flat, pooled는 site-inflation 제거로 하락) → site==population에선 site가 mask 아닌 inflation이라 강·약 task 둘 다 못 살림** · **09 학습 바닥 확정: morphometry+simple norm(icv/train-z)이 LOCO 0.91로 승자, ComBat은 일반화 부스터 신뢰불가(RF −0.014/LogReg +0.022 부호반전) → 이미지 방법이 넘어야 할 바 0.91** · **06 종합 verdict: image-level "정확도 향상" claim은 high-risk, 현실적 기여는 shortcut-audit 프로토콜** (문헌 24/25 confirmed).

> 💡 **모델링 결론(09 기준)**: 이미지 편향을 고치려 하지 말고 morphometry+simple norm으로 pooled 학습하라. 상세 규칙은 [`SCANNER_BIAS_PLAYBOOK.md`](SCANNER_BIAS_PLAYBOOK.md).

> 이미지-레벨 딥 harmonization(adversarial/disentangle)은 별도 워크스페이스
> `/home/vlm/minyoung4/docs/context/full_n4_experiment_redesign_20260603/`(stage8~20)에서 진행됨.
> 요약: 어떤 이미지 표현도 ROI-volume baseline(held-AUC 0.933)을 못 이김, scanner 누수 잔존. (그 폴더 참조)

## 데이터 소스 (전부 read-only)
- manifest: `/home/vlm/data/preprocessed_official/official_manifest_full_n4.parquet` (13,022×101)
  - scanner: `acq_scanner`(4 vendor), `acq_field_strength`, `acq_scanner_source`
  - voxel: `vox_x/y/z/min/max/aniso/mean`, `vox_source`
  - 정량: `fs_vol_*`(26), `fs_MaskVol`; 임상: `clin_*`
- 캐시 image-appearance 특징(2800 균형, 400×7): `roi_qc/reports/img_features.parquet`(원본),
  `img_features_n4prod.parquet`(N4), + n4ws/n4nyul/n4blur 변형

## 실행 / 검증
```bash
# 각 실험은 독립 실행 + 독립 검증(생성/검증 분리)
python roi_qc/experiments/harmonization/01_scanner_site_bias_check/scanner_site_bias_check.py
python roi_qc/experiments/harmonization/01_scanner_site_bias_check/verify_bias_check.py
python roi_qc/experiments/harmonization/02_combat_fsvol/exp_combat_fsvol.py
python roi_qc/experiments/harmonization/02_combat_fsvol/exp_combat_fsvol_v2.py     # 비순환·null control
python roi_qc/experiments/harmonization/02_combat_fsvol/verify_combat.py
```
모든 probe는 **subject_id 기준 GroupShuffleSplit**(누설 차단), 7-way chance=0.143.

## 공통 원칙 (검증 의무)
- 모든 harmonization 평가는 **site-probe↓ + biology-probe보존 + null control** 3종 동시 (Saponaro 2022).
- 생성과 검증을 분리(각 실험에 `verify_*.py`). 다른 분류기/seed로 재현해 아티팩트 배제.
- 잔여 site는 모집단 교란분이므로 chance까지 낮추지 않는다(=생물학 삭제 방지).
- 문헌 근거: `research_notes/daily/2026-06-04.md` (Fortin 2017 / Dinsdale 2021 / Saponaro 2022 / Cohen 2018).
