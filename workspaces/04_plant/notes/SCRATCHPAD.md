# SCRATCHPAD — microbrain (live state)

> 현재 라인의 상태·가설·결과를 여기에 누적. 핸드오프 시 이 파일로 상태 전달. 최신이 위.
> 과거 라인 기록은 `docs/DECISION_LOG.md`·`docs/ledgers/`·`insight/`에 보존됨.

## 2026-06-24 — ΔMMSE 주-outcome 확정 + 나이의존 인사이트
- 임상의 지적(혈관치매 별개라 "MCI→AD" 오명)·진단필드 4개 불일치·dx_detail baseline고정(0/286)·follow-up 세분 부재 확인 → **outcome을 ΔMMSE(etiology무관)로 전환**. 전환=치매진행(병인불문) 보조+한계.
- AJU 종단 검증: **2-wave only**(3회+ 0명), 295명 V2, median 1.94yr, 29% 추적, V2 실제 재평가. → "trajectory" 과대포장 금지, "2년 ΔMMSE".
- 주: amyloid β−1.39(p=0.002)·vascular β−1.28(p=0.004) ΔMMSE 독립·**가산**(교호 p=0.89), ΔCDR 일관.
- **★추가 인사이트: amyloid×age p=0.001 (Bonferroni 통과)** — amyloid 예후효과 *젊은 MCI서 강·고령서 소멸*. 임상 actionable. (edu교호 p=0.04 탐색적; APOE null; SUVR 용량반응 β−5.7.)
- 헤드라인 정정: "전환 47%"→"amyloid·vascular가 2년 인지쇠퇴 독립·가산 예측 + amyloid 나이의존". 산출 `docs/clinical_paper/12_dmmse_insights.md`, 코드 `11_dmmse_primary.py`.

## 2026-06-24 — positioning 확정 (delta reposition·JCN·인용정정)
- lit-scout(ART2026·Ye2015 정독): finding 방어가능, 단 **"두 독립축"은 delta 아님** — Vemuri2015 Brain("vascular·amyloid independent predictors", 정상노인)·K1(ART2026, 비치매 community, WMH부피, plasma통제)·K2(Ye2015 Neurology, SVaD치매 n61)가 점유.
- **방어 delta = 실세계 MCI clinic + MCI→AD 전환(Cox HR) + 가산 위험층화(47%vs1.5%) + "vascular=WMH부피 아닌 임상 병인라벨"(부피 null, K1/K2 정반대).**
- **베뉴 = JCN(IF~3) 1지망.** ART는 K1 근접으로 risk → 제외. 임상·실증 fork.
- 정정: 혈액=루틴검사만(p-tau217 등 혈장AD마커 미통제) → "혈액 null"=루틴한정+한계명시. 인용 Ye BS 2015(≠Lee2016).
- 미해결: Vemuri2015 본문 정독·K1 전환HR 여부. 산출 `docs/clinical_paper/20_manuscript_outline.md`.

## 2026-06-24 — 이중축 paper-ready 확정 (full 보정·Cox·2×2)
- 사전지정 모델만(조작 없음). **두 축 견고:** amyloid ΔMMSE β−1.86(p<0.001)·전환 Cox HR2.90(p=0.046); vascular-etiology β−1.03(p=0.021)·HR3.36(p=0.011). within-MCI 둘 다 p<0.005. **2×2 가산:** amy+vasc 전환 39% vs neither 2%.
- nuance(기록): vascular는 연관 유의·CV예측증분 약함; **AI-WMH(객관 부피)=null**(age corr0.42, full바 p=0.13)→vascular 신호=병인패턴≠부피; hippo 구조는 예측기여(+0.028).
- AI 위치: 파이프라인 도구(FastSurfer·DL-SUVR)만, novel AI 컴포넌트 없음. LLM=자유텍스트 0이라 자리 없음.
- 산출: `docs/clinical_paper/11_final_results.md`·`10_research_plan.md`(claim 갱신)·`figs/final_two_axis.png`. 코드 `experiments/incremental_value/10_final_analysis.py`.
- 미해소: ART2026 본문(tier)·Lee2016 정독(delta)·외부확인(KDRC 종단 가용성).

