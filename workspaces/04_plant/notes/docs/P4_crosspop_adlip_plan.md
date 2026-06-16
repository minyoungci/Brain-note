# P4 PLAN — 서양 vs Korean cross-population AD 모델 비교 (Path B / ADLIP式 fusion)

> 설계서(코드 전 합의). 2026-06-16. **전략 결정: Path B(venue 임팩트).** P3(Path A decidability)를 대체 —
> decomposition 도구는 본 설계의 *해석가능성 엔진*으로 흡수. 근거: 사용자 전략 결정 + 자산 인벤토리(parquet 직접) + ADLIP(Lin 2025) 레퍼런스 분석 + `insight/failure_root_causes.md`(4-사인).

## 0. 목표 / claim
**서양(ADNI+OASIS) vs Korean(AJU+KDRC) 인구 간, vision-language AD 진단모델(ADLIP式)이 일반화되는가 — 차이가
난다면 그것이 인구/생물학 차이인가 acquisition(스캐너/라벨) artifact인가를 분해한다.**
- task = **CN vs impaired(MCI+AD) 이진**(AD 단독은 얇음 128/그룹 → 이진이 안정).
- claim 종류 = cross-population generalization / health-equity (high-impact venue가 보상). 성능 SOTA 아님.
- 예상 결과(전이 저조·gap 일부 비가역)도 형평성 cautionary로 publishable.

## 1. 데이터 (검증 자산, parquet 직접 2026-06-16)
- **서양** = ADNI+OASIS: n=2,298, CN 1378 / impaired 920. core4(age/sex/mmse/apoe) 88%. amyloid 22%(OASIS만). age median 71, F 56%.
- **Korean** = AJU+KDRC: n=1,910, CN 307 / impaired 1603. core4 90%. amyloid 100%. age median 73, F 60%.
- **매칭(cross-population 비교 위해):** 그룹당 CN 307 / impaired 920 (age·sex stratified 매칭). 입력=T1w + 구조화 clinical.
- 제외: AIBL(APOE 0%), NACC(MMSE 16%) — fusion 불가. A4(preclinical, AD 0) — 보조 옵션만.
- 입력 누수 금지: subject-level split. CDR은 라벨 정의에만(입력 금지).

## 2. 방법 (ADLIP式 + 변형)
- **vision:** 3D CNN(DenseNet121 등) on T1w(FastSurfer skull-strip 기존 텐서). B200 torch.compile 필수(T9).
- **clinical:** 구조화 feature {age, sex, MMSE, APOE} (공통, core4) + {education, cdrsb}(있는 코호트). 결측 10~12%는 명시 imputation/mask.
- **fusion:** CLIP式 contrastive(InfoNCE) vision↔clinical 정렬(ADLIP 재현 base).
- **변형/hook(=desk-reject 회피의 핵심, "데이터만 추가" 아님):**
  1. **cross-population 매칭 비교 설계**(pooled 아님) + 양방향 transfer.
  2. **transfer gap의 acquisition/population 분해**(아래 §3) — 우리 고유 도구.
  3. **East-Asian(Korean)** 축(ADLIP은 백인/흑인 미국 내뿐).
  4. (보조) amyloid-aware auxiliary — **Korean 내부만**(amyloid 비대칭이라 대칭축 불가).

## 3. 비교 설계 (★ 해석가능성 엔진 — 없으면 reject)
1. **within-population:** 서양-train→서양-test, Korean-train→Korean-test (각 그룹 내 성능·feature 중요도).
2. **cross-population transfer:** 서양→Korean, Korean→서양 (zero-shot AUROC 하락폭).
3. **★ gap 분해:** transfer 하락을 **(a) BN-adapt(inductive, target-pop unlabeled K)로 회복되는 분 = acquisition shift** vs **(b) 회복 안 되는 잔여 = population/biology** 로 분해. → "서양≠Korean"을 *인구차 vs artifact*로 귀속(매칭이 dx/age/sex만 통제하므로 이 분해가 필수).
- 매칭은 dx/age/sex 통제. 스캐너/라벨(AJU CDR정적·amyloid 측정법)은 분해로만 해석.

