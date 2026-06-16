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

## Stage 1.5 — LLM 번역(findings→자연어) + 검증 (`02_llm_translate/`, 완료)
2층 구조 확정: (A)문헌-grounded findings[규칙] → (B)Medical LLM 번역 → (C)fidelity 게이트.
- **번역**: Qwen3-32B vs MedGemma-27B-it 각 12,590건 생성(constrained 프롬프트: findings만, 진단/추가소견 금지).
  MedGemma-it는 멀티모달(Gemma3) → AutoModelForImageTextToText로 텍스트전용 생성.
- **게이트**(`fidelity_gate.py`): 뇌 morphometry 전용 rule-based 추출기(RadGraph/CheXbert는 CXR라 비전이).
  세그먼트+공유severity 상속. 검증: 템플릿 self-test 100% / 적대적 6/6.
- **codex 독립검증**(생성≠검증): MedGemma가 PASS-라벨 결함 0·임상누출 0 → **keeper=MedGemma**.
  (Qwen은 'consistent with' 임상해석 누출 161건 → 탈락.)
- **boilerplate 수정**: 정상(all-normal, dict 1종→collapse) tag별 변주+temp0.9 재생성 → dup 0.54→0.47, 누출 0.
  최종 게이트 PASS **99.98%**. ⚠️ 정상 dup 0.67 잔존(저엔트로피 task 본질) → 나머지는 **학습-side**(클래스밸런싱+인코더 grounding)로.
- 산출: `medgemma_27b_reports.jsonl`(keeper), `qwen3_32b_reports.jsonl`(비교), `comparison_summary.json`.

## Stage 2 G0 probe — distillation feasibility (`03_g0_probe/`, 측정 완료 2026-06-16)
research-critic 함정 F1("라벨=morphometry 결정론 함수 → 이미지 기여 0?")을 *측정*으로 판정.
- 방법: image(96³ half-res) → DenseNet121(3D) → 12 w-score 회귀. memmap 병렬 캐싱(gpfs 경합 회피).
- **결과: 이미지가 morphometry를 강하게 재현** — w-corr MTL 0.776 / 측뇌실 0.937 / 전체 0.66~0.94.
  - **[G2 acid] PASS**: img grade-bAcc 0.487 vs no-image 0.25 (Δ+0.237) → 이미지를 진짜 읽음.
  - **[G1] grade-bAcc>0.6 소프트FAIL** (0.487): 극단 꼬리 binning + balanced-acc 가혹 탓, 연속신호는 강함(바닥 probe).
- **판정**: distillation VLM viable(이미지 기여 실재). 단 "morphometry 너머"는 라벨상 측정 불가 = 천장 그대로.
  → 정체성 = "FastSurfer를 single forward-pass로 증류 + grounding", *not* "이미지가 morphometry보다 잘 봄".
- 사용자 결정(2026-06-16): **VLM 구축(distillation 프레임) 진행**.

## Stage 2 VLM 빌드 (착수) — 설계 `02b_vlm/DESIGN.md`
⚠️ ROI-token 전제: FastSurfer seg(`aparc.DKTatlas+aseg.deep.mgz`, 256³ conformed) ≠ 학습이미지(192×224×192 RAS) → ROI 마스크 resample 필요(Phase 2 비용).
- **Phase 1(v1)**: 3D encoder(G0 재사용) + global-token projector + **frozen MedGemma-27B** + w-score aux 손실(grounding). 파이프라인 검증 + **G3**(LLM이 룰베이스 baseline 이기나) 판정.
- **Phase 2(v2, novelty)**: seg mask-pooling per-ROI **continuous token**(morphometry signature 주입). v1의 G3 정당화 시에만.
- 평가: content-fidelity(게이트) + acid test + **counterfactual(이미지 ROI perturbation)** + cross-cohort. 모니터링: 손실/aux/val-fidelity 실시간 로깅.

## 남은 작업 (Stage 2 — 빌드중)
- 3D encoder(MONAI, FS-volume-regression grounded) + projector + LLM backbone(MedGemma-27B-it keeper).
- **boilerplate 암기 방지(학습-side)**: ①인코더 grounding loss(이미지 강제 read) ②정상:이상 클래스 밸런싱 ③no-image acid test로 검증.
- 평가: content-fidelity + **no-image baseline(acid test)** — 이미지 없이 같은 점수면 텍스트 prior 암기.
- (선택) 362 Korean eTIV 2mm 복구.

## 비-목표
- 범주형 CN/AD·amyloid-status 영상 예측 = 측정 천장(닫힘). report 생성은 distillation 타깃이지 예측이 아님.
