# minyoungi — 리스크

_갱신: 2026-06-02 (커밋 2bfa860)_

범례: ✅확정 / 🟡잠정 / [VERIFY]추측

---

## R1. ROI 데이터가 공식적으로 BLOCKED_PROVISIONAL이다 (최상위) ✅

- **왜 문제**: minyoungi의 clinical 노트북(03/05/06)과 컨소시엄별 EDA, 그리고 Gate05b의 ROI 타깃·ROI text까지 전부 option_b final-grid ROI에 의존한다. 그 ROI는 manifest 플래그상 `roi_final_grid_qc_status=BLOCKED_PROVISIONAL`, `roi_final_ready=False`, `do_not_use_for_atlaswide_roi_features=True`다. FastSurfer→native transfer가 ROI별 시각 승인을 요구하는데 그게 안 끝났다. → ROI 기반 모든 정량 결론(해마 AUC 0.865, CDR↔ROI Spearman, ComBat 보존성)은 "검증됨"이 아니라 "후보(provisional)"다.
- **어떻게 확인**:
  - `roi_qc/manifest_roi_qc_final.parquet`의 `roi_final_ready` 컬럼이 전 행 False인지.
  - `roi_qc/ROI_USABLE_REPORT.md`의 3-게이트 표에서 Gate3(vision QC)가 "NOT done at scale"인지.
  - 정량 주장 전 `_reports/roi_transfer_option_b_*`의 per-ROI overlap/volerr/status로 QC 게이트 통과 여부.
- **완화**: representation-learning/pretraining(가끔의 ROI 노이즈 허용)에는 USABLE_AUTO 12,932건을 today 학습 풀로 쓸 수 있음. **anatomically-correct ROI를 요구하는 biomarker claim에는 사용 불가** — Gate3 사람 sign-off 후에만 `roi_final_ready=True`.

## R2. 노트북 재현성 — "생성 ≠ 검증" ✅

- **왜 문제**: 목표와 구조가 1:1로 맞는 노트북 5개(00~04) 중 **4개가 현재 데이터에서 깨져 있었다**. sex 컬럼 정수/문자 혼합(parquet 직렬화 실패), FastSurfer 경로 `<subject_id>` 레벨 누락, ROI 명명 오류, VINN eTIV 부재. 구조가 맞다고 돌아가는 게 아니다. 노트북을 "정렬돼 있으니 정상"으로 신뢰하면 깨진 분석 위에 결론을 쌓는다.
- **어떻게 확인**: 노트북은 반드시 **헤드리스 실행**으로 통과 여부를 검증 (`Clinical/notebooks/00~06`, 컨소시엄 21개). 자기 생성 결과를 스스로 "완료"로 판단 금지 — 생성과 검증을 분리.
- **완화**: 현재 00~06 + 컨소시엄 21개는 헤드리스 통과 보고됨. 🟡 (단 통과 = 실행 가능일 뿐 결론 정확성 아님; ROI는 여전히 R1).

## R3. "결측"으로 보이는 것의 1차 용의자는 데이터가 아니라 join/normalize 버그 ✅

- **왜 문제**: "FastSurfer stats 39% 결측"이 실제로는 ADNI 세션 경로의 `.0` 절단(정규화 버그)이었고, 전수 검증 시 100% 존재였다. 데이터 신뢰도를 잘못 깎으면 멀쩡한 코호트를 버리거나 잘못된 imputation을 한다.
- **어떻게 확인**: 결측·이상 비율 보고 전 (a) 전수(샘플 아님)로 재계산, (b) 경로/키 join이 코호트별로 깨지지 않는지 코호트별 커버리지 분해, (c) 경로는 `session_id` 재구성 대신 `final_tensor_path`에서 유도.
- **완화**: 사용자의 "정말 그게 맞아?" 패턴을 기본 절차로. 단일 숫자 보고 전 전수 교차검증.

## R4. NACC 회귀가 미해결인 채로 b2/VLM 확장 위험 ✅

- **왜 문제**: b1(global ROI-cos)이 ADNI/KDRC는 올리지만 NACC는 frozen AUC −0.0442, AD ROI cosine 음수 전환. ROI-cos/CE sweep으로 회복 안 됨. 이걸 "primary 평균만" 헤드라인으로 보고하면 실패 모드가 가려지고, global row-text alignment를 쓰는 b2가 같은 NACC AD 손실을 재생산한다.
- **어떻게 확인**: 모든 Gate05b 리포트가 (a) primary 평균 + (b) **NACC 별도 블록** + (c) fold별 Baseline06 대비 + (d) 명시적 pass/fail 라벨을 포함하는지. "모든 코호트 평균"만 단독 헤드라인이면 위반.
- **완화**: 라벨을 `image-baseline-partial-pass with NACC regression`으로 고정. b2는 per-target(lateral_ventricle/amygdala/thalamus std·q75) 모니터링 의무, global row-text alignment 금지.

## R5. site/scanner shortcut + 누수 평가 위험 ✅/🟡

- **왜 문제**: site 누수가 강도/대비(스캐너) 차원에 있고, random split CDR AUC 0.9는 site 누수를 포함할 수 있다. v2는 N4 미적용. N4는 스캐너 bias를 절반만 줄인다(chance 미달, 단일벤더 AJU는 오히려 악화).
- **어떻게 확인**: CDR/진단 AUC 주장은 **leave-one-consortium-out**으로 재평가해 site shortcut을 폭로. ComBat 등 harmonization은 누수 없는 train-fit→test-apply 프로토콜로만 평가. consortium은 거친 site 단위라 스캐너 내부 효과는 미모델링임을 명시.
- **완화**: site probe(APPEARANCE 0.565 vs biology≈chance)로 누수 차원 진단. N4는 후보지만 단일 해법 아님.

## R6. Vision QC subtle error 미정량 + 사람 sign-off 미완 🟡

- **왜 문제**: auto-QC PASS는 numeric+geometry 자기일관성일 뿐 FastSurfer 원본 분할 오류는 못 잡는다(Gate2 PASS ⇏ Gate3 PASS). PASS 표본 21개 사람 검토는 gross 0/21이지만 montage 해상도로는 few-mm boundary error를 못 잡는다. REVIEW_REQUIRED 11 + ROI_UNUSABLE 5는 사람 최종 확인 대기.
- **어떻게 확인**: 더 큰 표본의 사람 κ-rating(`VISUAL_QC_CRITERIA.md` 프로토콜). REVIEW/UNUSABLE 16건 사람 sign-off.
- **완화**: fail-closed 정책 유지(`roi_final_ready=False`). 사람 승인 전 `=True` 금지.

## R7. 워크스페이스 역할 경계 침식 🟡

- **왜 문제**: README/AGENTS.md는 "실험 코드는 minyoung2/minyoung4에서, 여기는 지원(문헌/clinical/QC)"이라 명시하나, 실제로 `experiments/voxelwise_feature_learning_v1`에 Gate04~05 GPU 진단 실험이 쌓여 있다. 역할 경계가 흐려지면 어느 워크스페이스가 source of truth인지 모호해진다.
- **어떻게 확인**: `experiments/`의 GPU 산출물이 minyoung2/4와 중복/분기되는지, VALIDATION_LOG의 Official note 경로(`/home/vlm/minyoung/Official/sky/`)가 일관 동기화되는지.
- **완화**: [VERIFY] 실험 본진과의 분담 규칙을 Min이 명시. 현재는 진단/audit 성격(eval-only, no training claim)이라 경계 위반은 경미.
