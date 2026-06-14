# 한국 멀티모달 AD 프로그램 — 기록·실패지점·insight (2026-06-14)

> 자체완결 기록. 프로그램: `experiments/⭐_20260613_korean_AD_multimodal/`.
> 목표였던 것: 한국 tri-modal(amyloid-PET+FLAIR+structural+혈액+APOE)로 Alzheimer's & Dementia급 멀티모달 특성화.
> **한 줄 결론**: 3 phase 검증 완료, 천장 = **mid-tier 임상**(A&D stretch). atlas/fusion/SSL은 측정-사망. mid-tier 방조차 일부 선점. 천장돌파 레버는 분석 아니라 데이터(pTau217).

## 0. 데이터 상태 (ground-truth 재확인, 독립 audit)
- manifest 2196 rows × 89 cols. tri-modal(T1+FLAIR+PET) **1836**(KDRC 873 + AJU 963).
- **SSL/atlas 가용 N = label-free T1 2196**(전수 디스크 존재, **192×224×192 @1mm RAS**, 0 unreadable). FLAIR 2148, PET 1882. (tri-modal 1836은 cross-modal 학습에만 제약.)
- **longitudinal: tri-modal 종단 = 0** (V2 follow-up은 T1+FLAIR만, **PET=0**). dx변화 31 / CDR변화 35, T1-only. → PET conversion 원천 불가.
- **tau/CSF/plasma/NfL/GFAP/FDG 전무**(확인). amyloid는 PET 유래만.
- scanner/manufacturer 메타 *manifest엔 없음*. site는 consortium(KDRC/AJU)+AJU 8 sub-site.
- KDRC 라벨 비대칭: 909 중 **375 imaging-only**(임상·유전·혈액 전무). 라벨이 cohort-orthogonal(amyloid_suvr/fazekas=KDRC전용, bmi/edu/wmh_grade=AJU전용) → pooled supervised 누수 위험.

## 1. Phase 1 — 결정인자 (🥉 confirmatory, 검증완료)
- amyloid←APOE(β+0.37)+맥압PP(PP-only β+0.13, MAP 무효=진짜 맥압효과). WMH←HTN(β+0.18). atrophy←APOE(β+0.23).
- **검증이 잡은 결함**: p-floor 버그(모든 p=0.004 가짜), atrophy ICV-미정규화(→DM/BMI 소멸=머리크기 artifact), tchol-ldl 공선(VIF8.5→LDL→WMH 철회), **AJU-only(complete-case 924 전원, KDRC=0)**.
- **선점**: Kang2023(Alz Res Ther, 한국 N=1175)가 핵심 프레임 선점. **PP needle도 A4/LEARN 2025가 선점** → 🥈 철회, confirmatory.

## 2. Phase 2 — 멀티모달 subtyping (☠️ subtype-discovery dead, 🥉 continuous)
- ordinal-WMH(3값) 포함 3축 GMM → **WMH 단일축으로 붕괴**(축 Δ: amyloid 0.07, vascular 1.92, atrophy 0.12).
- **bootstrap ARI 0.75±0.43**(SD가 평균 56%=불안정; auto-게이트가 SD 무시해 "안정" 오판정).
- 연속축(amyloid+atrophy) FULL N=1826: k=2 sil 0.42지만 = **AT(N) positivity(Jack2018 기존틀)**.
- **결론**: discrete multimodal subtype *부재* → 연속 co-pathology gradient. negative지만 *positive measurement*(continuous-vs-discrete 논쟁 기여, Prosser2024 unsubtyped과 동방향).

