# ClaimTrap-AD: A Replication-Grounded Benchmark for Claim Calibration in Medical Research Agents

> **Status:** Full-manuscript draft v2 (post research-critic + literature-scout integration). **Draft pending completion of human validation** (see Limitations) — not submission-final.
> **Target:** JAMIA — *Research and Applications* (body ≤4000 words excl. references/acknowledgments; structured abstract ≤250 words; ≤6 figures / ≤4 tables; Vancouver references; double-spaced; Word at submission).
> **Reporting:** TRIPOD-LLM (Gallifant et al., Nat Med 2025). Completed checklist = Supplementary File S1 (item wording to be reconciled with the official Nat Med supplement before submission).
> **Flags:** `[VERIFY]` = to confirm before submission; `[TODO]` = author-supplied metadata; `[WC]` = length note.
> **Length:** controller content moved to Supplement S2 and Methods condensed per research-critic M6; re-confirm exact body count once formatted.

---

## Title page

**Title:** ClaimTrap-AD: A Replication-Grounded Benchmark for Claim Calibration in Medical Research Agents

**Authors:** [TODO author list, degrees, affiliations]

**Corresponding author:** [TODO name, MD; postal address; email; telephone] — the corresponding author is a clinically qualified (MD) co-author, relevant to the human-validation plan (Limitations).

**Keywords (≤5, MeSH-aligned):** large language models; benchmarking; medical informatics; reproducibility of results; clinical decision support systems `[VERIFY: confirm each is a valid MeSH descriptor]`

**Word count:** [TODO excl. title, abstract, references, figures, tables]

---

## Structured abstract (≤250 words)

**Objective:** To benchmark whether medical research agents calibrate conclusions to the strength of the underlying evidence, using structured Alzheimer's-disease neuroimaging artifacts, and to release a reusable replication-grounded test set.

**Materials and Methods:** We developed ClaimTrap-AD, a dual-view framework in which an agent converts structured neuroimaging artifacts into a conclusion, while evaluators score it against held-out ordinal claim ceilings and out-of-cohort replication evidence. A 30-case pilot, labeled by independent large language model (LLM) reviewer agents, defined the claim-ceiling task and evaluated open-ended outputs. We then scaled to 2,888 auto-gold cases from a seven-cohort manifest (13,022 sessions; 7,231 subjects), using six diagnostic cohorts for leave-one-cohort-out evaluation; gold labels and a replication-rule baseline used disjoint held-out cohort signals. Reporting follows TRIPOD-LLM.

**Results:** In the pilot, generic agents over-claimed on 19/90 outputs; checklist prompting reduced this to 3/90 but concentrated all residual failures on one incremental-value case. In the scaled benchmark, 70.1% of non-planted labels were threshold-robust and 216/280 (77.1%) multi-cohort-judgeable findings were unanimous. A discovery-threshold rule had 0% recall on the hard-artifact stratum by construction; a replication-rule baseline recovered 148/206 stratum cases (recall 0.718, precision 0.987 [148/150]) but only 42/98 (42.9%) naturally occurring traps. Given discovery-only inputs, open LLMs uniformly declined to affirm generalization (0/960 each) — the task floor absent replication evidence.

**Discussion:** Claim calibration was sensitive to framing and replication structure; no evaluated method closed the gap.

**Conclusion:** ClaimTrap-AD exposes a measurable claim-calibration gap and releases a benchmark to track it.

---

## Introduction

Large language model (LLM) agents are increasingly proposed as research assistants that read analytic outputs and draft biomedical conclusions. A recurring concern in their evaluation is not factual fabrication but *over-statement*: a model summarizes a result with more confidence, generality, or causal force than the result supports. Head-to-head biomedical evaluations report that LLMs are sensitive to prompt formulation, respond inconsistently to identical inputs, and can degrade downstream performance when used uncritically [1], and that current models are better positioned as supplementary tools than as autonomous clinical assistants [2]. More directly, LLM summaries of scientific findings overgeneralize their source far more often than human summaries do [3], echoing a longer line of work on detecting exaggeration of research claims [4]. These findings motivate evaluating a specific, safety-relevant behavior: whether an agent's stated claim stays within the strongest claim the evidence licenses.

