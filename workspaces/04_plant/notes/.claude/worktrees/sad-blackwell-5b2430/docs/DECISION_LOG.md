# DECISION_LOG — plant (microbrain)

> 모든 피벗·NO-GO·폐기·롤백을 여기에 누적한다. 되돌리기는 이 로그를 근거로 한다.
> 형식: `[날짜] 무엇을 · 왜 · 되돌아갈 commit(또는 tag)`. 최신이 위.

## 결정 기록

- [2026-06-22] **E6 fine-tune 비교(BrainIAC vs AMAES vs fs_vol, T1→amyloid AJU N=1000) → 두 deep 모두 morph에 *짐*.** frozen(E5) 아닌
  *fine-tune*(partial: last block+head, leakage-clean subject CV + val early-stop). 결과: **fs_vol 0.697 / BrainIAC 0.503(chance, 학습실패) /
  AMAES 0.570**(val 0.59–0.67이나 held-out 0.57). ΔAUC: BrainIAC −0.193[−0.243,−0.141], AMAES −0.126[−0.176,−0.078] — **둘 다 CI<0 = morph에 유의하게 짐.**
  kill-rule(>>fs_vol=누수) 미발동(오히려 deep이 짐). **정직 해석:** "3D Transformer가 더 높은 finding"이라는 가설 미실현 — fine-tune해도 deep<morph.
  BrainIAC chance=96³ non-MNI 공간불일치+ViT 소-N 부적합; AMAES(CNN 128³)가 더 나으나 여전히 morph 아래. **recipe-dependent 단서**: 더 공격적
  fine-tune/더 큰 N이면 tie(~0.70) 가능하나 ceiling상 *넘기는* 어려움(문헌 deep≈morph 일치). hand-crafted morph(0.697)가 최선. portable
  패키지=`dist/e6_amyloid_finetune.zip`(다른 환경서 더 큰 데이터/recipe로 재검증 가능). 코드=`src/microbrain/e6_finetune_amyloid.py`. 되돌아갈 commit=현재 HEAD.

- [2026-06-22] **ROI/ontology task 설계(13-agent workflow w6oirulsn) → accuracy=ceiling(tie) 재확인, 유일 positive=robustness(~15% odds).** 96-영역 DKT
  파셀레이션 substrate로도 **clean-AUC에서 graph/learned가 hand-crafted 100영역 GBM 못넘음(사전등록 tie; clean-win=누수 audit)** — E5/RT-SSL/P2 일치.
  유일 비-누수 길=**robustness**: 해부 인접그래프가 imputation prior로 region-dropout·LOCO site-shift 하 우아하게 degrade하나(타깃 CDR CN-vs-impaired,
  비순환, ΔAUC over DEMO). 정직 odds: 55% tie·30% imputation+GBM서 붕괴·**15% 생존**. **워크플로가 잡은 무결성 문제(무관하게 중요): ①cross-cohort
  dedup 없음**(`build_qc_pass_manifest.py`는 AJU 내부만 → 코호트간 중복=누수위험) **②roi_final_ready=FALSE 전수**(파셀레이션=unsigned candidate, 사인오프
  전 보고불가) ③100영역 테이블 매니페스트 부재(재추출 필요). novelty=moderate(brain-region GNN 붐빔), venue=specialty. **판정: accuracy positive
  foreclosed(ceiling); robustness는 高비용·低odds. 정직 권고=ceiling 수용 또는 무결성 수정.** 되돌아갈 commit=현재 HEAD.

- [2026-06-22] **데이터 발견: 풀 DKT 파셀레이션(100영역) + voxelwise 라벨맵 — 26 fs_vol은 curated subset이었음.** 디스크 검증:
  `t1w/fastsurfer/<subj>/stats/aseg+DKT.stats`=**100-영역 volume**(피질 DKT+피질하 aseg, L/R), **전 7코호트 ~13k**(ADNI 5037·A4 7132·NACC 1876·
  OASIS 1613·AIBL 990·AJU 1287·KDRC 931). `t1w/roi_transfer_option_b_candidate_v0/aparc_DKTatlas_aseg_final_tensor_grid_*.nii.gz`=**192³ 텐서
  grid 정렬 96-라벨 voxelwise 파셀레이션**(T1과 동일 grid). roi_masks/(hippocampus 등 status PASS). **roi_usability=USABLE_AUTO 12932,
  단 roi_final_ready=FALSE(사인오프 미완 — validity flag, 사용 전 QC 필요).** 함의: (1) 감별-dx baseline을 26→100영역으로 강화 가능, (2) 사용자
  ontology 아이디어에 *실제 substrate*(DKT 해부 ontology+그래프) 생김. **단 핵심 질문 불변: region-structured/graph가 (더 풍부한) hand-crafted
  tabular을 *넘는가* — prior=ceiling으로 tie 우세(tabular>GNN, E5 null), 이젠 결정적 테스트 가능.** 설계 workflow=w6oirulsn 진행. 코드=`src/microbrain/`. 되돌아갈 commit=현재 HEAD.

- [2026-06-22] **감별-dx protocol 설계(13-agent workflow wrc2gv4m2) + E0–E3 leakage-clean 실행 = 검증된 positive.** auditor가 헤드라인이 인라인
  (repo 부재)이고 study1 zc()는 전역-z 누수라 지적 → **`src/microbrain/diffdx_tier1.py`로 재빌드(sklearn Pipeline=train-fold 전용 스케일링).**
  **E0 누수증명:** per-fold scaler.mean_ DIFFER, 음성대조 DEMO=0.512∈[0.45,0.55] PASS, N=355(190/165) 0-dropped 중복텐서0. ladder leak-free:
  0.512→0.677→**0.755**(인라인과 일치). **E1 PRIMARY C1: ΔMORPH-over-severity=+0.077 95%CI[+0.019,+0.132] CI>0 GO✓.** E2: C2 +0.155[+0.04,+0.27]✓,
  C3(N=138) +0.113[−0.01,+0.24] 비-gating. **E3 severity-MATCHED(N=246): ΔMORPH=+0.261[+0.172,+0.350] 생존✓ → severity-INDEPENDENT atrophy
  pattern(novelty 핵심). **E4 robustness ✅ 통과**(ICV-method robust; leave-one-ROI-out ×26 range[+0.073,+0.081] 전부양수 0이동; leave-one-subtype ×7 부호뒤집힘0).** **E5 학습-rep kill-test ✅ 완료=NULL 확정:** frozen BrainIAC(ViT-B 96³,768d) T1-only→aju_amyloid(N=1000): BrainIAC AUC=0.512 ≪ fs_vol 0.697, ΔAUC=−0.185[−0.231,−0.136]→학습 rep이 hand-crafted 못넘음(AI 돌파구 없음). kill-rule(>fs_vol=누수) 미발동. degeneracy 공포→positive control로 추출 유효 입증(sex AUC0.807·age R²0.099, amyloid만 chance=진짜 null; raw cos~1은 DC offset). 검증체인 E0–E5 전부 leakage-clean 완료. novelty=circularity-decomposition
  +co-located 멀티모달+East-Asian 감별라벨 조합(moderate, specialty venue). 천장: 단일코호트(외부복제 불가)·학습-rep NULL 우세. 코드/동결표 커밋. 되돌아갈 commit=현재 HEAD.

