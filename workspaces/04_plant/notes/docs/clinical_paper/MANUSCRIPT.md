# Neurodegeneration and amyloid burden, but not white-matter-hyperintensity burden, predict two-year cognitive decline in real-world Asian mild cognitive impairment: a prognostic structure concordant with a research-cohort benchmark

*Target venue: Journal of Clinical Neurology (clinical SCI, IF~3). Draft v2 — 2026-06-25, revised after independent reviewer-2 critique. **Single source of truth for all numbers = `experiments/incremental_value/16_manuscript_numbers.py` (+ supplementary computations 2026-06-25).** Older docs 13/15 used exploratory covariate sets and are superseded where they differ. 🔴 = author must supply before submission.*

---

## Abstract

**Background.** Amyloid-enriched research cohorts (e.g., ADNI) and cross-sectional Asian registries (e.g., K-ROAD) cannot simultaneously characterize the real-world etiologic mix and the longitudinal prognostic structure of mild cognitive impairment (MCI). Whether the prognostic structure established in research cohorts is reproduced in a vascular-inclusive Asian memory-clinic population, and what carries prognosis there, is unestablished.

**Methods.** We studied a single-center Korean memory-clinic cohort (AJU) of MCI patients with two-wave longitudinal assessment (n=252; median follow-up 1.9 years) and used the ADNI MCI cohort as a *research-cohort benchmark* (n=309), applying identical model specifications to each cohort separately (never pooled). Baseline predictors were amyloid (visual read and SUVR in AJU; Centiloid in ADNI), AD-signature neurodegeneration (N; hippocampal and entorhinal atrophy, intracranial-volume–normalized), white-matter-hyperintensity (WMH) burden (quantitative volume and visual grade), clinical vascular diagnosis, and APOE. The outcome was two-year change in MMSE (ΔMMSE), with "meaningful decline" (ΔMMSE ≤ −3) secondary. Estimates were stress-tested with robust (Huber) regression, influential-point exclusion, and bootstrap.

**Results.** In AJU (primary model with continuous amyloid, n=251), AD-signature neurodegeneration and amyloid burden were both robust, independent predictors of decline (N β = −0.60 per SD, 95% CI −1.00 to −0.19, p = 0.004; amyloid SUVR β = −5.17, 95% CI −7.99 to −2.35, p < 0.001), each surviving Huber regression, influential-point exclusion, and bootstrap (bootstrap P(β<0) = 0.999 and 1.000, respectively). The amyloid effect was robust to conservative baseline-cognition control (quadratic-MMSE: β = −4.25, p = 0.003), whereas *binary* amyloid positivity was weaker and attenuated under the same control. The two axes were statistically independent (variance inflation factor 1.05). After AT(N) adjustment, neither quantitative WMH (standardized β = −0.09, 95% CI −0.49 to +0.31, p = 0.65) nor visual WMH grade (p = 0.63) contributed; the pooled clinical vascular diagnosis was not robust. Applying the identical (harmonized) model to ADNI, both neurodegeneration (standardized β = −0.36, p = 0.008) and continuous amyloid burden (standardized β = −0.42, p = 0.002) reproduced, and binary positivity was again weak in both cohorts. An amyloid-by-age interaction seen in AJU did **not** replicate in ADNI (opposite-direction trend; comparable age distributions), indicating a cohort-specific effect.

**Conclusions.** A prognostic structure of AD-signature neurodegeneration plus continuous amyloid burden predicts two-year cognitive decline in vascular-inclusive Asian real-world MCI and is directionally concordant with a research-cohort benchmark. WMH burden adds no independent prognostic signal once neurodegeneration and amyloid are known, and continuous amyloid burden is more informative than binary positivity. These findings support a parsimonious approach to short-term prognosis in real-world MCI, pending replication.

**Keywords:** mild cognitive impairment; amyloid PET; neurodegeneration; white matter hyperintensities; prognosis; real-world cohort

---

## 1. Introduction

Predicting short-term cognitive decline in MCI is central to memory-clinic practice. The AT(N) framework organizes the biomarkers that drive Alzheimer-type decline,[1] and amyloid-PET prognosis is established in research cohorts.[VERIFY standard ADNI refs] Two structural gaps limit translation.

First, the cohorts that establish prognostic biomarkers are amyloid-enriched research cohorts that exclude substantial cerebrovascular and mixed pathology by design; real-world memory clinics see far more heterogeneous patients, and whether prognostic structure is reproduced there is rarely tested head-to-head. Second, Asian real-world longitudinal multimodal data are scarce: the Korean K-ROAD registry characterizes the cross-sectional etiology–amyloid distribution at scale[7] but does not report longitudinal prognosis; recent heterogeneous-cohort prognostic studies (Younes et al., 2025[4]) are Western and do not jointly model quantitative WMH; multimodal studies that include WMH (Bachmann et al., 2026[5]) are non-demented community samples, not memory-clinic MCI.

