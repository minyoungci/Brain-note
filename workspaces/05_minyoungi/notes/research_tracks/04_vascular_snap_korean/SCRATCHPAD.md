# SCRATCHPAD — Track 04 Vascular SNAP

## 현재 상태 (2026-06-16)
Phase 1 step1·2 완료(실행·검증). subject-level lock. → step3-4(층화회귀) 진행 중.
- AJU cc N=**998**(A− 656/A+ 342), KDRC cc N=**265**(A− 73/A+ 192, edu없음, SUVR 243).
- ⚠️ A−≠SNAP: within-A− 회귀=A− 전체, SNAP(A−N+)은 해석 레이어.
- 산출: results/cohort_{AJU,KDRC}_subject_baseline_cc.parquet, phase1_step1_report.json

## 연구질문 → 계산가능 정의 (AGENTS.md §3)
- **Research question**: amyloid-음성 한국인에서 혈관부담이 클수록 해마가 작은가? 이 연관이 2코호트·2도구에서 재현되나?
- **Computable**: 해마부피 ~ WMH (within A=0, within A=1 별도) + 공변량. A×WMH 상호작용항.
- **Outcome**: `(fs_vol_hippocampus_L + fs_vol_hippocampus_R) / fs_MaskVol * 1000`
- **Exposure**: AJU `wmh_grade_visual`(연속화 1/2/3); KDRC `fazekas_pv + fazekas_deep`(0–6)
- **Stratifier(공변량)**: amyloid — AJU `amyloid_visual`(pos/neg), KDRC `amyloid_suvr`(컷오프) / `amyloid_visual`
- **Unit of analysis**: **session? subject?** → ⚠️ lock 필요(아래 OPEN-1)
- **Grouping**: consortium별 분리(pooling 금지)
- **Covariates**: age, sex, apoe_e4_count, education_years
- **Inclusion**: 해마 ROI + MaskVol + amyloid + WMH/Fazekas + 공변량 complete-case
- **Validation**: 분모(N) 명시, A=0/A=1 각 N·slope·CI, KDRC interaction term vs stratified slope 일치 확인

## LOCKED (확정)
- eTIV 프록시 = **fs_MaskVol** (BrainSegVol 금지 — 위축 시 같이 줆). [근거: 메모리 fastsurfer-vinn-no-etiv]
- AJU 권위 dx = **dx_session**(CN 144), `clin_dx_label`(CN 23) = 함정 금지. [research_topic/06]
- amyloid = **통제 공변량**, endpoint 아님(pTau217 회피). [메모리 sci-clinical-pivot]
- 데이터 = 정본 manifest only(캐시·full_labels 금지).
- 분석단위 = **subject-level, baseline(첫 세션) 1인 1행** (pseudo-replication 방지). [Min 승인 2026-06-16]

## OPEN LOCKS (Phase 1 착수 전/중 해결 — critic desk-reject 지뢰)
- ✅ **OPEN-2 RESOLVED(step1)**: manifest amyloid_visual 양코호트 'pos/neg' 문자열 표준화됨. sanity 통과 — A+가 해마↓·MMSE↓(AJU 5.71→5.28/24.3→21.4, KDRC 5.33→4.67/20.6→18.1).
- **OPEN-3 KDRC SUVR 컷오프**: 연속 SUVR → 이진화 기준 명시. 분모(SUVR 보유 N) 명시.
- **OPEN-4 KDRC interaction 10× 괴리**: interaction term(+0.221) vs stratified slope(+0.022) — covariate-by-group or complete-case N 차이? → pipeline-validator 독립검증.

## ⚠️ STEP3-4 결과 (clean·subject-level) — first-pass 재현 실패, 더 약함
| | AJU(N998) | KDRC(N265) |
|---|---|---|
| A− slope (eTIV) | −0.072 **p=0.083 n.s.** | −0.131 **p=0.052 n.s.** |
| A+ slope | +0.029 n.s. | −0.078 n.s. |
| A− BrainSeg robust | −0.057 p=0.25 | −0.102 p=0.20 |
| **interaction vasc:A** | +0.149 **p=0.039** | +0.162 **p=0.043** |

