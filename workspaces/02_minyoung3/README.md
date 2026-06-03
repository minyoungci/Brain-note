# minyoung3 — F04 ROI-evidence 기반 해부학 VQA 생성 감시 카드

> **목적:** F04의 ROI-evidence encoder + 정규화 보정(normative calibration) 기반 해부학 QA/VQA 생성 현황 요약  ·  **출처:** `/home/vlm/minyoung3/reports`·`results/f04_roi_evidence_encoder`  ·  **갱신:** 2026-06-03

## 주제 (2026-06-03 전환)

❌ **2.5D axial MAE SSL은 완전 삭제됨.** masked center-slice 표현학습 라인은 폐기되었고
`results/`의 과거 산출물도 user 요청으로 제거(`F04_ACTIVE_ARTIFACT_REGISTRY.md`).

현재 F04는 **T1w MRI에 붙일 ROI-grounded 해부학 QA/VQA 데이터셋 생성**이다. 정답 라벨은
진단(diagnosis)이 아니라 **official N4 manifest의 보정된 FreeSurfer ROI evidence**에서 파생한다.
임상 필드는 train-only 정규 기준군과 안정적 longitudinal reference pair 정의에만 쓰인다.

## 현재 활성 파이프라인

| 단계 | 산출물 | 상태 |
|---|---|---|
| ROI-evidence encoder dataset | `results/f04_roi_evidence_encoder/20260531_235859_roi_evidence_dataset` | ✅ 활성 canonical (18,815 sess / 56,445 slab / 42 evidence target, subject overlap 0) |
| ROI-evidence slab cache | `…/20260601_114226_roi_evidence_slab_cache_full_v1` | ✅ full cache (`slab_images_float16.npy` `[56439,5,96,112]`) |
| 정규화 보정(normative calibration) | `…/20260603_031352_official_manifest_n4_normative_calibration_v6_global_cdr_primary` | ✅ train-only CN+CDR0+무악화 기준군 3,303 sess / 1,802 subj, pair 1,222/439(ADNI·AIBL) |
| QA 생성 | 58,330 QA rows · 6 템플릿 · `normative_reference_cutoff` | ✅ 생성됨 |

## 설계 원칙 (검증된 방어선)

- ROI 원값 → **age/sex/head-size/cohort 보정 percentile·z-score**로 변환 후 percentile 라벨 사용.
  보정 시 `normative_reference_cutoff`, 미보정 train quantile이면 `research_proxy_not_clinical` 표기.
- ⚠️ **진단 표현 금지.** 구조 T1w ROI는 해부학/신경퇴행 evidence만 지지하며 AD를 단독 진단하지 않는다.
- 임상 published cutoff를 ROI 변수에 직접 적용하지 않음 — construct를 정의하고 ROI를 proxy로 매핑(한계 명시).

## 다음 게이트

생성된 ROI-grounded QA가 (a) 외부 anchor(visual MTA rating·progression·within-cohort 안정성·AEB 예측)에
부합하는지 검증, (b) free-form medical VQA가 아닌 **anatomical evidence QA**라는 scope를 유지하는지 감사.
ROI 변수: `log1p_roi_hippocampus_vol`·`log1p_roi_mtl_sum_vol`·`log1p_roi_ventricle_sum_vol`·`roi_ventricle_to_brain_proxy`.

## 한 줄 리스크

⚠️ git 버전 안전망 0. ROI evidence는 ventricle 계열만 강하고(R²≈0.64) hippo/MTL은 약함(R²≈0.19) —
약한 evidence에서 파생한 QA 라벨은 신뢰구간을 동반해야 한다. 진단 데이터셋으로 오인되면 임상적 과대주장이 된다.