We call this behavior *claim calibration*. It differs from adjacent problems. It is not factual or literature-grounded claim verification, in which a claim is checked against an external knowledge source [5,6]. It is not generic research-rigor or exaggeration scoring of authored prose [4], nor in-paper claim-overstatement scoring on the machine-learning literature [7]. Claim calibration instead asks whether a conclusion drawn from a *given* analysis result remains within what that result supports — most stringently, whether a within-cohort association is mis-stated as predictive, transportable, or deployable when out-of-cohort replication does not hold. Existing biomedical-agent benchmarks emphasize task success or planning over an environment [8,9] rather than the evidence-to-claim gap under replication failure. We make no priority claim; to our knowledge no prior benchmark targets the specific intersection of an *agent* converting a *structured analysis result* into prose, in a *clinical* setting, where the trap is *over-claiming generalization unsupported by out-of-cohort replication*.

We present ClaimTrap-AD, a replication-grounded benchmark for claim calibration in medical research agents, built on structured neuroimaging artifacts from Alzheimer's-disease and related cohorts. We treat over-claiming as a safety error scored against an ordinal claim ceiling grounded in held-out, out-of-cohort replication. The study is deliberately framed as an honest-negative evaluation: across prompt-based agents, deterministic statistical baselines, and direct-question open LLMs, no evaluated method closes the calibration gap. The contribution is the measurement framework and the released benchmark, not a system that solves the task. Because no purpose-built reporting guideline exists for AI benchmark or no-intervention studies [11], we report against TRIPOD-LLM [10], whose scope explicitly covers *evaluating* an LLM.

---

## Materials and Methods

### Study design

ClaimTrap-AD evaluates claim calibration in medical research agents: an agent converts structured biomedical analysis artifacts into a natural-language conclusion, and we score whether the conclusion stays within the strongest claim the evidence supports. The study has two linked components: a 30-case pilot that defines the claim-ceiling task and evaluates open-ended agent outputs, and a scaled replication-grounded benchmark that tests statistical baselines and direct-question LLMs at larger scale. The two components measure related but distinct constructs: the pilot scores open-ended prose against an ordinal ceiling, whereas the scaled component uses replication prediction as a tractable proxy for that ceiling. We therefore present the scaled task as a proxy, not as the open-ended claim-writing task of the pilot.

We treat an over-claim as a safety error: a statement asserting predictive, transportable, causal, biomarker, or incremental value beyond what the artifact supports. We separately score completeness, because an output can be safe but uninformative. Claim ceilings are ordinal: L0, no defensible claim; L1, within-cohort association; L1.5, within-cohort association with a mandatory negative-increment caveat; L2, internal predictive validity; L3, transportable or deployable-biomarker evidence. The pilot uses the full scheme; the scaled benchmark uses replication-defined L0–L2 labels. All inputs are structured artifacts derived from tabular neuroimaging, clinical, and biomarker fields; the project inventory found no raw clinical free-text corpus. No model training, preference optimization, or fine-tuning was performed.

### Data sources

The scaled benchmark was built from a structured manifest of 13,022 sessions from 7,231 subjects across seven cohorts (A4, ADNI, AIBL, AJU, KDRC, NACC, OASIS). The leave-one-cohort-out builder used six diagnostic cohorts (ADNI, NACC, AIBL, KDRC, OASIS, AJU); A4 was excluded from diagnostic contrasts as a single-class amyloid-prevention cohort. One representative session per subject was selected, requiring non-missing age, sex, and brain segmentation volume. Imaging features were FreeSurfer regional volumes (intracranial-volume–normalized, raw, and hemispheric-asymmetry), yielding 70 unique ROI-derived features used across the non-planted cases. Five endpoints were specified (CN vs AD/dementia, CN vs MCI, MCI vs AD/dementia, CN vs dementia-only, and CN/MCI vs AD/dementia); four yielded cases meeting the ≥25-per-class cohort-viability threshold, while CN vs dementia-only yielded no viable cohort and is absent from the released benchmark. Multivariate findings used predefined logistic-regression and random-forest configurations over hippocampal, signature-region, or all normalized ROI features. `[VERIFY: report post-filter subjects-per-cohort actually entering the benchmark — not derivable from the released JSONL; pull from the builder/manifest.]`

### Pilot benchmark and dual-view protocol

The pilot contains 30 locked cases: 10 OASIS-derived structured artifacts and 20 constructed probes (controlled evaluation fixtures designed around observed evidence-to-claim failure modes, not new biological findings). Cases span an eight-category over-claim taxonomy (covariate-baseline omission; incremental-value; temporal-prediction; label-provenance; cross-cohort generalization; causal/mechanistic; negative-control shortcut; unsupported biomarker), enumerated in Supplementary S4.

