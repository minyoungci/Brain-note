# SCRATCHPAD — microbrain (live state)

> 현재 상태·가설·결과를 여기에 누적. 핸드오프 시 이 파일로 상태 전달. 최신이 위.

## 2026-06-16 (오후) — 전략 피벗 Path B + P4 설계 확정
- **결정: venue 임팩트(Path B).** field가 site-LOCO/morph-bar를 gating 안 함(ADLIP 게재 증거) → rigor는 진실용. P3(Path A) 대체.
- **P4 주제:** 서양(ADNI+OASIS) vs Korean(AJU+KDRC) cross-population AD 모델 비교(ADLIP式 fusion). **task=CN-vs-impaired 이진.**
- **데이터(검증):** 매칭 CN 307/impaired 920/그룹(age·sex 매칭). core4(age/sex/mmse/apoe) 서양88%/Korean90%. amyloid 서양22%(OASIS만)/Korean100%→비대칭. AIBL(APOE0)·NACC(MMSE16%) 제외.
- **hook(=desk-reject 회피):** cross-pop 매칭+transfer gap의 **acquisition/population 분해**(=해석가능성 엔진, P3 도구 흡수)+East-Asian.
- **★내장 리스크:** site×dx confound(AJU CN27, 서양 CN多) → 분해 없으면 비교 해석불가(NO-GO 1). 잔여 confound=스캐너·라벨 측정법(AJU CDR정적).
- **Stage-1 완료(CPU):** `experiments/P4/build_matched_set.py` → `data/derived/P4/matched_cohort.csv`. age×sex×CDR단계 매칭, 그룹당 **CN302/MCI717/AD124**(binary impaired 841/그룹, 총 2,286), split 누수 0.
- **★Stage-1 발견:** **MMSE 인구-비등가** — 매칭 후에도 Korean이 체계적으로 낮음(Δ CN+1.1/MCI+2.4/AD+4.7, 문화·교육 의존). → 결정: fusion feature=culture-invariant{APOE,age,sex,영상}, MMSE/edu는 발견/민감도 축으로만(equity 기여로 전환). CDR은 라벨 유지.
- **Stage-1b baseline 완료(CPU):** `experiments/P4/baseline_morph_clinical.py` → `data/derived/P4/baseline_results.csv`. morph(head-size 정규화)+culture-invariant clinical(APOE/age/sex, MMSE 제외)로 CN-vs-impaired transfer 매트릭스.
- **★Baseline 발견 3 (예상과 다름):**
  1. **Korean 과제가 훨씬 쉬움**(K→K 0.85 vs W→W 0.66) — Stage-1 중증도 비등가 반영(같은 CDR인데 Korean 더 중증→더 분리).
  2. **전이 비대칭**: K→W 무손실(0.67≈Western천장), W→K는 Korean천장 못미침(0.74<0.85)이나 **붕괴 아님**. AD/CN harmonization식 catastrophic R1 붕괴가 morph엔 없음.
  3. **culture-invariant clinical 약함**(~0.55–0.62), morph가 신호 독점. 강한 feature(MMSE)가 곧 비전이 feature = equity 핵심 메시지.
- **morph 바(영상이 넘어야 할 것):** W 0.66 / K 0.85 / W→K 0.74 / K→W 0.67.
- **방향 확정:** "deep>morph"는 dead(R2). GPU 질문 = **"deep/VLM이 이 비대칭(W→K vs K→W)에서 morph보다 transfer 더 잘/못 하나"** + 중증도·MMSE 비등가 backbone. Path-B 시의성 유지, baseline이 분모.
- **Stage-2a GPU 진행:** image-only 3D CNN(96³ 2mm), `experiments/P4/train_image_cnn.py`.
  - **인프라 교정:** ① `.nii.gz` 순차로딩 timeout → 2mm 병렬캐시 `data/derived/P4/vols_2mm_f16.npy`(2286×96×112×96 f16, 4.7GB, 220s). ② max-autotune 컴파일 timeout → **default compile**로 전환.
  - **T9 검증(smoke):** 컴파일 1회 82s → step **0.1s**(14s/step 재앙 회피 확인). 파이프라인 정상.
  - **smoke 러프(2ep):** W→W 0.67·W→K 0.71 → 이미 morph 바(0.66/0.74)에 붙음 = deep≈morph(R2) 조짐(미결).
  - **full 가동:** WESTERN(GPU2)·KOREAN(GPU3) 각 3-seed×30ep → cnn_{group}_s{0,1,2}.json. 끝나면 transfer 매트릭스 집계 vs morph 바.
  - **★IO 함정(교정):** DataLoader num_workers=4 + 4.7GB mmap 랜덤 페이징 → full에서 epoch 0이 9분+ 멈춤(smoke는 page cache라 안 보임). **해결: 캐시 전체를 GPU 상주(4.7GB on B200) + DataLoader 제거 + manual 배칭** → epoch 9분+ → **~3초**. (insight T12)
  - **검증런(3ep,seed0):** test_W 0.62 / test_K 0.74 = morph 바(0.66/0.74)에 붙음 = deep≈morph(R2) 조짐.
  - **full 재가동:** WESTERN(GPU2)·KOREAN(GPU3) 3-seed×30ep(런당 ~3분). 끝나면 `aggregate_transfer.py`.
