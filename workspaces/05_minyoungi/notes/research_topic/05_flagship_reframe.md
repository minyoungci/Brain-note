# 플래그십 재프레임 — 비식별성 형식화로 격상 (2026-06-15)

_외부 피드백(데이터-명세 기반) 교정 + literature-scout 2건 독립조사 종합. `04_sci_clinical_pivot.md`의
**보완**이지 대체 아님. 04는 보존; 이 문서가 04 §1(플래그십)의 척추 재중심화 제안을 담는다._

## TL;DR (결정)
> **#6(cross-population shortcut-audit)을 메인 플래그십으로 유지·격상한다.** 격상 경로는 외부 피드백이 제안한
> "ancestry confound 정량화"(=traveling=0에서 **dead on arrival**, R-2 死因 재발)가 아니라, **"site≡population·
> traveling=0 regime에서 harmonization 성공의 비식별성(non-identifiability)을 형식화하고, 비순환 biology-보존
> probe가 유일 판정자임을 입증"** 이다. conformal/calibration은 **novelty 동력이 아니라 도구**로 강등.
> **AJU 멀티모달은 구제용으로 불필요 → 보조 트랙으로만 유지.** 단 Bridgeford 2025 must-cite가 격상의 조건.

---

## 1. 외부 피드백 교정 기록 (반복 금지용)
데이터 명세(`docs/MANIFEST_FINAL_DATA_SPEC.md`/`DATA_INVENTORY.md`)만 보고 실험 이력(post-mortem)을 못 본
피드백. 두 오류 + 한 수렴:

| 항목 | 피드백 주장 | 교정 (증거) |
|---|---|---|
| ❌ amyloid 미활용 | "amyloid를 안 쓰고 있었다, 가장 아까움" | **틀림.** `Flagship_Exp/exp01~04`가 전부 centiloid 기반, amyloid=주인공. `04 §2` 횡단 amyloid 5,433/5코호트=핵심 산출물. (raw_pet_path=0·Tier2 배치를 "방치"로 오독) |
| ❌ T1→centiloid / PET distill | "라벨 dx→centiloid 전환, PET-guided distillation을 메인으로" | **이미 닫힌 루프.** image→molecular ~chance(`04 §1`), `exp01` centiloid headroom modest(+0.013 AUC), **`exp04`: learned T1 rep 위에서도 amyloid +0.04~0.07 추가 → PET irreplaceable** = distillation 전제 직접 반증. `experiments/roi_to_image_distill_v0/` 종료됨 |
| ✅ 방법론(베이스라인 사다리·LOSO·site probe) | "이번 주에 하라" | **이미 institutionalized** (exp01 L0/L1/L2 사다리, baseline_06 LOCO, harmonization/01 site-probe 0.565 vs 0.143). **행동 변경 사유 아님 → 독립 수렴(검증) 신호로만 수용.** |

**ancestry 격상 레버에 대한 반론(확증됨)**: traveling subject=0 → 한국 population 신호가 scanner와 완벽 교란 →
"모델이 ancestry를 질병으로 오인하는가"는 정량 분해 불가. 이는 `02 R-2`("nuisance vs population 완전 분리 불가")의
재발. **Scout B가 이를 정확히 확증**(아래 §2).

## 2. literature-scout 2건 결과 (2026-06-15)

### Scout A — 감사-방법론 장르 신규성 → **PARTIALLY-COVERED (sharper differentiation 필요, scoop 아님)**
- **미점유 cell(우리 것)**: deep **image** representation × zero-traveling-subjects collinearity × **비순환 probe가
  유일 판정자**. 이 조합은 비어 있음.
- **비순환 biology probe를 "유일 판정자"로 명시한 선행 없음** → 그 normative claim은 open.
- **최대 위협 — Bridgeford & Vogelstein 2025 (*Imaging Neuroscience*, peer-reviewed)**: batch effect를 causal하게
  비식별로 증명. 단 (a) **feature-table/connectome**이지 learned image 아님, (b) **부분** collinearity지 zero-overlap
  극단 아님, (c) 판정 수단=**abstention**이지 probe 아님. → **must-cite·정면 차별화 안 하면 derivative로 reject.**