Pilot gold labels were generated by two independent LLM reviewer agents — a critic persona and a domain-expert persona — that scored blinded artifacts without access to draft labels, taxonomy, revision notes, or answer-key fields. Consensus cases were mechanically locked; tier-preserving disagreements were resolved by conservative tie-breaking; disagreements crossing claim tiers or error families were escalated to manual adjudication, which one case required. Full human-expert relabeling of the pilot was not performed. Final pilot gold labels comprised 17 L1, 10 L1.5, and 3 L0 cases.

To prevent evaluation leakage, each case has two views. The generation view contains only agent-visible inputs (task text, structured metrics, provenance, focus question); the scoring view contains judge-only fields (gold claim level, allowed claim, forbidden assertions, required checks, primary error type, adjudication metadata). Both prompts were scanned for leakage; the locked run reported zero leaks across 60 prompts. The checklist prompt, implemented as the `verification_aware` arm, received only a global checklist and claim schema identical for every case; it never received case-specific gold.

### Pilot agents and judging

Two open-ended generation arms were compared. The generic arm used a medical-research-assistant prompt with only the generation-view artifact; the checklist arm used the same model and artifact plus the global verifier checklist and ordinal claim schema. Both arms used `claude-sonnet-4-6`; for the n=3 recurrence run, decoding used temperature 1.0 and a 4,000-token budget. Each arm generated three outputs per case (90 per arm); the comparison is therefore a within-model prompt ablation, not a model comparison. (A deterministic inference-time Claim Safety Controller was evaluated separately as a rewrite controller on fixed generic drafts; because that protocol measures rewrite stability rather than independent generation, it is reported in Supplementary S2 and excluded from the main comparison.)

Pilot outputs were scored by a reference-guided, non-self LLM judge (GPT-5.5) that read the scoring view and the agent output, hid agent identity, and scored each claim on a 0–3 rubric (0, invalid/dangerous over-claim; 1, partial, missing required limitations; 2, calibrated within-ceiling claim; 3, stronger calibrated claim with required caveats), with hard-fail and over-claim indicators recorded separately. The protocol explicitly distinguishes calibrated negation from over-claiming (e.g., "not a robust biomarker" is not an over-claim merely for containing a forbidden concept); rule-based screens were coarse gates only. Two human-review packs were used: in the locked n=3 run, a human-corrected recurrence review confirmed the persistent checklist failure on the incremental-value case as a genuine over-claim in all three repeats (9 over-claiming case-arm pairs reviewed; none rejected); a separate keyword-flag spot-check of nine cases confirmed all nine as calibrated negations rather than over-claims (human over-claim rate 0/9), reclassifying their keyword hits as completeness gaps.

### Scaled replication-grounded benchmark construction

The scaled benchmark was generated by `scripts/build_claimtrap_scaled.py`. For each endpoint, viable cohorts required ≥25 positive and ≥25 negative cases. For each case context, one cohort was assigned as the unseen gold cohort, one disjoint cohort as the held-out replication (tool) cohort, and the remaining viable cohorts as the discovery set, separating the discovery, replication-baseline, and gold-label signals at the cohort level. The replication-rule baseline and the gold label are not literal duplicates but are both out-of-cohort replication estimates and therefore correlated. Univariate cases evaluate individual ROI features; model cases evaluate predefined multivariate classifiers; planted controls were added at graded signal strengths as known real/artifact anchors. Each case stores discovery AUROC, held-out tool-cohort replication AUROC, covariate-incremental AUROC when available, unseen gold-cohort AUROC, endpoint, finding type, gold label, ordinal ceiling, and difficulty stratum.

Gold labels were assigned from the unseen gold-cohort AUROC. For non-planted findings, a finding was labeled real when gold-cohort AUROC exceeded 0.60 and artifact otherwise; the 0.60 threshold reflects a conventional weak-discrimination floor, and we report sensitivity across 0.55–0.65 and flag a near-boundary zone (below). Planted controls instead retained their design label. In 11 of 2,888 cases (0.4%) — all weak planted-real signals, 8 in the hard-artifact stratum and 3 in the easy-artifact stratum — the design label remains real even though the weak effect did not exceed the gold-cohort replication threshold; we retain the design label intentionally, so that a replication rule rejecting a genuinely planted-but-weak real signal is counted as over-rejection rather than as a correct call, making the hard stratum a more conservative test of replication-based calibration rather than a self-confirming one. Scaled ceilings were L0 when the finding did not replicate, L1 when gold-cohort AUROC was >0.60 and ≤0.70, and L2 when >0.70. The hard-artifact stratum was defined as high discovery-cohort AUROC with failed gold-cohort replication; a discovery-threshold rule is blind to this stratum by construction, a property used to define the trap, not an empirical claim that thresholding unexpectedly failed.