- **★누수버그 발견·수정:** 1차 full은 `tr_idx=train+val`로 학습+val로 checkpoint선택 → val≈1.0 암기(R3/T7). **train-only로 수정** → val 정상(0.75 peak→과적합), 결과 신뢰가능.

## 2026-06-16 (저녁) — Stage-2a deep image transfer 결과 (누수수정·3-seed)
- **deep CNN transfer 매트릭스 vs morph:** W→W 0.631/0.653 · W→K 0.730/0.734 · **K→W 0.584/0.666(−0.082)** · **K→K 0.911/0.843(+0.067)**.
- **★핵심 발견:** deep는 within-population에선 morph 비슷~우세(특히 K→K +0.067, Korean이 더 분리되는 과제)지만 **cross-population 전이는 morph보다 *나쁨*(K→W −0.082, drop 더 큼)** → deep가 인구-특이 feature 학습→within 좋고 transfer 안 됨, **morphometry가 더 transportable**. (R1/R2 thesis 일치.)
- **형평성 헤드라인 후보:** "deep AD 모델은 within-population 성능 부풀려지나 cross-population 전이는 단순 morph보다 못함 → naive 배포 위험."
- **caveat:** ① 약한 4-conv CNN + Western 과적합(val 0.75→0.5) → "deep≈morph in Western"은 모델한계일 수 있음(강 backbone 검증 필요) ② K→K +0.067은 Korean 중증도/site 분리일 수 있음 ③ 단일 split. ④ 집계 스크립트 "MORE/LESS robust" 라벨 버그 수정함.
- 산출: `data/derived/P4/cnn_{W,K}_s{0,1,2}.json`, `aggregate_transfer.py`.
- **강 backbone 검증 완료(ResNet+aug, 3-seed):** transfer 매트릭스 cnn/resnet/morph —
  W→W 0.63/0.61/0.65 · W→K 0.73/0.65/0.73 · **K→W 0.58/0.56/0.67** · K→K 0.91/0.88/0.84.
  → **확정:** ① within-Western deep≤morph(강 backbone도 못 올림=약CNN artifact 아님) ② **cross-pop 전이 deep≪morph robust**(K→W −0.10) ③ **강 backbone이 전이 더 악화**(capacity↑→인구특이 feature↑→transfer↓, 메커니즘 강화).
  헤드라인 확정: "deep는 within 성능은 morph 비슷~우세지만 cross-pop 전이는 morph보다 못함, 키우면 더 악화 → naive 배포 위험." 산출 `resnet_*_s*.json`.
