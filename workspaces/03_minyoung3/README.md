# minyoung3 — F04 3D ROI-grounded 해부학 VQA 감시 카드

> **목적:** F04의 3D ROI-grounded VQA(three-zone 해부학 추론) 및 raw-visible 학습 트랙 현황 요약  ·  **출처:** `/home/vlm/minyoung3/reports`·`results/f04_roi_evidence_encoder`(2026-06-06~07 run)  ·  **갱신:** 2026-06-07 (mtime 기준, git 부재)

## 주제 (2026-06-07 현황)

❌ **2.5D axial MAE SSL은 완전 폐기됨**(2026-06-03, 코드·결과 제거). 현재 헤드라인은 ROI evidence를
원천으로 한 **image-only 3D ROI-grounded VQA**이며, 주장은 진단 분류기가 아니라 **task/evaluation 기여**다:
ROI evidence를 *far-negative / near-cutoff-uncertain / far-positive* **three-zone 해부학 추론**으로 프레이밍하고,
validation-locked LOCO 프로토콜에서 **3D가 고정 2.5D를 이긴다**는 것.

정답 라벨은 6/7 기준 **raw-visible ROI-VQA**(원본 영상에서 실제로 보이는 해부 기준)로 피벗했다.
이전 "adjusted normative residual" 라벨은 ratio far-positive row에서 raw 해부와 약하게만 정렬되어
이미지로부터 부분적으로 학습 불가했기 때문이다(`reports/F04_ACTIVE_ARTIFACT_REGISTRY.md`).

## 입력 정책 (전 산출물 공통, 엄격)

모델 입력 = **이미지 텐서 + question ID 만**. ROI 원값·evidence percentile·임상 필드·scanner/cohort·
diagnosis·CDR/CDR-SB·age/sex·morphometry는 **target 구성/stratification/audit 전용**, 입력 금지
(`results/.../20260607_092509_v6_latest_threezone_manuscript_assets/LATEST_MANUSCRIPT_ASSET_SUMMARY.md`,
`reports/F04_NEXT_UNCERTAINTY_AWARE_3D_ROI_VQA_PLAN.md`).

## 현재 활성 파이프라인

| 단계 | 산출물 | 상태 |
|---|---|---|
| ROI-evidence encoder dataset | `results/f04_roi_evidence_encoder/20260531_235859_roi_evidence_dataset` | ✅ canonical (18,815 sess / 56,445 slab, overlap 0) |
| matched 3D VQA 벤치마크 | `…/20260603_050611_3d_roi_grounded_vqa_design/matched_session_qa_with_3d_paths.csv` | ✅ 19,236 QA / 9,278 sess / 5,601 subj (overlap 0) |
| three-zone 3D-vs-2.5D 평가 | `…/20260607_092509_v6_latest_threezone_manuscript_assets` | ✅ manuscript asset(table·figure·ledger) 생성 |
| **raw-visible ROI-VQA 학습** | `…/20260607_0650~0810*_raw_visible_*` | ✅ 활성 positive image track (3D > 2.5D 전 seed) |
| operating-policy / recall audit | `…/20260607_0828~0921*_*policy*·*missed_positive*` | 🟡 진행 중 (OASIS recall 손실 통제) |

## 최신 결과 (실측, 출처 병기)

three-zone core table — `…/20260607_092509_…/core_threezone_results_table.md`:

| 평가 | 고정 2.5D (zone-bacc/uncertain-recall/far-AUC) | 3D primary | Δzone-bacc vs 2.5D |
|---|---|---|---|
| AJU LOCO (n=340) | 0.436 / 0.000 / 0.756 | 0.643 / 0.543 / 0.948 | **+0.208** [+0.148,+0.270] |
| 내부 matched test (n=2538) | — | 0.687 / 0.662 / 0.969 | **+0.223** [+0.196,+0.250] |

raw-visible 학습 모델(`negative_control_ledger.md`, AUC/calibrated-bacc):
AJU 2.5D `0.593/0.531` vs 3D `0.934/0.812` · OASIS `0.700/0.650` vs `0.957/0.833` · NACC `0.714/0.667` vs `0.898/0.812`.
seed 안정성(3 LOCO seed): 3D AUC sd 0.001~0.005(2.5D sd 0.04~0.06), 최소 cross-cohort delta AUC **+0.159**·bacc **+0.146**.

## 결정 — 채택 vs 보류 (`claim_decision_table.md`)

| 판정 | 내용 |
|---|---|
| ✅ KEEP_CORE | three-zone ROI-grounded VQA 프레이밍 + "이 task에서 3D > 고정 2.5D" |
| ⚠️ CAVEAT | 이미지 방법이 외부 morphometry 분류기 bar(**CN/AD LOCO AUC ≈ 0.91**)를 못 넘음 (이미지 3D AJU 0.879, 후보 0.853~0.866 < 0.910/0.909) |
| ❌ DO_NOT_PROMOTE_METHOD | 새 uncertainty/ranking/gating novelty **미확립**. negative-control 56건 전부 NEGATIVE/MIXED — uncertain row를 살리면 far-positive recall 손상(반복 실패) |

긍정 항목은 *방법이 아닌 진단(diagnostic)*뿐: frozen-primary morphometry probe(AJU ROI-percentile Spearman
hip/MTL/vent/ratio `0.655/0.771/0.881/0.629`) — 3D 표현이 형태 신호를 담음을 입증하나 promote된 답안 방법은 아님.

## 다음 게이트

`ACTIVE_OPERATING_POLICY_TARGET`: **validation-locked ROI/question operating policy(constrained thresholding)**로
OASIS 3개 질문(저해마부피·환실확대·해마/환실 비율)의 positive-recall 손실을 3D 우위(specificity/bacc/AUC) 유지하며 통제.
`stop_rules.md`가 "새 메커니즘 없는 boundary/ranking/gate-reweight 변형 실행 중단"을 명시. 잔존 OASIS miss = **4세션/4명**(시각 audit 완료).

## 리스크 (상세: `risks.md`)

⚠️ **git 부재**(오늘 422개 run 포함 전부 안전망 0) · **OASIS recall 비대칭**(3D < 2.5D, 정직한 주장은 ranking+calibrated bacc) ·
**진단 과대주장 가드레일**(0.91 bar 아래) · **front-door 문서 stale**(README·STUDY_DECISION·configs/active가 죽은 2.5D-MAE-SSL 프레이밍 광고 — `reports/`와 최신 run만 신뢰).