### Auto-gold reliability checks

We assessed auto-gold stability three ways (full procedure in Supplementary S2): threshold robustness of real/artifact labels as the cut varied across 0.55–0.65 (identifying the near-boundary region); unanimous cross-cohort agreement for findings evaluated under ≥2 held-out gold cohorts; and a convergent-validity comparison of discovery, replication, and covariate-incremental signals between gold-real and gold-artifact groups. A 120-case human-validation subset (hard-artifact and planted cases) is undergoing blinded adjudication by a clinically qualified (MD) co-author with a strong non-tested LLM as a convergence rater; until this is complete, scaled labels are described as auto-gold labels with reliability checks, not as labels with completed human sign-off (Limitations).

### Statistical baselines and direct-question LLM evaluation

Two deterministic artifact-detection baselines were evaluated. The discovery-threshold rule predicts real when discovery AUROC ≥0.60 and artifact otherwise. The replication-rule baseline predicts artifact when held-out tool-cohort replication AUROC is missing or ≤0.58, or when covariate-incremental AUROC is available and ≤0.02; otherwise real. We computed recall, precision, F1, and accuracy for artifact detection, overall and by prespecified subsets (all cases; hard-artifact stratum; non-planted univariate/model cases; planted controls).

We also evaluated open LLMs as direct-question subjects on a stratified sample (`scripts/run_agent_eval_scaled.py`; up to 120 cases per difficulty stratum, fixed seed; 480 cases). Each model received a generic direct-question prompt and a checklist prompt that required independent replication and covariate-incremental value before affirming generalization. Critically, the input showed only discovery-side information and stated that no external-cohort result was given; because the label is defined by unseen gold-cohort replication, no information in the input distinguishes real from artifact cases. This arm therefore measures default stance behavior under non-identifying inputs, not discrimination. Models were Qwen3-32B (thinking disabled) and MedGemma-27B, decoded at temperature 0 with a short JSON-only budget; responses were parsed as "yes"/"no"/"uncertain".

### Statistical reporting

The pilot is reported descriptively as a controlled benchmark pilot, not a powered superiority trial, with Wilson score 95% confidence intervals (CIs) for proportions and no cross-arm hypothesis testing. The scaled benchmark reports deterministic classification metrics and label-reliability summaries with Wilson CIs. Wilson CIs treat cases as independent Bernoulli trials; because the 2,660 non-planted cases derive from only 70 unique ROI features across four endpoints and multiple gold/replication cohort assignments, cases are non-independent, so the intervals are descriptive and are not adjusted for this clustering. The discovery-threshold rule's 0% hard-artifact recall is reported as a definitional consequence of the stratum and rule, not as an empirical headline; the empirical emphasis is the residual difficulty after adding disjoint replication information.

### Reproducibility and scope

Deterministic components (scaled builder, statistical baselines, evidence extraction, verifier modules, ceiling estimation, over-claim detection, post-rewrite enforcement) are fully reproducible; LLM generation and judging are reproducible only conditional on recorded model identifiers, prompts, decoding settings, and saved raw outputs. Released artifacts include benchmark JSONL, prompt manifests, leakage scans, judge prompts and verdicts, token usage, and summary reports. Gold provenance is a central scope limitation: the pilot uses LLM reviewer-agent labels with one adjudicated case, and the scaled benchmark uses auto-gold replication labels with reliability checks; neither component currently has complete independent human-expert gold labels. The study evaluates claim calibration over structured neuroimaging research artifacts and does not evaluate clinical deployment, diagnostic decision-making, arbitrary biomedical free text, or model safety in unconstrained settings.

---

## Results

### Pilot evaluation: checklist prompting reduced but did not eliminate over-claims

