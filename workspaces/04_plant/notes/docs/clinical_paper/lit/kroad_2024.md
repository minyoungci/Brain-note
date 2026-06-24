# 정독: K-ROAD (Kim H.-R. et al., 2024)

- **Citation:** Korea-Registries to Overcome Dementia and Accelerate Dementia Research (K-ROAD). *Dementia and Neurocognitive Disorders* 23(4):212.
- **DOI:** 10.12779/dnd.2024.23.4.212 · PMC11538854
- **상태:** ✅ 정독 (full text, 2026-06-24)

## 설계 / N / 코호트
- **28개 병원 기반 센터, N=5,856** (2023-12 기준), 2019-05~2023-12.
- 3개 prospective sub-cohort(PREMIER, LLOD, SMC amyloid PET registry). **memory clinic 기반.**
- prospective open cohort지만 **종단 추적 불완전**(저자 명시: PREMIER 미추적, 예후 연구 제약).

## 보유 데이터 (★우리 차별점과 직접 충돌)
- 영상: 3D T1(필수), **FLAIR(LLOD 필수)**, optional DTI/rs-fMRI.
- **amyloid PET: PiB/FBB/FMM → Centiloid 조화.** tau PET(flortaucipir, n=275).
- **혈장 바이오마커: Aβ40/42, GFAP, NfL, p-tau181/231/217.** (우리 *없음* — 그들이 앞섬)
- **루틴 혈액검사 보유:** WBC·RBC·Hb·Hct·PLT·ALT·AST·BUN·Cr·Glucose·HbA1C·HDL·TChol·LDL·TG·TSH·FT4·Folate·VitB12 — **우리 22종과 사실상 동일.**
- **FLAIR/WMH: modified Fazekas 시각평가 + lacune + microbleed 정량.**
- 유전: APOE, microarray(n=4787), WGS 30×, **DNA methylation(EPIC 850K).**
- 인지: SNSB-II, K-MMSE, CDR 등.

## amyloid+ 비율 (Centiloid≥20)
| 군 | N | Aβ+ % |
|---|---|---|
| CU | 1249 | 20.8 |
| MCI | 2595 | 48.6 |
| DAT | 1277 | 79.6 |
| **SVCI(피질하혈관)** | 583 | **35.2** |
| FTD | 152 | 13.8 |

## etiology 정의 — **영상이 진단기준에 *공식* 포함** (우리 순환성 우려=field 표준)
- 범주: ACS(CU/MCI/DAT) · SVCI · FTD.
- **SVCI 진단이 MRI 중증 허혈을 *요구***: periventricular WMH ≥10mm + deep WMH 최장경 ≥25mm. → post-hoc 아닌 *criterion*. (우리 dx_detail 혈관 라벨의 순환성과 동일 구조)

## ethnic/population 주장 (ADNI 비교 *이미 수행*)
- Korean CU의 Aβ+ < NHW CU (MCI/DAT는 차이 없음).
- 같은 Aβ+여도 Korean이 CU·MCI에서 인지저하 *더 빠름*(DAT는 아님).
- 교육 median 12y(K-ROAD) vs 16y(ADNI NHW). APOE rs429358의 Aβ 효과가 Korean에서 더 강함.

## 저자 명시 한계 / 안 한 것
1. 종단 불완전 → 예후 연구 제약.
2. **DLB 미포함**(우리도 사실상 없음 — DLB n=4).
3. tau PET은 n=275뿐.
4. **단일기관 deep 통합 안 함 / 멀티모달 *한계기여(incremental value)* 분석 안 함**(데이터는 "ML에 쓸 수 있다"고만 언급) / real-world utility(비용·진단시간) 안 함 / ADNI와 *동일 셋업 head-to-head*는 안 함.

## 우리 헤드라인 위협 판정
- ① etiology–amyloid dissociation: **점유**(위 표가 정확히 그것, n=5856).
- ② ethnic 분포차: **점유**(ADNI 비교 수행).
- "혈액22종 통합" 차별점: **소멸**(동일 패널 보유).
- "FLAIR/멀티모달 통합" 차별점: **소멸**(더 많이 보유).
- "더 깨끗한 감별로 더 깨끗한 분리"(우리 혈관 10% vs SVCI 35%): 정의 차이일 뿐, delta로 약함.

## 남는 *비점유* 틈 (유일하게 살아있는 것)
- **③ 멀티모달/혈액의 인지(또는 진단) *한계기여(incremental value)* 정량** — K-ROAD가 *명시적으로 안 함*. 우리 +0.03 R²(T1 위)가 직접 답함. = **parsimony/“multimodal 필수론 반례” 메시지.**
- (약함) AD+SVD·AD+vascular 같은 *혼합형 etiology 세분*은 K-ROAD의 ACS-vs-SVCI 이분보다 finer — 단 N 얇음(68/45).

## delta 후보 한 문장 (잠정)
"풍부하게 표현형화된 실세계 코호트에서도 멀티모달 영상+혈액의 *한계기여는 작다*(구조 T1이 대부분 운반) — K-ROAD가 구축만 하고 수행하지 않은 incremental-value 정량."
→ 단 이건 **null·단일기관**이라 ARL이 아니라 JAD/JCN/DADM 체급.