## 4. 평가
- subject-level split, **multi-seed ≥3**, bootstrap CI. discrimination=**AUROC**(불균형 CN 307/impaired 920 → class-weight, bACC 고정임계 금지 T11).
- **baseline 동반(정직·reviewer 방어):** clinical-only(age/APOE/MMSE) + **morphometry(fs_vol)+clinical**. fusion이 이들 위에 더하는지 분해 보고(헤드라인은 cross-pop 비교지만 morph bar는 둔다).
- transfer 주장=one-sided, "동등"=TOST. 점추정 금지(T4).

## 5. KILL-CRITERIA (숫자)
- **NO-GO 1(해석불가):** transfer gap 분해에서 acquisition/population 귀속이 안 되면(BN-adapt 회복분 추정 불안정, seed sd>0.05) → "서양≠Korean" 주장 금지, 진단 먼저.
- **NO-GO 2(누수):** within-population AUROC가 cross보다 비현실적으로 높고 site-probe 높으면(R3/T1) → split 재점검.
- **NO-GO 3(fusion 무의미):** fusion이 morph+clinical baseline 대비 CI 겹침(증분 0) → "fusion이 더한다" 주장 삭제, 비교/형평성으로만 포지셔닝(여전히 publishable).
- **NO-GO 4(반복):** 같은 arm 3회 NO-GO → 폐기(T8).

## 6. 스테이징
1. **[CPU]** 매칭셋 구성(CN 307/impaired 920/그룹, age·sex stratified) + clinical feature 결측 처리 확정.
2. **[GPU 승인]** ADLIP式 base 재현(서양·Korean 각 within-population).
3. **[GPU]** cross-population transfer 양방향 + BN-adapt 분해.
4. **[CPU]** baseline(clinical / morph+clinical) 대비 분해 + CI/TOST.
- Stage 진입 전 git 체크포인트. GPU=별도 승인. 실패·교훈 `insight/` 누적.

## 7. OPEN ITEMS / 리스크
- [x] **Stage-1 발견 (2026-06-16): MMSE 인구-비등가.** age·sex·CDR단계 매칭 후에도 Korean MMSE가 체계적으로 낮음
  (Δ CN +1.1 / MCI +2.4 / AD +4.7). 문화·언어·교육 의존(education은 통제 불가, 대부분 결측). → **결정:** 1차 fusion
  feature = culture-invariant{APOE, age, sex, 영상}; **MMSE/education은 feature 강제 금지, 비등가를 *발견/민감도 축*으로
  보고**(equity 기여로 전환). CDR은 라벨 유지(MMSE보다 문화-강건). 매칭셋=`data/derived/P4/matched_cohort.csv`(CN302/MCI717/AD124/그룹).
- [ ] clinical 결측(APOE 서양 impaired 14%) imputation(mode+indicator, 이미 산출물에 반영) 적정성.
- [ ] amyloid 비대칭(서양 22%) → 대칭 비교축 불가, Korean 내부 auxiliary로만(확정).
- [ ] Korean 종단 약함(AJU CDR정적·KDRC 단면) → progression 불가, cross-sectional만(확정).
- [ ] AD 128/그룹 얇음 → 이진(CN-vs-impaired)으로 회피(확정). AD 세부는 보조 분석.
- [ ] 잔여 confound(스캐너·라벨 측정법) → §3 분해로만 해석 가능, 분해 실패 시 NO-GO 1.
- [ ] dataset redistribution(Korean 공개 가능 여부) — benchmark/equity claim [VERIFY].
- [ ] novelty 방어: "ADLIP+데이터" 아닌 "cross-pop 매칭+분해+East-Asian"이 hook임을 positioning에 명시.
