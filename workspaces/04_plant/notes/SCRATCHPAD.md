# SCRATCHPAD — microbrain (live state)

> 현재 상태·가설·결과를 여기에 누적. 핸드오프 시 이 파일로 상태 전달. 최신이 위.

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
