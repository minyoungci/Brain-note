# Results

_Draft — clinical track (number-driven; β, 95% CI, P; uniform notation). Every figure referenced; placeholders marked. [VERIFY] = not confirmable from source files._

## Participant characteristics and selection

Of 1001 AJU participants with a baseline session, 998 met the complete-covariate criterion and 982 additionally yielded an automated WMH segmentation; 643 were amyloid-negative and 339 amyloid-positive (Insert Figure 1 here — participant flow). In the KDRC cohort, 265 of 909 participants met the complete-covariate criterion and 259 yielded a WMH segmentation, of whom 69 were amyloid-negative. As expected, amyloid-positive participants had smaller eTIV-normalized hippocampal volumes and lower Mini-Mental State Examination scores than amyloid-negative participants in both cohorts (AJU 5.28 vs 5.71 and 21.4 vs 24.3; KDRC 4.67 vs 5.33 and 18.1 vs 20.6), confirming the expected direction of amyloid stratification. Vascular risk factors were complete in the AJU cohort (hypertension, diabetes, and dyslipidemia available for all participants) and present in approximately 58% of the KDRC cohort. The primary analyses were conducted in the 643 amyloid-negative AJU participants.

## Concurrent validity of automated WMH quantification against visual grade

Automated WMH volume increased monotonically across visual grades in both cohorts (Insert Figure 2 here — segmentation examples; Insert Figure 3 here — WMH volume by visual grade). In the AJU cohort the automated WMH volume correlated with the three-level visual grade (Spearman ρ = 0.55, P = 5 × 10⁻⁹; Kruskal–Wallis P = 9 × 10⁻⁸), with per-grade median WMH of 0.43%, 0.96%, and 1.00% of intracranial volume for grades 1–3. In the KDRC cohort, correlation with the summed Fazekas score was stronger (Spearman ρ = 0.70, P = 1 × 10⁻¹⁵; Kruskal–Wallis P = 3 × 10⁻⁹), with a monotone increase from 0.40% to 1.73% across Fazekas 0–6. The discrimination of higher versus lower visual burden was moderate in AJU (area under the curve 0.73) and high in KDRC (0.90). Automated WMH quantification therefore reproduced the visual ordering while resolving variation within the saturated upper grades.

## WMH and hippocampal volume in amyloid-negative individuals

Within the 643 amyloid-negative AJU participants, greater WMH burden was associated with smaller eTIV-normalized hippocampal volume (standardized β = −0.17 per standard deviation of log-WMH, 95% confidence interval [CI] −0.22 to −0.12, P = 3 × 10⁻¹⁰; Insert Figure 4 here — robustness forest plot; Insert Figure 5 here — partial-residual plot). The association was essentially unchanged after substituting a natural cubic spline for age (β = −0.17), and was attenuated but remained significant after adjustment for a non-circular global-atrophy control (cortical grey-matter volume; β = −0.12, P = 2 × 10⁻⁵), after additional adjustment for vascular risk factors (β = −0.12, P = 3 × 10⁻⁵), and after adjustment for FLAIR-to-T1 registration quality (β = −0.12, P = 2 × 10⁻⁵; 641 participants with the registration metric). The association was robust to specification: across all 32 model specifications crossing outcome normalization, WMH transform, age model, atrophy control, and vascular-risk adjustment, the WMH coefficient was negative and significant (median β = −0.21, range −0.16 to −0.25). The amyloid-negative WMH–hippocampus association was thus specific to WMH and independent of global atrophy and nonlinear age.

## Detection by quantitative versus visual WMH

The same association was not detectable with the ordinal visual grade. In the amyloid-negative stratum the standardized visual-grade coefficient was −0.07 (P = 0.08), whereas the standardized continuous-WMH coefficient in the same participants, in a model matched to the visual-grade specification, was −0.25. The ratio of the two standardized coefficients (0.28) approximated the square of their correlation (ρ = 0.55; ρ² = 0.30), the attenuation predicted when a coarse three-level scale measures the same construct with error. Quantitative segmentation therefore recovered an association that the visual grade attenuated below detectability.

## Vascular risk factors: positive control and mediation

Vascular risk burden predicted greater WMH (β = +0.11, P = 0.004), as did hypertension (β = +0.22, P = 0.004) and diabetes (β = +0.33, P = 2 × 10⁻⁴), confirming that the automated WMH measure captured vascular pathology. However, vascular risk burden showed no net association with hippocampal volume (total β = −0.008, P = 0.76); the indirect path through WMH was significant (β = −0.019, 95% CI −0.036 to −0.006) but was offset by a near-zero direct path. Among individual factors, only diabetes was associated with smaller hippocampal volume (β = −0.12, P = 0.04, exploratory and uncorrected). Vascular risk factors therefore validated and were upstream of the WMH burden, but the brain-level WMH—not clinical risk-factor status—was the marker associated with hippocampal volume.

## Mediation of the age–hippocampus association by WMH

WMH was associated with hippocampal volume independently of age (P = 3 × 10⁻⁵), and mediated 22.5% of the age–hippocampus association (indirect β = −0.006, 95% CI −0.009 to −0.004). WMH thus acted beyond age rather than as a proxy for it.

## WMH and apolipoprotein E ε4

The WMH–hippocampus association did not differ by APOE ε4 status (interaction P = 0.59) and was present in both ε4 carriers (β = −0.13, P = 0.046) and non-carriers (β = −0.18, P < 0.001). The association was therefore not confined to ε4 carriers.

## Registration robustness

WMH quantified from native FLAIR (reconstructed from source DICOM, without registration or normalization) correlated with WMH from the registered pipeline (Spearman ρ = 0.83), although absolute volumes were higher in the thicker-slice native acquisition (median 1.18% vs 0.60% of intracranial volume); the within-stratum analysis used z-scored WMH and was invariant to this scale difference. Registration quality was correlated with both hippocampal volume (r = −0.31) and WMH (r = +0.31) at the bivariate level, but the WMH–hippocampus association was unchanged after adjustment for registration quality (β = −0.120 to −0.119), and registration quality had no independent association with hippocampal volume (P = 0.13). Registration was therefore not a source of the association.

## KDRC consistency cohort

In the 69 amyloid-negative KDRC participants, greater WMH was associated with smaller hippocampal volume in the primary model (β = −0.19, P = 0.015), but the association did not survive the non-circular global-atrophy adjustment (β = −0.10, P = 0.29) and was present in both amyloid strata (amyloid-positive β = −0.19, P = 0.002). Given its small amyloid-negative subgroup and non-specific pattern, the KDRC cohort provided a directionally consistent but underpowered observation that did not establish amyloid-negative specificity.
