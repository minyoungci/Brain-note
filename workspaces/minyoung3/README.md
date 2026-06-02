# minyoung3 — F04 2.5D + ROI MRI 표현학습 감시 카드

> **목적:** F04 2.5D axial T1w SSL + ROI-informed 보조경로의 검증 현황 요약  ·  **출처:** `/home/vlm/minyoung3` reports·configs·results  ·  **갱신:** 2026-06-02

## 주제

2.5D axial T1w MRI masked center-slice 표현학습과 ROI-informed 보조/probe 경로. multi-consortium(A4/ADNI/AIBL/AJU/KDRC/NACC/OASIS) 무라벨 SSL 코퍼스와 official CDR/CDR-SB 라벨 probe를 분리 보고하는 점이 novelty 축이다.

## 핵심 SSL objective

5-slice slab `[z-2..z+2]` → center slice `z`의 masked brain patch 복원 (ViT/MAE-style). ✅ (README·DDP trainer 확인)

## 현재 상태

| 항목 | 상태 | 근거 |
|---|---|---|
| MAE 백본 | 🟡 scaffold + 짧은 CUDA pilot만 통과, full-train 0회 | DDP launch 산출물 `f04_ddp_b200_4gpu_vitlarge_launch`는 2026-06-01 cleanup으로 삭제, `results/`에 MAE checkpoint 부재 — 미학습 확정 ✅ |
| ROI evidence encoder | ✅ full run 완료 | ventricle 계열 강(R²≈0.64), hippo/MTL 약(R²≈0.19). 이미지 전용 입력, subject split overlap 0 |
| leakage audit | ✅ 통과 | `PASS_NO_DIRECT_SPLIT_LEAKAGE_DETECTED`, soft warning 6건(공통값 중복) |
| AEB downstream probe | 🟡 novelty 확정 불가 | diagnosis_worsening에서 balanced accuracy/recall 소폭 개선, raw split은 여전히 clinical context 우위 |
| downstream probe 산출물 | ✅ 결과 전부 삭제(2026-06-01), 스크립트 생존 | 옛 PET/3D/longitudinal voxel 잔재는 2026-05-27 삭제 명시 |

## 다음 게이트

official-label-enriched F04 slab manifest 검증(`build_f04_official_label_slab_manifest.py` → label-join). 이후 clinical-matched / within-cohort / LOCO / label-permutation 평가로 ROI 보조경로가 clinical/shortcut baseline을 넘는지 검증한다(`configs/active/f04_roi_evidence_next_experiment.json`의 promotion_gate).

## 한 줄 리스크

⚠️ git 버전 안전망이 0이고 헤드라인 모델(MAE)이 미학습인 상태에서, 검증된 신호는 환실 확대 ROI 회귀뿐이다. recon loss나 ROI R²는 임상 표현 품질을 증명하지 않는다.
