# CDR 공통 타깃 설계 · ComBat Harmonization

> **목적:** 7개 컨소시엄을 잇는 공통 라벨로서의 CDR Global 타당성과 site harmonization(ComBat) 효과를 정리한다.  ·  **출처:** `minyoungi/Clinical/notebooks/05_cdr_common_target.ipynb`, `06_harmonization_combat.ipynb` (입력: `master_df.parquet` 13,022행, `roi_volumes_full.parquet`)  ·  **갱신:** 2026-06-02

⚠️ **BLOCKED_PROVISIONAL — 모든 ROI/부피 기반 결론은 후보(provisional)다.**
05·06이 쓰는 option_b ROI/부피는 manifest 전수 13,022행에서 다음 플래그를 가진다. 정량 주장 전 per-ROI QC 게이트 통과가 선행되어야 한다.

| 플래그 | 값 (전수 13,022) |
|---|---|
| `do_not_use_for_atlaswide_roi_features` | `True` |
| `roi_final_ready` | `False` |
| `roi_final_grid_qc_status` | `BLOCKED_PROVISIONAL` |
| `roi_block_reason` | "FastSurfer-to-native transfer requires ROI-specific visual approval; legacy ROI dirs and repair candidates are provisional." |

또한 '부피'는 native mm³가 아니라 option_b final_tensor-grid의 `voxel_count` + `MaskVol`(ICV 프록시)이다. 그리드 리샘플이 부분적 크기 정규화를 이미 포함하므로 Spearman/AUC 해석에 그리드 아티팩트가 혼입된다.

---

## 05. CDR Global을 7개 코호트 공통 타깃으로

### 왜 CDR인가 — 커버리지

diagnosis 라벨은 A4(preclinical)·KDRC(별도체계)에서 0%다. CDR Global만이 7개 전부 100% 존재 → 유일한 공통 라벨 후보.

| consortium | CDR coverage | diagnosis coverage |
|---|---|---|
| A4 | 1.0 | 0.000 |
| ADNI | 1.0 | 0.999 |
| AIBL | 1.0 | 1.000 |
| AJU | 1.0 | 0.964 |
| KDRC | 1.0 | 0.000 |
| NACC | 1.0 | 0.853 |
| OASIS | 1.0 | 1.000 |

### cdr_global 분포 — 코호트 간 큰 이질성 (행 정규화)

| consortium | 0.0 | 0.5 | 1.0 | 2.0 | 3.0 |
|---|---|---|---|---|---|
| A4 | 0.687 | 0.293 | 0.019 | 0.001 | 0.000 |
| ADNI | 0.530 | 0.408 | 0.050 | 0.011 | 0.001 |
| AIBL | 0.696 | 0.223 | 0.064 | 0.014 | 0.003 |
| AJU | 0.023 | 0.799 | 0.148 | 0.027 | 0.004 |
| KDRC | 0.308 | 0.510 | 0.145 | 0.036 | 0.000 |
| NACC | 0.640 | 0.292 | 0.055 | 0.011 | 0.002 |
| OASIS | 0.798 | 0.147 | 0.051 | 0.004 | 0.000 |

⚠️ AJU는 memory clinic 편향(CDR0=2.3%), OASIS는 건강 편향(CDR0=79.8%). 같은 CDR 타깃이라도 기저 분포가 site마다 달라 site-stratified split이 필수다.

### cdr_bin 정의 — 3-class

`cdr_bin(x)`: `x==0 → CDR0_normal` / `x==0.5 → CDR0.5_questionable` / 그 외 → `CDR>=1_dementia`. CDR≥2,3은 희소(<2%)라 ≥1로 병합한다.

| consortium | CDR0_normal | CDR0.5_questionable | CDR>=1_dementia |
|---|---|---|---|
| A4 | 1245 | 530 | 36 |
| ADNI | 2511 | 1936 | 295 |
| AIBL | 687 | 220 | 80 |
| AJU | 29 | 1028 | 230 |
| KDRC | 280 | 464 | 165 |
| NACC | 1195 | 544 | 127 |
| OASIS | 1133 | 209 | 78 |
| **전체** | **7080** | **4931** | **1011** |

