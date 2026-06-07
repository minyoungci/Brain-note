# minyoung3 sources — 근거 파일 + 재사용 자산

> **목적:** F04 카드가 인용한 근거 파일과 생존 코드 자산 목록  ·  **출처:** `/home/vlm/minyoung3` 파일 mtime + reports 본문  ·  **갱신:** 2026-06-07

읽은 날짜: 2026-06-02(기반) + 2026-06-07(three-zone/raw-visible) · mtime은 UTC.

⚠️ minyoung3는 독립 git 저장소가 아니다(.git 부재, toplevel=/home/vlm). 시점 추적은 mtime + reports 본문 날짜로만 가능하다. `Official/potato/Reset_Audits/`는 현재 부재(find 0건).

## 0. 현재 헤드라인 근거 (2026-06-07, 최우선)

| 경로 | 내용 |
|---|---|
| `results/f04_roi_evidence_encoder/20260607_092509_v6_latest_threezone_manuscript_assets/` | manuscript asset 패키지. `LATEST_MANUSCRIPT_ASSET_SUMMARY.md`(decision line)·`core_threezone_results_table.md`·`claim_decision_table.md`·`negative_control_ledger.md`(56건)·`stop_rules.md` |
| `results/f04_roi_evidence_encoder/20260603_050611_3d_roi_grounded_vqa_design/matched_session_qa_with_3d_paths.csv` | matched 3D VQA 벤치마크 19,236 QA / 9,278 sess / 5,601 subj (overlap 0) |
| `results/f04_roi_evidence_encoder/20260607_0650~0810*_raw_visible_*` | raw-visible 학습·벤치마크·seed 안정성·cross-cohort 합성 |
| `results/f04_roi_evidence_encoder/20260607_0828~0921*_*policy*·*missed_positive*` | operating-policy·recall-constrained·OASIS miss 시각 audit |
| `reports/F04_NEXT_UNCERTAINTY_AWARE_3D_ROI_VQA_PLAN.md` | 입력/출력 정책·아키텍처(global64³+MTL64³ fusion, tri-view) |
| `reports/F04_IMAGE_REPRESENTATION_VS_MORPHOMETRY_BAR_20260606.md` | 외부 morphometry bar(CN/AD LOCO AUC 0.910/0.909) |
| `reports/F04_ACTIVE_ARTIFACT_REGISTRY.md` | adjusted→raw-visible 피벗 근거(ratio far-pos median 0.018 vs raw 0.706) |

⚠️ front-door 문서(아래 1번 표)는 stale — 폐기된 2.5D-MAE-SSL 프레이밍을 광고. 현재 상태 판단에 쓰지 말 것.

## 1. 최상위 / 정책 문서

| 파일 | mtime |
|---|---|
| `/home/vlm/minyoung3/README.md` | 2026-05-27 11:41 |
| `/home/vlm/minyoung3/docs/STUDY_DECISION.md` | 2026-05-27 11:41 |
| `/home/vlm/minyoung3/docs/PATH_CONVENTIONS.md` | 2026-05-27 11:42 |
| `/home/vlm/minyoung3/docs/F04_F05_ARTIFACT_AND_AGENT_WORKFLOW.md` | 2026-05-27 13:35 |

## 2. reports (핵심 근거)

| 파일 | mtime | 인용 내용 |
|---|---|---|
| `reports/F04_ROI_EVIDENCE_TRAINABILITY_REVIEW.md` | 2026-06-01 13:23 | ROI R² 표(ventricle 0.643/0.618, hippo 0.190), AEB downstream, feasibility 스케일 |
| `reports/F04_ACTIVE_ARTIFACT_REGISTRY.md` | 2026-06-01 12:00 | 데이터셋 스코프(18,815/56,445/10,564), 캐시 shape, 삭제 정책 |
| `reports/F04_ROI_EVIDENCE_MODEL_CODE_REVIEW.md` | 2026-06-01 11:24 | 코드 리뷰, methodology risk 표(cohort shortcut 미감사 등) |
| `reports/raw_consortium_modality_counts_20260601.csv` | 2026-06-01 12:27 | 컨소시엄·모달리티 카운트 |

## 3. configs

| 파일 | mtime | 내용 |
|---|---|---|
| `configs/active/f04_roi_evidence_next_experiment.json` | 2026-06-01 00:04 | promotion_gate(clinical_matched/permutation/LOCO/shortcut), 타깃 정의 |
| `configs/f04_f05_auto_research_experiment_matrix.csv` | 2026-05-27 13:24 | 실험 매트릭스 |
| `configs/f04_ssl_center_slice_smoke_config.json` | 2026-05-27 08:29 | SSL smoke 설정 |

## 4. 활성 결과 (results/f04_roi_evidence_encoder/)