The 30-case pilot evaluated open-ended research-agent conclusions under the dual-view protocol; agents saw only the generation view, while the non-self judge saw the scoring view. Each arm was sampled three times per case (90 outputs per arm). Generic outputs over-claimed on 19/90 (21.1%; Wilson 95% CI, 14.0%–30.6%) and hard-failed on 14/90, at mean completeness 1.678 (0–3). Checklist prompting reduced over-claims to 3/90 (3.3%; 95% CI, 1.1%–9.3%) and hard-fails to 1/90, while raising completeness to 2.622. The residual failures were not random: all three occurred on the same incremental-value case, indicating that a global checklist reduced broad over-claiming but did not reliably enforce a case-specific ceiling. In the locked n=3 recurrence review, 9 over-claiming case-arm pairs were human-reviewed; no over-claim verdict was rejected, and the checklist recurrence target was adjudicated as a safety over-claim in 3/3 repeats. (The Claim Safety Controller, evaluated as a rewrite controller on fixed drafts, removed all observed over-claims in that rewrite-stability setting at a completeness cost; full results are in Supplementary S2 and are not part of the main comparison.)

**Table 1. Pilot generation arms (90 outputs per arm).**

| Pilot arm | Over-claim | Hard-fail | Mean completeness |
|---|---:|---:|---:|
| Generic | 19/90 | 14/90 | 1.678 |
| Checklist prompt | 3/90 | 1/90 | 2.622 |

### Scaled benchmark composition and auto-gold checks

We scaled the benchmark to 2,888 auto-gold cases over six diagnostic cohorts (ADNI, NACC, AIBL, KDRC, OASIS, AJU; A4 excluded from contrasts). It contained 2,470 univariate ROI findings, 190 multivariate model findings, and 228 planted controls; labels were 1,008 artifact and 1,880 real; ordinal ceilings were L0 (1,019), L1 (957), L2 (912); difficulty strata were 1,706 easy-real, 805 easy-artifact, 214 hard-artifact, and 163 hard-real. Reliability analyses used the 2,660 non-planted cases with gold-cohort AUROC. Labels were invariant for 1,864/2,660 (70.1%; 95% CI, 68.3%–71.8%) across thresholds 0.55–0.65; the remaining cases form a near-boundary zone and should not be read as equally stable. Cross-cohort consistency was assessable for 280 findings under ≥2 held-out cohorts; 216/280 (77.1%; 95% CI, 71.9%–81.7%) were unanimous. Convergent-validity checks separated gold-real from gold-artifact cases: higher mean replication signal (0.696 vs 0.551), covariate-incremental signal (0.080 vs 0.009), and discovery AUROC (0.699 vs 0.546).

**Table 2. Scaled benchmark composition and reliability.**

| Scaled benchmark property | Value |
|---|---:|
| Total cases | 2,888 |
| Artifact / real labels | 1,008 / 1,880 |
| Univariate / model / planted cases | 2,470 / 190 / 228 |
| Hard-artifact stratum | 214 |
| Non-planted naturally occurring hard traps | 98 |
| Threshold-robust non-planted labels | 1,864/2,660 (70.1%) |
| Unanimous multi-cohort labels | 216/280 (77.1%) |

### Hard artifact traps expose a replication-recovery problem

The hard-artifact stratum was defined as high discovery-cohort performance with failed replication; consequently a discovery-threshold rule is blind to it by construction, so we do not treat its 0% recall here as an empirical result. Its role is definitional: findings can look claim-worthy in discovery data while failing out-of-cohort replication. The empirical question is whether a replication-aware baseline recovers these traps using a disjoint held-out signal. Because the replication-rule signal and the gold label are both out-of-cohort replication estimates on disjoint cohorts, they are correlated rather than independent; the baseline tests recoverability from a related signal, not validation by an independent oracle.

Within the hard-artifact stratum, the replication-rule baseline detected 148/206 artifact-labeled cases (recall 0.718; 95% CI, 0.653–0.775) at precision 0.987 (148/150; 95% CI, 0.953–0.996). On the 98 naturally occurring non-planted hard traps, recall was 42/98 (42.9%; 95% CI, 33.5%–52.7%); we omit precision on this subset because it is all-artifact by definition, making any artifact prediction trivially correct. Replication-aware rules thus recover part, but not all, of the designed hard stratum; the missed natural traps define the unsaturated portion of the benchmark (Table 3).