We asked: (RQ1) does a neurodegeneration-plus-amyloid prognostic structure predict two-year decline in vascular-inclusive Asian memory-clinic MCI; (RQ2) is this structure reproduced when the identical model is applied to ADNI as a benchmark; (RQ3) does WMH burden add independent prognostic information over AT(N); (RQ4) is the structure modified by age or vascular subtype. We frame the ADNI analysis explicitly as a **benchmark comparison, not external validation** — cohorts are analyzed separately, never pooled — and report what reproduces and what does not.

## 2. Methods

### 2.1 Ethics
🔴 *The AJU study was approved by the Institutional Review Board of [INSTITUTION] (approval no. [NUMBER]); [written informed consent was obtained / consent was waived for this retrospective analysis]. ADNI data were used under ADNI data-use agreement; ADNI was approved by the IRBs of participating sites and all participants provided written informed consent.* (Author must insert AJU IRB number and consent status before submission.)

### 2.2 Cohorts and design
AJU is a single-center Korean memory clinic. We included participants clinically staged as MCI at baseline with baseline and follow-up visits and non-missing MMSE at both (n=252; median follow-up 1.9 years, IQR 1.7–2.3). The benchmark cohort was ADNI MCI participants with ≥2 visits carrying MMSE and structural MRI and a baseline-aligned amyloid scan (n=309; the follow-up visit nearest 24 months was used). Cohorts were analyzed separately with identical model code; data were never pooled. A participant-flow diagram (Fig 1) reports screening → MCI → two-wave → analyzed counts. 🔴 *(Fig 1 counts to be finalized from the screening log.)*

### 2.3 Measures
- **Amyloid (A).** AJU: clinical visual read (positive/negative) and global SUVR. ADNI: UC Berkeley tracer-harmonized Centiloid and binary status (UCBERKELEY_AMY). Continuous amyloid was the pre-specified primary amyloid operationalization; binary positivity secondary.
- **Neurodegeneration (N).** AD-signature atrophy = mean of intracranial-volume–normalized hippocampal and entorhinal volumes (FreeSurfer-pipeline morphometry common to both cohorts), z-scored within cohort, sign-oriented so higher = more atrophy.
- **WMH.** Quantitative WM-hypointensity volume (raw, log, age-residualized) and clinical visual grade.
- **Vascular diagnosis (V).** Clinical etiologic label (e.g., Vascular MCI, Subcortical VaD).
- **Covariates.** Age, sex, baseline MMSE, CDR–Sum of Boxes, follow-up interval; education additionally in AJU.

### 2.4 Outcome, models, and statistics
Primary outcome: two-year ΔMMSE (continuous). Secondary: meaningful decline (ΔMMSE ≤ −3; ≤ −2 and ≤ −4 as sensitivity). **Two model families are reported and labelled throughout:** (i) the *AJU full model* (covariates + education, used for Table 2), and (ii) the *harmonized model* (common covariate set without education, used for all AJU↔ADNI benchmark comparisons, because education was unavailable in the ADNI source). Linear models were fit for ΔMMSE and logistic models for meaningful decline. Robustness: Huber M-estimation, exclusion of influential points (|studentized residual| > 3), and 5000-sample bootstrap. A–N collinearity by variance inflation factor. **Missing data were handled by complete-case analysis;** analytic n is reported per model (binary-amyloid models n=252; continuous-SUVR models n=251 [one missing SUVR]; ADNI n=309). **Effect-modification tests (A×age and three other modifiers) form a pre-specified family of 4 and were Bonferroni-corrected (α = 0.0125);** main-effect models were not multiplicity-adjusted and are interpreted as a single pre-specified model. For RQ2, the identical harmonized specification was applied to ADNI; agreement/disagreement were interpreted under pre-registered expectations (neurodegeneration expected to reproduce as a positive control; age-modification flagged a priori as exploratory). 🔴 *(Sample size was fixed by cohort availability; a precision statement: at n=252 the two-sided 95% CI half-width for a standardized β was ≈0.13 SD.)*

## 3. Results

### 3.1 Cohort characteristics (Table 1)
AJU MCI were older-skewed memory-clinic referrals (age 72.2 ± 7.4; 71% female; baseline MMSE 24.8 ± 3.2; amyloid-positive 30% [76/252]). ADNI MCI were milder and more amyloid-enriched (MMSE 27.9 ± 2.0; amyloid-positive 46%; 43% female; APOE-ε4 40% vs 27%), consistent with the research-versus-real-world contrast.