- [2026-06-22] **감별-dx positive 결과 go/no-go 검증(workflow wbkqc4tfp) → GO-with-conditions, moderately-novel. 2 flag 해소.** 핵심:
  비순환 morphometry(임상의 미열람 fs_vol)가 중증도 통제 후에도 AD-계열 vs 혈관-계열 가름(3 contrast ΔMORPH-over-sev CI>0) = **durable positive headline**.
  멀티모달 고AUC(0.91)는 circular(WMH/amyloid를 임상의가 읽고 라벨링)→decision-support로 강등. **flag 검증:** ①provenance OK(wmh_grade_visual은
  korean_multimodal_manifest 1287, aju_amyloid 메인 1286 — 재현가능, 출처문서화 필요) ②leakage OK(내 N=355=subject-level, drop_duplicates 선행).
  **정직한 천장(부풀림 없이):** 단일코호트 AJU(감별라벨 고유, KDRC/Western 무 → 외부복제 불가)·NINDS-AIREN VaD=영상정의 라벨 → "severity-independent
  atrophy-pattern etiology signal"로만 주장. 경쟁 강함(Kolachalama Nat Med 2024 neuropath 51k AUROC 0.96). **학습-rep "AI 기여"는 N~355서 NULL 우세
  =kill-test이지 headline 아님.** 현실 venue=NeuroImage:Clinical/Alz&Dem/HBM(specialty), Nat Med/MICCAI 아님. **= 세션 최초 생존 positive(단 modest).** 되돌아갈 commit=현재 HEAD.

- [2026-06-22] **POSITIVE 결과 확보: 멀티모달 MRI가 AD-계열 vs 혈관-계열 치매 감별, 각 모달 유의 보탬.** (사용자 정당한 지적: null은 negative,
  positive 필요.) AJU 감별라벨, N=355(AD-계열 190 vs 혈관-계열 165). 계층 5-seed CV + paired ΔAUC bootstrap: DEMO 0.510(우연)→+MORPH 0.756
  (Δ+0.237 [+0.161,+0.314])→**+WMH 0.811(Δ+0.058 [+0.027,+0.089], CI>0)**→**+AMYLOID 0.912(Δ+0.109 [+0.075,+0.145], CI>0)**. 핵심: 나이는 우연,
  멀티모달 쌓으면 AUC 0.91; **혈관 모달(WMH)이 morphometry가 버린 신호를 유의하게 더함**(올바른 paired 검정). within-cohort 분류라 #4(비식별)·#1(null)을
  죽인 함정 회피. 코드=`src/microbrain/study1_*`(인접). **정직한 한정(부풀림 없이):** N=355 단일코호트(AJU), 라벨 임상의-assigned(경미 circularity),
  novelty=applied/clinical(새 method 아님); structure-only(morph+WMH=0.811)=routine MRI 배포판(PET 불요). **다음 positive 빌드아웃:** KDRC 복제 +
  학습 멀티모달 rep이 hand-crafted 넘나(3D-rep 기여 각도) + routine-MRI 배포판. 되돌아갈 commit=현재 HEAD.

- [2026-06-22] **Study #1 1차 결과 = NULL(사전등록 NO-GO 충족). super-additivity 미지지.** `src/microbrain/study1_amyloid_wmh_interaction.py`,
  사전등록 1차=MTL(해마+내후각), KDRC 연속 SUVR×Fazekas-deep→부피, N=616. **beta_int(MTL)=+0.024 boot95%[−0.037,+0.087] → CI 0 포함 NULL**(부호도 가설
  반대=양수); POST +0.048[−0.007,+0.107] NULL. 주효과 건전(amyloid→MTL −0.393, WMH→MTL ~0). 정밀도: |시너지|>~0.09SD 배제, 그 이하 배제불가.
  **C1**(혈관위험 보정) base 이미 null. **C2/C3**: recruitment-collapse attenuation=−0.019 vs H0 null mean+0.001 sd0.041, **P(|null|≥|obs|)=0.637 →
  range-restriction tautology와 구별 불가 = recruitment headline 사망**(무너질 상호작용 없음). **C5** AJU 복제도 NULL(MTL +0.020[−0.031,+0.071]). →
  **결론: amyloid+WMH는 단면 위축에 가산적; super-additivity 없음. grand 주장 2연속 사망(#4 비식별, #1 null).** 한정: 단면 atrophy만(인지/진행률 미검=사전등록밖,
  종단 간격부재). 정직한 산출=사전등록 null(가산성) 또는 within-cohort #3(T1→WMH)로 전환. 부풀림 없이 보고함. 되돌아갈 commit=현재 HEAD.

- [2026-06-22] **Study #4 KILL(타당성 workflow wptr3lcs0): novelty=already-established, defensibility=fatally-confounded.** 3중 사망:
  **(1) 비-novel** — EA-vs-Western APOE4→amyloid는 이미 점유(Li 2026·Duara 2019·Jang 2024). **(2) 방향 반박** — 우리 예비 OR=1.75(EA 강함)는
  소수/반박 방향; **Jang 2024(Korean N=5121, adj OR=0.60)**·Li 2026·Xiao 2026 전부 비-White에서 *약함*. 우리 N은 그에 비해 빈약. **(3) 비-식별** —
  EA 연속-amyloid arm=KDRC 단독(SUVR), AJU는 binary뿐 → ancestry가 site/tracer/scale과 완전 공선(K1 already-triggered); SUVR(KDRC med 0.95)↔
  centiloid(West med 5) 변환 부재→scale-bridge 불가; binary는 NACC 단독구동(EA vs OASIS p=0.45). **메타 교훈(durable):** 이 7코호트 데이터에선
  *모든* cross-population/cross-cohort 인과비교가 cohort-수준 공선(site/scanner/측정법=population)으로 **non-identifiable**; **within-cohort estimand만 생존.**
  #4 salvage=non-identifiability 측정-validity note(원하는 임상 novelty 아님). **권고: within-cohort인 Study #1(recruitment-dependent super-additivity,
  amyloid×WMH) 또는 #3(T1→WMH)로 복귀.** 되돌아갈 commit=현재 HEAD. 검증 코드=`src/microbrain/study4_*.py`(보존, salvage용).