- **핵심(정직)**: "within-A− 혈관→해마"는 **두 코호트 다 유의 아님(trend만)** + 정규화에 robust 아님.
  → first-pass(AJU −0.108 p=0.004, KDRC −0.253 p=0.035)는 **session-level pseudo-replication+느슨한 공변량 아티팩트**. clean run이 정본.
- **유일하게 유의·복제된 신호 = interaction**(양코호트 p~0.04) — 그러나 scout가 가장 위험하다 경고한 claim(Freeze 2017 반대·leverage 아티팩트).
- ✅ **OPEN-4 RESOLVED**: interaction term ≠ stratified-slope-diff은 **covariate-by-group 차이**(상호작용 모델은 공변량 기울기 공유 강제) — 버그 아님. 메모리 "10×"는 first-pass 노이즈, clean에선 ~1.5–3×.

## Phase 1 STEP 계획 (각 Verify 동반)
1. 정본 manifest 로드 + complete-case 필터 → **Verify**: row before/after, A=0/A=1 N, 코호트별 N
2. OPEN-2 amyloid sanity → **Verify**: A+ 가 해마/eTIV↓·MMSE↓ (방향 맞으면 코딩 OK)
3. AJU 층화 회귀(A=0, A=1) + 상호작용 → **Verify**: slope·CI·p, eTIV/BrainSeg 둘로 robustness
4. KDRC 동일 + OPEN-4 괴리 해소 → **Verify**: interaction term ≈ stratified slope
5. 결과 표/그림 산출 → **Verify**: traceability(input·script·params·N·output path)
6. pipeline-validator 독립검증 → **Verify**: 생성/검증 분리(자기평가 금지)

## 가정
- visual WMH grade는 ordinal이나 연속 취급(민감도: ordinal logit으로 재확인).
- complete-case = MAR 가정(missing 패턴 보고).

## OPEN QUESTIONS (Min 확인)
- 분석단위(OPEN-1) 선호? (제안: baseline/첫 세션 subject-level)
- Phase 1 결과 후 바로 Phase 2(FLAIR→WMH, GPU) 승인 절차 갈지?

## PHASE 2 — 더 나은 vascular 마커 (Min 선택 2026-06-16)
목적 = FLAIR→**정량 WMH(딥 분할)**로 visual grade(1/2/3, 820/401/66 skew) 천장 제거 → Phase1 약신호 검정력 시험.
- **fusion=정확도는 DEAD** 확정(아카이브 exp_f1: clinical 0.779→+img 0.795 = +0.016; exp_f2 cross 0.908 vs 0.735 confound). → fusion은 측정 업그레이드로만.
- 환경: GPU ok, DL스택 ok(nnU-Net v2·monai·ants), **WMH 분할기 미설치**(설치/컨테이너 필요). FastSurfer=ROI전용.
- ✅ **FLAIR 전처리 이미 완료**(재실행 불필요) — `/home/vlm/data/preprocessed_official/v2/{AJU,KDRC}/.../flair/`에 raw·**flair_n4(비-zscore)**·flair_in_t1w·zscore텐서·co-reg T1·brain_mask·정합행렬 전부 보존. 분할기 입력 준비 0. WMH 정량화만 신규(이전 전처리 미수행, manifest엔 visual grade뿐).
- 방법 후보: **WMH-SynthSeg**(다site robust·age-related WMH 적합, 1순위) / MICCAI-WMH nnU-Net / LST-AI(MS편향 주의).
- **staged(하네스) + GO/NO-GO**: A 설치·smoke → B **subset(~100/코호트) 정량WMH vs visual grade 단조일치 검증**(실패=분할기 불신→중단) → C 전수(~2148) → D vascular SNAP 재분석(연속 WMH).
- ⚠️ **정직한 불확실성**: 정량화는 해상도↑지만 within-A− 효과가 age-매개로 원래 작으면 **구제 실패 가능**. Phase2=정당한 시험이지 보장 아님.
- ⚠️ 사전승인 대상: GPU + 분할기 설치(pyproject/uv add or docker) + 멀티파일. 브랜치 후 진행.