### 3.2 Neurodegeneration and amyloid predict decline in real-world MCI (RQ1; Fig 2, Table 2)
In the AJU primary model (continuous amyloid, n=251; Table 2), AD-signature neurodegeneration and amyloid burden were both robust, independent predictors of two-year ΔMMSE: neurodegeneration β = −0.60 per SD (95% CI −1.00 to −0.19, p = 0.004) and amyloid SUVR β = −5.17 (95% CI −7.99 to −2.35, p < 0.001). Both survived Huber regression (N p = 0.005; amyloid p < 0.001), influential-point exclusion (p = 0.004; p < 0.001), and bootstrap (P(β<0) = 0.999 and 1.000). The amyloid effect remained significant under conservative baseline-cognition control (quadratic-MMSE adjustment: β = −4.25, p = 0.003). In contrast, *binary* amyloid positivity was weaker (β = −1.15, p = 0.011, n=252) and attenuated to borderline under the same conservative control (see Limitations); we therefore emphasize the continuous measure. Neurodegeneration and amyloid were statistically independent (r = 0.21; VIF = 1.05). APOE-ε4 count was not independently prognostic once amyloid was modeled (β = +0.10, p = 0.82). For meaningful decline (harmonized model), amyloid was associated at the ≤ −2 threshold (OR 2.26, p = 0.010) but only borderline at ≤ −3 (OR 1.84, p = 0.084), underscoring that the continuous amyloid signal is more stable than dichotomized exposures or outcomes.

### 3.3 Reproduction in the research-cohort benchmark (RQ2; Fig 3)
We compared standardized effects (per SD) from the identical harmonized model in each cohort (Fig 3). Both axes reproduced: in AJU, neurodegeneration β = −0.47 (95% CI −0.84 to −0.11, p = 0.011) and amyloid β = −0.45 (−0.82 to −0.08, p = 0.017); in ADNI, neurodegeneration β = −0.36 (−0.63 to −0.09, p = 0.008) and amyloid β = −0.42 (−0.69 to −0.16, p = 0.002). The two axes were of comparable magnitude within each cohort, and binary amyloid positivity was weak in both (AJU p = 0.054; ADNI p = 0.115). Thus the core structure — neurodegeneration plus continuous amyloid burden, independent and additive — was concordant across a research and a real-world Asian cohort, and the inferiority of binary positivity was a shared, reproducible feature. We interpret this as cross-cohort concordance (two separate within-cohort fits), not as a transported or externally validated prediction model.

### 3.4 WMH burden adds no signal over AT(N) (RQ3; Fig 4)
After AT(N) adjustment, quantitative WMH was null with a 95% CI that **excludes any effect larger than ≈0.5 SD** (standardized β = −0.09, 95% CI −0.49 to +0.31, p = 0.65) — i.e., no larger than the neurodegeneration and amyloid effects themselves (each ≈ −0.4 to −0.5 SD, §3.3) and most plausibly near zero — and visual WMH grade was likewise null (β = −0.09, 95% CI −0.45 to +0.28, p = 0.63); a nonlinear (quartile) specification was also null. A marginal association for raw (untransformed) WMH volume did not survive log-transformation or nonlinear modeling, consistent with an influential-point artifact. Notably, WMH burden in this MCI population was mild (visual grade 1 in 172, grade 2 in 76, grade 3 in only 4 patients), unlike cohorts selected for subcortical vascular disease; we therefore interpret the result as a **boundary condition** (see Discussion), supported by a CI that excludes clinically meaningful WMH effects rather than by absence of evidence alone.

### 3.5 Age- and subtype-modification do not generalize (RQ4)
Among the pre-specified family of four effect-modifiers (Bonferroni α = 0.0125), an amyloid-by-age interaction was present in AJU (binary β = +1.15, p = 0.005; continuous β = +0.39, p = 0.043) but did **not** replicate in ADNI, where it trended oppositely (binary β = −0.48, p = 0.069; continuous β = −0.25, p = 0.064) despite near-identical age distributions (AJU 72.2 ± 7.4; ADNI 71.1 ± 7.5). We therefore treat age-modification as cohort-specific, not generalizable. In a full-cohort (n=286) supplementary analysis, the pooled clinical vascular diagnosis was not robust to Huber regression; the residual signal localized to small subcortical/mixed-vascular subgroups (Subcortical VaD, n=7, adjusted residual −2.48) rather than to the bulk "Vascular MCI" category (n=46, −0.31).