## 3. Phase 3 + 3b — PET 증분가치 (🥉, 검증완료·de-overclaimed)
- **T2 CN/AD**: clinical 0.652→+APOE 0.822(+0.170)→+vasc+meta 0.905(+0.083)→+morph 0.943(+0.038)→+WMH 0.943(Fazekas 15%결측, 보류)→**+PET 0.946 (+0.003 [−0.001,+0.006] CI∋0=redundant)**. dx 비순환 확인(dx_source=임상 SD-code, PET유래 0).
- **T1 amyloid status(PET제외)**: 비-PET AUC 0.793. "irreplaceable" 과장 → **"부분회복, 확정엔 PET 필요"로 철회**.
- **3b MCI(실제 PET 용처, n=823 AJU713+KDRC110)**: 비-PET AUC **0.760**(clinical 0.611→+APOE 0.737이 거의 전부, **+영상/혈관/대사 ΔAUC CI∋0=0**). triage: 최저위험 **15%는 NPV≥0.90으로 PET 생략 가능**(30%면 NPV 0.87). cross-cohort: KDRC→AJU 0.704, AJU→KDRC 0.723("붕괴없음"만 주장, '일반화'는 과장). cohort 비대칭: **KDRC-MCI pos 0.47·APOE 0.55 vs AJU 0.30·0.26**(prevalence+유전 shift).
- 🐛 검증이 잡은 버그: triage가 변수 재사용으로 AD에 계산(NPV<base 이상신호)→수정.
- **선점**: MCI amyloid-without-PET 한국 출판 **0.856/0.835 > 우리 0.76**. triage는 plasma pTau217(0.935)이 점령.

## 4. Atlas/voxel/SSL 학습 — ☠️ 측정-사망 (사용자 제안 직접 판정)
- 사용자 분기점("ROI 정보손실이면 atlas가 뚫고, 원영상 정보부재면 못 뚫는다")에 대해: **자체 측정이 답=원영상 정보부재**(intensity 0.88 < morpho 0.91, residual ΔAUC +0.0001).
- 3벽: scale(2000 = SOTA 5%, BrainIAC 0.735<morpho), 선점(Dalca NeurIPS19/AtlasMorph MedIA25; Korean template KOR152·2016), 2-site(site-invariance 불가, traveling 0).
- **유일 viable 조건**: downstream을 image-headroom task(WMH/lesion seg, PET-SUVR 예측)로 전환 — AD 라벨 자산 포기.
- → "atlas 학습"은 fusion/SSL 실패의 *우회로가 아님*. 같은 벽. GPU 투입 = 5번째 부검.

## 5. 정직한 천장 + 남은 출구 (새 GPU 0)
- 천장: **mid-tier 임상(NeuroImage:Clinical/JAD)**. A&D stretch. 일부 mid-tier 방도 선점(#8-10 in INDEX).
- **A. 임상 1편**: headline=continuous co-pathology(triage 아님, 선점됨). Phase1(AJU-only 명시)+3 보조.
- **B. negative-result 방법론 1편**: dead-end map 자산화(foundation 패배 측정). 덜 선점. ⚠️ third-party 검증축 필요 + site=pop 프레임 폐기.
- **C. 데이터 unlock(진짜 레버)**: plasma **pTau217**(AJU 잔여혈액 assay 가능시) — 영상 vs 혈액 vs 둘다 증분구조 = 덜 닫힌 질문. [VERIFY 가능여부].

## 6. 핵심 정정 (이전 인식 오류)
- 🔴 "site=population irreducible" — *우리 자신의 E2가 반증*(p=0.79). 천장 이유는 site혼입 아니라 *imaging 정보부재*(이유 다르나 천장 동일).
- 🔴 SSL 가용 N은 1836 아니라 2196(label-free).
- 🔴 longitudinal은 "36건"보다 나쁨 — tri-modal 종단 0(V2 PET 없음).

## 증거 위치
- 프로그램: `experiments/⭐_20260613_korean_AD_multimodal/` (REGISTRY.md, 0X/SUMMARY.md, 0X/reports/).
- 이전 closure: `docs/context/FAILED_*.md`, `experiments/CLOSED_negatives/`.
- 검증 에이전트(2026-06-14): research-advisor(scooping·atlas), data-audit(ground-truth), literature-scout(atlas/SSL 규모요건).