- **★Decomposition 완료(BN-adapt cross-pop):** W→K raw 0.605→adapt 0.607(회복 1%), K→W raw 0.581→adapt 0.579(−3%) vs morph 0.73/0.67. → **cross-pop deep gap은 population-level(BN 비가역), acquisition 아님.** AD/CN C4(scanner shift +0.06 회복)와 대비 = "site shift 회복가능 vs population shift 비가역" 분리 확립.
- **P4 4-발견 확정:** ①within deep≈morph ②cross-pop 전이 deep<morph(robust) ③그 결손=population-level(BN 비가역) ④MMSE 인구-비등가(Stage-1). 헤드라인: "deep cross-pop 전이는 morph보다 못하고 그 결손은 비가역 population-level → 인구간 배포 위험."
- **caveat:** seed 불안정(W→K 0.46–0.69, sd 0.12, cudnn 비결정성). K→W는 안정(0.58±0.025). → CI/TOST·seed↑ 필요.
- **★Stats 견고화 완료 — 헤드라인 통계 확정(power 결정적):** cross 셀을 full-target(n=173→**1143**)로 평가(target 전체가 unseen) + 5-seed ensemble + paired bootstrap CI.
  | cell | n | deep | morph | Δ | 95%CI | 판정 |
  |W→W|173|0.650|0.673|−0.023|[−0.110,+0.069]|inconcl|
  |**W→K**|1143|0.624|0.730|**−0.106**|[−0.143,−0.068]|**deep<morph 유의**|
  |K→K|173|0.893|0.837|+0.055|[−0.009,+0.119]|inconcl|
  |**K→W**|1143|0.625|0.687|**−0.062**|[−0.101,−0.022]|**deep<morph 유의**|
  BN-adapt recovery W→K +0.001 / K→W +0.000 = **0% → population-level(비가역), acquisition 아님**.
- **확정 발견:** ① cross-pop 전이 deep<morph **양방향 유의**(n=1143 tight) ② 그 결손=population-level(BN 0% 회복; AD/CN C4 scanner +0.06 회복과 대조) ③ within deep≈morph(유의차 없음, TOST는 n=173이라 미확정) ④ MMSE 인구-비등가(Stage-1).
- **헤드라인(통계 확정):** "deep AD 모델은 인구 간 전이가 morph보다 유의하게 나쁘고 그 결손은 비가역 population-level → 인구간 배포는 morph가 안전." 산출 `stats_summary.json`, `experiments/P4/{train_image_cnn,baseline_preds,stats_robust}.py`.
- **커밋 077f87c** (P4 실증+문서, main). data/derived gitignore.
- **★Fusion arm 완료(ADLIP式 image+clinical, 5-seed):** fusion cross ≈ image-only(W→K 0.623≈0.624, K→W 0.619≈0.625), 여전히 morph보다 유의 낮음(W→K −0.106, K→W −0.068). BN-adapt 회복 ~0%(population). → **clinical 융합이 cross-pop 결손 못 메움**(image population-특이성이 binding liability). "fusion이면 다르지 않나" 반론 차단. 코드 `train_fusion.py`, `stats_summary_fusion.json`.
- **P4 논문 골격 완성**(5발견): cross deep<morph(유의·image+fusion) / population-level(BN비가역) / within≈ / fusion 무구제 / MMSE 비등가.
- **다음(선택):** ① within k-fold로 TOST 동등성 강화 ② 강 pretrained foundation backbone(완성도) ③ 논문 초고/figure. 설계=`docs/P4_crosspop_adlip_plan.md`, 결과=`docs/P4_results.md`.

