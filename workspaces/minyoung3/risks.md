# minyoung3 risks — F04 감시

> **목적:** F04 표현학습 파이프라인의 구조적·방법론적 약점과 확인 방법 정리  ·  **출처:** `/home/vlm/minyoung3` reports·configs·manifests  ·  **갱신:** 2026-06-02

각 항목: 왜 문제 / 어떻게 확인.

## R1. git 버전 안전망 0 (구조적) ⚠️

- **왜 문제**: `/home/vlm/minyoung3`에 `.git`이 없다. git toplevel은 `/home/vlm`이며 minyoung3는 그 트리에서 추적되지 않는다(run의 `git_info.json` status에 minyoung3 파일이 전혀 나타나지 않음). 따라서 2026-05-27/06-01의 대규모 삭제(PET/3D 잔재, results 35개 디렉토리)는 되돌릴 수 없다. 실험 결과가 reports의 표 텍스트로만 남고 raw 산출물은 소실됐다(frozen embedding source run 포함).
- **어떻게 확인**: `ls -la /home/vlm/minyoung3/.git`(부재 확인됨), `git -C /home/vlm/minyoung3 rev-parse --show-toplevel` → `/home/vlm`. cleanup 범위는 `.../20260531_235859_roi_evidence_dataset/CLEANUP_MANIFEST.md`.
- **주의**: 배경 지시의 `Official/potato/Reset_Audits/`는 현재 존재하지 않는다(`find` 결과 0건). pre-delete inventory의 실제 보존 여부는 `[VERIFY]` — CLEANUP_MANIFEST.md의 삭제 목록만 확인됨.

## R2. MAE 2.5D SSL 백본 미학습 (헤드라인 공백) ⚠️

- **왜 문제**: novelty 1순위인 "center-slice masked recon SSL 표현"이 full-train 0회. scaffold + 짧은 CUDA pilot만 통과. DDP launch 산출물은 cleanup으로 삭제됐고 `results/`에 MAE checkpoint가 없다. 현재 검증된 신호는 ROI 회귀 encoder(별개 경로)뿐이라, 논문 헤드라인을 받칠 SSL 표현 품질 증거가 0이다.
- **어떻게 확인**: `results/` 트리에 ViT/MAE checkpoint·run 디렉토리 부재 확인됨. trainer(`train_f04_ssl_vit_mae_ddp.py`)·launch(`launch_f04_ddp_b200_4gpu_vitlarge.sh`)는 생존. full-train 시 `runs/f04_axial_k5_s4_dense_main/` 산출 예상.

## R3. ROI fail-closed / 잠정 🟡

- **왜 문제**: `manifests/v2_integrated/longitudinal_voxel_manifest_v0.csv`의 `roi_final_ready`가 전 18,868행 False(검증됨). ROI는 정책상 fail-closed — Visual-QC PASS를 해부학적 정확성으로 간주하지 않는다(README/STUDY_DECISION 명시). 즉 ROI 보조경로는 controlled novelty layer이지 검증된 atlas-wide 진실이 아니다. 또한 ROI evidence에서 강한 신호는 환실뿐이고 hippo/MTL(AD 핵심 영역)은 약하다(R²≈0.19).
- **어떻게 확인**: 위 manifest `roi_final_ready` value_counts(`{False: 18868}`). 강/약 신호는 `F04_ROI_EVIDENCE_TRAINABILITY_REVIEW.md` 표.

## R4. "recon loss ≠ 임상 표현 품질" 경계 위반 위험 🟡

- **왜 문제**: trainer docstring·README·STUDY_DECISION 모두 reconstruction loss와 GPU util은 plumbing 신호일 뿐이라 경고한다. 마찬가지로 ROI R²나 AEB feature가 학습된다는 사실이 임상적으로 유용한 표현을 증명하지 않는다. AEB downstream은 raw split에서 clinical context를 넘지 못했다(cdrsb 0.671 vs clinical 0.677). 단일 run downstream metric을 표현 품질 증거로 쓰는 것은 STUDY_DECISION이 금지한 헤드라인이다.
- **어떻게 확인**: `configs/active/f04_roi_evidence_next_experiment.json`의 `promotion_gate`(clinical_matched/permutation 95th pct/LOCO/cohort shortcut). 이 게이트 통과 전에는 novelty 주장을 보류한다.

## R5. leakage / shortcut audit — 부분 존재 🟡

- **왜 문제**: 직접 split leakage는 audit됨(PASS). 그러나 (a) cohort/site shortcut은 ROI 표현 단계에서 아직 미감사(코드 리뷰가 "high for claims"로 표시), (b) leakage audit이 soft warning 6건(여러 split에 걸친 rounded target 중복)을 남겼다 — 생물학적 공통값인지 미해소. (c) 옛 cohort/LOCO/permutation probe 결과는 전부 삭제돼 재현이 필요하다.
- **어떻게 확인**: `scripts/audit_f04_roi_evidence_leakage.py` + 결과 `.../20260601_121136_roi_evidence_leakage_audit/`(verdict `PASS_NO_DIRECT_SPLIT_LEAKAGE_DETECTED`, soft_warnings 1항목). cohort shortcut은 `run_f04_binary_cohort_shortcut_probe.py`로 재실행해야 측정 가능(현재 결과 없음).

## R6. 라벨 불균형 + 다음 게이트 의존성 🟡

- **왜 문제**: progression 타깃 양성률이 낮다(future_ad ~3.6%, diagnosis_worsening ~8%). 다음 게이트(official-label slab manifest)가 검증 안 된 상태라 downstream 전체가 이 manifest 정합성에 의존한다. join 오류 시 모든 probe가 무효가 된다.
- **어떻게 확인**: `pair_target_summary.csv` 분포. manifest 빌더 `build_f04_official_label_slab_manifest.py` 출력 검증 필요(현재 검증 산출물 미확인).