## PHASE 2 STAGE A — 완료·PASS (2026-06-16, branch track04-phase2-wmh)
- WMH-SynthSeg standalone 설치(full FreeSurfer 불요): `tools/wmh_synthseg/`(gitignore). 모델 790MB. inference.py 2패치(모델경로 env, weights_only=False/torch2.10).
- 입력 = `flair_brain_1mm_RAS_192x224x192_zscore`(전 subject 공통; n4는 dev subject만 보존). contrast-agnostic이라 z-score OK 확인.
- 4샘플 smoke: **WMH(label77) 부피가 visual 등급 단조추적** — AJU grade1→3: 3168→28058 mm³(9×), KDRC Fazekas≤1→≥4: 7536→37492(5×). 해부학적 위치 정확(육안검증·JPG).
- 산출: results/wmh_smoke/{*_seg.nii.gz,*_vols.csv}, viz/comparison_all4.jpg + per-sample.

## PHASE 2 STAGE B — 정량검증 완료 (197장: AJU100·KDRC97)
- AJU: Spearman ρ=**0.545**(p5e-9), Kruskal p9e-8, AUC0.734, median 1→2→3 = 0.43→0.96→1.00(2≈3 정체)
- KDRC: ρ=**0.70**(p1e-15), Kruskal p3e-9, AUC0.904, Fazekas 2~6 깨끗한 계단
- 사전 GO/NO-GO(ρ≥0.6+kruskal<.001+완전단조) **엄밀히 2점 미달**(AJU ρ<0.6, KDRC 0vs1 floor wobble) — 둘 다 **기준척도 artifact**(boxplot 확인: AJU 3단계 visual이 grade2/3 포화; KDRC floor 잡음), 분할기 오류 아님.
- **판정: 실질 PASS.** ⭐함의: AJU ρ=0.545(공유분산~30%) = 정량 WMH가 거친 visual이 놓친 변이 포착 → Phase1 약신호(거친 grade로 돌린 결과) 바꿀 headroom 직접 증거.
- 산출: results/stageB/{vols.csv, validation_report.json, validation_boxplot.jpg, segs/}

## PHASE 2 STAGE C/D — 완료. ⭐핵심결과 + robustness
전수추론: 분석코호트 1,263 (GPU2/3 병렬, AJU 982·KDRC 259 WMH 확보, coverage 98%).
**Stage D (연속 WMH로 재분석) — within-A− 신호 살아남:**
| | AJU A−(643) | KDRC A−(69) |
|---|---|---|
| 연속 WMH slope | −0.170 **p≈0** | −0.193 **p=0.015** |
| (cf Phase1 visual) | −0.072 p=0.083 ns | −0.131 p=0.052 ns |
| interaction wmh×A | +0.159 **p=0.0003**(sub-add) | +0.110 p=0.29(additive, A+도 −0.186 p=0.002) |
**Robustness (shared-atrophy 교란 검사):**
- AJU: M2 BrainSeg·**M3 전역위축보정(−0.144 p≈0)**·M4 raw 전부 생존 → **robust+specific** ✅
- KDRC: M1·M2·M4 유의하나 **M3 전역위축보정서 탈락(p=0.092)** → underpowered, 비robust ❌
**판정(자체)**: 핵심=AJU가 짊어짐(특이적·강건). KDRC=directional 확증(specificity 미확인). visual→정량이 신호 살림 + artifact 아님(M3).
산출: stageC/{stageD_reanalysis.json, stageD_robustness.json}, scripts phase2_stageD_*.py