- **경험적 경쟁자 — Reynolds/Batmanghelich 2026 (arXiv:2601.16467, "Cautionary Tale of SSL for AD")**: SSL<FreeSurfer
  보임, 독립 validator 사용. undecidability/collinearity 논증 없음 → **LOCO 설계로 out-rigor.**
- **removable-world foil**: Dinsdale 2021(unlearning), Moyer 2020(invariant rep), Glocker 2023(protected-attr
  encoding), Bayer 2022·Zhao/Adeli 2020·OpenBHB/Dufumier 2022 — **전부 site=biology 분리 가능 가정** = 우리 regime의 반대.
- **경고**: 비대칭(morphometry 전이/image 붕괴) 현상 *자체*는 un-novel → novelty는 그게 **undecidability의 구성적
  증명**일 때만 산다. **논문 척추=논증, 벤치마크 아님.** 가열 중: arXiv:2603.04113(KCL, 2026-03). [VERIFY] 제출 전 재-sweep.

### Scout B — 다인종(Korean vs Western) 격상 → **NOVEL-BUT-UNSUPPORTABLE-AS-CAUSAL-ANCESTRY, but SUPPORTABLE if reframed**
- **귀속 문제(결정적)**: cross-ancestry 연구 중 **traveling subject across ancestry를 가진 곳 0, 분리 method 0.**
  Choi 2021/2024=공변량 회귀로 "noise일 것" *희망*, Sun 2025(중국-서구 charts)=population별 harmonize 후 비교(귀속
  불가). **traveling=0은 우리만의 결함이 아니라 field-wide 구조적 한계** → *형식화*가 기여(남들은 hand-wave).
- **biology-is-real(절반) 견고**: Choi 2021(PMC8369368, Korean vs Caucasian norm incompatible), Choi 2024(JAD,
  ethnicity-adjusted AD 분류 개선), Tang 2018·Wang 2020(동아시아 cortex 차이), Sun 2025(대규모). → "site 보정이 실제
  ancestry biology 삭제 = reference-class fairness harm" **지지됨.**
- **flanking(scoop 아님)**: Choi 2024(가장 가까운 "already-done"이나 고전 volumetrics+회귀, DL transportability 아님),
  Sun 2025(부분 scoop, 단 normative/developmental·中國·DL 아님), arXiv:2407.19114(reference-class fairness 프레이밍
  선점 중), Ribeiro 2023·HABS-HD 2025(서구-내 race brain-age, 단일 scanner로 귀속 — 우리가 못 쓰는 lever).
- **미점유 삼중 조합(2026-06 현재)**: **Korean + AD-진단 DL transportability + 형식화된 비식별성.**
- **scoop-watch**: Korean-vs-Western *DL transportability* 정식 논문 출현 시 scoop → 제출 전 재확인. [VERIFY] 2026 일부 arXiv ID.

### 두 scout의 수렴
Scout A의 **undecidability** = Scout B의 **ancestry-vs-scanner 비식별성**. 같은 기여의 양면. population stake가
Bridgeford(추상 논증, feature-table, abstention)와의 차별점을 만든다.

## 3. 재프레임 — 제3의 경로 (척추)
> *"site≡population·traveling=0 regime에선 harmonization 성공이 **비식별(non-identifiable)**이다 — site-probe 하락이
> nuisance 제거인지 biology 삭제인지 단일 probe로 결정 불가. 따라서 **비순환·biology-보존 downstream probe(within-cohort
> 진단 AUC 불변)가 유일한 valid 판정자**다. 한국-서구 AD에서 'morphometry는 전이(LOCO 0.91)·learned image는 붕괴'라는
> **비대칭이 이 비식별성의 구성적 증명**이며, naive site-보정은 독립 입증된 실제 한국-서구 biology(Choi 2021, Sun 2025)를
> 지워버린다 = reference-class fairness harm."*