## 2026-06-24 — 연구계획(중간): amyloid–vascular 이중 예후축
- EDA(07)+빈틈감사(08)로 "amyloid only" 오류 정정 → **이중 독립축**: amyloid β−1.96(p<1e-4, MCI→AD 전환 20%vs5% p=3e-4) + vascular etiology β−1.20(p=0.008), full 통제. amyloid음성-AD 17명=혈관/혼합 11/17. 페어링 무결·SUVR신뢰(AUC0.966)·interval 보수적·바닥효과 없음 전부 감사 통과.
- **권위 계획서: `docs/clinical_paper/10_research_plan.md`** (메인주제·RQ1-4·Task/실험 E1-8·Figure·delta·게이트). 00/01 parsimony 프레임 대체.
- 미해소 게이트: ART2026 본문(tier)·E2 full임상바 재현·Lee2016 정독(delta).
- 코드 `experiments/incremental_value/00-08`.

## 2026-06-24 — 최종 판정(중간): 확실한 주제 없음→이중축으로 전환 (incremental-value/longitudinal)
- goal: (A)amyloid-비선형 + (B)전략 둘 다 확인 후 확실한 주제 finding 존재 여부.
- **(A) 죽음:** amyloid 인지-status 비선형 added-value = Giorgio 2020·MEMENTO 2025 점유.
- **종단 탈출구 검증(3게이트):** G1 interval(edate 복원 295명 median 1.94yr)·G3 robustness(Ridge+GBM, 2 outcome) **통과** — baseline amyloid가 인지쇠퇴/conversion 유일 예후 모달리티(ΔMMSE +0.058, GBM +0.092). **G2 점유 FAIL** — Lee 2016 Neurology(한국 amyloid 종단)·Younes 2025 Alz&Dem·effect "small"(PMC8233225). 살아있는 niche=(b)full-stack modality-specific+(c)K-ROAD종단공백뿐, 좁고·결과의존·만료.
- **amyloid-음성 검정(06)으로 완결:** amyloid+ ΔMMSE −1.80(예측가능) vs amyloid− −0.22(어떤 모달리티로도 예측불가) → 예후=amyloid-구동 완성.
- **결론: novel-headline 없음, 그러나 commit 가능한 중위 임상 SCI 주제 있음.** 주제="실세계 Asian의 modality-specific×amyloid-층화 종단 예후 지도"(full-stack 통제, amyloid만 예후, amyloid−다수 안정). 체급 JAD/JCN~ART, top 아님. delta=(b)+(c)+실세계Asian, 데이터/프로토콜 기여.
- 남은 단일 게이트: **ART2026 본문**(full-stack modality-specific 했나) → 안 했으면 ART, 했으면 JAD.
- 산출: `docs/clinical_paper/05_final_verdict.md` §commit, 코드 `experiments/incremental_value/00-06`.

## 2026-06-24 — 디렉토리 연구 라인 전수 파악
- 요청: `/home/vlm/plant`에서 진행 중/과거 연구 라인을 전부 파악.
- 확인 문서: `RESEARCH_BRIEF.md`, `docs/DECISION_LOG.md`, `docs/clinical_paper/*`, `docs/ledgers/*`, `insight/*`, `src/microbrain/audit.py`, `experiments/incremental_value/00_assemble_cohort.py`.
- 현재 활성 라인: **임상 SCI incremental-value/parsimony 논문**. K-ROAD가 Korean memory-clinic 멀티모달 구축·amyloid/ethnic 분포를 이미 점유했기 때문에, 남은 delta는 AJU all-3(T1+FLAIR+amyloid PET) + 혈액/APOE에서 모달리티별 한계기여를 leakage-free nested CV와 TOST 등가검정으로 정량하는 것.
- 새 코드 상태: `experiments/incremental_value/00_assemble_cohort.py`가 AJU all-3 file-verified 분석 테이블을 `data/derived/incremental_value/aju_analysis_table.parquet`로 조립하는 스캐폴드. 129K parquet 산출물이 존재하나, 이번 파악 중 sandbox Python/bwrap 오류로 내부 shape 재검증은 못 함.
- 종료/폐기 라인: microbrain bias-robust T1 표현(P0/P2), P3 구조 MRI 신호분해, P4 서양-vs-Korean cross-pop AD 전이, rich-data longitudinal/혈액 incremental 라인은 모두 NO-GO/체급부족/천장으로 닫힘. 근거는 `docs/DECISION_LOG.md`, `docs/ledgers/`, `insight/empirical_findings.md`.
- 주의: 작업 중 `experiments/korean_clinical_original_parse_eda.ipynb`, 재생성 스크립트, `apoe_mri_qc_jpg/`가 현재 디스크에서 사라지고 `experiments/incremental_value/`가 생긴 상태를 확인. 사용자/외부 변경으로 간주하고 되돌리지 않음.