### 3.6 Follow-up selection (directional caveat)
Followed-up patients were milder than non-followed (baseline MMSE 24.1 vs 23.0; CDR-SB 2.4 vs 2.9; both p < 0.001) but did not differ in age (p = 0.31) or amyloid positivity (p = 0.35). Because the (binary) amyloid effect concentrated in higher-functioning patients (Limitations), **selection toward milder MCI could amplify rather than null the amyloid estimate**; we therefore treat this as a directional caveat, not a reassurance. Balance on amyloid *prevalence* does not guarantee an unbiased amyloid–outcome slope.

## 4. Discussion

In a vascular-inclusive Asian memory-clinic MCI cohort, two-year cognitive decline was predicted by two robust, independent axes — AD-signature neurodegeneration and continuous amyloid burden — of comparable magnitude; the same structure reproduced in ADNI as a benchmark. The contributions are a *bundle*, not a single novelty: (i) a head-to-head demonstration that the neurodegeneration+amyloid prognostic structure is concordant between a research and a real-world Asian cohort; (ii) a defended **boundary condition** for WMH; and (iii) disciplined negatives (binary-positivity inferiority and a non-replicating age interaction).

These results must be positioned against close prior work. Vemuri et al. (2015)[2] showed amyloid and vascular pathology are independent predictors of decline, but in *normal elderly*, cross-sectionally defined, without joint modeling of continuous amyloid and quantitative WMH; we extend the independence question to real-world MCI and show the vascular contribution is not robust once AT(N) is modeled. Younes et al. (2025)[4] demonstrated amyloid prognosis in a heterogeneous cohort, but a *Western* one without quantitative WMH and without a head-to-head Asian benchmark. Bachmann et al. (2026)[5] jointly modeled amyloid, hippocampus, WMH, and plasma, but in a *non-demented community* sample rather than memory-clinic MCI. Ye et al. (2015)[3] found WMH independently predicts decline in Korean *subcortical vascular dementia* — a population enriched for severe WMH, exactly the burden largely absent here — which is why our null is a boundary condition (WMH matters where WMH burden is high; it adds nothing over AT(N) in typical MCI) rather than a contradiction.

Clinically, the continuous-over-binary amyloid result argues against dichotomized cutoffs for prognostication, and the WMH boundary suggests quantitative WMH may not need to be weighted for short-term MMSE prognosis once atrophy and amyloid are known — pending replication. This is a clinical/empirical contribution; the AT(N) framework and amyloid prognosis are established, and we claim no methodological novelty.

## 5. Limitations

- Single-center primary cohort; two-wave design (a single change, not a trajectory); MMSE is a screening instrument.
- **Amyloid-effect robustness is operationalization-dependent.** The continuous SUVR effect survived quadratic-MMSE adjustment (p = 0.003), but *binary* positivity attenuated to borderline under quadratic-MMSE (p ≈ 0.06) and ceiling-exclusion (p ≈ 0.10), and the amyloid effect concentrated in higher-functioning MCI; ceiling/regression-to-the-mean cannot be fully excluded for the binary measure. The headline therefore rests on the continuous measure.
- ADNI is a **benchmark, not an external validation**: cohorts were not pooled, instruments differ (Korean vs standard MMSE; segmentation/version), and the N effect was ~2× smaller in ADNI. Within-cohort standardization mitigates but does not eliminate harmonization differences. No external *longitudinal* validation cohort exists on hand (the Korean KDRC cohort is cross-sectional only).
- The follow-up selection toward milder patients may *amplify* the amyloid estimate (directional, §3.6).
- Bloods were routine panels; plasma AD markers (p-tau217, GFAP, NfL) were unavailable.
- WMH visual grading used a local scale; standardized Fazekas scores were missing for this subset.
- The pooled vascular diagnosis was not robust; we claim no vascular prognostic axis.

## 6. Conclusion

A prognostic structure of AD-signature neurodegeneration plus continuous amyloid burden predicts two-year cognitive decline in vascular-inclusive Asian real-world MCI and is directionally concordant with a research-cohort benchmark. In this setting prognosis is carried by amyloid and neurodegeneration rather than WMH burden, and continuous amyloid burden outperforms binary positivity. The results support a parsimonious approach to short-term prognosis in real-world MCI, pending external longitudinal replication.

---

## Table 1. Baseline characteristics (mean ± SD unless noted)

