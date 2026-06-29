# 07. C3 External Validation — Pre-Registration (v2, critic-hardened)

> ⛔ 외부 데이터 결과를 보기 *전에* 가설·코호트·split·baseline·shortcut audit·falsification을 고정. lock 후 사후
> 변경 금지(변경=deviation 명시). 필수 동반: `docs/08_shortcut_and_confound_control.md`.
> **v2 (LOCKED 2026-06-29)**: 독립 research-critic 적발(F1·F2·M1–M7) 1:1 반영. 아래 임계값 동결 — 결과 보기 전 변경 금지(변경=deviation 명시). unblinding *전* code-auditor가 §3·§4 코드(patient-GroupKFold·CN-fit·nested CV·A2 train-only)를 확인한 뒤 실행.

작성일: 2026-06-29. 상태: **LOCKED — 외부 전처리 산출물 도착 즉시 §7 실행.** 동결 임계값: post-A2 site-acc ≤ chance+0.10; random ≥3 seed; CI 95% 양측 BCa 1000; Holm 보정; brain-age fit=CN-only.

## 0. 목적
C2 brain-age inverted-U(내부 SOLID 1개)가 외부·multi-site·대륙간에서 재현되고, **shortcut(7종)으로 설명되지 않으며,
단순 morphometry보다 낫다**를 보여 AAAI-grade로 만든다. global 축 전용(외부엔 seg 라벨 없음).

## 1. 가설 (사전 고정)

```text
H1 (transfer, PRIMARY):  [primary endpoint] CN-only fit, pooled cross-cohort brain age Δ-over-matched-random
                         의 95% CI가 0 제외. (이것이 THE 단일 1차 지표; 나머지는 2차)
H2 (balance, 양성기준):   wg0.5 ≥ 양 이웃 AND 더 높은 이웃에 대해 CI-분리(내부 C2와 동일 바). 
                         plateau/peak-이동은 "balance 최적이 data-dependent"로 *정직 보고*(replication 아님).
H3 (shortcut-controlled, 합접속): H1이 (a) A2 직교화(train-only, nested) 후 (b) cross-cohort (c) within-cohort(patient-grouped)
                         *모두*에서 성립 AND (d) **post-A2 외부 site/scanner balanced-acc ≤ chance + 0.10**.
                         age-Δ는 살아남되 site-acc가 높으면 → claim을 "held-out site에서 전이"로 *축소*(="site-불변" 주장 금지).
H4 (semantics):          cross-cohort dx (ADNI→KDRC AND ADNI→AJU, **co-primary**), **age-adjusted** AUROC > random, 라벨 harmonized.
H5 (vs morphometry, M3): foundation brain age Δ-over-(FreeSurfer fs_* morphometry) ≥ 0. <0이면 claim 축소("morphometry 비열등 아님").
```

## 2. 코호트 — 포함/제외 (사전 고정)
| 코호트 | 포함 | 근거 |
|---|---|---|
| ADNI/NACC/A4/AIBL/AJU/KDRC | 포함 | FOMO300K filelist와 0건(leakage-safe, 검증) |
| OASIS-3 | 제외 | OASIS-1/2 사전학습 포함·ID 재익명화→disjoint 증명 불가 |

포함 조건(전처리 후 재확인): Yucca 산출물 존재 + filelist 0-overlap 재대조 + age 라벨. 미달=제외(사후 추가 금지).

## 3. Task & Split (사전 고정)

### 공통 — leakage 차단 (F2·M4)
- **patient-level GroupKFold**: 한 subject의 모든 session이 한 fold에만(종단 autocorrelation 누수 차단). 코드에서 grouping 명시, unblinding 전 code-auditor 검증.
- **nested CV**: probe 하이퍼파라미터·A2 site subspace는 *inner train에서만* fit → test 적용(transductive 누수 금지).