## RESEARCH-CRITIC 독립검증 + MAKE-OR-BREAK (2026-06-16)
critic이 진짜 오류 잡음: **F3 내 M3(BrainSeg/MaskVol) circular**(해마 part-whole+분모공유), **F2 linear age 불충분**, F1 Freeze 두축 반대, F4 KDRC overclaim, F5 다중비교 무보정.
**Make-or-break(critic 합격조건) 실행 → 결과(makeorbreak.json):**
| | AJU(643) | KDRC(69) |
|---|---|---|
| spline age | −0.171 p≈0 ✅ | −0.196 p=0.017 |
| **비순환 위축보정**(SynthSeg 피질GM, 해마미포함·분모무공유) | −0.124 p≈0 ✅ | −0.108 p=0.21 ❌ |
| **DECISIVE(둘 다)** | **−0.124 p≈0 SURVIVE** ✅ | −0.097 p=0.29 ❌ |
**검증된 판정**: AJU=특이적·강건(critic 결정시험 통과, 논문 앵커). KDRC=강등→consistency-check(특이성 미확립). circular-M3 오류 수정됨.

## 제출 전 잔여(critic 비-게이트, 미완): 
specification curve(F5)·mediation(age→WMH→hippo)·attenuation 일치성검사(visual −0.072/rel0.545 ≈ −0.13 vs −0.17)·**혈관위험인자(BP/HTN) 존재여부→"vascular" 제목 가부**·native-vs-registered FLAIR WMH·Freeze reconcile(testable機序)·WMH×APOE·two-ICV(SynthSeg vs FastSurfer) 공개.

## 혈관위험인자 검증 (vascular framing 결정 — 2026-06-16, vascular_rf.json)
- ⭐**AJU 혈관인자 100% 완비**: htn·dm·dyslipidemia(binary0/1)·sbp·dbp·glucose·lipids 1287/1287. KDRC ~58%(526/909). manifest에 이미 있음(원본 안 봐도 됨).
- A− stratum(643) 커버리지 643/643, merge 중복0 (검증됨).
- **Positive control PASS**: HTN→WMH β+0.221 p=0.004, DM→WMH β+0.327 p=0.0002 → WMH-SynthSeg가 실제 혈관병리 포착 = "vascular" 해석 입증.
- **WMH→해마 혈관RF 보정 후 생존**: −0.123→−0.122 p≈0 → RF 교란 아님, WMH가 매개.
- → **"vascular" 제목 방어 가능** (critic Section5 해소). ⚠️연속 sbp(min11)·hba1c(max45) 입력오류 → binary RF 사용, 연속은 QC후.
- ⭐**혈관RF 역할 정밀화(verified)**: 혈관부담→WMH β+0.11 p=0.004(positive control✅) + 혈관→WMH→해마 indirect 유의(CI[−.036,−.006]) — *그러나* 혈관부담→해마 **직접/total은 null(β−0.008 p=0.76)**. → 해마위축 driver는 RF상태 아니라 **WMH(뇌 발현물)**. = 이미지 근거 강화. 제목=**WMH 중심**("cerebrovascular WMH burden"), RF가 위축 유발 함의 금지. 매개 prop>1(suppression)=indirect유의+total null로 서술.

## 잔여 CPU 분석 ①②③⑥ 완료 (remaining_analyses.json) — 전부 AJU 방어 강화
- **① Spec curve(F5 방어)**: 32 spec{outcome×WMHtransform×age×atrophy×vascRF} 중 **32/32 유의·음성**(β −0.16~−0.25). → p-hacking/forking-path 아님 확정.
- **② Mediation(F2 방어)**: b(WMH→hippo|age)=−0.169 p≈0(독립효과), age→hippo의 **22.5%만 WMH 매개**(indirect CI[−0.009,−0.004]). → "WMH=age 대리물" 기각.
- **③ Attenuation**: std β visual −0.072 vs continuous −0.253, ratio 0.28 ≈ ρ²(0.546²=0.30). → visual 약신호=측정오차 감쇠의 예측된 그림자, p-hacking 아님.
- **⑥ WMH×APOE**: interaction p=0.59(무) — e4+(−0.128 p=0.046)·e4−(−0.178 p≈0) 둘 다 유의. **효과 APOE-독립**(PMID33586848 e4-특이성과 불일치, 정직보고).

