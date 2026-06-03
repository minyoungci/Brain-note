# minyoung3 findings — F04 패밀리

> **목적:** F04 패밀리의 검증된 결과와 미검증 항목 분리 기록  ·  **출처:** `/home/vlm/minyoung3` reports·results summary.json  ·  **갱신:** 2026-06-03

표기: ✅확정 / 🟡잠정 / ❌반증 / `[VERIFY]`미검증

## F04 패밀리 구조 (2026-06-03 전환)

| 라인 | 정의 | 상태 |
|---|---|---|
| ~~2.5D MAE SSL~~ | ~~axial slab masked center-slice SSL (ViT/MAE)~~ | ❌ **완전 삭제(폐기).** 코드·결과 모두 제거 — 헤드라인 라인 아님 |
| **ROI-evidence encoder** | T1w 이미지 → 42개 FreeSurfer ROI evidence 회귀 | ✅ full run 완료 (활성 canonical 데이터셋) |
| **normative calibration** | train-only CN/안정 기준군으로 ROI → 보정 percentile·z-score | ✅ `…_n4_normative_calibration_v6_global_cdr_primary` |
| **ROI-grounded QA 생성** | 보정 ROI evidence → T1w에 붙일 해부학 QA/VQA (진단 아님) | ✅ 58,330 QA rows · 6 템플릿 · `normative_reference_cutoff` |

라벨 권위: `official_manifest_full_n4.csv` (CDR global / CDR-SB / source). QA 정답은 진단이 아닌 **보정 ROI evidence**에서 파생. ✅

## 활성 데이터셋 (검증됨)

`results/f04_roi_evidence_encoder/20260531_235859_roi_evidence_dataset` — `summary.json` 직접 확인:

- ✅ 18,815 세션 / 56,445 selected slab / 10,564 longitudinal pair
- ✅ ROI summary 가용: 18,813/18,815 세션, 56,439/56,445 slab (각 2·6개 결측)
- ✅ evidence target 42개
- ✅ subject split overlap = 0 (train/val/test 전 쌍)
- ✅ 7개 컨소시엄 분할 균형 (A4/ADNI/AIBL/AJU/KDRC/NACC/OASIS, `split_summary.csv`)
- 🟡 pair label 분포(`pair_target_summary.csv`): cdrsb_progression_ge05 1,179/4,457, diagnosis_worsening 436/4,774, future_ad_from_nonad 177/4,774 — 양성 클래스 불균형(특히 future_ad ~3.6%)

## ROI evidence encoder 결과 (full cache-backed run, 검증됨)

run `20260601_125527_roi_evidence_cached_full_v1` (best epoch 4, train 13,221세션/39,663slab, test 2,855세션/8,565slab). test session-level R² (`F04_ROI_EVIDENCE_TRAINABILITY_REVIEW.md`):

| target | R² | Pearson | 해석 |
|---|---:|---:|---|
| `roi_ventricle_to_brain_proxy` | **0.643** | 0.809 | ✅ 강 |
| `log1p_roi_ventricle_sum_vol` | **0.618** | 0.802 | ✅ 강 |
| `roi_hippocampus_to_ventricle` | 0.417 | 0.734 | 🟡 primary로 충분, 단 ventricle-driven 의심 |
| `log1p_roi_mtl_sum_vol` | 0.195 | 0.472 | 🟡 약, secondary |
| `log1p_roi_hippocampus_vol` | 0.190 | 0.482 | 🟡 약, secondary |
| `roi_mtl_to_brain_proxy` | 0.109 | 0.344 | 🟡 약하지만 양성 |

- ✅ **검증된 핵심 주장**: 다중 타깃 ROI 감독으로 T1w 이미지 인코더가 해부학적 퇴행 패턴을 회복 가능. 가장 강한 신호는 환실(ventricle) 확대/비율. 512→1,024→full 세션 확대 시 단조 개선(소규모 artifact 아님).
- 🟡 **해석 경계**: hippo/MTL은 axial-only slab + tiny CNN에서 약하다. "해마 위축을 정밀하게 학습한다"는 주장은 금지(코드 리뷰 명시). hippocampus_to_ventricle 개선도 분모(환실) 신호에 끌려갈 수 있다.

### feasibility 단계 (참고)

512s smoke / 1,024s medium 모두 동일 추세(ventricle 강, hippo 약). medium val RMSE 0.1657→0.1595→0.1578(ep3). 4,096s 시도는 산출물 미완성으로 폐기. ✅

## downstream (AEB) probe 결과 🟡

run `20260601_131409_aeb_downstream_probe_full_v1`, 10,562 pair. 최선 모델 `aeb_pred_plus_clinical`:

| 타깃 | macro F1 | 비교 |
|---|---:|---|
| diagnosis_worsening | 0.662 | clinical 대비 F1 유사, balanced acc 0.687·pos recall 0.453 개선 |
| cdrsb_progression_ge05 | 0.671 | clinical(0.677) 못 넘음 |
| future_ad_from_nonad | 0.750 | clinical과 유사, balanced acc는 낮음 |

🟡 결론: ROI evidence는 학습되나, raw split downstream은 여전히 clinical context 지배. **novelty 확정 불가** — clinical-matched / within-cohort 평가 필요.

## 검증 / 미검증 분리

| 구분 | 항목 |
|---|---|
| ✅ 검증 | 활성 데이터셋 무결성(split overlap 0), leakage audit PASS, ROI evidence 학습 가능성(ventricle 강), feasibility 스케일 단조성 |
| 🟡 미검증 | F04-label manifest, F05, clinical-matched/LOCO/permutation 게이트 통과 여부 |
| ❌ 폐기(헤드라인 전환) | 2.5D MAE SSL 라인 **완전 삭제** — full-train 0회였고 이제 코드·결과 모두 제거. 헤드라인은 ROI-grounded QA 생성으로 이동. 검증 부담: QA가 진단 데이터셋으로 오인되지 않고 외부 anchor에 부합하는가 |
| `[VERIFY]` | `20260602_005520_famous_ssl_dinov2_smoke_download_check`는 DINOv2 frozen baseline 비교 준비 단계(스크립트 `run_f04_famous_ssl_downstream_probe.py`, 06-02 00:34/00:55 갱신) — 결과 metric 미생성, manifest export만 존재 |