## 2026-06-24 — 임상 SCI 논문 라인 착수 + K-ROAD 정독 세팅
- 라인 재정의: microbrain ML-novelty 닫힘 → **임상 SCI 베뉴 고정**(자산=희귀 Korean 멀티모달 데이터). 메모리 [[clinical-sci-venue-target]]·[[kroad-occupancy-threat]].
- 데이터 feasibility 검증(GPU 없이, manifest 직접): AJU all-3(T1+FLAIR+PET) 파일-검증 963·blood완비 863; 멀티모달 인지예측 한계기여 +0.03 R²(T1 위, 전 seed robust); amyloid–etiology dissociation AD~81% vs 혈관~10%.
- 정정(Min 지적): ADNI amyloid *있음* — `v2/manifests/official_v2_t1w_pet_pair_manifest.csv` 709 paired + 전처리 SUVR 텐서 1792(디스크) + UCBERKELEY_AMY_6MM(오프로드, Centiloid 골드). 스칼라 index만 미빌드. [[multimodal-data-inventory]] 갱신.
- literature-scout: 타깃 사다리(Reach ARL~7.6 / Primary JCN 3.1 SCIE·JAD / Safety BMC Neurol; DADM은 ESCI 주의). **최대 위협=K-ROAD**(28-center n=5856)가 헤드라인 ①② 선점 → 방어선=②분포+③한계기여 null 통합, ① 강등.
- 세팅: `docs/clinical_paper/`{README, 00_positioning(claim-first+delta 게이트), lit/_landscape, lit/kroad_2024}. 다음=K-ROAD full text 정독 → delta 한 문장 확정.
- 미해결 게이트: (1) 기관 SCIE 요건(tier 결정), (2) K-ROAD 대비 delta.

## 2026-06-22 — 디렉토리 내부 분석 산출물 점검
- 요청: 현재까지 진행한 디렉토리 내부 분석 결과 확인.
- 확인 파일: `experiments/korean_clinical_original_parse_eda.ipynb`, `experiments/build_korean_clinical_original_parse_eda_nb.py`, `experiments/apoe_mri_qc_jpg/`.
- Git 상태: `experiments/...` 산출물은 untracked, `CLAUDE.md`와 `SCRATCHPAD.md`는 modified 상태. 기존 산출물은 수정하지 않았고 이 점검 기록만 추가.
- 노트북 출력 요약: full manifest `(13022, 141)`, Korean manifest `(2196, 93)`; Korean rows는 AJU 1287, KDRC 909. 원본 clinical 파싱은 AJU BL 1322행, AJU TFU 295행, KDRC 576행이며 key missing 0.
- raw-manifest 대조: AJU session 1287/1287 match, KDRC 534/909 match, KDRC unmatched 375행은 `demo_source` 결측 구조와 연결됨. 비교 테이블의 핵심 raw-derived vs manifest mismatch는 0.
- APOE-MRI QC: `dx_session` 기준 eligible 2056행, T1w path exists 2056/2056, duplicate consortium+subject+session key 0. 클래스별 JPG 5개(`CN`, `MCI`, `AD`, `OtherDementia`, `Other`)와 `apoe_mri_qc_index.csv` 존재 확인.
- 이미지 직접 view는 sandbox bwrap 오류로 실패했으나, PIL로 JPEG dimensions/pixel stats 확인: 각 JPG는 `(1365,3432)` 또는 `(1365,2574)` 크기이며 grayscale std 약 64-69, extrema `(0,255)`로 비어 있거나 단색인 파일은 아님.