클래스 불균형(CDR≥1=1011, 약 7.8%) 보정이 필요하다.

### CDR ↔ diagnosis 일관성 (라벨 보유 코호트 한정, 행 정규화)

| cdr_global | AD | CN | MCI |
|---|---|---|---|
| 0.0 | 0.001 | 0.990 | 0.009 |
| 0.5 | 0.075 | 0.032 | 0.893 |
| 1.0 | 0.997 | 0.000 | 0.003 |
| 2.0 | 1.000 | 0.000 | 0.000 |
| 3.0 | 1.000 | 0.000 | 0.000 |

극단(0, ≥1)은 진단과 거의 일치(CDR0→CN 99.0%, CDR≥1→AD 99.7%). CDR0.5는 본질적으로 모호(전이/이질) 구간.

⚠️ **'CDR0.5 = 89% MCI'는 전역 통계가 아니다.** dx 보유 코호트 한정이며, CDR0.5 다수인 KDRC(464)+A4(530)=994건은 dx 100% 결측이라 89%를 적용할 수 없다(표본 외 추정).

### ROI → CDR class 예측 (공통 타깃 유효성 후보 근거)

- CDR Global ↔ 해마 부피 Spearman r=−0.327, p≈0 (n=13022, A4/KDRC 포함 전 코호트). 해마 평균 부피: CDR0=7911 → 0.5=7466 → 1.0=6489 → 2.0=6106 → 3.0=5605 (단조 감소).
- ROI 8개(ICV 정규화) 로지스틱 5-fold CV:
  - CDR≥1 vs CDR0: ROC-AUC **0.895±0.019** (n=8091, pos=1011)
  - CDR0.5 vs CDR0: ROC-AUC **0.687±0.046** (n=12011, pos=4931) — 모호 구간이라 더 어려움.

⚠️ random split AUC≈0.9는 site 누수를 포함하므로 '유효 타깃' 근거로 단정하지 말 것. leave-one-consortium-out으로 site shortcut을 폭로한 뒤에만 인용해야 한다. [VERIFY] LOCO 검증은 05 노트북에 미수행.

### 라벨 정의 시 주의 (source 이질성)

- ⚠️ source 컬럼(`cdr_source`/`cdr_source_table`)이 코호트마다 다른 테이블/스키마에서 유래 → CDR 시행 프로토콜의 사이트 차이 가능성. CDR-SB(`cdrsb`, AIBL 외 보유)로 교차검증 권장. [VERIFY] cdr_source/cdr_source_table 값별 분포는 05 출력에 직접 표시되지 않음 — 코드에 컬럼명만 등장.
- ⚠️ A4 CDR 출처는 `A4/Clinical/Raw Data/cdr.csv`(cdr_source=raw_a4_cdr)로 확인됨 — 조작 아님(critic 우려 해소).
- ⚠️ cdr 라벨 string 타입 주의: cdr_class는 string('CDR0_normal' 등 / 06에서는 '0','0.5','ge1'). 비교·매핑 시 타입 일관성 확인 필요. [VERIFY] cdr_global 원본 dtype은 출력에 명시되지 않음(float로 매핑 사용).

### CDR을 site로 학습할 위험

CN만 추출해도 컨소시엄별 해마/ICV 차이가 유의: Kruskal **p=1.15e-13**. 진단이 같아도(CN) site 간 차이가 유의 → CDR 타깃도 site 보정 없이는 위험.

### 05 결론

✅(후보) CDR Global을 공통 타깃으로 **use_with_safeguards**. 멀티에이전트 검증(critic 2/3 holds, must-fix 다수). 권장 타깃: 3-class ordinal `CDR0 / CDR0.5 / CDR≥1`, 엄격 분류 시 `CDR0 vs CDR≥1` binary + CDR0.5 별도/회귀. 필수 안전장치: site-stratified split, harmonization(ComBat), CDR0.5 모호성 명시 처리, 클래스 불균형 보정, CDR-SB 교차검증.