- [2026-06-22] **Study #4(APOE4→amyloid coupling cross-pop) 착수 + 적대 검증 → 신호 실재하나 측정법=population 교란.**
  `src/microbrain/study4_apoe_amyloid_coupling.py`+`study4_verify.py`. 코호트별 OR(e4carrier→amyloid+): AJU 5.52·KDRC 6.99(EA) /
  OASIS 6.06·NACC 2.19(West) / A4 제외(screened 100%+). pooled e4×EA OR=1.68 [1.26,2.25] p<0.001(N=3558). **적대 검증:**
  **(V1)** binary interaction은 **NACC가 단독 구동** — EA vs OASIS만=OR 1.18 p=0.448(NULL), EA vs NACC만=3.61 → binary fragile.
  **(V2)** 연속 amyloid(within-cohort z, cutoff제거): KDRC slope +0.680≫A4 0.328≫NACC 0.171; KDRC vs NACC 연속 interaction +0.506
  [0.31,0.70] p<0.001 → cutoff-free서 robust. **(V3)** APOE2 EA 9.9%≈West 9.3%(교란 아님), 나이 통제. **근본 문제: amyloid 측정법(visual/binary/
  centiloid)이 코호트=population과 교란**(site=population의 amyloid 판박이). binary는 NACC-driven, 연속은 robust하나 EA 연속 1코호트(KDRC)뿐.
  **해법=Centiloid 조화**(KDRC/A4 SUVR→CL, NACC CL; AJU/OASIS binary 합류불가). 타당성 workflow=wptr3lcs0 진행 중(OR non-collapsibility·
  harmonization 표준·novelty vs Belloy2023). 잠정: 연속-CL 분석을 1차로, binary를 보조로. 되돌아갈 commit=현재 HEAD.

- [2026-06-22] **임상-novelty headline 확정(workflow wmmzgqu9y + 검증): "recruitment-dependent super-additivity".** 주장=혈관병 배제 안 하는
  실세계 East-Asian 클리닉에선 amyloid×WMH가 신경퇴행에 **초가산적**, **같은 코호트를 ADNI/A4식 혈관-배제로 재표집하면 가산성으로 붕괴** →
  "amyloid+SVD는 가산적"이라는 통설이 부분적으로 **모집 편향**. novelty=상호작용 자체가 아니라 *recruitment에 의한 효과변경*; **within-cohort
  falsification이라 site 교란 우회**; 항-amyloid 치료 시대 actionable. **검증된 feasibility:** KDRC 1차 joint cell **N=616**(korean매니페스트 age 397뿐
  →메인 clin_age 770 join 복구; 검증), ICV=fs_BrainSegVol, AJU 2-site sign replication(N=1000 binary×visual). **#1 reject 위험(검증):** range-restriction이
  상호작용을 기계적 약화→ recruitment-붕괴가 tautology일 수 있음 → **완화=한계분포 맞춘 시뮬레이션으로 초과분 입증**(필수). runner-up=discordance/
  symptomatic-SNAP(임상AD-amyloid음성 17·Vascular-MCI− 94)=치료 부적격 flag, 단 소N→sub-arm. 종단(AJU V1/V2 286)은 scan-interval 부재로 delta만(slope 불가).
  cheap-first 전부 CPU(STEP0 join→STEP2 SUVR×WMH→atrophy 상호작용→STEP4 recruitment test→STEP5 2-site sign). null 사전등록=1차결과. 되돌아갈 commit=현재 HEAD.

- [2026-06-22] **피벗: 임상-novelty(혼합병리) 방향 + feasibility 확정.** 사용자가 "임상적으로 매우 novel하면 OK". 닫힌 프레임(morph 이기기/교란하 method)
  대신 **서양이 *배제*하는 혼합·실세계 병리의 멀티모달 특성화**(ADNI/A4는 혈관 exclusion=pure-AD bias). **데이터 feasibility 확정(올바른 컬럼):**
  AJU=aju_amyloid(1000)+wmh_grade_visual(1001)+aju_dx_detail+APOE+MMSE/CDR; KDRC=amyloid_suvr(855,정량)+fazekas(661)+APOE+혈액패널+혈관위험(dm/htn/dyslip).
  **amyloid×WMH "two-hit" 셀:** AJU A+/WMHhi=141·A+/WMHlo=203·A−/WMHhi=231; KDRC(suvr>1,faz≥2) 49/194/84. **임상-바이오마커 불일치 직접관측:**
  "AD without"에 amyloid− 17명(SNAP), Vascular-MCI 94 A−/10 A+, AD+SVD 49 A+. 1836 full multimodal·2 Korean site·일부 종단. **고유성:** subject당 임상감별라벨
  +T1+FLAIR+PET+APOE+혈액 동시 = 실세계 East-Asian 기억클리닉(혼합이 다수). 후보 임상주장: amyloid×SVD 상호작용(가산 vs 시너지)·discordance(SNAP)
  특성화/예후·routine-T1 dual-pathology triage·항amyloid치료 적격/ARIA위험. novelty 검증 workflow=wmmzgqu9y 진행 중. 되돌아갈 commit=현재 HEAD.

- [2026-06-22] **A 식별가정 테스트 → A 경험적 사망; 알고리즘 novelty foreclosed; 수렴=VASCULAR-DECOUPLE-XFER 식별 프로토콜.**
  `src/microbrain/gateA_asymmetry_test.py`(AJU+KDRC 230/230, registered T1+FLAIR+PET, coarse-pool→PCA, cross-modal shared/specific 분해):
  **site(AJU vs KDRC, 스캐너우세)가 shared AUC=0.911 > specific 0.622 → site_specificity=−0.289**. 즉 스캐너가 모달-고유가 아니라
  **cross-modal 공유성분에 더 강하게 결합**(공유 registration 파이프라인). A의 "스캐너=모달고유" 가정 거짓. biology(age)는 shared에 결합(+0.21,
  A의 나머지 절반은 맞음)이나 식별에 필요한 절반이 깨짐. **→ A 사망(검증). A/B/C 전부 rigorous check 통과 못함 → 순수 알고리즘 novelty foreclosed.**
  부수 발견: multi-cohort에서 cross-modal-shared 신호는 site-지배(naive "멀티모달공유=biology" 가정 반증) — 프로토콜 동기로 유용.
  **수렴 방향(cross-pop workflow wbyyh0vpi):** VASCULAR-DECOUPLE-XFER = *식별 프로토콜*(아키텍처 아님). between-site 절대량 금지, 대신 scanner-
  unforgeable estimand 3종: ①APOE4-dose→vascular-readout slope(2 Korean site 복제, 혈액유래=스캐너무관) ②KDRC-Fazekas-fit readout을 freeze→AJU
  감별라벨 zero-shot 순서전이(circularity firewall) ③FLAIR-vascular vs amyloid-SUVR cross-modal decoupling. 전부 CPU-first, scanner-bound 초과 요구.
  데이터 게이트 PASS(AJU FLAIR+dx_detail 985). 한계: traveler 0=절대량 영구 도달불가; 기여=defensible measurement protocol(생물 증명 아님). 되돌아갈 commit=현재 HEAD.