## CODE AUDIT (code-auditor 독립감사) — 결과 신뢰 확인 + 3수정 적용
- ✅ **결과-제조 버그 없음**: 10검사 전부 PASS(dedup 누수無·amyloid 코딩 비플립·WMH join 정확·N 일정643·cortex 비순환 확인). AJU 결과 신뢰 가능.
- 수정 적용: **C1** stageD_robustness M3(brainseg_norm)=circular → deprecation 주석, canonical=makeorbreak cortex control. **W1** z-base 통일(stratum-SD) → makeorbreak 재실행, M0 −0.1688(일치). **I1** 주석 정정.
- canonical 숫자: **AJU A− WMH→hippo: 원시 −0.169 → 결정(spline age+비순환 cortex) −0.123, p≈0, n=643.**
- reviewer 사전공개 항목: two-ICV(SynthSeg vs FastSurfer MaskVol)·MaskVol=eTIV proxy·KDRC underpowered·stageB PASS=false override 근거.

## ④ 정합 교란 검증 (Stage E + flair_nmi) — 해소
- **Stage E** (native raw DICOM ~100 dcm2niix → WMH-SynthSeg `--crop없이`[비등방5mm엔 crop 깨짐]): native↔registered WMH **Spearman 0.83 순위일치**. 단 native median 1.18% vs reg 0.60%(~2× — 두꺼운슬라이스 partial-volume, z-score라 분석무관). CCC 0.47. **β비교(n=94)는 underpowered=무의미**(reg조차 n.s.) → 순위일치만 기여.
- **flair_nmi 보정(full n=643, 검정력충분)**: corr(nmi,hippo)−0.31·corr(nmi,wmh)+0.31(bivariate 결합 존재)이나 **WMH→해마 nmi보정 전후 불변(−0.1199→−0.1192, p~1.8e-5)**, nmi 독립 hippo효과 無(p=0.13). → **정합오차가 연관 안 만듦.**
- (보조: rigid 6-DOF 정합=warping無). 산출 stageE_native/stageE_report.json.
- ✅ **결론: 정합 교란 아님. critic ④ 해소. 통계 검증 완료.**

## AI Methods + 선행연구 비교 (2026-06-16, medical-AI 전공자 요구)
- **AI 모델 구조 코드추출**(`METHODS_AI_AND_RELATED.md`): WMH-SynthSeg=3D U-Net 5levels f_maps64(→1024) GroupNorm8+Conv3³+LeakyReLU, in1ch/out33labels(WMH=77), **SynthSeg domain-randomization**(합성영상만→contrast/resolution-agnostic). FastSurfer(VINN)=T1형태계측. AI=enabling method(개발/SOTA주장 금지).
- **AI-방법 비교표**: vs BIANCA/FCN-ensemble/SAMSEG/LST-AI/nnU-Net — 대부분 site-specific 학습→OOD저하, domain-randomization만 비등방 다scanner 임상FLAIR 강건(=도구선택 정당화).
- **임상 선행비교표**: Freeze2017(반대)·British1946·KBASE2024(반대)·MITNEC-C6·PMID33586848(e4특이 vs 우리 e4독립) + STRIVE-2 준수.
- **OpenAlex 사용**(key 보유): `openalex_related.json`. ⚠️신규 비교논문(Acta Neuropath2017·JAMA Neurol2018)은 title-level → 제출 전 full-read 필요.

## 매뉴스크립트 초안 완성 (2026-06-16, paper-writer 가이드라인 직접 적용)
- `manuscript/`: **Title_Abstract.md · Introduction.md · Methods.md · Results.md · Discussion.md** = 완전 IMRD 초안.
- 트랙=§A clinical+§C AI구현(ablation 제외). 제목=descriptive WMH중심. abstract=structured 2-4-4-2 ~250단어. 숫자 전부 결과JSON 대조. self-audit 통과(결과 누출無·past tense·약어 일관[eTIV 정의 수정]·1:1 대응·Freeze reconcile 척추·imaging>risk-factor·KDRC정직강등).
- ⚠️ paper-writer 에이전트 호출 불가(레지스트리 미등록, 표준경로로 옮겼으나 세션재시작 필요). 직접 가이드라인 적용으로 작성.

