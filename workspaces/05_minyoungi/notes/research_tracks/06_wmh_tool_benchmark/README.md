# MIN-WMH — Multi-cohort Inter-tool benchmark for WMH quantification & Neurodegeneration-inference

_("MIN" = **M**ulti-cohort **I**nter-tool **N**eurodegeneration-inference. Track 06. 생성 2026-06-16.)_
_**named 기여** (GT-free clinical-validity benchmark + tool choice가 임상 추론을 바꾸는가). Track 04 임상 논문과 직결._

## 코호트 현황 (2026-06-16, multi-consortium FLAIR — 실측 확정)
| 코호트 | 인구 | FLAIR | amyloid | synthseg β(p) | 3-tool(SYSU/SHIVA) | 역할 |
|---|---|---|---|---|---|---|
| **OASIS** | 미국 | native 2D 5mm | A− 242 | **−0.115 (0.002)✓** | ✅ 完 (SYSU 놓침/SHIVA 검출) | **headline + robust 복제✓** |
| **A4** | 미국 | native 2D 5mm | A+ only 250 | **−0.146 (0.000)✓** | 🔴 nohup 진행 | A+ 비교 |
| **AJU** | 한국 | native 5mm (Stage E) | A− 96 | +0.034 (0.64)✗ | 🔴 nohup 진행 | native 해상도 검정 ⚠️ |
| KDRC | 한국 | registered (native 5/20) | A− 69 | Track04 完 | — (native 부족, 보류) | directional |
→ **3코호트 active eval, 2인구(한국+미국).** ⚠️ **ADNI 제외**(다운로드=T1전용, FLAIR 1건). AIBL/NACC도 FLAIR 없음. FLAIR-보유 코호트는 AJU·KDRC·OASIS·A4 4개가 전부.
→ ⚠️ **AJU native n=96 = null**: 원래 Track04 AJU(registered 1mm, n=643)=β−0.123. 차이는 해상도+표본 동시교란 → M2 robustness로 정직히 다룸(RUN_STATUS 참조).

## 도구 (multi-paradigm)
1. **WMH-SynthSeg** (domain-randomization) — 보유, 코호트별 실행 중
2. **ANTsPyNet** (SYSU-media 챌린지우승·SHIVA — TF, 격리 venv) — 셋업 중
3. LST-AI (torch, MS) — 추후

## ⭐ 핵심 기여 (왜 novel)

대부분 WMH 벤치마크 = **manual GT 대비 Dice** (curated 데이터). 한계: (1) GT가 비싸고 rater-편향, (2) curated 데이터는 실제 임상 이질성 미반영, (3) Dice가 *임상 유용성*을 측정 안 함.

> **우리 프레임워크: GT 없이, 다site 한국 임상 FLAIR에서 WMH 도구를 *임상 타당도·강건성·유용성*으로 평가.**
> = "어느 WMH 정량 도구를 실제 임상에서 믿을 수 있나" — Dice가 아닌 *clinical validity*. 프레임워크 자체가 기여.

## 평가 도구 (3, 서로 다른 패러다임)
1. **WMH-SynthSeg** (domain-randomization 합성학습) — 보유
2. **ANTsPyNet WMH** (supervised, SYSU-media 챌린지 ensemble) — antspynet pip
3. **LST-AI** (DL, MS-lesion 학습) — git pip
(선택 4. nnU-Net WMH — 가중치 확보 시)

## 평가 metric (GT 불요 — 이게 핵심 설계)
| # | metric | 무엇 측정 | 데이터(보유) |
|---|---|---|---|
| M1 | **Concurrent validity** | ρ(도구 WMH, visual grade) — 임상 reference 추적 | AJU wmh_grade / KDRC Fazekas |
| M2 | **Cross-resolution robustness** | CCC(native 5mm, registered 1mm) — acquisition 재현성 | Stage E paired ~100 |
| M3 | **Cross-scanner stability** | scanner/site 효과 크기(age보정) — 낮을수록 robust | scanner-model 데이터 |
| M4 | **Construct validity(혈관)** | HTN/DM→도구WMH 효과크기 — 혈관병리 반영도 | AJU 혈관인자 100% |
| M5 | **Downstream utility** | amyloid-음성 WMH→해마 연관 강도(Track04) — 임상신호 검출력 | Track04 코호트 |
| M6 | **Inter-tool agreement** | 도구쌍 CCC 행렬 | — |
| M7 | **Failure/outlier rate** | QC 실패·비현실적 부피 | — |

→ 각 도구를 M1-M7로 점수화 = "robustness/validity 프로파일". 단일 승자 아닌 *trade-off* 보고(정직).

## 데이터셋 (multi-consortium, 실측 2026-06-16)
**핵심 = cross-population tool-dependence (M5).** amyloid-음성 + FLAIR + 해마 보유:
- **AJU 851** (한국, FLAIR=raw DICOM→dcm2niix 변환 필요)
- **KDRC 492** (한국)
- **OASIS 718** (미국 community, FLAIR 665 nii.gz raw) ⭐ cross-population
- 보조(broad metric만): A4(전원 amyloid양성=A−0), ADNI(amyloid manifest 부재→외부 UCBERKELEY join 필요, 보류)
- 해마·amyloid는 코호트별 컬럼 → 이진 amyloid harmonize 필요(aju_amyloid/kdrc_visual/oasis_positive).
- native 5mm cross-resolution(M2): AJU Stage E ~100.
- **staged subset**: 균형 ~150-200/코호트(AJU·KDRC·OASIS) = ~500 우선 → 검증 후 확대.

## ⚠️ 데이터 엔지니어링 (S2 전)
- FLAIR 형식 코호트별 상이: OASIS=nii.gz raw, AJU=DICOM(변환), KDRC=raw → **공통 raw FLAIR NIfTI 확보** 필요.
- 각 도구가 자체 전처리 → raw FLAIR 입력(z-score 아님).
- amyloid 이진화: 코호트별 cutoff/라벨 harmonize.

## 단계 (하네스 + 게이트)
- **S1 (설치, 승인 대상)**: antspynet + LST-AI 설치 + smoke (각 1-2장, 출력 sane?)
- **S2 (GPU, 승인)**: 공통 subset에 3도구 추론
- **S3 (CPU)**: M1-M7 평가 + 프로파일 표/그림
- **S4**: 확대(전수) + 매뉴스크립트

## 정직한 한계/리스크
- GT-free라 "절대 정확도" 못 말함 → *상대 타당도/강건성*만(이게 의도된 framing).
- ANTsPyNet WMH 함수·LST-AI WMH 적용성 [VERIFY](설치 후 smoke).
- 단일 인구(한국)·단일 데이터 → 일반화 한정 명시.
- 타깃: medical-AI(MedIA/Radiology:AI/npj Digital Medicine) 또는 Track04 보조.

## 상태
셋업·프로토콜 lock. **S1(도구 설치) 승인 대기** — pyproject/env 변경 + GPU smoke = 사전승인 대상.