### Task A. Brain age (primary)
- **fit = CN-only**(M7, 위축이 chronological-age 타깃 오염 방지). eval = 전체 + dx-stratified.
- **within-cohort**(#6 통제): 코호트별 patient-GroupKFold.
- **cross-cohort**(일반화, primary): fit {ADNI,NACC}-CN → test {AIBL, **KDRC, AJU**(대륙간)}. 코호트를 cluster로 per-cohort+pooled 보고.
- metric: MAE + Pearson r(BCa), **Δ-over-matched-random**(§6).

### Task B. CN/MCI/AD (secondary)
- **cross-cohort co-primary**: ADNI → KDRC **및** ADNI → AJU(둘 다 보고; 단일 test cohort 금지).
- **age-adjusted** macro-AUROC + balanced acc. 라벨 harmonization 사전 정의(아래).
- 라벨 매핑(고정): NACC "Dementia"→AD군, MCI 기준 코호트별 명시[VERIFY: KDRC/AJU MCI 정의 문서], 불일치 클래스는 binary(CN vs impaired)로 강등.

### Baselines (M3·M6, 필수)
| baseline | 목적 |
|---|---|
| **matched random encoder × ≥3 seed** (recipe=resenc_s3d) | Δ-over-random 분모, seed 분산 포함 |
| **FreeSurfer fs_* morphometry** (부피 회귀) | *skeptic 바* — foundation이 단순 부피 넘는가(H5) |
| scratch / full-FT (reference, primary 아님) | frozen-probe가 전이를 과소평가하는지 상한 |
| wg0 / wg0.5 / wg1 | inverted-U 외부 재현(H2) |

### Probe protocol
**frozen-primary**(linear/shallow MLP). encoder 동결 해제 안 함(primary). 보조 low-LR.

## 4. Shortcut Audit (사전 고정, `docs/08`)
```text
1. 측정: frozen global vector로 scanner/site(acq_scanner_raw)·cohort 예측 → balanced acc 기록.
2. A2(train-only, split 내부 nested): site subspace 선형 제거 후 target probe.
3. B: cross-cohort + within-cohort(patient) + 공변량 보정.
4. resolution/FOV/sequence audit: native spacing·neck/skull coverage·sequence variant를 covariate로 기록,
   target의 discriminant가 아님을 확인.
```
covariate: acq_scanner_raw(site/scanner/vendor), age, sex, native spacing, FOV proxy, sequence variant, fs_*.

## 5. Falsification (사전 고정 — 결과 보기 전, 다중비교 보정 포함)
```text
primary endpoint = H1(pooled cross-cohort CN-fit brain age Δ-over-random). 보고 시 Holm 보정(wg×cohort×task×audit grid).
H1 기각: primary Δ의 (Holm-보정) 95% CI가 0 포함.
H2 기각: wg0.5가 더 높은 이웃에 CI-분리로 dominated, 또는 양성기준(≥양이웃 & CI-분리) 미충족 → "정점 아님"으로 보고.
H3 기각: A2-후/cross-cohort/within-cohort 중 하나라도 Δ CI가 0 포함, **또는 post-A2 site-acc > chance+0.10** → "shortcut으로 설명/축소".
H4 기각: ADNI→KDRC 또는 ADNI→AJU의 age-adjusted AUROC CI가 random 포함.
H5 기각: foundation brain age가 morphometry에 CI-분리로 열등 → "morphometry 비열등 아님"으로 축소.
```
기각 시 행동: H3 기각(shortcut load-bearing) → A1 재학습 검토 또는 "internal-only"로 축소. 나머지 기각 → claim 철회·negative 보고, C2-internal 유지.

## 6. 고정된 분석 규칙 (왜곡 차단)
```text
- 단일 primary endpoint(H1) 지정 + Holm/hierarchical 다중비교 보정. cross-cohort "4/5 성공" cherry-pick 금지.
- Δ-over-random = matched random **≥3 seed**, **paired BCa bootstrap**(model−random 동일 subject), 95% 양측, 1000 resample.
- cohort를 cluster로: per-cohort + pooled 둘 다. 단일 test cohort로 일반화 주장 금지.
- random floor가 chance 포함인 신호(내부 polymicro 등)는 정점/우월 증거로 쓰지 않음. n<50/CI-chance → 제외·강등.
- 표/수치는 source에서 프로그램 추출(build_c2_table.py식), 손 전사 금지.
- #5 registration shortcut은 *템플릿 정합 부재로 중립*임을 명시(uncontrolled 아님).
```

## 7. 실행 순서 (전처리 완료 후)
```text
1. cohort별 Yucca 산출물 + label table + filelist 0-overlap 재확인 + patient-grouping/CN-flag 코드 명시.
2. eval_harness 외부 task 배선(brainage_ext CN-fit, cnmciad_cls; nested CV; cross-cohort).
3. §4 shortcut audit(측정→A2 nested→B + resolution/FOV/sequence).
4. baselines: random×3seed, morphometry, (ref) scratch + wg0/0.5/1.
5. §5 falsification(Holm)으로 H1–H5 판정 → 긍정/부정 모두 기록.
```

## 8. 독립 검증 (상시, unblinding 전·후)
unblinding *전*: code-auditor가 patient-grouping·A2 train-only·nested CV·CN-fit를 코드에서 확인.
결과 후: code-auditor(provenance/통계) + research-critic(해석/설계)가 §5 기준 대비 재검증 후에만 "확정".
관련 메모리: `code-review-mandatory`, `shortcut-confound-control`, `eval-probe-confounds`, `t1-morphometry-saturation`.

## 변경 이력
- v2 (2026-06-29): research-critic 적발 반영 — F1(H3에 post-A2 site-acc 임계 추가), F2(patient-GroupKFold), M1(H2 양성기준),
  M2(primary endpoint+Holm), M3(morphometry+scratch baseline, H5 신설), M4(nested CV), M5(dx co-primary+age-adjusted+라벨harmonize),
  M6(≥3 random seed+paired BCa), M7(CN-only brain-age fit). minor: resolution/FOV/sequence audit, registration 중립 명시, CI 95%/BCa.