## 2026-06-16 (밤) — 필요 실험/분석 끝까지 (코드리뷰+산출물 비교)
- **독립 코드감사(code-auditor):** 치명 누수 0(val-leak 수정·cross full-target leak-free·BN-adapt disjoint·morph train-only·정렬 검증). 결함: M1(aggregate_transfer 깨짐→삭제), M2(morph가 train+val로 deep보다 +171 라벨=불공정), M4(단일 split fragility), 잔여 minor.
- **M1 수정:** 깨진 `aggregate_transfer.py` 삭제(stats_robust가 정본).
- **M2 수정(공정성):** morph도 source train-only(799)로 맞춤. 재실행 — morph 약간↓(W→K 0.730→0.715, K→W 0.687→0.680), **cross 양방향 deep<morph 유의 유지**(resnet W→K −0.091[−0.129,−0.053], K→W −0.055[−0.095,−0.015]; fusion 동일).
- **per-cohort 분해:** cross deep<morph가 **4개 target 코호트 전부**(AJU −0.084·KDRC −0.130·ADNI −0.064·OASIS −0.094) = 단일코호트 artifact 아님.
- **M4 split robustness:** 3 split-seed 전부 양방향 deep<morph(W→K −0.091/−0.085/−0.202, K→W −0.055/−0.097/−0.080). 방향 불변, 효과크기만 변동. borderline K→W도 견고.
- **강 backbone:** CNN<ResNet10 capacity 논거(큰 모델이 전이 더 악화)+3모델 일치 → "약한 모델 탓" 약화. **foundation pretrain은 명시적 한계로 scope**(주장=표준 supervised 3D CNN).
- **결론:** P4 claim이 공정성·코호트·split·코드감사 전반에서 robust. 문서 `docs/P4_results.md` §4/§4c/§4d/§7 갱신. 코드 `experiments/P4/{per_cohort,m4_robust}.py` 추가.
- **★강 backbone(brain-age 사전학습) — 헤드라인 정정:** source-only brain-age pretrain→finetune(3-seed). cross: **W→K agepre 0.713 ≈ morph 0.715(Δ−0.002, CI[−0.036,+0.032] 동등) / K→W 0.627 < morph 0.680(Δ−0.053 유의)**; within-Korean agepre 0.909 > morph 0.834(Δ+0.075 유의). → **"deep<morph 비가역 population"은 과함 → 정정:** test-time(BN) 비가역이나 **전이가능 사전학습으론 비대칭 부분회복**(W→K 회복, K→W·= Korean→Western이 가장 취약, 비회복). 코드 `train_agepre.py`·`agepre_compare.py`, 문서 §0/§4e/§5/§7/§8 정정.
- **필요 실험 완료:** per-cohort·M2·M4·코드감사·strong-backbone(agepre) 전부. 남은 한계=대규모 외부 FM(명시). P4 측정/equity 논문 실증부 + robustness 완결.

## 2026-06-16 — 자산 재인벤토리 + P3 주제 설정 (signal decomposition + AD-specificity)
- **manifest 재확인(parquet 직접, datadict 신뢰 안 함):** datadict stale(127 vs 141컬럼, clin_apoe ADNI 0%→실제 94%·OASIS 99.6%).
  ROI=morphometry(fs_vol 전수, roi_final_ready=False=target sign-off만). PET 원본=KDRC만 903. scanner-model ADNI 16종 fine-grained.
- **종단/전환 직접 측정:** 진짜 MCI→AD 전환은 ADNI 앵커(88), 외부 합 ~42(AIBL19/OASIS12/NACC11, A4=preclinical 제외, AJU CDR정적, KDRC 단면). → progression은 transport 불가.
- **★신규 자산:** amyloid 라벨 5코호트 3,774 subj. impaired 내 amyloid+/− 대비는 **Korean 집중**(AJU −629/+344, KDRC −236/+393; 서구 NACC/OASIS 소수). AJU↔KDRC=같은 population/다른 site → R1 청정.
- **실패 통합:** `insight/failure_root_causes.md` 작성(4-사인 R1 site==population·R2 morph천장·R3 평가누수·R4 약한target, 원본 file:line 검증).
- **에이전트 수렴(literature-scout+research-advisor):** 성능논문 dead(R1+R2). 답=measurement/decidability 벤치마크, 엔진=C3 gap-분해. Bron2021이 안 한 morph-분해+Korean amyloid가 차별점. 체급 NeuroImage:Clinical급(top-tier 위험).
- **설정 주제→개정:** `docs/P3_signal_decomposition_plan.md`. **research-critic 조건부 GO**: F1(scanner/population 분리 원리적 불가)·F2(Q2 null=SNAP 문헌 기출판)·F3(AJU↔KDRC 측정법+base-rate 1.77× confound)·M2(C3 미완주). → Q2 헤드라인 강등(within-cohort 보조만), Q1=gap **decidability 지도**(decidable vs 원리적 undecidable), C3=Stage-0 GATE, F1은 within-NACC 독립 2차추정 검증.
- **다음:** ① within-NACC scanner BN-recovery 추정 가능성 확인(F1 사활·CPU) + MCI dx_source base-rate audit ② C3 git `2508378` 복원 → OOF 재생성(GPU 승인) = Stage-0 GATE ③ GATE 통과 시 Q1.