| 경로 | mtime | 내용 |
|---|---|---|
| `20260531_235859_roi_evidence_dataset/summary.json` | 2026-06-01 00:00 | 데이터셋 스코프·split overlap 0 (✅ 직접검증) |
| `20260531_235859_roi_evidence_dataset/split_summary.csv` | 2026-06-01 00:00 | 7컨소시엄 분할 |
| `20260531_235859_roi_evidence_dataset/target_summary.csv` | 2026-06-01 00:00 | 42 evidence target 분포 |
| `20260531_235859_roi_evidence_dataset/pair_target_summary.csv` | 2026-06-01 00:00 | progression 라벨 분포(불균형) |
| `20260531_235859_roi_evidence_dataset/CLEANUP_MANIFEST.md` | 2026-06-01 00:02 | 삭제된 35개 results 디렉토리 목록 |
| `20260601_114226_roi_evidence_slab_cache_full_v1/` | 2026-06-01 11:55 | full slab cache `[56439,5,96,112]` float16 |
| `20260601_125527_roi_evidence_cached_full_v1/` | 2026-06-01 12:57 | 학습된 ROI evidence encoder(best ep4) |
| `20260601_131409_aeb_downstream_probe_full_v1/` | 2026-06-01 13:18 | AEB downstream probe |
| `20260601_121136_roi_evidence_leakage_audit/` | 2026-06-01 12:11 | leakage audit verdict PASS |
| `20260602_005520_famous_ssl_dinov2_smoke_download_check/` | 2026-06-02 00:55 | DINOv2 비교 준비(manifest만, metric 없음) |
| `results/f04_roi_evidence_encoder/README.md` | 2026-06-01 13:24 | 활성 산출물 인덱스 |

## 5. manifests

| 경로 | mtime | 비고 |
|---|---|---|
| `manifests/v2_integrated/longitudinal_voxel_manifest_v0.csv` | (v2_integrated) | `roi_final_ready` 전 18,868행 False (✅ 검증, fail-closed) |
| `manifests/f04_25d/` | 2026-05-28 01:39 | F04 2.5D slab manifest |

## 6. 재사용 코드 자산 (생존 스크립트)

| 스크립트 | mtime | 역할 |
|---|---|---|
| `scripts/train_f04_roi_evidence_cached.py` | 2026-06-01 12:53 | cache-backed ROI evidence multi-target encoder 학습 |
| `scripts/build_f04_roi_slab_cache.py` | 2026-06-01 11:40 | slab cache(float16 npy + row-aligned manifest) 빌더 |
| `scripts/train_f04_ssl_vit_mae_ddp.py` | 2026-05-28 07:28 | MAE 2.5D SSL DDP/BF16 trainer (미full-train) |
| `scripts/train_f04_ssl_vit_mae.py` | 2026-05-28 02:57 | 단일 GPU MAE trainer(전신) |
| `scripts/launch_f04_ddp_b200_4gpu_vitlarge.sh` | 2026-05-28 07:22 | 4×B200 DDP launch + cache/manifest gate |
| `scripts/audit_f04_roi_evidence_leakage.py` | 2026-06-01 12:09 | split leakage + cache 정합 audit |
| `scripts/run_f04_famous_ssl_downstream_probe.py` | 2026-06-02 00:34 | DINOv2 frozen baseline vs AEB 비교(진행 중) |
| `scripts/run_f04_aeb_downstream_probe.py` | 2026-06-01 13:12 | AEB feature export + progression probe |
| `scripts/run_f04_binary_cohort_shortcut_probe.py` | 2026-05-31 04:38 | cohort shortcut control(결과 삭제됨, 재실행 필요) |
| `scripts/run_f04_binary_repeated_loco_probe.py` | 2026-05-31 04:48 | repeated LOCO probe |
| `scripts/build_f04_official_label_slab_manifest.py` | 2026-05-27 11:52 | 다음 게이트: official-label slab manifest 빌더 |
| `scripts/build_f04_25d_slab_manifest.py` | 2026-05-27 07:46 | 2.5D slab manifest 빌더 |
| `scripts/build_f04_session_volume_cache.py` | 2026-05-28 02:58 | session volume cache 빌더 |
| `scripts/f04_ssl_center_slice.py` | 2026-05-28 07:16 | center-slice SSL dataset/loss 정의 |
| `scripts/export_f04_frozen_embeddings_and_probe.py` | 2026-05-31 04:10 | frozen embedding export + probe |
| `scripts/posthoc_f04_subject_level_probe.py` | 2026-05-31 04:31 | subject-level probe |

## 검증 메모

| 구분 | 항목 |
|---|---|
| ✅ 직접검증 | 데이터셋 summary.json, split overlap, roi_final_ready=False, leakage PASS, results 트리(MAE checkpoint 부재), .git 부재 |
| 🟡 텍스트의존 | ROI R²·AEB metric은 report 표 인용(raw 산출물 일부는 cleanup으로 소실, dashboard.csv 등은 잔존) |
| `[VERIFY]` | Reset_Audits/pre-delete inventory 실제 보존 위치 불명, F04-label manifest·F05 검증 산출물 미확인, famous_ssl 최종 metric 미생성 |
