# minyoungi — 감시 카드

_갱신: 2026-06-02 (커밋 2bfa860)_

## 역할: 지원 워크스페이스 (실험 본진 아님)

`/home/vlm/minyoungi`는 실험 코드 본진이 아니라 **지원 워크스페이스**다. 세 가지 일을 한다.

1. **문헌 triage** — `literature/` (논문 index, notes, PET/MRI background task 정리).
2. **clinical 데이터 이해(교육용 ipynb)** — `Clinical/notebooks/00~04` + `05/06` + 컨소시엄별 EDA(7×3).
3. **ROI QC (Gate05b)** — `roi_qc/` (option_b final-grid ROI 마스크의 numeric+visual QC, voxel-wise supervision의 게이트).

실제 학습/평가 실험은 `/home/vlm/minyoung2`, `/home/vlm/minyoung4`에서 한다 (README/AGENTS.md 명시). ✅
단, 이 워크스페이스 안에도 `experiments/voxelwise_feature_learning_v1`이 존재하며 Gate04~05 진단 실험 산출물이 쌓여 있다 — README의 "실험 코드는 두지 않는다" 원칙과 현실이 부분적으로 어긋남. 🟡

## 현재 활동 (2026-05-28 ~ 06-02)

- **Gate05b ROI/structured-language supervision 설계 + NACC 실패 audit** (최근 커밋 흐름 전부). 🟡
  - b1(global ROI-cos)이 ADNI/KDRC는 개선하나 **NACC는 회귀** → 라벨 `image-baseline-partial-pass with NACC regression`. ❌(representation-readiness-pass 아님, vlm-scaling-ready 아님)
  - NACC 실패를 per-target ROI 수준까지 분해: lateral_ventricle/amygdala/thalamus의 std·q75 타깃이 b1에서 alignment 손상.
- **clinical 데이터 이해** — 노트북 00~06 검증·수정, CDR Global을 7-컨소시엄 공통 타깃으로 채택(안전장치 조건부), ComBat로 site 편향 제거 실증.
- **ROI QC 전수 완료(2026-06-01)** — 13,022건 auto-QC: 12,932 PASS / 46 FLAG. 단 `roi_final_ready`는 **전부 False (fail-closed)**.

## 다음 게이트

1. ROI `roi_final_ready=True` 승급 — numeric ∧ visual PASS ∧ **사람 sign-off** 필요. 아직 미충족. 🟡
2. NACC: b2(`b2_region_prompt_phrase_contrastive`) 전에 per-target 모니터링 의무화. global row-text alignment 금지.
3. leave-one-consortium-out로 CDR AUC 0.9가 site 누수인지 폭로 (random split은 site 누수).

## 한 줄 리스크

내가 써온 ROI 데이터는 공식적으로 `BLOCKED_PROVISIONAL`이고 사람 시각 승인 전이라, ROI 기반 모든 정량 결론은 "검증됨"이 아니라 "후보(provisional)"로 강등해야 한다. ❌
