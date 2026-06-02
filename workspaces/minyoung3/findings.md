# minyoung3 findings — F04 패밀리

_갱신: 2026-06-02_ · 표기: ✅확정 / 🟡잠정 / ❌반증 / [VERIFY]추측

## F04 패밀리 구조

- **F04** — 2.5D axial slab masked center-slice SSL (ViT/MAE-style patch Transformer). ✅ (README, `train_f04_ssl_vit_mae_ddp.py`)
- **F04-label** — official manifest 라벨로 enrich된 slab manifest, downstream probe 용. 🟡 (다음 게이트, `build_f04_official_label_slab_manifest.py` 존재하나 검증 결과 미확인)
- **F05** — ROI-informed 2.5D 확장. label-join + ROI-source contract 검증 후 착수 예정. 🟡 아직 미구현 (README "to be built").

라벨 권위: `/home/vlm/data/preprocessed_official/official_manifest.csv` (CDR global / CDR-SB / source). ✅

## 활성 데이터셋 (검증됨)

`results/f04_roi_evidence_encoder/20260531_235859_roi_evidence_dataset` — `summary.json` 직접 확인:

- ✅ 18,815 세션 / 56,445 selected slab / 10,564 longitudinal pair
- ✅ ROI summary 가용: 18,813/18,815 세션, 56,439/56,445 slab (각 2·6개 결측)
- ✅ evidence target 42개
- ✅ subject split overlap = 0 (train/val/test 전 쌍)
- ✅ 7개 컨소시엄 분할 균형 (A4/ADNI/AIBL/AJU/KDRC/NACC/OASIS, `split_summary.csv`)
- pair label 분포(`pair_target_summary.csv`): cdrsb_progression_ge05 1,179/4,457, diagnosis_worsening 436/4,774, future_ad_from_nonad 177/4,774 — 🟡 양성 클래스 매우 불균형(특히 future_ad ~3.6%).

## ROI evidence encoder 결과 (full cache-backed run, 검증됨)

run `20260601_125527_roi_evidence_cached_full_v1` (best epoch 4, train 13,221세션/39,663slab, test 2,855세션/8,565slab). test session-level R² (`F04_ROI_EVIDENCE_TRAINABILITY_REVIEW.md`):

| target | R² | Pearson | 해석 |
|---|---:|---:|---|
| `roi_ventricle_to_brain_proxy` | **0.643** | 0.809 | ✅ 강 |
| `log1p_roi_ventricle_sum_vol` | **0.618** | 0.802 | ✅ 강 |
| `roi_hippocampus_to_ventricle` | 0.417 | 0.734 | 🟡 primary로 충분 (단 ventricle-driven 의심) |
| `log1p_roi_mtl_sum_vol` | 0.195 | 0.472 | 🟡 약, secondary |
| `log1p_roi_hippocampus_vol` | 0.190 | 0.482 | 🟡 약, secondary |
| `roi_mtl_to_brain_proxy` | 0.109 | 0.344 | 🟡 약하지만 양성 |

- ✅ **검증된 핵심 주장**: 다중 타깃 ROI 감독으로 T1w 이미지 인코더가 해부학적 퇴행 패턴을 회복 가능. **가장 강한 신호는 환실(ventricle) 확대/비율.** 512→1,024→full 세션 확대 시 단조 개선(소규모 artifact 아님).
- 🟡 **해석 경계**: hippo/MTL은 axial-only slab + tiny CNN에서 약함. "해마 위축을 정밀하게 학습한다"는 주장 금지(코드 리뷰 명시). hippocampus_to_ventricle 개선도 분모(환실) 신호에 끌려갈 수 있음.

### feasibility 단계 (참고)
- 512s smoke / 1,024s medium 모두 동일 추세(ventricle 강, hippo 약). medium val RMSE 0.1657→0.1595→0.1578(ep3). 4,096s 시도는 산출물 미완성으로 폐기. ✅

## downstream (AEB) probe 결과 🟡

run `20260601_131409_aeb_downstream_probe_full_v1`, 10,562 pair. 최선 모델 `aeb_pred_plus_clinical`:

- diagnosis_worsening: macro F1 0.662, balanced acc 0.687, pos recall 0.453 — clinical 대비 F1 유사, balanced acc/recall 개선.
- cdrsb_progression_ge05: macro F1 0.671 — clinical(0.677) 못 넘음.
- future_ad_from_nonad: macro F1 0.750 — clinical과 유사, balanced acc는 낮음.
- 🟡 결론: ROI evidence는 학습되나, raw split downstream은 여전히 clinical context 지배. **novelty 확정 불가** — clinical-matched / within-cohort 평가 필요.

## 무엇이 검증됐고 무엇이 미검증

- ✅ 검증: 활성 데이터셋 무결성(split overlap 0), leakage audit PASS, ROI evidence 학습 가능성(ventricle 강), feasibility 스케일 단조성.
- 🟡 미검증: F04-label manifest, F05, clinical-matched/LOCO/permutation 게이트 통과 여부.
- ❌ 미검증(헤드라인): **MAE 2.5D SSL 백본 full-train은 한 번도 완료 안 됨.** pilot/scaffold만 통과. 따라서 "SSL 표현이 임상적으로 유용하다"는 핵심 주장은 현재 무근거.
- [VERIFY] `20260602_005520_famous_ssl_dinov2_smoke_download_check`는 DINOv2 frozen baseline 비교 준비 단계(스크립트 `run_f04_famous_ssl_downstream_probe.py`, 06-02 00:34/00:55 갱신) — 결과 metric 미생성, manifest export만 존재.