The benchmark's discriminative value is concentrated in this stratum rather than in the average case. On planted controls the replication-rule baseline far exceeded the discovery-threshold rule (F1 0.974 vs 0.095), but on non-planted ROI/model findings the discovery-threshold rule was higher (F1 0.861 vs 0.825), because ordinary ROI findings often replicate well enough that discovery AUROC is already informative. The all-cases aggregate (replication-rule F1 0.841 vs discovery-threshold 0.812) is therefore dominated by benchmark composition and should not be read as general superiority of either rule.

**Table 3. Artifact-detection performance by subset (per-stratum first; all-cases aggregate is composition-dependent).**

| Evaluation subset | Baseline | Recall | Precision | F1 | Accuracy |
|---|---|---:|---:|---:|---:|
| Hard-artifact stratum | Replication-rule | 0.718 | 0.987 | 0.831 | 0.720 |
| Hard-artifact stratum | Discovery-threshold | 0.000 | NA | NA | 0.037 |
| Non-planted ROI/model cases | Replication-rule | 0.886 | 0.773 | 0.825 | 0.874 |
| Non-planted ROI/model cases | Discovery-threshold | 0.888 | 0.835 | 0.861 | 0.903 |
| Planted controls | Replication-rule | 0.982 | 0.966 | 0.974 | 0.974 |
| Planted controls | Discovery-threshold | 0.053 | 0.500 | 0.095 | 0.500 |
| All cases (composition-dependent) | Replication-rule | 0.897 | 0.792 | 0.841 | 0.882 |
| All cases (composition-dependent) | Discovery-threshold | 0.794 | 0.831 | 0.812 | 0.872 |

### Direct-question LLM agents under non-identifying inputs default to refusal

We evaluated two open LLM agents (Qwen3-32B, MedGemma-27B) on a stratified 480-case sample with generic and checklist prompts, asking directly whether each finding generalized. By design the input carried no external-cohort evidence, so the real/artifact label was not identifiable from the input. Neither model affirmed generalization for any case (0/960 each; 95% CI upper bound, 0.4%): Qwen produced 701 "no" and 259 "uncertain"; MedGemma 901 "no" and 59 "uncertain". Both therefore had 0 over-claims on artifact cases (0/468 each; 95% CI upper bound, 0.8%). This uniform refusal is the task floor for non-identifying inputs — declining to affirm generalization absent replication evidence is the conservative, ceiling-respecting response, not a calibration error — so the arm should be read as a non-identifiability/floor check rather than as evidence of discrimination. Notably, this conservative default contrasts with the pilot's open-ended setting, where generic agents did over-claim; because the two evaluations differ in model family, response format, and judging, the contrast indicates that elicited claim behavior is highly protocol-sensitive (Table 4).

**Table 4. Direct-question LLM stances (960 outputs per model; non-identifying inputs).**

| Model | Outputs | Yes | No | Uncertain | Artifact over-claims |
|---|---:|---:|---:|---:|---:|
| Qwen3-32B | 960 | 0 | 701 | 259 | 0/468 |
| MedGemma-27B | 960 | 0 | 901 | 59 | 0/468 |

### Summary of empirical support

The results support three bounded claims: (1) open-ended medical research-agent outputs can over-claim structured biomedical artifacts, and checklist prompting reduces but does not eliminate this in the 30-case pilot; (2) the scaled benchmark creates a replication-defined hard stratum where discovery and replication evidence disagree, in which a replication-rule baseline recovers only part of the naturally occurring traps; and (3) under non-identifying direct-question inputs, open LLMs default to uniform refusal — the task floor — underscoring how protocol-dependent elicited claim behavior is. Together these motivate ClaimTrap-AD as an evaluation benchmark, not as evidence that any method closes the problem.

---

## Discussion

### Principal findings

Across the evaluated modes, claim calibration was measurable but unsolved. Checklist prompting cut open-ended over-claiming roughly sevenfold yet left a recurrent, case-specific failure; a replication-aware statistical rule recovered most designed hard traps but fewer than half of the naturally occurring ones; and direct-question open LLMs, given non-identifying inputs, returned the refusal floor rather than discrimination. No method demonstrated calibrated discrimination on the hard stratum.

### Relation to prior work