- [2026-06-22] **method-novelty 적대검증 + B kill-test → 순수 fresh-method 거의 foreclosed, fresh-ish=gene-anchored pathway 비교.**
  사용자가 "Method 측면 완벽 fresh" 요구. novelty referee(literature-scout): 후보 A(cross-modal factorization)=PARTIAL-OVERLAP(Daunhawer
  ICLR'23 block-identifiability + MDPI MRI-PET-site near-scoop; "스캐너=모달고유" 가정이 B0/motion/registration로 경험적 거짓) · B(APOE
  genetic-anchor)=**GENUINE-GAP(유일)**(GEMCONT은 역으로 ancestry 제거) · C(modality-discordance ruler)=false-novel(Liu&Yap'24 phantom-free
  소유 + 생물 불일치 confound). **B kill-test(CPU):** fs_vol→APOE4 carrier AUC=0.56–0.60(ADNI/AJU/OASIS), NACC 0.49(우연) → **구조 instrument 약함**.
  **APOE4→amyloid(AJU): 비보유 23% vs 보유 61%, OR=5.19 p=1.8e-29 → amyloid 축은 강한 instrument.** 함의: B는 amyloid-anchored로만 생존하나
  amyloid는 PET 직접측정 가능 → imaging-genetics로 미끄러져 method-novelty 약화. **결론: 순수 fresh-method는 식별가정(traveler 부재시 반증불가)
  위에서 high-risk; memory "방법론 novelty 없음" 재확인.** 가장 방어가능한 fresh-ish=**유전-imaging coupling(APOE→amyloid OR)이 스캐너 오프셋에
  강건한 site-robust estimand** → 치매 *경로분해*(amyloid: APOE+PET vs 혈관: FLAIR-WMH) population 비교. 무게중심=데이터+estimand 프레임(순수
  method 아님). 되돌아갈 commit=현재 HEAD. 미해결: cross-pop 설계 workflow(wbyyh0vpi) 결과 대기 중.

- [2026-06-22] **대형 정정: 멀티모달은 4코호트(Korean 전용 아님) — cross-modal T1 학습축 개방.** 전 코호트 디렉토리 스캔+로드 검증:
  **정합 192³ 텐서 — FLAIR 4159(A4 1807·AJU 1256·KDRC 892·OASIS 204) / PET-amyloid 4305(ADNI 1792·AJU 993·KDRC 891·OASIS 629).**
  A4/AJU FLAIR Dice 1.0, ADNI PET Dice 0.869, 전부 finite·정량 SUVR. AIBL·NACC=T1단독. OASIS FLAIR 대부분 thick-slice(256×256×35) native.
  **함의:** (1) cross-modal 표현학습 = 라우틴 T1 → FLAIR-WMH/PET-amyloid 회수, registered voxelwise GT + **4코호트 LOCO + 수천 N** → frozen probe
  아닌 **실제 3D 학습 가능**(N 제약 해소). (2) Korean 고유성 재정의=멀티모달 아님(Western도 보유)→**감별병리 라벨**. (3) site 교란 LOCO로 검정가능.
  **함정:** cross-cohort PET tracer/SUVR 정규화 상이(harmonization), T1→amyloid는 atrophy-proxy라 morph천장 재출현 위험(혈관/FLAIR가 더 물리적).
  Western 멀티모달 **인덱싱 매니페스트 없음→glob 빌드 필요**. 인벤토리=memory `multimodal-data-inventory`. 되돌아갈 commit=현재 HEAD. 다음=멀티모달 index 빌드 + T1→모달 천장 LOCO.

- [2026-06-22] **정정: 전처리 멀티모달 텐서 실재(raw만 오프로드).** 사용자 지적 후 `korean_multimodal_manifest.parquet`(2196행, 메인에 없음) 확인:
  **전처리 FLAIR(flair_brain_1mm_RAS_192³_zscore, 2148, 20/20)·PET-SUVR(pet_suvr_1mm_RAS_192³, 1882) 디스크 실재**, T1과 동일공간(Dice 0.917),
  finite·정상. subject full(T1+FLAIR+PET)=AJU 963/KDRC 873(총 1836), FLAIR+감별라벨=1489, 정량 amyloid_suvr+apoe+혈액+혈관위험 동봉.
  → **직전 workflow의 "다모달·T1→diffusion DEAD"와 memory의 "치명 mismatch(라벨⊥모달)" 둘 다 거짓**(raw_*_path만 보고 오판; raw는 대용량이라 타 서버 이동).
  **함의:** (a) AJU가 FLAIR+PET+감별라벨 동시보유 → 혈관 라벨×모달 동일코호트, (b) AJU·KDRC 2-site LOCO 가능, (c) positive 후보 격상=**라우틴 T1 표현이
  멀티모달 신호(FLAIR-WMH·PET-amyloid) 얼마나 회수하나**(registered ground-truth 보유, cross-modal 감독). 되돌아갈 commit=현재 HEAD. 다음=재설계.