| | AJU real-world MCI (n=252) | ADNI research MCI (n=309) |
|---|---|---|
| Age, years | 72.2 ± 7.4 | 71.1 ± 7.5 |
| Female, % | 71 | 43 |
| Education, years | 8.6 ± 4.7 | not available |
| MMSE, baseline | 24.8 ± 3.2 | 27.9 ± 2.0 |
| CDR–Sum of Boxes | 2.0 ± 1.0 | 1.8 ± 2.1 |
| Amyloid-positive, % (n) | 30 (76/252) | 46 (143/309) |
| APOE-ε4 carrier, % | 27 | 40 |
| Follow-up, years | median 1.9 (IQR 1.7–2.3) | ≈2.0 (24-mo–targeted visit) |
| ΔMMSE (2-year) | −0.4 ± 3.1 | −0.7 ± 2.5 |

## Table 2. Decomposition of two-year ΔMMSE — AJU primary model (single model, continuous amyloid; n=251)

| Predictor | β (95% CI) | p |
|---|---|---|
| N (AD-signature atrophy) | −0.60 (−1.00, −0.19) | 0.004 |
| A (amyloid, continuous SUVR) | −5.17 (−7.99, −2.35) | <0.001 |
| V (clinical vascular diagnosis) | −1.03 (−2.05, −0.01) | 0.047 (not Huber-robust) |
| WMH (log-volume) | +0.13 (−0.54, +0.81) | 0.694 |

*Single multivariable model (ΔMMSE ~ age + sex + education + baseline MMSE + CDR-SB + interval + N + amyloid SUVR + vascular dx + WMH), n=251. Both N and amyloid survive Huber regression, influential-point exclusion, and bootstrap (P(β<0) = 0.999 and 1.000). A–N independence: r = 0.21, VIF = 1.05. APOE-ε4 count, when added to this model, was not prognostic (β = +0.10, 95% CI −0.72 to +0.91, p = 0.82). **Sensitivity:** substituting binary amyloid positivity for SUVR, binary A β = −1.15 (95% CI −2.03 to −0.27), p = 0.011 (n=252), but this attenuates under quadratic-MMSE/ceiling control whereas continuous SUVR does not. Harmonized AJU↔ADNI standardized estimates (no education) are in Fig 3.*

## Figure legends
- **Fig 1.** 🔴 Participant flow (to be drawn with counts): AJU screening → MCI → two-wave → analyzed (n=252); ADNI MCI benchmark (n=309). Analyzed separately, not pooled.
- **Fig 2.** AT(N) prognostic decomposition in AJU (standardized β on ΔMMSE; N and amyloid significant, vascular and WMH not). `figs/fig2_forest.png`
- **Fig 3.** Benchmark AJU vs ADNI (same harmonized model, not pooled): neurodegeneration and amyloid burden reproduce directionally; the amyloid-by-age interaction does not. `figs/fig3_benchmark.png`
- **Fig 4.** WMH burden (log-volume, visual grade) adds no signal over AT(N) in AJU; CIs exclude effects larger than ≈0.5 SD. `figs/fig4_wmh_boundary.png`

## References (verified anchors; [VERIFY] = confirm full citation before submission)
1. Jack CR Jr, et al. NIA-AA Research Framework: AT(N). *Alzheimers Dement.* 2018. [VERIFY]
2. Vemuri P, et al. Vascular and amyloid pathologies are independent predictors of cognitive decline. *Brain.* 2015;138(3):761.
3. Ye BS, et al. Effects of amyloid and vascular markers on cognitive decline in subcortical vascular dementia. *Neurology.* 2015. (PMC4653105) [VERIFY domain coefficients]
4. Younes K, et al. Amyloid-PET predicts longitudinal cognitive trajectories in a heterogeneous cohort. *Alzheimers Dement.* 2025. (PMC11947745)
5. Bachmann …, et al. Independent and interactive contributions of WMH and AD biomarkers. *Alzheimers Res Ther.* 2026;18:106. [VERIFY WMH effect direction after AD-marker adjustment]
6. Yim Y, et al. Integrating MRI volume and plasma p-tau217 for amyloid risk stratification (K-ROAD↔ADNI, cross-sectional). *Neurology.* 2025.
7. Kim H-R, et al. K-ROAD cohort. *Dement Neurocogn Disord.* 2024;23(4):212.
8. Li …, et al. Association of WMH with cognitive decline and neurodegeneration (ADNI). *Front Aging Neurosci.* 2024. (PMC11425965)
9. Petersen RC. Mild cognitive impairment. [VERIFY] · 10. Folstein MF, et al. Mini-Mental State Examination. [VERIFY] · 11. Klunk WE, et al. The Centiloid project. [VERIFY]

> ⚠️ 인용 금지: "Lee BS 2016 Neurology 한국 amyloid 종단" — lit-scout 특정 실패, 미사용.