The pilot over-claiming pattern is consistent with prior reports that LLMs over-state and respond inconsistently on biomedical tasks [1,2] and overgeneralize when summarizing findings [3,4]. ClaimTrap-AD differs from literature-grounded claim verification [5,6] and from prose-level exaggeration or in-paper overstatement scoring [4,7] by holding the analysis result fixed and asking whether the stated conclusion exceeds what out-of-cohort replication supports. Relative to biomedical-agent task benchmarks [8,9], the contribution is an explicit, replication-grounded calibration target with an ordinal ceiling and a designed hard stratum. We make no priority claim; the positioning is complementary, and the most conceptually adjacent work scoring conclusion-vs-evidence overstatement [3,7] is recent and either non-clinical or operating on free text rather than an agent over a structured analysis result.

### Why a discovery-threshold "0% recall" is not a straw-man

A reviewer may object that the hard-artifact stratum is rigged against the discovery-threshold rule. It is — by construction, and we report it as such. The stratum's purpose is definitional: it isolates exactly the cases where in-sample performance and out-of-cohort replication diverge. The empirical content is not that thresholding fails there, but that a replication-aware rule still misses 57.1% of naturally occurring traps in the same stratum, quantifying how far an honest replication signal goes and where the benchmark remains unsaturated.

### Limitations

First and most important, neither component yet has complete independent human-expert gold labels: the pilot relies on LLM reviewer-agent labels with one adjudicated case, and the scaled benchmark on auto-gold replication labels. A human-validation protocol is underway in which a clinically qualified (MD) co-author adjudicates a blinded, full-evidence 120-case subset, with a strong non-tested LLM as a convergence rater and a rater-agnostic design allowing an independent MD to be added; agreement will be reported with Gwet AC1 as the primary metric given the artifact-prevalence skew. Second, the replication-rule baseline and the gold label are correlated out-of-cohort signals, so baseline performance reflects recoverability from a related signal, not validation by an independent oracle. Third, the gold cut (AUROC >0.60) is a single conventional threshold applied to a binary real/artifact dichotomy; roughly 30% of non-planted labels lie in a near-boundary zone and are less stable. Fourth, the pilot and scaled tasks measure related but distinct constructs (open-ended ordinal calibration vs replication-prediction proxy) and are not matched in model, format, or judge, so their contrast is descriptive. Fifth, reported CIs treat cases as independent although the 2,888 cases reuse a small set of features and subjects across endpoints and cohort pairings. Sixth, the substrate is restricted to structured neuroimaging artifacts in Alzheimer's-disease–related cohorts and to a small set of generation and subject models; generalization to other domains, modalities, and models is untested.

### Implications

For developers and evaluators of medical research agents, the results argue for treating claim calibration as an explicit, separately scored objective grounded in replication rather than fluency, and for reporting where a system sits on the safety/completeness trade-off. ClaimTrap-AD provides a reusable, dual-view, replication-grounded test set; its hard stratum is deliberately unsaturated so future methods can be measured against a well-defined target.

---

## Conclusion

ClaimTrap-AD operationalizes claim calibration in medical research agents as an over-claim safety error scored against replication-grounded ordinal ceilings. Across prompt-based agents, deterministic baselines, and direct-question open LLMs, no evaluated method closed the calibration gap. We release the benchmark and its reliability analyses as an honest-negative measurement target rather than as a solution.

---

## Declarations

**Data availability statement (required by JAMIA).** The ClaimTrap-AD benchmark artifacts — scaled case JSONL, pilot dual-view cases, prompt manifests, leakage scans, baseline outputs, judge prompts and verdicts, and summary reports — will be deposited in a public repository with a persistent DOI (Dryad/Zenodo) on acceptance [TODO URL/DOI]. All reported analyses are repeatable from the archived artifacts. `[VERIFY: finalize the release/hold split — held-out gold-cohort fields and scoring-view answer keys are released under an evaluation-only arrangement to prevent training on the gold.]` Raw cohort-level clinical data are governed by the originating cohorts (A4, ADNI, AIBL, AJU, KDRC, NACC, OASIS) and available from those sources under their access procedures; no raw individual-level clinical free text is redistributed.

**Code availability.** The deterministic builder, baselines, controller, prompts, and decoding configurations will be released with the data [TODO URL]. JAMIA has no separate mandatory code statement; code is provided under data availability and as supplementary material.

**Use of AI (required disclosure).** The study evaluates LLM agents as its subject matter (Methods). In addition, AI assistance (Claude/Anthropic and OpenAI models) was used during manuscript drafting/editing and to scaffold analysis and benchmark code; all methods, results, and interpretations were verified by the authors against the committed artifacts, and the authors take full responsibility for the content. AI tools are not authors. [TODO: confirm exact tools/versions and mirror this disclosure in the cover letter, per JAMIA policy.]