- [2026-06-22] **"AD MRI 특징 학습법" 17-agent workflow(survey→adversarial-verify→design→synth, 디스크 검증 포함) → CPU-first radiomics-gated 혈관축.**
  검증된 핵심: **(1) raw DWI/FLAIR/PET 전부 디스크 부재**(raw_dwi 0/20, raw_flair 0/20, raw_pet 0/20; `/home/vlm/data/raw/`엔 `AJU/`만)
  → T1→diffusion(MD/FA) 합성 생성기 + KDRC 다모달 방향(구 priority #2/#3) **이 머신에서 DEAD**(매니페스트 경로만 살아있고 파일 없음).
  **(2) 신규: KDRC Fazekas WMH ordinal 점수 실재**(pv 662, deep 661) — tabular 혈관부담 타깃, T1→Fazekas 가능. **(3) 방법론 정밀화:
  혈관축의 진짜 경쟁자는 volumetry가 아니라 handcrafted radiomics(texture)** → 구속 bar = DEMO+fs_vol+**radiomics**. learned rep은 *그걸* 넘어야 기여.
  **(4) 최대 위협: texture = 가장 site-교란된 feature class**(un-LOCO'd 승리=scanner-ID, AJU 단일site라 within-CV로 검증불가).
  **권고:** STEP-0 = GPU/신규데이터 0의 **CPU radiomics kill-gate**(AJU AD-vs-VaD + KDRC-Fazekas 교차검증)로 (a)beyond-atrophy 신호 확정/사망 (b)learned rep이 넘을 bar 설정. radiomics가 포화면 learned rep 사전확률 null. **정직한 천장:** 증분 ~0.03–0.10 AUC, 단일코호트, "learned>radiomics"는 高bar로 미달 가능; 바닥=측정 논문(gap-decidability). 되돌아갈 commit=현재 HEAD. 전문=`tasks/wf82xb079.output`.

- [2026-06-22] **Korean 축 피벗 + kill-test → priority #1(순수vs혼합) NO-GO, etiological subtyping live.** AJU subject-level(1001),
  baseline collapse, DEMO(나이+성별)/MORPH(fs_vol26) 5seed CV + bootstrap. **① amyloid+ 순수AD(77) vs 혼합AD(78): NULL** —
  DEMO 0.697이 분리 대부분, Δ(morph|demo)=[−0.046,+0.109] 0포함(나이교란, morph 증분 ~0). 메모리 "viable binary" 정정: N은 되나 신호=나이.
  **③ Amnestic-MCI amyloid± : NULL**(T1 morph로 amyloid 불가, 선례 일치). **반면 ④ AD-계열 vs VaD-계열: HEADROOM** — DEMO 0.528(≈우연)
  → +MORPH 0.688, Δ=[+0.028,+0.250] 0제외(나이교란 아님, 구조 신호 실재), N=251(190/61). **② Vascular-MCI vs Amnestic-MCI: HEADROOM**
  Δ=[+0.058,+0.200], N=475. **새 positive 후보:** "학습 3D rep > fs_vol, 감별진단(혈관 etiology)" — fs_vol이 버리는 WM/lacune 공간패턴,
  amyloid천장 직교, AJU 고유라벨. **한계:** N=251~475 → from-scratch 학습 불가(frozen/transfer probe만), 단일코호트(외부검증 불가).
  **다음:** ④ 대상 image-rep > DEMO+MORPH 사전등록 kill-test. 되돌아갈 commit=현재 HEAD. 코드=`src/microbrain/`(inline), 결과 위 표.

- [2026-06-22] **GATE-3 de-risk → Track C(off-the-shelf 1mm frozen) NO-GO.** AMAES unet_b 정찰 후 smoke+pooling probe
  (`src/microbrain/gate3_amaes_{smoke,pooling_probe}.py`): ✅strict load(0/66 미스매치)·1mm/192³ finite·OOD안전·텐서 공통공간(Dice 0.89).
  ❌**사전등록 "bottleneck GAP" pooling 반증**(random≈brain cos 0.9994, 뇌끼리 0.9999; GAP/GMP/std 전부 degenerate). 구조적: bottleneck
  16mm 유효해상도라 cortical 디테일 부재(BrainIAC 2mm보다 거침), early layer는 억-차원 pooling 미해결, 정공법=decoder fine-tune(=학습).
  설계 교란: ViT global-CLS vs U-Net 공간피라미드. **판정: frozen-feature로 cortical GATE-3는 cheap·clean 둘 다 실패 → frozen 경로 폐기.**
  GPU 배치 전 de-risk가 차단(절약). 다음=fork(Track S only / fine-tune 투자 / Korean 축). 되돌아갈 commit=현재 HEAD. 산출=`results/gate3/`.

- [2026-06-22] **GATE-3 사전등록 = 해상도×영역 통제 표현 측정(`docs/gate3_plan.md`).** 정찰 2건으로 두 사실 확정:
  ① **persist된 frozen feature 0개**(BrainIAC/F04/MAE 전부 on-the-fly, 캐시 없음) → 재추출 불가피.
  ② **AMAES(Zenodo, U-Net/MedNeXt, 128³@1mm, fully-conv)가 유일하게 released+1mm+T1** → cortical GATE-3를 self-train 없이
  frozen extraction으로 가능(BrainIAC 96³=ViT 고정, Triad/BrainFM/BrainFound 부적합). **재구성:** 두 트랙(subcortical/cortical)을
  BrainIAC(2mm) vs AMAES(1mm) × subcort/cort fs_vol **interaction 측정**으로 통합 → positive-framable(필드 96³ 관행이 cortical
  병목인지 측정). Gate A=rep→fs_vol R²(해상도 interaction ΔR²_cort≥+0.10/CI), Gate B=morph 위 ΔAUC headroom. **NO-GO 사전등록.**
  사전확률: Gate B 탈락 우세(선례 4회), Gate A cortical interaction이 유일 미지·positive 후보. **다음:** GPU 추출 2배치(ADNI baseline
  1578subj) Min 승인 대기. 되돌아갈 commit=현재 HEAD.

- [2026-06-20] **closure 정밀지도 + 우선순위 + Korean 데이터 역할 종합(8-agent workflow).** sibling 4라인 closure 원문 추출 +
  AJU/KDRC 분석. **상세 closure(5축):** R1 site=population(traveling-subject=0 비식별, decomposition artifact는 disease-prevalence
  불균형 ρ+0.90→−0.20), R2 morph천장(m2 5-ROI vs deep KDRC 0.836/0.816 regional 더 높음), molecular(IDH oracle dAUC −0.0405),
  foundation(BrainIAC frozen site 0.842>morph 0.770, dx 0.735<0.911), harmonization(deflate-not-unmask). **안 닫힌 빈틈:** 3D-full-volume
  minyoung2 미실행(SIGHUP)·TOST 미완(단 사용자 from-scratch 실패가 메움). **Korean DECISIVE 3축:** ①감별/혼합병리(AJU dx_detail —
  AD+SVD/Subcortical VaD/Multi-infarct, 서양 코호트 부재) ②amyloid×WMH×다모달 co-location(KDRC SUVR+Fazekas+FLAIR/DWI) ③leakage-clean
  East-Asian 외부검증. **치명 mismatch:** 혈관라벨=AJU(T1전용) ⊥ FLAIR/DWI=KDRC(coarse dx). **우선순위:** #1 amyloid-조건부 순수AD vs
  혼합(A+ 77 vs 78 subj) morph+WMH bar 위 측정 · #2 East-Asian 외부검증+gap-decomposition · #3 KDRC 다모달→SUVR(WMH통제) · **#4 DO-NOT-PURSUE:
  morph 넘는 아키텍처/SSL·site제거·fine 4-way 혈관staging(MID 11)·longitudinal conversion·IDH/MGMT.** 데이터 정정: KDRC cdrsb *있음*(909)·
  education=0·SUVR ratio단위·amyloid 비-Korean고유. 상세=`docs/analysis/04_closure-and-priorities.md`, memory `korean-data-value`. 되돌아갈 commit: `59c0a1e`.

- [2026-06-20] **encoder 조사 — BrainIAC usable(off-the-shelf) + both-compare 권고.** 4-agent workflow(HF+문헌+범용 3D).
  **BrainIAC**(HF eugenehp/brainiac, ViT-B 96³ patch16 768-d, SimCLR)가 공개 weight 검증(backbone.safetensors 353MB live)·
  brain-T1 native·turnkey feature 경로 → 1순위(license non-commercial academic, research OK). AMAES ResEnc-B FOMO300K(CC-BY-NC-SA)
  =독립 cross-check. **치명 confound(우리 voxel-rep 질문과 직결):** ① 둘 다 **96³(≈2mm) downsample 요구** → cortical GATE-3를
  *또 해상도로 confound*(frozen 실패가 신호천장인지 해상도손실인지 구별불가, CPU trivial rep과 동일 함정). ② BrainIAC **MNI152
  재등록**이 volume 정보 재주입 → image→fs_vol R² *성공*도 의심(encoder가 volume 재학습). ③ 입력 mismatch(우리 텐서는 이미
  z-score/identity-grid, BrainIAC는 MNI 96³ 자체정규화). **권고=both-compare:** off-the-shelf(BrainIAC+AMAES, morph와 cross-check)
  먼저, **full-res self-SSL(12,978, 192³ identity-grid=MNI 재등록 불요=registration-leakage 면역)을 deconfounding companion으로
  사전등록**(fallback 아님). 다음: `docs/gate3_plan.md`(96³ 해상도·등록 leakage confound + NO-GO 사전등록) + BrainIAC **CPU smoke
  test**(strict=False 키 무결·feature 유한/non-constant/subject-varying) → 통과 시 GPU 추출(12,978) 승인 게이트. 되돌아갈 commit: `712bde4`.

- [2026-06-20] **GATE-3 CPU 시도 — inconclusive(ambiguous band) + voxel-SSL feasibility 확인.** GATE-3(`image→fs_vol R²`)를
  trivial 4mm-PCA 표현으로 측정(ADNI baseline 1,575, `src/microbrain/gate3_image_to_fsvol.py`). 결과: SUBCORT R² 0.29
  (thalamus 0.46·hippocampus 0.30·amygdala 0.10 — *너무 낮음*, 충분한 표현이면 ~0.7+여야), AD-CORTICAL R² **−0.03**(entorhinal
  0.03·precuneus 0.01·PCC −0.1). 직접 headroom: image-PCA가 morph 위 −0.08~−0.41(300 PCA feature 과적합, 무의미).
  **판정: trivial 표현이 subcortical조차 못 복원 → cortical≈0은 *표현약함 vs 정보없음* 구별 불가 = ambiguous band.** ledger
  C2/C6/C7 불변(strongly-disfavored 유지). **결정적 GATE-3는 deep/pretrained encoder(GPU) 필요.** + **voxel-SSL feasibility 확인:**
  12,978 QC-pass(7,206 subj) 전수 clean·identity-grid → 즉시 SSL 사용가능, RAM 캐싱(~428GB/1.8TB), 8×B200 가용, 3D MAE patch16³
  =2016 tokens. caveat: scale 12,978≪49k, R3 hold-out 필수, prior=null. 다음: off-the-shelf encoder 조사(workflow) → off-the-shelf
  vs 자체 pretrain. 되돌아갈 commit: `cf052b6`.

- [2026-06-20] **방향 설정 — Lane B(label-efficiency × LOCO), gated.** 6축 학계동향 조사(literature-scout)+종합.
  핵심 전환: R2 천장이 학계 전체를 막아 게재기준이 accuracy→label-efficiency·LOCO·leakage-clean·deployability로
  이동(우리 자산과 일치). **권장 thesis**: morph-aware T1 SSL이 low-label×leave-one-cohort-out에서 FreeSurfer-morph
  대비 label-efficiency 우위 + inductive BN-adapt가 site=population을 공정·배포가능 증분으로(full-label in-dist엔 둘 다
  morph 못 넘어도 됨). **공백**: BrainIAC/BrainFound/FOMO25가 morph 미비교; Cautionary Tale(2601.16467)이 SSL-vs-FS
  +R-NCE 했으나 in-cohort full-label만 → low-budget×LOCO×confound cell 비어있음. window 수개월. **Lane A pivot**:
  T1→FA/MD 합성 천장우회(KDRC/OASIS DWI=train→ADNI). **지배 prior=null**(R2 천장). 사전등록 kill-test(CPU/소-GPU):
  frozen 표현 vs fs_vol 예산grid{1..100%} nested-LOCO, GO=≤20%서 held-out site morph CI하한>0 + inductive BN-adapt
  CI하한>0. 설계=`docs/analysis/03_novelty-and-direction.md`. 되돌아갈 commit: `42b0b31`.

- [2026-06-20] **종단 변화율 thesis kill-test 실패 — NO-GO 폐기.** "기술 novelty"의 마지막 live 후보(종단 변화율
  deep). CPU kill-test(ADNI 614 ≥3tp + OASIS 193 transport): Δmorph(Δfs_vol/yr)가 static morph+cognition을 못 넘음
  (내부 ΔR² −0.089 CI[−0.172,−0.031] 전부 음수) + transport 파탄(OASIS R²<0, population shift 지배=R1 종단판) +
  미래저하 천장 낮음(best R²~0.11). 사전등록 NO-GO(Δmorph CI하한>0) 위반 → 즉시 중단. **누적 4 독립라인**(R2천장·
  baseline bar·문헌 4팀·이 kill-test)이 "구조 T1 *정확도* novelty 경로 없음"으로 수렴. 단 caveat: refute=naive
  per-ROI Δvolume(깨끗), deep이 변화*패턴* 뽑을 가능성은 미refute(prior 강 null). 근거=`docs/ledgers/2026-06-20_longitudinal_changerate_negative.md`,
  문헌=`docs/analysis/03_novelty-and-direction.md`, memory `novelty-landscape-verdict`. 상위 결정점 복귀: 다른 modality(FLAIR/DWI/PET
  원본 존재) vs novelty 축 재정의 vs denoised 1회 재검. 되돌아갈 commit: `4d2eb1b`.

- [2026-06-20] **데이터 정정 — 종단 코호트는 ADNI뿐이 아니다.** YYYYMMDD-only 파싱 오류였음. 시간인코딩이 코호트별
  상이(OASIS day-offset·A4 VISCODE월·AIBL날짜). 복원 결과 종단 라벨(cdrsb 2tp+): ADNI 849·OASIS 357·A4 777·AIBL 0(비라벨).
  → cross-site 종단 transport 가능(ADNI↔OASIS). 권장 조합=SSL pool 전체 12,978 / 지도종단 ADNI+OASIS(+A4 preclinical) /
  AJU·KDRC·NACC는 audit·SSL만. 데이터-준비 게이트: 종단 within-subject 정합(매니페스트는 미정합). 측정=NB06 후속.

- [2026-06-20] **QC-pass 작업 매니페스트 빌드 — base-텐서 전수 검증 + 파생본 생성.** 사용자 결정(QC-fail 데이터
  미사용 + 로컬 사용가능 매니페스트). **검증:** canonical 13,022 전수 — `final_qc_status`/`fs_qc_status` 전수 PASS,
  base-텐서 직접 로드 전수 QC(`src/microbrain/qc_base_tensors.py`, 13,022/13,022)로 **NaN/Inf 0 · z-score σ=1 전수 ·
  brain-mask 무결**(0 flagged). 06-18 검증서(경로·morph·임상 exhaustive PASS) 위에 base판 수치 무결성(기존 무커버
  축)을 닫음. **빌드:** 모든 QC 게이트 AND → **12,978 keep / 44 drop**(=`voxelwise_qc_candidate=False` 정확일치:
  A4 39·ADNI 3·KDRC 1·NACC 1). 추가 컬럼 `base_tensor_qc_pass`·`dup_group`. **누수 dup 2쌍(AJU cross-subject,
  md5 재확인)은 drop 아닌 flag만** — split 시 collapse 별도. 산출=`data/derived/manifest_qc_pass/`(gitignore·재현가능),
  빌드=`src/microbrain/build_qc_pass_manifest.py`, 증거=`results/p0_base_tensor_qc/summary.txt`. memory
  `manifest-leakage-duplicates`. 되돌아갈 지점: commit `6fafde2`(빌드 직전 클린 상태).

- [2026-06-17] **P4 라인 폐기 — 코드·산출물 삭제.** 사용자 결정. P4(서양 vs Korean cross-pop AD 전이)는
  실증·robustness가 닫혔으나 **체급 부족으로 폐기**: ① 방법 아닌 경고성 negative 결과(Bron2021 영역 중첩,
  [[p2-novelty-positioning]]) ② 최강 펀치라인(비가역 population)을 strong-backbone에 스스로 철회(2026-06-16 기록) ③
  within deep≈morph로 전제 약함 ④ "population effect" 해석이 MMSE/중증도/라벨정의 confound에 노출(4코호트로 미해소).
  삭제: `experiments/P4/`(11 .py, git 복구가능) + `data/derived/P4/`(4.4GB, gitignore=영구). **보존:** `docs/P4_*.md`·
  `insight/`·`SCRATCHPAD.md`. 되돌아갈 지점: commit `5eae3c1`(P4 코드·문서 온전).
  필요실험 완수(per-cohort·M2공정성·M4 split·독립 코드감사·강backbone) + 코드리뷰·산출물비교. 핵심 정정:
  from-scratch deep은 cross 양방향 deep<morph(유의)이나, **brain-age 사전학습이 W→K를 morph *동등*까지 회복
  (Δ−0.002, CI[−0.036,+0.032]) · K→W는 비회복(Δ−0.053 유의) · within-Korean은 morph 초과(Δ+0.075)**.
  → "test-time(BN) 비가역이나 전이가능 사전학습으론 *비대칭* 부분회복; Korean→Western 가장 취약." (이전 "비가역
  population" 단정 철회 — 점추정→CI/추가실험으로 정정한 정직 사례.) 부수 수정: M2(morph train-only 공정성),
  M1(aggregate_transfer 삭제). 결과=`docs/P4_results.md`(§0/§4c-e/§5/§7/§8). 되돌아갈 지점: commit `e932647`.

- [2026-06-16] **P4 실증 완료 — 헤드라인 통계 확정.** 서양(ADNI+OASIS) vs Korean(AJU+KDRC) CN-vs-impaired,
  matched(age·sex·CDR-stage, 2286 subj). deep(CNN·ResNet 5-seed) vs morph transfer 매트릭스. **cross-pop full-target
  (n=1143)** 평가로 power 확보: **cross 양방향 deep<morph 유의**(W→K Δ−0.106[−0.143,−0.068]·K→W −0.062[−0.101,−0.022]),
  within 유의차 없음. **BN-adapt 0% 회복 → 결손=population-level(비가역)**, scanner shift(C4 +0.06 회복)와 대조.
  Stage-1: MMSE 인구-비등가. 인프라 교훈: DataLoader/mmap thrash→GPU상주(insight T12), val⊂train 누수버그 수정.
  결과=`docs/P4_results.md`, 코드=`experiments/P4/`. 되돌아갈 지점: commit `6300402`.

- [2026-06-16] **전략 피벗 Path A→B + P4 설계.** 사용자 결정: venue 임팩트 우선(Path B). field는 site-LOCO/morph-bar를
  gating 안 함(ADLIP이 그 없이 Alz&Dem 게재) → 우리 rigor는 진실용이지 보상용 아님. **P3(Path A decidability) 대체.**
  새 주제 = **서양(ADNI+OASIS) vs Korean(AJU+KDRC) cross-population AD 모델 비교**(ADLIP式 vision-language fusion).
  task=CN-vs-impaired 이진(AD 128/그룹 얇음 회피). 매칭 CN 307/impaired 920/그룹(age·sex). hook=cross-pop 매칭+
  transfer gap의 acquisition/population **분해**(P3 도구 흡수=해석가능성 엔진)+East-Asian(ADLIP 미보유). amyloid는
  비대칭(서양 22%)이라 Korean 내부 보조만. AIBL(APOE0)·NACC(MMSE16%) 제외. ★리스크: site×dx confound 내장(AJU CN27)
  → 분해 없으면 "서양≠Korean" 해석불가(NO-GO 1). 설계=`docs/P4_crosspop_adlip_plan.md`. 되돌아갈 지점: commit `6300402`.

- [2026-06-16] **P3 개정 — research-critic 조건부 GO(범위 절반 축소).** 적대검증 치명결함 3: F1(scanner/population
  분리는 traveling-subject=0이라 원리적 불가) · F2(Q2 amyloid specificity null은 SNAP/amyloid-independent atrophy
  문헌이 이미 출판=새 과학 아님) · F3(AJU↔KDRC "R1 청정" 거짓: 측정법+base-rate 1.77× confound). + M2(C3 미완주를
  엔진 전제). → **개정:** Q2 헤드라인 강등(within-cohort 보조만), Q1을 "gap decidability 지도(어느 성분이 decidable/
  원리적 undecidable)"로 재정의, C3를 Stage-0 GATE로 격상, F1은 within-NACC 독립 2차추정(|Δ|<0.02)으로 검증/강등.
  scout·advisor·critic·memory 전부 동일 결론(decidability/negative-result framing이 유일 생존로). 개정=`docs/P3_signal_decomposition_plan.md`.

- [2026-06-16] **P3 주제 설정 — 구조 MRI 신호 다기관 분해 + AD-특이성 벤치마크.** 성능 논문 포기(R1+R2
  구조적). literature-scout/research-advisor 독립 수렴 + 자산 재인벤토리(parquet 직접)로 확정. 두 질문:
  Q1(gap을 scanner-회복/population-비가역/morph-천장으로 분해, 엔진=C3) + Q2(transport 신호가 AD-특이인가
  — impaired 내 amyloid+/− specificity, **AJU↔KDRC=Korean 청정 testbed**). ★신규 자산: amyloid 라벨 5코호트
  3,774 subj, impaired 대비는 Korean 집중(서구 문헌 공백). null도 1차 결과. 체급=NeuroImage:Clinical급.
  설계=`docs/P3_signal_decomposition_plan.md`, 근거=`insight/failure_root_causes.md`(4-사인). 되돌아갈 지점: commit `6300402`.

- [2026-06-16] **자산 정정(parquet 직접):** datadict stale 확인(127 vs 141컬럼, clin_apoe ADNI 0%→실제 94%).
  ROI=morphometry(roi_final_ready=False는 target sign-off만 미완, baseline 사용가능). PET 원본영상=KDRC만 903.
  scanner-model fine-grained 존재(ADNI 16종) — BRIEF "scanner 데이터 없음" 전제 부정확. memory `manifest-only-source-of-truth`.

- [2026-06-15] **C4 PASS — BN-adapt 회복은 공정·inductive·배포가능.** 3-seed×5-fold 동일 eval subset 3-way BN:
  raw 0.850 / transductive 0.909 / **inductive(K64) 0.912** → recovery_ratio (ind−raw)/(trans−raw)=**1.05**(전 K).
  target-site **unlabeled 64장**으로 BN 재계산→freeze→per-subject가 +0.06 회복 전부 재현(K64 포화).
  → **transductive 공정성 confound 제거**: image(BN-adapt) 0.91 vs morph 0.931은 이제 양쪽 inductive=공정 비교,
  잔여 −0.02 유지. 회복은 site-shift 큰 fold(ADNI .75→.92, NACC .78→.90)에 집중. 단 공정성만 해결 — 잔여=천장
  판정은 **C3**(잔여의 morph 환원불가 + 회복↔site-decode 인과) 필요. 근거=`results/P2/adcn_inductive_bn_adcn_2mm.{csv,json}`,
  설계=`docs/P2_plan.md §6b`. 되돌아갈 지점: commit `af0ecdb`.

- [2026-06-15] **P2 Tier-2 방법론 4-arm 확정 + 해상도 축 종료(NO-GO).** LOCO 5-cohort×2-seed, image-only,
  morph bar 0.931. 결과: none 0.844 / grl 0.817(**적대 디바이싱 악화**, NACC .82→.70) / **none_tta(BN-adapt) 0.910**.
  해상도-매칭 검정(2mm→1.5mm, voxel 2.37×): none_tta Δ=**0.000**(0.910→0.910), none Δ=+0.005 → **잔여 −0.021은
  해상도 핸디캡 아님 = 천장 성분**. 사전 등록 NO-GO(≤0.910) 트리거 → **1mm 캐시 빌드 안 함.** 단 none_tta는
  transductive(C4 confound)라 0.910은 낙관적 상한. 다음=천장 확정용 C2(multi-seed dissociation)·C3(site-decode 인과)·
  C4(inductive 변형). 근거=`docs/ledgers/2026-06-15_adcn_resolution_ceiling_negative.md`,
  novelty 실측=memory `p2-novelty-positioning`(Bron 2021이 최대 위협 — C1 단순비교는 점유됨, C3 분해만 공백).
  되돌아갈 지점: commit `51944b3`(1.5mm 실행 직전 체크포인트).

- [2026-06-11] 라인 시작 — plant를 longitudinal에서 **microbrain(bias-robust micro-level T1w 표현)**으로
  재정의. 옛 longitudinal 산출물 제거. · 되돌아갈 지점: commit `27b1665`(git init, longitudinal 상태).

- [2026-06-11] **P0 audit 실행 완료**(CPU + voxel smoke). 판정: **bias 실재(voxel→site 0.475, 3.3×chance) +
  N4 무효(−0.006) + disease 는 morphometry 수준에서 site 와 분리 가능(A4 잔차 0.722, drop −0.05) → decidable**.
  BRIEF §5 "bias 실재+분리가능" 경로 → P2 진입 근거 확보. 단 (b) 천장이 여전히 최우선 prior. ·
  산출: `results/P0/P0_AUDIT_REPORT.md` + notebooks/01~06 + figures. 되돌아갈 지점: 직전 commit.

- [2026-06-11] **주제 제안 확정(근거 기반)**: 5각도 수렴(P0·morph바·harmon scout·deep-research·혈액검증) →
  "T1w micro-표현이 **morphometry 약한 regime(MCI/amyloid)** 에서 transportable하게 더하는가" cross-site decidability 연구.
  AD/CN(천장 0.94)·harmonization·혈액바이오마커(+0.00 반증)·멀티모달 fusion(crowded)은 headline에서 제외. 문서=`docs/RESEARCH_PROPOSAL.md`.

- [2026-06-11] **insight/ 폴더 신설(표준 규칙):** 실패·실패지점·교훈을 항상 `insight/`에 누적
  (methodological_traps·empirical_findings). 추후 인사이트·연구 활용. + P2 target을 **AD/CN**(morph 강 0.936)으로
  확정, **컨소시엄 bias 처리를 층상 방어(L1~L6)로 통합**(erase 아닌 측정·통제·전이). 설계=`docs/P2_plan.md`.

- [2026-06-11] **(b) 천장 주장 철회 — research-critic 적대 검증.** P2-③의 "image≈morph fair-test"가
  F1(인코더 random-split = 표현수준 LOCO 누수)·F2(morph-distilled emb 순환 + amyloid 약한 target)·F3(1.5mm
  mean R²=0.23·precuneus 음수 = "cortical 복원" 과대진술)으로 무효. **(a)/(b) 미결로 되돌림.** FINDINGS §0.1 정정.
  되돌아갈 지점: commit `2ff018d`(철회 전 상태). · 다음(필수): nested-LOCO + AD/CN target 검정.

## NO-GO / 폐기 ledger (요약 — 상세는 docs/ledgers/)

- [2026-06-11] **D5 혈액바이오마커+MRI 폐기** — novel(whitespace)이나 morph+age 대비 incremental 반증:
  dementia +0.005 · MCI-vs-CN +0.000 · amyloid +0.007. tested-negative control로만 잔존. 근거=`docs/novelty_deep_research.md`.
- [2026-06-15] **AD/CN 이미지 해상도 추격 NO-GO** — 잔여 −0.021(none_tta 0.910 vs morph 0.931)이 해상도 불변
  (2mm→1.5mm Δ0.000) → 1mm 빌드 폐기. + **grl(consortium-adversarial) 폐기**(0.817, raw보다 악화). 근거=`docs/ledgers/2026-06-15_adcn_resolution_ceiling_negative.md`.
- (P0 audit 자체는 폐기 arm 없음.)