## 2026-06-18 — Korean 원본 clinical 파싱/EDA 노트북 생성
- 용량 해석 보정: 사용자가 지적한 대로 현재까지 일반 경로 스캔으로 확인한 visible 큰 트리 합계는 `df`의 12T 사용량에 못 미침. `/home/vlm`은 GPFS 15T 중 12T 사용, inode는 33M 중 32M 사용(98%). 따라서 현재 보고값은 "접근 가능한 visible subtree의 apparent-size"이며, 실제 `df` 차이는 GPFS quota/fileset/snapshot/deleted-open file/권한 없는 트리/블록 accounting 차이까지 확인해야 함. 긴 `find` 스캔은 GPFS I/O에서 D-state로 멈춰 종료 처리.
- 추가 용량 조사: `df`의 15T/12T는 GPFS 파일시스템 전체 사용량이며, visible subtree apparent-size와 1:1 대응하지 않을 수 있음. 접근 가능한 큰 데이터 트리 기준으로는 `/home/vlm/data/FOMO300K`가 약 2134.2G로 최대. 내부 top: `PT030_OpenNeuro` 1115.1G, `PT020_HCP_Wu_Minn` 328.7G, `PT018_HBN` 222.3G. `/home/vlm/data/preprocessed_official/v2` cohort 합산은 약 370G대(AJU 85.4G, KDRC 65.5G, OASIS 60.6G 등). raw는 약 786.2G.
- raw top-level 용량 확인: `/home/vlm/data/raw` apparent-size 합산 기준 약 786.2G. 큰 순서: oasis3 263.8G(33.6%), ADNI 170.0G(21.6%), KDRC 132.9G(16.9%), A4 98.7G(12.6%), NACC 63.0G(8.0%), AJU 57.8G(7.4%). top3가 약 566.7G(72.1%).
- 추가: APOE와 MRI row 매칭을 눈으로 확인하기 위해 `experiments/korean_clinical_original_parse_eda.ipynb`에 APOE-MRI QC 섹션 추가.
- 산출물: `experiments/apoe_mri_qc_jpg/apoe_mri_{CN,MCI,AD,Other,OtherDementia}.jpg`와 `experiments/apoe_mri_qc_jpg/apoe_mri_qc_index.csv`.
- QC 결과: `dx_session` 기준 eligible 2056행, T1w path exists 2056/2056, duplicate consortium+subject+session key 0. 클래스별 montage는 sagittal/coronal/axial mid-slice와 subject/session/APOE/e4/MMSE 라벨을 같이 표시.
- 시각 확인: `apoe_mri_CN.jpg`를 열어 MRI와 APOE 라벨 가독성 확인 완료.
- 요청: Korean(AJU·KDRC) 데이터를 canonical manifest 기준으로 가져오고, 원본 clinical Excel을 보수적으로 파싱해 EDA하는 ipynb 작성.
- 생성: `experiments/korean_clinical_original_parse_eda.ipynb`; 재생성 스크립트 `experiments/build_korean_clinical_original_parse_eda_nb.py`.
- 데이터 기준: `/home/vlm/data/preprocessed_official/official_manifest_full_n4_real_final.parquet`, `/home/vlm/data/preprocessed_official/korean_multimodal_manifest.csv`.
- 원본 clinical: AJU `/home/vlm/data/raw/AJU/metadata/임상역학정보 분양_all.xlsx`(실제 파일명은 NFD라 notebook에서 NFC resolver 사용), KDRC `/home/vlm/data/raw/KDRC/clinical.xlsx`.
- 파싱 검증: AJU BL 1322행·TFU 295행, KDRC 576행; key missing 0. 핵심 numeric 변환 실패 0.
- manifest 대조: AJU 1287/1287 session raw clinical 매칭, KDRC 534/909 session raw clinical 매칭; KDRC unmatched 375는 manifest의 `demo_source` 결측 375와 일치. raw-derived 핵심 변수와 manifest 비교 mismatch 0.
- EDA 포함: diagnosis/MMSE/amyloid/SUVR 분포, modality coverage, cohort별 missing-rate heatmap, numeric describe.
- 다음: 노트북 결과를 열어 mismatch=0과 KDRC 결측 구조를 확인한 뒤, clinical text schema 또는 분석 타깃 설계로 넘어갈 수 있음. KDRC 환자 인구학은 raw Excel의 보호자 정보와 혼동 금지.

## (과거 라인 정리 — 2026-06-24)
- old-line 삭제: `RESEARCH_BRIEF.md`·`src/microbrain/`·`insight/` (git `6fafde2`에서 복구 가능).
- 현재 라인 가드레일은 `docs/clinical_paper/02_inherited_guardrails.md`로 증류 보존.
