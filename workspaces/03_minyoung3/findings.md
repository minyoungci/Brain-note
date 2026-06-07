# minyoung3 findings — F04 패밀리

> **목적:** F04 패밀리의 검증된 결과와 미검증 항목 분리 기록  ·  **출처:** `/home/vlm/minyoung3` reports·results summary.json·manuscript_assets(2026-06-07)  ·  **갱신:** 2026-06-07

표기: ✅확정 / 🟡잠정 / ❌반증 / `[VERIFY]`미검증

## F04 패밀리 구조 (2026-06-07)

| 라인 | 정의 | 상태 |
|---|---|---|
| ~~2.5D MAE SSL~~ | ~~axial slab masked center-slice SSL~~ | ❌ **완전 삭제(폐기)** — 헤드라인 아님 |
| ROI-evidence encoder | T1w 이미지 → 42개 FreeSurfer ROI evidence 회귀 | ✅ full run 완료 (canonical 데이터셋 원천) |
| normative calibration | train-only CN/안정 기준군으로 ROI → 보정 percentile·z-score | ✅ `…_n4_normative_calibration_v6_global_cdr_primary` |
| **3D ROI-grounded VQA (three-zone)** | image-only 3D 입력 → far-neg/uncertain/far-pos 해부 추론 | ✅ **현 헤드라인.** 3D > 고정 2.5D 확립 |
| **raw-visible ROI-VQA** | 원본 영상에서 보이는 해부 기준 라벨 | ✅ positive image track, 전 seed 3D > 2.5D |

## three-zone 3D-vs-2.5D 결과 (✅ 검증, 2026-06-07)

`results/f04_roi_evidence_encoder/20260607_092509_v6_latest_threezone_manuscript_assets/core_threezone_results_table.md`:

| 평가 | 고정 2.5D (zone-bacc/uncertain-recall/far-AUC) | 3D primary | Δzone-bacc |
|---|---|---|---|
| AJU LOCO (n=340) | 0.436 / 0.000 / 0.756 | 0.643 / 0.543 / 0.948 | +0.208 [+0.148,+0.270] |
| 내부 matched test (n=2538) | — | 0.687 / 0.662 / 0.969 | +0.223 [+0.196,+0.250] |
| OASIS LOCO (n=210) tri-view | — | zone-bacc 0.649 / far-AUC 0.968 | — |
| NACC LOCO (n=320) tri-view | — | zone-bacc 0.683 / far-AUC 0.968 | — |

raw-visible 학습 모델(`negative_control_ledger.md`, AUC/calibrated-bacc): AJU `0.593/0.531`→`0.934/0.812` ·
OASIS `0.700/0.650`→`0.957/0.833` · NACC `0.714/0.667`→`0.898/0.812`. seed sd: 3D 0.001~0.005 vs 2.5D 0.04~0.06,
최소 cross-cohort delta AUC +0.159·bacc +0.146(`…_cross_cohort_seed_synthesis`).

✅ **검증된 핵심 주장**: image-only 3D가 three-zone 해부 추론 task에서 고정 2.5D를 internal·AJU·OASIS·NACC LOCO 전반에서 능가(ranking·calibrated bacc 기준).
🟡 **경계**: OASIS positive recall은 3D < 2.5D(비대칭). recall 균형이 아닌 ranking 우위로 한정해야 함.

## 외부 morphometry bar (⚠️ 분류 우월 주장 가드레일)

`reports/F04_IMAGE_REPRESENTATION_VS_MORPHOMETRY_BAR_20260606.md`(원천 `/home/vlm/minyoungi/roi_qc/.../09_modeling_path_comparison/RESULTS.md`):
CN/AD LOCO morphometry+simple-norm RF AUC **0.910(train-z)/0.909(ICV)**. 현 이미지 3D AJU binary AUC 0.879, 후보 0.853~0.866, 고정 2.5D 0.684.
→ 이미지 방법은 아직 bar 아래. "이미지가 CN/AD 분류에서 우월" 주장 금지.

## negative-control / method novelty (❌ 미확립)

`negative_control_ledger.md`: 컨트롤 **56건**. uncertainty/ranking/gating/morphometry-distillation/ROI-token 변형 전부
3D primary 대비 NEGATIVE 또는 MIXED — uncertain row 회복이 far-positive recall 손상을 동반(반복 실패 모드).
유일한 POSITIVE는 *방법이 아닌 진단*: frozen-primary morphometry probe(Spearman hip/MTL/vent/ratio 0.655/0.771/0.881/0.629), raw-visible 3D>2.5D 우위.

## ROI evidence encoder 결과 (full cache-backed run, ✅ 검증 — 기반 결과)

run `20260601_125527_roi_evidence_cached_full_v1`. test session-level R²(`F04_ROI_EVIDENCE_TRAINABILITY_REVIEW.md`):

| target | R² | 해석 |
|---|---:|---|
| `roi_ventricle_to_brain_proxy` | **0.643** | ✅ 강 |
| `log1p_roi_ventricle_sum_vol` | **0.618** | ✅ 강 |
| `roi_hippocampus_to_ventricle` | 0.417 | 🟡 ventricle-driven 의심 |
| `log1p_roi_mtl_sum_vol` | 0.195 | 🟡 약, secondary |
| `log1p_roi_hippocampus_vol` | 0.190 | 🟡 약, secondary |
| `roi_mtl_to_brain_proxy` | 0.109 | 🟡 약하지만 양성 |

✅ 다중 타깃 ROI 감독으로 T1w 인코더가 해부학적 퇴행 패턴 회복, 최강 신호는 ventricle. 🟡 hippo/MTL 약 — "해마 위축 정밀 학습" 주장 금지.

## downstream (AEB) probe — 🟡 novelty 미확정 (기반 결과)

run `20260601_131409_aeb_downstream_probe_full_v1`. 최선 `aeb_pred_plus_clinical`: diagnosis_worsening F1 0.662·cdrsb_progression 0.671(clinical 0.677 못 넘음)·future_ad 0.750.
🟡 raw split downstream은 여전히 clinical context 지배 → 단독 novelty 근거 아님.

## 검증 / 미검증 분리

| 구분 | 항목 |
|---|---|
| ✅ 검증 | 데이터셋 무결성(overlap 0)·leakage PASS·ROI evidence 학습성(ventricle 강)·three-zone 3D>2.5D(internal·AJU·OASIS·NACC)·raw-visible 3D>2.5D 전 seed·seed 안정성 |
| 🟡 미검증/잠정 | OASIS recall 비대칭 통제(operating-policy 진행 중)·외부 anchor(MTA·progression) 부합 |
| ❌ 폐기/반증 | 2.5D MAE SSL 완전 삭제 · uncertainty/ranking method novelty(56 control NEGATIVE/MIXED) · 이미지 CN/AD 분류 우월(0.91 bar 미달) |
| `[VERIFY]` | front-door 문서(README·STUDY_DECISION·configs/active) stale — 현재 상태와 불일치, `reports/`·최신 run만 신뢰 |
