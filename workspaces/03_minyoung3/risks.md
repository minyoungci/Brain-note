# minyoung3 risks — F04 감시

> **목적:** F04 3D ROI-grounded VQA·operating-policy 파이프라인의 구조적·방법론적 약점과 확인 방법  ·  **출처:** `/home/vlm/minyoung3` reports·results(2026-06-07)  ·  **갱신:** 2026-06-07

각 항목: 왜 문제 / 어떻게 확인.

## R1. git 버전 안전망 0 (구조적) ⚠️

- **왜 문제**: `/home/vlm/minyoung3`에 `.git`이 없다(git toplevel=`/home/vlm`, minyoung3는 미추적). 2026-06-07 하루에만 **59개 run 디렉토리**(누적 422개)가 생성됐고 전부 버전 백업이 없다. 과거 대규모 삭제(results 35개)는 복구 불가, 결과가 report 텍스트로만 잔존.
- **어떻게 확인**: `ls -la /home/vlm/minyoung3/.git`(부재), `git -C /home/vlm/minyoung3 rev-parse --show-toplevel` → `/home/vlm`. cleanup 범위는 `…/20260531_235859_roi_evidence_dataset/CLEANUP_MANIFEST.md`.

## R2. front-door 문서 stale → 상태 오인 위험 ⚠️ (신규)

- **왜 문제**: `README.md`·`docs/STUDY_DECISION.md`·`docs/context/WORKSPACE_STATE.md`·`configs/active/f04_roi_evidence_next_experiment.json`이 폐기된 **2.5D-MAE-SSL / progression-teacher** 프레이밍을 여전히 광고한다(mtime 5/27~5/31). 카드/외부가 이 문서를 현재 상태로 읽으면 헤드라인을 오인한다.
- **어떻게 확인**: 위 파일 mtime이 5월 말. 현재 상태는 `reports/`(6/6~6/7)와 `results/.../20260607_092509_…manuscript_assets/`만 신뢰. decision line `promote_threezone_task_and_3d_vs_2p5d; do_not_promote_current_uncertainty_or_ranking_methods`.

## R3. 진단 과대주장 — morphometry 0.91 bar 미달 ⚠️

- **왜 문제**: 이미지 3D AJU CN/AD binary AUC 0.879(후보 0.853~0.866)로 외부 morphometry+simple-norm RF LOCO AUC **0.910/0.909** 아래다. "MRI VQA가 치매를 진단/판별한다" 또는 "이미지가 분류에서 우월"로 포지셔닝되면 임상적 과대주장. 정답 라벨 품질은 ROI evidence R²에 상한(ventricle 강, hippo/MTL 약).
- **어떻게 확인**: `reports/F04_IMAGE_REPRESENTATION_VS_MORPHOMETRY_BAR_20260606.md`, `claim_decision_table.md`의 `IMPORTANT_CAVEAT`, `stop_rules.md` rule 1.

## R4. OASIS positive-recall 비대칭 🟡 (신규)

- **왜 문제**: raw-visible 3D는 AUC·calibrated bacc에서 우월하나 OASIS positive recall은 모든 seed에서 2.5D보다 낮다(policy delta CI가 0을 가로지름). 잔존 pure-3D miss = 4세션/4명(3×환실확대, 1×저해마). recall 균형까지 주장하면 반증된다.
- **어떻게 확인**: `…/20260607_084958_…policy_uncertainty_calibration_audit`(OASIS positive-recall delta mean −0.134, CI −0.313→+0.065), `…/20260607_091249_…OASIS_MISSED_POSITIVE_VISUAL_AUDIT.md`. 정직한 주장 = ranking + calibrated operating-policy.

## R5. method novelty 미확립 — 동일 tradeoff 반복 🟡

- **왜 문제**: uncertainty/ranking/gating/morphometry-distillation/ROI-token 변형 56건 전부 3D primary 대비 NEGATIVE/MIXED. uncertain row를 회복하면 far-positive recall이 깎인다(반복 실패). `stop_rules.md`가 "새 메커니즘 없는 boundary/ranking/gate-reweight 변형 실행 중단"을 선언.
- **어떻게 확인**: `…/20260607_092509_…/negative_control_ledger.md`(56건), `stop_rules.md` rule 2. 새 주장은 genuinely new mechanism 또는 operating-policy 검증 통과 전 보류.

## R6. ROI fail-closed / 라벨 construct 약점 🟡

- **왜 문제**: `manifests/v2_integrated/longitudinal_voxel_manifest_v0.csv`의 `roi_final_ready` 전 18,868행 False(검증). ROI는 정책상 fail-closed(Visual-QC PASS≠해부학적 정확성). 또한 adjusted normative residual 라벨이 ratio far-positive row에서 raw 해부와 약하게만 정렬(median 0.018 vs raw 0.706) → 원 라벨 일부는 이미지로부터 학습 불가했고, 그래서 raw-visible로 피벗.
- **어떻게 확인**: 위 manifest `roi_final_ready` value_counts(`{False: 18868}`), `reports/F04_ACTIVE_ARTIFACT_REGISTRY.md`의 ratio 질문 분석.

## R7. 평가 표본 작음 + leakage 부분 감사 🟡

- **왜 문제**: raw-visible positive가 ~14%라 held-out 벤치마크가 작다(AJU 96 / OASIS 60 / NACC 96 row). recall-floor 정책은 "risk control이지 임상 sensitivity 추정 아님". 직접 split leakage는 PASS이나 cohort/site shortcut은 표현 단계에서 부분 감사.
- **어떻게 확인**: `…_raw_visible_*` run의 row count, `scripts/audit_f04_roi_evidence_leakage.py` 결과(verdict `PASS_NO_DIRECT_SPLIT_LEAKAGE_DETECTED`, soft warning 잔존).