## 2026-06-11 — P2 1.5mm 검증: cortical R² 복원 (해상도가 범인 확정)
- 1.5mm 캐시(128×149×128, 16.5GB) + morph-regression 재실행. **cortical 복원 확인:**
  entorhinal_L −1.07→**0.61** · fusiform_L −2.02→**0.16** · parahippocampal_L −0.63→**0.53** · middletemporal_R −0.21→**0.43**.
  subcortical 유지(ventricle 0.95/0.85·hippo 0.57/0.65·amyg 0.55/0.73). mean R² −0.06→0.23, median 0.41→0.50.
  (precuneus/cingulate 등 thin midline은 여전히 음수 → 1mm 필요할 수도. 회귀 학습 다소 불안정.)
- **판정:** 2mm가 cortical 신호를 죽인 게 맞음(Min 지적 확정). 1.5mm면 이미지가 morph 신호(subcortical+대부분 cortical)에 *공정하게* 접근.
- backbone 확보: `diag_morph_regress_1p5mm_encoder.pt`. **다음: 이걸 init/frozen으로 amyloid LOCO probe + site-invariance(③).**
- ⚠️ 비용: 2mm Stage-1이 ~80분/training(12회 ≈ 다수 시간). 1.5mm full fine-tune LOCO multi-seed는 비현실적(~수십시간) → ③은 frozen-probe 우선.

## 2026-06-11 — P2 진단: 이미지→FastSurfer 부피 재현 (b vs c 판별)
- Stage-1 재해석: image<morph가 (b)천장 증명 아님(약백본/2mm/site-shortcut 혼재). → 진단 실행(image 2mm→fs_vol 회귀, R²).
- **결과(held-out R², subject-disjoint):** subcortical/ventricle **mean 0.67**(ventricle 0.91/0.94·hippo 0.68/0.54·amyg 0.63/0.72) — **모델 정상, 부피 추출 가능**.
  cortical ribbon **mean −0.50**(entorhinal/fusiform/precuneus 음수) — **2mm가 thin cortex 못 잡음 = 해상도 병목**. (자동 verdict "못뽑음"은 mean이 극단음수에 끌린 오판; median 0.41 + 패턴이 진실.)
- **판정:** (b)도 (c)도 아님 → **모델은 subcortical 부피 OK, cortical은 1mm 필요(해상도)**. Stage-1 amyloid 0.63은 ①2mm로 cortical 소실 ②site-shortcut(0.81) 핸디캡. **Min 지적(2mm)이 정확.**
- **다음:** disease (a)/(b) 검정을 **1mm + site-invariance**로 공정하게 재실행. 산출=`results/P2/diag_morph_regress.{json,log}`·`diag_morph_regress_perROI.png`·`diag_morph_encoder.pt`.

## 2026-06-11 — P2 진입: amyloid texture/biomarker CPU + GPU Stage-0 smoke
- **biomarker (amyloid, n~750):** morph+age 0.755 · +regional texture +0.002 · +global texture −0.003 (이미지 texture 무) ·
  **+APOE4 +0.023** · +APOE+cognition +0.026. → amyloid 레버는 이미지 아닌 **APOE/임상 biomarker**. 바 상향: morph+APOE ~0.78.
  centroid std 0.9~2.2vox(뇌 박스 정렬 양호 → native-space regional 우려 일부 완화, 그래도 texture 0).
- **GPU Stage-0 smoke PASS** (`experiments/P2/stage0_smoke.py`, GPU5, resnet10, 2mm, OASIS held-out, 1 seed, 10ep):
  loss 0.726→0.452 하강(학습 정상), held-OASIS AUROC last-3 **0.583** (morph 바 0.72 ↓). 입력=이미지만(누수 0). 파이프라인 검증 완료.
  단 smoke=crude(1 fold·1 seed·minimal aug·no SSL) → 결정 아님. overfit/no-transport 징후(train loss↓ held flat)=minyoung 패턴.
  IO 느림(preload 1000=13분) → Stage1 npy 캐시 필요.
- **다음:** Stage-1 결정 run(full LOCO amyloid·multi-seed·proper train·kill-criteria) — git checkpoint + 확인 후. 설계=`docs/P2_plan.md`.

