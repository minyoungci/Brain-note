# Phase 1 — systemic/genetic determinants of pathology axes (Korean tri-modal)

표준화 선형회귀(축 ~ 통제+예측), bootstrap 95% CI. |CI가 0 미포함|=유의(*).

## amyloid (PET-SUVR global)  (n=924)
| predictor | std β | 95% CI | 유의 |
|---|--:|--:|:--:|
| age(control) | +0.099 | [+0.03,+0.16] | * |
| sex_n(control) | -0.152 | [-0.22,-0.09] | * |
| education_years(control) | +0.119 | [+0.05,+0.18] | * |
| apoe_e4_count | +0.374 | [+0.31,+0.43] | * |
| dm_n | -0.029 | [-0.10,+0.04] |  |
| htn_n | -0.013 | [-0.08,+0.05] |  |
| dyslip_n | -0.013 | [-0.07,+0.05] |  |
| hba1c | -0.053 | [-0.09,+0.01] |  |
| glucose | +0.056 | [-0.02,+0.15] |  |
| tchol | -0.151 | [-0.31,+0.03] |  |
| hdl | +0.009 | [-0.07,+0.09] |  |
| ldl | +0.139 | [-0.04,+0.30] |  |
| bmi | -0.054 | [-0.12,+0.01] |  |

→ **amyloid (PET-SUVR global) 유의 결정인자**: ['apoe_e4_count']

## vascular (WMH visual grade)  (n=929)
| predictor | std β | 95% CI | 유의 |
|---|--:|--:|:--:|
| age(control) | +0.163 | [+0.10,+0.23] | * |
| sex_n(control) | +0.069 | [+0.00,+0.14] | * |
| education_years(control) | -0.073 | [-0.14,-0.01] | * |
| apoe_e4_count | -0.046 | [-0.11,+0.02] |  |
| dm_n | +0.052 | [-0.02,+0.13] |  |
| htn_n | +0.187 | [+0.12,+0.25] | * |
| dyslip_n | -0.021 | [-0.09,+0.04] |  |
| hba1c | +0.019 | [-0.08,+0.06] |  |
| glucose | -0.016 | [-0.09,+0.06] |  |
| tchol | -0.223 | [-0.41,-0.06] | * |
| hdl | +0.050 | [-0.02,+0.12] |  |
| ldl | +0.285 | [+0.13,+0.46] | * |
| bmi | -0.034 | [-0.11,+0.04] |  |

→ **vascular (WMH visual grade) 유의 결정인자**: ['htn_n', 'tchol', 'ldl']

## atrophy (−hippocampal vol)  (n=929)
| predictor | std β | 95% CI | 유의 |
|---|--:|--:|:--:|
| age(control) | +0.202 | [+0.14,+0.26] | * |
| sex_n(control) | +0.111 | [+0.05,+0.18] | * |
| education_years(control) | +0.029 | [-0.04,+0.10] |  |
| apoe_e4_count | +0.232 | [+0.17,+0.29] | * |
| dm_n | +0.036 | [-0.04,+0.11] |  |
| htn_n | -0.044 | [-0.11,+0.02] |  |
| dyslip_n | -0.038 | [-0.10,+0.03] |  |
| hba1c | -0.025 | [-0.08,+0.03] |  |
| glucose | +0.054 | [-0.01,+0.14] |  |
| tchol | -0.016 | [-0.19,+0.13] |  |
| hdl | +0.014 | [-0.06,+0.09] |  |
| ldl | +0.107 | [-0.05,+0.30] |  |
| bmi | -0.039 | [-0.11,+0.04] |  |

→ **atrophy (−hippocampal vol) 유의 결정인자**: ['apoe_e4_count']

## 해석 골격 (한국-특화 발견 후보)
- amyloid가 APOE에 강하게? vascular가 대사/혈관위험(hba1c/htn/dm)에? atrophy가 둘 다에?
- 서구 보고와 *다른* 결정인자 패턴이면 = Korean-특화 기여. (Q4 ADNI 대조로 확인)