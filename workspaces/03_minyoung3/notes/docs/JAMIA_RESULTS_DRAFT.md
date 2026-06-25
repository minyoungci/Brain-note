# JAMIA Results Draft

Status: Results-section draft cross-checked against `docs/JAMIA_ABSTRACT_BASELINE.md`, `docs/JAMIA_METHODS_DRAFT.md`, and source artifacts.

Working manuscript and artifact name: **ClaimTrap-AD**.

## Results

### Pilot evaluation: checklist prompting reduced but did not eliminate over-claims

The 30-case pilot evaluated open-ended research-agent conclusions under the dual-view protocol. Agents saw only the generation view; the non-self judge saw the scoring view containing the allowed claim ceiling, required limitations, and forbidden over-claims. Each arm was sampled three times per case (90 outputs per arm). Generic outputs over-claimed on 19/90 outputs (21.1%; Wilson 95% CI, 14.0%-30.6%) and hard-failed on 14/90 outputs, with mean completeness 1.678 on a 0-3 scale. Checklist prompting reduced over-claims to 3/90 (3.3%; 95% CI, 1.1%-9.3%) and hard-fails to 1/90, while increasing completeness to 2.622.

The residual checklist failures were not random. All three checklist over-claims occurred on the same incremental-value case, indicating that a global checklist instruction reduced broad over-claiming but did not reliably enforce a case-specific claim ceiling. In the locked n=3 recurrence review, 9 over-claiming case-arm pairs were selected for human review; no over-claim verdict was rejected, and the checklist recurrence target was adjudicated as an E2 safety over-claim in 3/3 repeats.

The pilot Claim Safety Controller was evaluated as an inference-time rewrite controller, not as an independent generation arm. It rewrote fixed generic drafts and resampled the rewrite three times per case. In this rewrite-stability setting, controller v4 eliminated observed over-claims and hard-fails (0/90 each; 95% CI upper bound, 4.1%), with no strict-fallback events. Completeness was 1.878, lower than checklist prompting but higher than the generic arm. Thus, the controller result should be interpreted as a safety/completeness trade-off: ceiling-dependent routing removed observed over-claims in the pilot, but it did not dominate checklist prompting on informativeness.

| Pilot arm | Generation/rewrite setting | Over-claim | Hard-fail | Mean completeness |
|---|---|---:|---:|---:|
| Generic | independent open-ended generations | 19/90 | 14/90 | 1.678 |
| Checklist prompt | independent open-ended generations | 3/90 | 1/90 | 2.622 |
| Claim Safety Controller v4 | fixed generic draft + rewrite resampling | 0/90 | 0/90 | 1.878 |

### Scaled benchmark composition and auto-gold checks

We then scaled the benchmark to 2,888 auto-gold cases. The source manifest contained 7 cohorts, 13,022 sessions, and 7,231 subjects; the scaled leave-one-cohort-out benchmark used 6 diagnostic cohorts (ADNI, NACC, AIBL, KDRC, OASIS, and AJU), excluding A4 from diagnostic contrasts. The benchmark contained 2,470 univariate ROI findings, 190 multivariate model findings, and 228 planted controls. Labels were distributed as 1,008 artifact and 1,880 real cases, with ordinal claim ceilings L0 (1,019), L1 (957), and L2 (912). Difficulty strata comprised 1,706 easy-real cases, 805 easy-artifact cases, 214 hard-artifact cases, and 163 hard-real cases.

Auto-gold reliability analyses were performed on the 2,660 non-planted cases with ground-truth cohort AUROC values. Non-planted labels were invariant for 1,864/2,660 cases (70.1%; 95% CI, 68.3%-71.8%) across replication thresholds from 0.55 to 0.65; the remaining cases form a near-boundary zone and should not be interpreted as equally stable labels. Cross-cohort consistency was assessable for 280 findings evaluated under at least two held-out ground-truth cohorts; 216/280 (77.1%; 95% CI, 71.9%-81.7%) received unanimous real/artifact labels across those cohorts. Convergent validity checks showed separation between gold-real and gold-artifact cases: gold-real cases had higher mean replication signal (tool_repl 0.696 vs 0.551), higher mean covariate-incremental signal (0.080 vs 0.009), and higher discovery AUROC (0.699 vs 0.546).

| Scaled benchmark property | Value |
|---|---:|
| Total cases | 2,888 |
| Artifact / real labels | 1,008 / 1,880 |
| Univariate / model / planted cases | 2,470 / 190 / 228 |
| Hard-artifact stratum | 214 |
| Non-planted naturally occurring hard traps | 98 |
| Threshold-robust non-planted labels | 1,864/2,660 (70.1%) |
| Unanimous multi-cohort labels | 216/280 (77.1%) |

### Hard artifact traps expose a replication-recovery problem, not an empirical failure of a straw baseline