## 2026-06-11 — rich-data 종단/멀티모달 가능성 점검 (음성)
- 혈액 morph 대비 Δ: dementia +0.005·MCI +0.000·amyloid +0.007 → 어떤 task도 기여 없음.
- 종단 궤적: ADNI만 849 subjects(5.7y, 진행자 246). Korean(rich)은 cross-sectional(1.15 sess/subj, CDR변화 35명).
- **세 어긋남:** feature↔label / rich↔longitudinal(ADNI vs Korean disjoint) / rich↔transport(CN-poor Korean).
- 판정: rich-data 엔진의 별도 flashy win 불가. rich = cross-site benchmark testbed. 연구는 PROPOSAL(morph-weak)로 수렴.
  문서: docs/ledgers/2026-06-11_longitudinal_richdata_negative.md
- 디렉토리 정리: docs/README 인덱스 + investigations/ 분리(commit bf9e7a3).

## 2026-06-11 — 멀티모달/clinical 인벤토리 + novelty deep-research
- **이미징:** T1w 전수(processed). raw_{flair,t2,dwi,pet}_path 컬럼 존재하나 대부분 raw·부분(minyoungi: flair 26%/dwi 13%/pet 7%). amyloid 라벨은 7코호트 광범위(A4 1811·AJU 1286·OASIS 1048·KDRC 534·NACC 515, +ADNI raw). tracer 이질(PiB/AV45/FBB/FMM).
- **★ Korean(AJU/KDRC) 고유 richness (공개셋엔 없음):** korean_multimodal_manifest(2196×89)에 processed flair_final_path·pet_suvr_path + **혈액검사**(hba1c·tsh·ft4·**vitb12·folate**·lipid·CBC·간/신장) + 동반질환(dm/htn/dyslipidemia) + vitals/bmi + GDS + WMH/Fazekas. → "MRI + 혈액바이오마커 치매표현"은 공개 MRI-only 셋이 못 하는 각도.
- **deep-research 완료(104 agents):** D1 missing-modality fusion·D2 imaging+tabular·D3 PET→MRI distillation·D4 VLM = 전부 crowded + **cross-site(LOCO) 증거 전무**. imaging-only SSL "matches morphometry" 주장 REFUTED. **D5 혈액바이오마커+MRI = 유일 whitespace**(공개셋 미보유).
- **★ D5 직접 검증(kill):** Korean 1821세션, morph+age 0.787 → +혈액17종 0.792 = **Δ+0.005(사실상 0)**. "혈액이 AD분류 개선"은 경험적 반증. novel≠작동. (단 morph-약한 task[MCI/amyloid]는 미검증.)
- **판정:** novel(D5)과 promising이 갈림. morphometry 0.93 천장이 공통 벽. 권고=D5를 AD분류로 팔지 말 것; 살아있는 후보=혈액-privileged distillation(upside 작음) 또는 LOCO benchmark 기여. 문서=`docs/novelty_deep_research.md`.
- 주의(critic): 멀티모달은 minyoung2 adapter "코호트 간 공유 안 됨"으로 막힘. PET=amyloid target=누수. dx 정적.

## 2026-06-11 — 다기관 AD/CN + harmonization scout 검토
- 다기관 AD/CN 구성 가능: CN 3909/AD 807, disease-rich 5코호트(ADNI/NACC/OASIS/AIBL/KDRC) 6551세션, confound V=0.24(완화).
- **★ morphometry LOCO 바 = 0.936**(0.92~0.96). morphometry가 cross-site 거의 완벽 transport → CN-vs-AD서 bias는 baseline 병목 아님.
- harmonization scout(top-tier): **IGUANe(MedIA25)가 single-T1w 유일 적합 후보**나 vs morphometry 증거 없음·HC-only라 우리 confound 미대응. ComBat/CovBat/MixStyle NO-GO, CALAMITI/HACA3 multi-contrast 필요 NO-GO. 문헌에 "confound regime서 harmon>morphometry LOCO" 직접 증거 부재.
- **판정:** 진행 기술적 가능, 과학적 신중. CN-vs-AD는 바 0.94=headroom 거의 없음=천장 → harmonization upside 구조적으로 작음. micro-signal headroom은 morphometry 약한 곳(MCI/progression/preclinical). 문서=`docs/harmonization_scout_review.md`.

