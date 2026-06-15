# SCRATCHPAD — VLM brain report (3D MRI → radiology report)

## 현재 상태 (2026-06-15)
**Stage 1 (eTIV + pseudo-label report 생성) 완료 + 독립검증 통과.** Stage 2(VLM) 미착수.

## 완료 항목
1. **eTIV 배치** (`00_etiv_batch/`): orig.mgz(full-head) → MNI152 12-dof FLIRT affine → eTIV ∝ 1/det.
   - 성공 6869/7231 subject. 실패 362(AJU 180/KDRC 175/NACC 7) = `excluded_subjects.csv`로 **연구 배제**
     (사유 = FLIRT 1mm timeout; 2mm 복구 가능하나 미수행). 결과 = `etiv_full_merged.csv`(det/inv_det/eTIV_mm3).
   - 설계 근거: eTIV는 **division 아니라 회귀 공변량**(Voevodskaya 2014, atrophy 상쇄 방지). subject당 상수 → 다세션 broadcast(의도).
2. **Report 생성** (`01_reports/generate_reports.py` → `reports.jsonl` 12,590건):
   - CN-internal normative w-score = (obs − CN예측)/CN잔차SD, 모델 `vol ~ age+sex+inv_det+cohort`.
   - 등급 band = **명명 z-임계 앵커**(OpenAlex 검증): 정상≥10th / mild 2.5–10th / moderate 0.5–2.5th(2.5th=z−1.96) / severe <0.5th(z−2.58).
     근거: Nobis 2019(AD<5th·MCI 5–25th) 경험 재현 + La Joie 2012 w-score + Voevodskaya 2014(ICV 공변량). 레퍼런스 표 = RESEARCH_PLAN §6.
   - **image-grounded only**(morphometry/ventricles/WMH). amyloid/dx/APOE 제외(hallucination 방지).
   - phrasing 20+ 변형/카테고리 + section-summary/intro/opener 다양화 → **dup_ratio 0.0**(전 12,590 고유).

## 독립검증 (생성≠검증, CLAUDE.md 준수)
codex(read-only audit) + 직접 재검(codex sandbox 차단분):
- Faithfulness 0모순(151,080 라벨) / Modality WMH=Fazekas만(590/590) / Grading 로직 PASS — **codex**
- dup 0.0 / split 누수 0(subject-wise) / dx gradient **CN 9.9% < MCI 27.3% < AD 65.7%** 단조 — **직접**
- codex 지적 결함 3건 → 수정 완료:
  1. norm fit-before-split 누수 → **train CN만 적합**(7563→5344).
  2. min_count=1 부분 ROI 합 → **전 구성요소 있을 때만**(수정 후 12/12 구조 유지, 손실 0).
  3. session eTIV collapse → **의도된 설계**(eTIV subject당 상수), 결함 아님.
- CN 위축률 ~10% = 설계대로(10th band) → norming calibrated 확인.

## 데이터 산출물 경로
- `00_etiv_batch/etiv_full_merged.csv` (6869 ok), `excluded_subjects.csv` (362)
- `01_reports/reports.jsonl` (12,590), `reports_stats.json`
- by_cohort: ADNI 4699 / NACC 1859 / A4 1811 / OASIS 1420 / AJU 1107 / AIBL 987 / KDRC 707

## 남은 작업 (Stage 2 — 미착수)
- 3D encoder(MONAI, FS-volume-regression grounded) + projector + LLM backbone(Qwen3-32B Apache-2.0 / MedGemma-27B-it).
- 평가: content-fidelity + **no-image baseline(acid test)** — 이미지 없이 같은 점수면 텍스트 prior 암기.
- (선택) 362 Korean eTIV 2mm 복구.

## 비-목표
- 범주형 CN/AD·amyloid-status 영상 예측 = 측정 천장(닫힘). report 생성은 distillation 타깃이지 예측이 아님.