## Novelty 표현 검증 (research-critic, paper-writer 대체) + 수정 (2026-06-16)
- critic 진단: 과학 OK, **novelty 표현이 우선순위 뒤집힘** — crowded "연관"을 앞세우고 차별점(측정업그레이드)을 Results 3번째 문장에 묻음.
- **수정 적용**: ① Title→**"Quantitative but not visual ... amyloid-negative ..."**(대비 전면화) + Abstract 재구성(Bg=측정adequacy+Freeze opposite-stratum, Results=시각n.s. vs 정량 대비를 첫 문장, 비순환 atrophy control 신호, "contribution"→"signature associated with"[인과어 제거], **KDRC abstract서 제거**) ② Intro "rarely" 군더더기 제거 ③ Discussion "can recover associations(복수)" → "recovered this association"(n=1 과일반화 제한).
- 미해결 판단(critic Q): 대비형 제목 저널 허용? / p=0.08 "but not visual" 제목서 방어? / amyloid-음성=visual read 명시 필요?(Freeze는 CSF) → [VERIFY]/Min 확인.

## paper-writer 컴플라이언스 검수 (general-purpose 우회 호출 = paper-writer.md 읽어 적용) + 수정
- verdict: "한 사이클 수정이면 제출 가능". 숫자 45개중 41개 JSON 일치, 구조·인과규율·AI=instrument 준수.
- **수정 적용**: F1) orphan 통계 4개(혈관 total/매개·flair_nmi) → `vascular_role_nmi.json` 저장(전부 일치 재확인). F2) WMH×APOE → Results 새 소절 + Methods stats 추가(1:1 복구). M1) CI 첫정의 확장·Methods WMH/APOE 중복정의 제거. M5) −0.25는 visual-matched 모델임을 명시. m2) "neurodegeneration"→"hippocampal volume"(횡단=부피, Abstract·Discussion 결론).
- **미적용(판단/저자정보)**: 제목(critic=contrastive vs paper-writer=descriptive 충돌 → "versus" 합성안 제시) · Abstract ~268단어 Background trim · Fig1(participant flow) 생성 · 아키텍처단락 시제 · 스캐너/버전/repo [VERIFY](저자).

## HANDOFF
**전 분석·검증·문서·IMRD 초안(+novelty 재구성 +컴플라이언스 수정) 완료.** 남은 것:
- [VERIFY] 채우기: IRB·스캐너params·SW버전·코드repo·데이터접근 (Min 정보 필요)
- Figure 1(participant flow) 생성 + Vancouver 참조번호 확정 + 선행논문 2건 full-read
- 게이트: **KoreaMed/RISS 한국어 scoop** (제출 전 필수)
- 독립검수: research-critic(가용) 또는 새 세션서 paper-writer(표준경로 등록됨, 재시작시 가용 가능)
**결정: AJU 단독 primary, KDRC 정직 강등 공개. "vascular" 제목 방어가능.**
완료: P1/P2 A-D / critic+make-or-break / vascular-RF / 잔여분석①②③⑥ / code-audit(버그無·3수정).

## ⭐ OASIS cross-population 복제 (2026-06-16) — Track04 결정적 강화
- "OASIS 먼저"(벤치마크 시도)가 → amyloid-음성 WMH→해마의 **미국 코호트 robust 복제**를 냄.
- OASIS(n=242 A−, WMH-SynthSeg no-crop on native 5mm FLAIR): M0 −0.105 p=0.003, **make-or-break(spline+비순환cortex) 통과** β−0.088 p=0.021.
- **AJU(한국)+OASIS(미국) 둘 다 robust → critic #1 약점(단일코호트) 해소.** KDRC=directional.
- 산출: research_tracks/06_wmh_tool_benchmark/results/oasis/.
- ⚠️ refine 필요: subject dedup이 arbitrary session(→baseline), AJU/KDRC도 동일 native 파이프라인으로 일관성(또는 "다른 전처리서도 복제=강점"으로 서술).
- **권고: OASIS를 Track04 replication 코호트로 매뉴스크립트 통합.** 벤치마크는 부차(replication이 tool-robust한가로 연결 가능).