## 2026-06-11 — P0 audit 실행 완료 (notebooks 01~06, 검증됨)
- 6개 ipynb 실행·검증(코드+그림 임베드). `src/microbrain/audit.py` 1차 primitives.
- **결과:** A0 confound 강(V=0.42, site-only AUROC 0.71) · A1 morph→site 0.27(2×) · A1★ vendor⊥dx clean=A4/ADNI뿐 ·
  A2 voxel→site **0.475(3.3×)**, N4 effect **−0.006**(N4≠harmon) · A3 atlas η²>0.1 = 4% · **A4★ 잔차화 후 disease 0.722 생존(drop −0.05)=SEPARABLE** ·
  A5 LOCO morph→CDR mean **0.766**, in-dist≈LOCO(transport 됨).
- **판정:** bias 실재+분리가능 → P2 진입 근거 O. 결정적 질문=이미지가 site 빼고 0.77 바 넘나(P2/GPU). prior=(b) 천장 여전.
- 산출: `results/P0/P0_AUDIT_REPORT.md`·`P0_summary.csv`·figures 12. 
- **다음(Min 결정):** 메인 주제 프레이밍 확정 + target 정의(CDR≥0.5 vs CN/AD) / A2·A3 full-pass 승인 / P2 설계서.

## 2026-06-11 — 구조 + 다기관 RL 전략 (P0 승인 여전히 대기)
- 디렉토리 목적별 분리: `src/microbrain`(생성)·`experiments/P0_audit/A0~A5`(1실험1질문)·`tests`(누수/split)·
  `docs/ledgers`(음성)·`results/`·`data/derived/`(gitignore). 규약=`docs/REPO_STRUCTURE.md`. **빈 스캐폴드(코드는 승인 후).**
- ★측정: within-cohort vendor⊥diagnosis 확인 — **A4 V=0.012 / ADNI V=0.060 (깨끗)**, NACC V=0.146(얽힘·제외),
  AJU/KDRC CN없음, AIBL/OASIS 단일vendor. → 글로벌 site삭제 말고 **A4/ADNI 내부 vendor로 acquisition-invariance 분리**가
  측정으로 뒷받침되는 유일 진입로. 전략=`docs/multisite_RL_strategy.md`(가설·pre-P0). 마이크로 사다리 M0~M6 + kill-criteria.
- 여전히 (b) 천장이 지배적 prior(null이 1차 결과 가능성 최고). 성공=G1∧G2 동시.

## 2026-06-11 — P0 설계 완료, 승인 대기
- 읽기 완료: BRIEF·CLAUDE·과거실패 3종(minyoung2/4/i)·datadict·README_MANIFEST·SCANNER_BIAS_PLAYBOOK.
- raw inspect 확인: site×diagnosis confound 심각(impaired rate OASIS 20% ↔ AJU 98%) = site가 diagnosis proxy.
  bias 축 사실상 consortium 하나(scanner=vendor coarse, AIBL/OASIS SIEMENS 단일; field_strength KDRC 전무).
  텐서·N4 7코호트 전수 디스크 존재. CPU 스택(sklearn/scipy/nibabel) 가용.
- **`docs/P0_bias_audit_plan.md` 작성**(설계만): A0 confound · A1 morph→site · A2 voxel→site+N4 · A3 bias atlas
  · A4 decidability(★핵심) · A5 morph→CDR LOCO bar. A0/A1/A4/A5 게이트 불필요(CPU). A2/A3만 텐서 1-pass(smoke→full 승인).
- **여기서 멈춤(BRIEF step 5).** Min 승인 전 코드·추출·GPU 금지. 승인 시 §7 순서로 착수.

## 2026-06-11 — 설계 착수
- 라인 생성. `RESEARCH_BRIEF.md`(설계 SoT) + `CLAUDE.md`(운영) 작성.
- 임무 확정: **(a) site/scanner bias 오염 vs (b) 부피 너머 미세신호 천장**을 분리·판정.
- manifest 확정: `/home/vlm/data/preprocessed_official/official_manifest_full_n4_real_final.parquet`.
- 다음: P0 bias audit 설계(`docs/P0_bias_audit_plan.md`) → Min 승인 → 코드.

## 미해결/결정 대기
- [ ] 디렉토리 top-level 승격 여부(현재 minyoung/ 하위, 권한 때문).
- [ ] OBSERVATORY 6번째 워크스페이스로 추적 등록할지.
- [ ] P2 arm 우선순위(A 기반 먼저, B/C는 P0 누수 지도 결과로 조정).