**Funding.** [TODO name sources or state none — Crossref Funder Registry.]

**Competing interests.** [TODO statement.]

**Author contributions (CRediT).** [TODO assign CRediT roles per author.]

**Ethics.** Secondary analysis of de-identified, previously collected cohort data plus synthetic/constructed evaluation fixtures; [TODO IRB determination/exemption statement].

---

## References

> Vancouver style; ≤3 authors list all, else first 3 + "et al." Final numbering on submission. DOIs/venues from `literature-scout` live fetch (2026-06-27); `[VERIFY]` items still to confirm.

1. Guo Y, Ovadje A, Al-Garadi MA, et al. Evaluating large language models for health-related text classification tasks with public social media data. J Am Med Inform Assoc. 2024;31(10):2181–2189. doi:10.1093/jamia/ocae210.
2. Zhang J, Sun K, Jagadeesh A, et al. The potential and pitfalls of using a large language model such as ChatGPT, GPT-4, or LLaMA as a clinical assistant. J Am Med Inform Assoc. 2024;31(9):1884–1891. doi:10.1093/jamia/ocae184.
3. Peters U, Chin-Yee B. Generalization bias in large language model summarization of scientific research. R Soc Open Sci. 2025;12(4):241776. doi:10.1098/rsos.241776. `[VERIFY DOI/issue]`
4. Wright D, Augenstein I. Semi-supervised exaggeration detection of health science press releases. In: Proc EMNLP 2021. `[VERIFY ACL Anthology ID; arXiv:2108.13493]`
5. Wadden D, Lin S, Lo K, et al. Fact or fiction: verifying scientific claims. In: Proc EMNLP 2020:7534–7550. ACL Anthology 2020.emnlp-main.609. `[VERIFY page range]`
6. Zhang B, Bornet A, Yazdani A, et al. CliniFact: a dataset for evaluating clinical research claims in large language models. Sci Data. 2025;12(1):86. doi:10.1038/s41597-025-04417-x.
7. James J, Xiao C, Li Y, et al. RIGOURATE: quantifying scientific exaggeration with evidence-aligned claim evaluation. arXiv:2601.04350 (preprint). 2026. `[VERIFY — preprint; do not cite as settled]`
8. Jiang Y, et al. MedAgentBench: a virtual EHR environment to benchmark medical LLM agents. NEJM AI. 2025. doi:10.1056/AIdbp2500144 (also arXiv:2501.14654). `[VERIFY author list/issue]`
9. Huang K, et al. Biomni: a general-purpose biomedical AI agent. bioRxiv. 2025. doi:10.1101/2025.05.30.656746 (preprint). `[VERIFY — preprint]`
10. Gallifant J, Afshar M, Ameen S, et al. The TRIPOD-LLM reporting guideline for studies using large language models in health care. Nat Med. 2025;31(1):60–69. doi:10.1038/s41591-024-03425-5.
11. [Author list]. Guidelines and standard frameworks for artificial intelligence in medicine: a systematic review. JAMIA Open. 2025;8(1):ooae155. doi:10.1093/jamiaopen/ooae155. `[VERIFY author list]`

---

## Supplementary files (planned)

- **S1.** Completed TRIPOD-LLM checklist (19 items / 50 subitems; item → manuscript location). *Item wording to be reconciled with the official Nat Med supplement (DOI 10.1038/s41591-024-03425-5) before submission.*
- **S2.** Claim Safety Controller (architecture, verifier modules, rewrite-stability protocol, and results: 0/90 over-claims and hard-fails at completeness 1.878, with the fixed-draft caveat); full auto-gold reliability procedure; direct-question decoding/parsing detail.
- **S3.** Per-stratum and per-endpoint baseline metrics; full Wilson CI table (`outputs/agent_benchmark/claimtrap_scaled/headline_cis.csv`).
- **S4.** Pilot over-claim taxonomy (eight categories) and a dual-view example (generation vs scoring view) with leakage-scan summary.

---

## Figures (planned; ≤6 allowed)

- **Figure 1.** Dual-view protocol schematic: generation view (agent-visible) vs scoring view (judge-only held-out ceilings + replication evidence).
- **Figure 2.** Scaled construction and difficulty strata: discovery vs gold-cohort AUROC plane with the hard-artifact stratum and planted controls highlighted.