차별화 첫 문장(후보): *"When scanner site is statistically inseparable from population — Korean vs Western AD cohorts
with zero traveling subjects — a drop in site-predictability is uninterpretable for learned image representations:
it cannot distinguish nuisance removal from biology erasure, so the only valid evidence of harmonization success is a
non-circular, biology-preserving downstream probe, which learned features fail and hand-engineered morphometry passes."*

## 4. 격상 하드 조건 (미충족 시 격상 무효)
1. **Bridgeford & Vogelstein 2025 must-cite·정면 차별화** (image+zero-overlap+probe-based vs feature-table+partial+abstention).
2. **Reynolds 2026(2601.16467) out-rigor** — LOCO·명시적 collinearity로.
3. **척추=논증(비식별성+probe), 벤치마크(비대칭) 아님.** ("성패는 프레이밍에서 갈린다" — `02` 자체 경고와 일치.)
4. **fairness-of-norms 프레이밍 회피**("서구 norm 불공정"은 선점됨) → **Korean+AD-DL-transportability+형식화 비식별성** 삼중으로.
5. **정직 scope**: ancestry-vs-scanner를 *resolve*가 아니라 *characterize/bound*. (R-2 → thesis 전환, 04와 일관.)
6. **속도·scoop-watch**: 제출 전 재-sweep; Korean-vs-Western DL transportability 정식 논문 출현=scoop.

## 5. 04 대비 변화 (04 편집 안 함 — 다음 04 개정 시 반영 제안)
- 척추 재중심화: *"transportability & fairness with conformal/calibration"* → **"비식별성 형식화 + 비순환 probe 판정자"**.
  conformal/calibration = **헤드라인→도구** 강등(표준 기법, novelty 동력 아님).
- must-cite 추가: Bridgeford 2025, Reynolds 2026, Choi 2021/2024, Sun 2025.
- `04 §3 #1` 타깃·데이터 골격은 유효(서구학습→Korean external LOCO). 프레이밍만 교체.

## 6. 결정 & 다음 액션
- **AJU 멀티모달**: 구제 불요(#6 격상됨). **보조 트랙 후보로만 보존.** 본격 착수 시 "영상을 주역에서 빼는 질문"
  (actigraphy/lifelog → 인지 궤적) 각도 + 교집합 N 확인 선행 필요 — 별도 scout 시 결정.
- **AJU scout 지금 실행 안 함** (토큰 절약, 의사결정 불필요).
- 권고 순서: (1) `04` 다음 개정에 §5 척추 교체 반영, (2) `04 §5 CPU 경로`로 harness 진행(라벨 lock → 서구→Korean LOCO →
  비순환 probe 판정 → 독립검증), (3) 매뉴스크립트 intro에 Bridgeford/Reynolds 차별화 단락 선작성.

## 출처
- literature-scout A(afb3b775) · B(a4d2b41d), 2026-06-15 조사.
- **Bridgeford & Vogelstein 2025**, "When no answer is better than a wrong answer," *Imaging Neuroscience* (PMC12319767). ★ 최대 위협.
- **Reynolds/Batmanghelich 2026**, "A Cautionary Tale of SSL for Imaging Biomarkers: AD," arXiv:2601.16467. [VERIFY 제목/저자]
- Choi 2021, *Front Aging Neurosci* 13:675016 (PMC8369368); Choi 2024, *JAD* 10.3233/JAD-231182.
- Sun 2025, bioRxiv 2025.06.17.659820 (PubMed 40667167). [VERIFY peer-review]
- Dinsdale 2021 *NeuroImage*; Moyer 2020 *MRM*; Glocker 2023 *eBioMedicine*; Bayer 2022 *Front Neurol*; Zhao/Adeli 2020
  *Nat Commun*; Bethlehem 2022 *Nature* 604:525; Ribeiro 2023 arXiv:2309.10835; arXiv:2407.19114; arXiv:2603.04113 [VERIFY].
- 연결: [`04_sci_clinical_pivot.md`](04_sci_clinical_pivot.md) · [`02_trajectory_ranking.md`](02_trajectory_ranking.md)(R-2) · `Flagship_Exp/exp01,exp04`.