The hard-artifact stratum was defined as high discovery-cohort performance with failed replication. Consequently, a discovery-threshold rule is blind to this stratum by construction: because membership requires discovery AUROC at or above the threshold while the artifact label is assigned from failed replication, thresholding on discovery performance alone cannot recover these traps. We therefore do not treat the discovery-threshold rule's 0% recall in this stratum as an empirical headline result. Its role is to define the claim-calibration challenge: findings can look claim-worthy in discovery data while failing out-of-cohort replication.

The empirical question is whether a replication-aware baseline can recover these traps using a disjoint held-out replication signal. Because both the replication-rule signal and the gold label are out-of-cohort replication estimates on disjoint cohorts, they are correlated rather than independent; the baseline therefore tests recoverability from a related signal, not validation by an independent oracle. Across all 214 hard-artifact-stratum cases, the replication-rule baseline detected 148/206 artifact-labeled cases (recall 0.718; 95% CI, 0.653-0.775) at precision 0.987 (148/150; 95% CI, 0.953-0.996). On the 98 naturally occurring non-planted hard traps, it detected 42/98 (42.9%; 95% CI, 33.5%-52.7%) at precision 1.000 (42/42; 95% CI, 91.6%-100%). Thus, replication-aware rules recover part, but not all, of the designed hard stratum; the remaining missed natural traps define the unsaturated portion of the benchmark.

Across all 2,888 cases, the replication-rule baseline achieved F1 0.841 for artifact detection, compared with 0.812 for the discovery-threshold rule. The difference depended strongly on stratum. On planted controls, the replication-rule baseline achieved F1 0.974 versus 0.095 for the discovery-threshold rule. On non-planted ROI/model findings, however, the discovery-threshold rule achieved higher F1 (0.861 vs 0.825), reflecting that ordinary ROI findings often replicate well enough that discovery AUROC is already informative. The benchmark's discriminative value is therefore concentrated in the hard-artifact stratum rather than in the average case.

| Evaluation subset | Baseline | Recall | Precision | F1 | Accuracy |
|---|---|---:|---:|---:|---:|
| All cases | Replication-rule | 0.897 | 0.792 | 0.841 | 0.882 |
| All cases | Discovery-threshold | 0.794 | 0.831 | 0.812 | 0.872 |
| Hard-artifact stratum | Replication-rule | 0.718 | 0.987 | 0.831 | 0.720 |
| Hard-artifact stratum | Discovery-threshold | 0.000 | NA | NA | 0.037 |
| Non-planted ROI/model cases | Replication-rule | 0.886 | 0.773 | 0.825 | 0.874 |
| Non-planted ROI/model cases | Discovery-threshold | 0.888 | 0.835 | 0.861 | 0.903 |
| Planted controls | Replication-rule | 0.982 | 0.966 | 0.974 | 0.974 |
| Planted controls | Discovery-threshold | 0.053 | 0.500 | 0.095 | 0.500 |

### Direct-question LLM agents collapsed to rejection rather than calibrated discrimination

We evaluated two open LLM agents (Qwen3-32B and MedGemma-27B) on a stratified 480-case sample from the scaled benchmark, with both generic and checklist prompts. The task asked directly whether each finding generalized. Under this direct questioning setup, neither model affirmed generalization for any case (0/960 for each model; 95% CI upper bound, 0.4%). Qwen produced 701 "no" and 259 "uncertain" responses across 960 model-arm outputs; MedGemma produced 901 "no" and 59 "uncertain" responses. Both models therefore had 0 over-claims on artifact cases (0/468 for each model; 95% CI upper bound, 0.8%), but this was not calibrated safety: they also failed to affirm any real cases.

This direct-question result contrasts with the pilot open-ended generation setting, where generic outputs did over-claim and checklist prompting reduced but did not eliminate those failures. Because the pilot and scaled LLM evaluations differ in model family, response format, and judging procedure, the contrast should not be attributed to framing alone. The conservative conclusion is that claim calibration behavior is sensitive to the evaluation setup, and that direct yes/no questioning can induce near-uniform rejection rather than discriminative evidence use.

| Model | Outputs | Yes | No | Uncertain | Artifact over-claims |
|---|---:|---:|---:|---:|---:|
| Qwen3-32B | 960 | 0 | 701 | 259 | 0/468 |
| MedGemma-27B | 960 | 0 | 901 | 59 | 0/468 |

### Summary of empirical support

The results support three bounded claims: open-ended medical research-agent outputs can over-claim structured biomedical artifacts, and checklist prompting reduces but does not eliminate those over-claims in the 30-case pilot; the scaled benchmark creates a replication-defined hard stratum in which discovery evidence and replication evidence disagree, with a replication-rule baseline recovering only part of the naturally occurring traps; and direct yes/no LLM evaluation on the scaled benchmark does not show over-claiming, but rather near-uniform rejection. Together, these findings motivate ClaimTrap-AD as an evaluation benchmark for claim calibration, not as evidence that any current controller or LLM agent closes the problem.