---

## 06. ComBat Harmonization — site effect 제거

### 보정 대상과 입력

- **보정하는 것:** consortium(7 site) 단위 site/scanner effect의 평균·분산(L/S) 이동.
- **입력 feature:** ICV 정규화 ROI 부피 **10개**(hippocampus, amygdala, entorhinal_cortex, parahippocampal_cortex, lateral_ventricle, thalamus, caudate, putamen, pallidum, accumbens).
- **batch:** consortium. **보존 공변량:** CDR class(100% 커버 → 7 site 유지). age는 KDRC 100% 결측이라 제외, sex는 일부 결측 → caveat.
- 분석 n=13022. site별 n: ADNI 4742, NACC 1866, A4 1811, OASIS 1420, AJU 1287, AIBL 987, KDRC 909.

ComBat는 CDR을 categorical 보존 공변량으로 넣어 over-correction(신호 제거)을 방지한다.

### Before → After (실측 수치)

| 지표 | BEFORE | AFTER | 기저선/목표 |
|---|---|---|---|
| site 분류 정확도 (↓good) | 0.407 | **0.362** | 0.364 (다수클래스 기저선) |
| CN 내 site Kruskal p (↑good) | 1.1e-13 | **1.8e-01** | 클수록 site 제거 |
| CDR↔해마 Spearman (보존) | −0.297 | −0.389 | 유지=신호보존 |
| ROI→CDR0vs≥1 AUC (보존) | 0.905 | **0.908** | 유지=신호보존 |

해석:
- ✅ site 분류 정확도가 0.407 → 0.362로 다수클래스 기저선(0.364) 수준까지 하락 → ROI feature로 site를 거의 못 맞춤 = site 정보 제거됨.
- ✅ CN 내 site Kruskal p가 1.1e-13 → 0.18로 상승 → site 간 유의차 소멸.
- ✅ 임상신호 보존: ROI→CDR AUC 0.905 → 0.908(유지). CDR↔해마 Spearman −0.297 → −0.389(약화 아님, 절댓값 증가). ⚠️ Spearman 절댓값 증가는 site 분산 제거의 부수효과일 수 있어 '신호 강화'로 단정하지 말 것.

### 한계 (반드시 인지)

1. ⚠️ **누수:** 06은 EDA 시연이라 전체에 ComBat fit(낙관적). 실제 ML 평가는 **train에만 fit → test에 apply**(neuroHarmonize/`.transform` 패턴)여야 누수 없음.
2. ⚠️ **site=consortium은 거친 단위:** 같은 컨소시엄 내 다중 스캐너/프로토콜 미모델링 → 잔여 site effect 가능. 가능하면 scanner 단위 batch.
3. ⚠️ **공변량 불균형:** AJU(거의 CDR0.5)·OASIS(건강 편향)처럼 site와 covariate가 교란되면 ComBat이 신호를 일부 흡수 가능. CDR class 보존으로 완화하나 한계 존재.
4. ⚠️ **age 제외:** KDRC age 100% 결측 → 공변량에서 제외. age가 핵심 교란이면 결측 보강 후 포함 권장.
5. ⚠️ ComBat는 평균/분산 보정만 — 비선형 site 효과는 잔존. 영상 직접 보정엔 adversarial/style harmonization 등 더 강한 방법 고려.

### 06 결론

✅(후보) ComBat는 ROI feature 수준에서 site 분류 가능성을 기저선까지 낮추면서 CDR 신호를 보존한다(위 지표로 정량 확인). 이는 05의 'CDR 공통 타깃' 권고가 요구한 harmonization 안전장치의 실증이다. 단 BLOCKED_PROVISIONAL ROI 상태와 누수-없는 train-fit 검증 미수행으로 인해 '검증됨'이 아니라 '후보'다.
