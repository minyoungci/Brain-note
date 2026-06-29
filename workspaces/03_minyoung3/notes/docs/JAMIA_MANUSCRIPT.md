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

**Objective:** To benchmark whether medical research agents calibrate conclusions to the strength of the evidence, using structured Alzheimer's-disease neuroimaging artifacts, and release a reusable replication-grounded test set.

**Materials and Methods:** We developed ClaimTrap-AD, a dual-view framework in which an agent converts structured neuroimaging artifacts into a conclusion, while evaluators score it against held-out claim ceilings and replication evidence. A 30-case pilot, labeled by independent large language model (LLM) reviewer agents, defined the claim-ceiling task and evaluated open-ended outputs. We then scaled to 2,888 auto-gold cases from a seven-cohort manifest (13,022 sessions; 7,231 subjects), with leave-one-cohort-out evaluation and disjoint held-out signals for gold labels and a replication-rule baseline. Reporting follows TRIPOD-LLM.

**Results:** In the 30-case pilot, generic agents over-claimed on 19/90 outputs and checklist prompting reduced this to 3/90. At scale, 70.1% of non-planted labels were threshold-robust and 77.1% of multi-cohort findings unanimous. No cohort-based rule resolved the natural hard strata: a replication-rule baseline caught only 42.9% of natural hard-artifact traps while over-rejecting 73.6% of real hard cases. Given discovery plus one external replication cohort, a frontier agent over-claimed on 48.3% of cases — halved to 19.2% by checklist prompting (100%→50% on the hard-artifact stratum) — whereas with no replication evidence open LLMs refused uniformly (0/960).

**Discussion:** Claim calibration was sensitive to framing and replication structure; no evaluated method closed the gap.

**Conclusion:** ClaimTrap-AD exposes a measurable claim-calibration gap — agent over-claiming in both a pilot and a scaled graded arm, over an unsaturated hard stratum — and releases a benchmark to track it.

---

## Introduction

Large language model (LLM) agents are increasingly proposed as research assistants that read analytic outputs and draft biomedical conclusions. A recurring concern in their evaluation is not factual fabrication but *over-statement*: a model summarizes a result with more confidence, generality, or causal force than the result supports. Head-to-head biomedical evaluations report that LLMs are sensitive to prompt formulation, respond inconsistently to identical inputs, and can degrade downstream performance when used uncritically [1], and that current models are better positioned as supplementary tools than as autonomous clinical assistants [2]. More directly, LLM summaries of scientific findings overgeneralize their source far more often than human summaries do [3], echoing a longer line of work on detecting exaggeration of research claims [4]. These findings motivate evaluating a specific, safety-relevant behavior: whether an agent's stated claim stays within the strongest claim the evidence licenses.

We call this behavior *claim calibration*. It differs from adjacent problems. It is not factual or literature-grounded claim verification, in which a claim is checked against an external knowledge source [5,6]. It is not generic research-rigor or exaggeration scoring of authored prose [4], nor in-paper claim-overstatement scoring on the machine-learning literature [7]. Claim calibration instead asks whether a conclusion drawn from a *given* analysis result remains within what that result supports — most stringently, whether a within-cohort association is mis-stated as predictive, transportable, or deployable when out-of-cohort replication does not hold. Existing biomedical-agent benchmarks emphasize task success or planning over an environment [8,9] rather than the evidence-to-claim gap under replication failure. We make no priority claim; to our knowledge no prior benchmark targets the specific intersection of an *agent* converting a *structured analysis result* into prose, in a *clinical* setting, where the trap is *over-claiming generalization unsupported by out-of-cohort replication*.

We present ClaimTrap-AD, a replication-grounded benchmark for claim calibration in medical research agents, built on structured neuroimaging artifacts from Alzheimer's-disease and related cohorts. We treat over-claiming as a safety error scored against an ordinal claim ceiling grounded in held-out, out-of-cohort replication. The study is deliberately framed as an honest-negative evaluation: across prompt-based agents, deterministic statistical baselines, and direct-question open LLMs, no evaluated method closes the calibration gap. The contribution is the measurement framework and the released benchmark, not a system that solves the task. Because no purpose-built reporting guideline exists for AI benchmark or no-intervention studies [11], we report against TRIPOD-LLM [10], whose scope explicitly covers *evaluating* an LLM.

---

## Materials and Methods

### Study design

ClaimTrap-AD evaluates claim calibration in medical research agents: an agent converts structured biomedical analysis artifacts into a natural-language conclusion, and we score whether the conclusion stays within the strongest claim the evidence supports. The study has two linked components: a 30-case pilot that defines the claim-ceiling task and evaluates open-ended agent outputs, and a scaled replication-grounded benchmark that evaluates statistical baselines, direct-question LLMs, and a graded agent arm at larger scale. The components measure related but distinct constructs: the pilot scores open-ended prose against an ordinal ceiling; the scaled graded arm scores an agent's chosen ceiling (from discovery plus one replication cohort) against the held-out gold ceiling; and the scaled baselines use replication prediction as a tractable proxy. We do not equate the scaled proxy with the pilot's open-ended claim-writing task.

We treat an over-claim as a safety error: a statement asserting predictive, transportable, causal, biomarker, or incremental value beyond what the artifact supports. We separately score completeness, because an output can be safe but uninformative. Claim ceilings are ordinal: L0, no defensible claim; L1, within-cohort association; L1.5, within-cohort association with a mandatory negative-increment caveat; L2, internal predictive validity; L3, transportable or deployable-biomarker evidence. The pilot uses the full scheme; the scaled benchmark uses replication-defined L0–L2 labels. All inputs are structured artifacts derived from tabular neuroimaging, clinical, and biomarker fields; the project inventory found no raw clinical free-text corpus. No model training, preference optimization, or fine-tuning was performed.

### Data sources

The scaled benchmark was built from a structured manifest of 13,022 sessions from 7,231 subjects across seven cohorts (A4, ADNI, AIBL, AJU, KDRC, NACC, OASIS). The leave-one-cohort-out builder used six diagnostic cohorts (ADNI, NACC, AIBL, KDRC, OASIS, AJU); A4 was excluded from diagnostic contrasts as a single-class amyloid-prevention cohort. One representative session per subject was selected, requiring non-missing age, sex, and brain segmentation volume. Imaging features were FreeSurfer regional volumes (intracranial-volume–normalized, raw, and hemispheric-asymmetry), yielding 70 unique ROI-derived features used across the non-planted cases. Five endpoints were specified (CN vs AD/dementia, CN vs MCI, MCI vs AD/dementia, CN vs dementia-only, and CN/MCI vs AD/dementia); four yielded cases meeting the ≥25-per-class cohort-viability threshold, while CN vs dementia-only yielded no viable cohort and is absent from the released benchmark. Multivariate findings used predefined logistic-regression and random-forest configurations over hippocampal, signature-region, or all normalized ROI features. `[VERIFY: report post-filter subjects-per-cohort actually entering the benchmark — not derivable from the released JSONL; pull from the builder/manifest.]`

### Pilot benchmark and dual-view protocol

The pilot contains 30 locked cases: 10 OASIS-derived structured artifacts and 20 constructed probes (controlled evaluation fixtures, not new biological findings). Cases span an eight-category over-claim taxonomy enumerated in Supplementary S4 (covariate-baseline omission, incremental-value, temporal-prediction, label-provenance, cross-cohort generalization, causal/mechanistic, negative-control shortcut, unsupported biomarker).

Pilot gold labels were generated by two independent LLM reviewer agents — a critic persona and a domain-expert persona — that scored blinded artifacts without access to draft labels, taxonomy, revision notes, or answer-key fields. Consensus cases were mechanically locked; tier-preserving disagreements were resolved by conservative tie-breaking; disagreements crossing claim tiers or error families were escalated to manual adjudication, which one case required. Full human-expert relabeling of the pilot was not performed. Final pilot gold labels comprised 17 L1, 10 L1.5, and 3 L0 cases.

To prevent evaluation leakage, each case has two views. The generation view contains only agent-visible inputs (task text, structured metrics, provenance, focus question); the scoring view contains judge-only fields (gold claim level, allowed claim, forbidden assertions, required checks, primary error type, adjudication metadata). Both prompts were scanned for leakage; the locked run reported zero leaks across 60 prompts. The checklist prompt, implemented as the `verification_aware` arm, received only a global checklist and claim schema identical for every case; it never received case-specific gold.

### Pilot agents and judging

Two open-ended generation arms were compared. The generic arm used a medical-research-assistant prompt with only the generation-view artifact; the checklist arm used the same model and artifact plus the global verifier checklist and ordinal claim schema. Both arms used `claude-sonnet-4-6`; for the n=3 recurrence run, decoding used temperature 1.0 and a 4,000-token budget. Each arm generated three outputs per case (90 per arm); the comparison is therefore a within-model prompt ablation, not a model comparison. (A deterministic Claim Safety Controller, evaluated separately as a rewrite controller on fixed drafts, is reported in Supplementary S2 and excluded from the main comparison.)

Pilot outputs were scored by a reference-guided, non-self LLM judge (GPT-5.5) that read the scoring view and the agent output, hid agent identity, and scored each claim on a 0–3 rubric (0, invalid/dangerous over-claim; 1, partial, missing required limitations; 2, calibrated within-ceiling claim; 3, stronger calibrated claim with required caveats), with hard-fail and over-claim indicators recorded separately. The protocol explicitly distinguishes calibrated negation from over-claiming; rule-based screens were coarse gates only. Two human-review packs were used: in the locked n=3 run, a human-corrected recurrence review confirmed the persistent checklist failure on the incremental-value case as a genuine over-claim in all three repeats (9 over-claiming case-arm pairs reviewed; none rejected); a separate keyword-flag spot-check of nine cases confirmed all nine as calibrated negations rather than over-claims (human over-claim rate 0/9), reclassifying their keyword hits as completeness gaps.

### Scaled replication-grounded benchmark construction

The scaled benchmark was generated by `scripts/build_claimtrap_scaled.py`. For each endpoint, viable cohorts required ≥25 positive and ≥25 negative cases. For each case context, one cohort was assigned as the unseen gold cohort, one disjoint cohort as the held-out replication (tool) cohort, and the remaining viable cohorts as the discovery set, separating the discovery, replication-baseline, and gold-label signals at the cohort level. The replication-rule baseline and the gold label are not literal duplicates but are both out-of-cohort replication estimates and therefore correlated. Univariate cases evaluate individual ROI features; model cases evaluate predefined multivariate classifiers; planted controls were added at graded signal strengths as known real/artifact anchors. Each case stores discovery AUROC, held-out tool-cohort replication AUROC, covariate-incremental AUROC when available, unseen gold-cohort AUROC, endpoint, finding type, gold label, ordinal ceiling, and difficulty stratum.

Gold labels were assigned from the unseen gold-cohort AUROC. For non-planted findings, a finding was labeled real when gold-cohort AUROC exceeded 0.60 and artifact otherwise; the 0.60 threshold reflects a conventional weak-discrimination floor, and we report sensitivity across 0.55–0.65 and flag a near-boundary zone (below). Planted controls instead retained their design label. In 11 of 2,888 cases (0.4%) — all weak planted-real signals, 8 in the hard-artifact stratum and 3 in the easy-artifact stratum — the design label remains real even though the weak effect did not exceed the gold-cohort replication threshold; we retain the design label intentionally, so that a replication rule rejecting a genuinely planted-but-weak real signal is counted as over-rejection rather than as a correct call, making the hard stratum a more conservative test of replication-based calibration rather than a self-confirming one. Scaled ceilings were L0 when the finding did not replicate, L1 when gold-cohort AUROC was >0.60 and ≤0.70, and L2 when >0.70. The hard-artifact stratum was defined as high discovery-cohort AUROC with failed gold-cohort replication; a discovery-threshold rule is blind to this stratum by construction, a property used to define the trap, not an empirical claim that thresholding unexpectedly failed. Because this label privileges one designated held-out gold cohort, a hard-artifact finding can still show partial replication in other (non-gold) cohorts; the stratum therefore encodes failure against the designated gold cohort, not failure to replicate in every cohort, and a holistic multi-cohort reading of the same evidence may treat some of these cases as weakly real (Discussion).

### Auto-gold reliability checks

We assessed auto-gold stability three ways (full procedure in Supplementary S2): threshold robustness of real/artifact labels as the cut varied across 0.55–0.65 (identifying the near-boundary region); unanimous cross-cohort agreement for findings evaluated under ≥2 held-out gold cohorts; and an internal-consistency comparison of discovery, replication, and covariate-incremental signals between gold-real and gold-artifact groups. A prespecified 120-case human-validation subset — 60 planted objective-truth anchors plus naturally occurring hard-artifact and hard-real cases, stratified across the four endpoints — will undergo blinded adjudication by the clinically qualified (MD) co-author, with a strong non-subject LLM as a convergence rater (full protocol and pre-registered decision rules in Supplementary S5); until labeling is complete, scaled labels are described as auto-gold labels with reliability checks, not as labels with completed human sign-off (Limitations).

### Statistical baselines and direct-question LLM evaluation

Two deterministic artifact-detection baselines were evaluated. The discovery-threshold rule predicts real when discovery AUROC ≥0.60 and artifact otherwise. The replication-rule baseline predicts artifact when held-out tool-cohort replication AUROC is missing or ≤0.58, or when covariate-incremental AUROC is available and ≤0.02; otherwise real. We computed recall, precision, F1, and accuracy for artifact detection, overall and by prespecified subsets (all cases; hard-artifact stratum; non-planted univariate/model cases; planted controls).

We evaluated open LLMs as direct-question subjects on a stratified sample (`scripts/run_agent_eval_scaled.py`; up to 120 per difficulty stratum, fixed seed; 480 cases, 960 outputs/model). Each model (Qwen3-32B, thinking disabled; MedGemma-27B; temperature 0, JSON-only) answered "yes"/"no"/"uncertain" under a generic and a checklist prompt. Because the input carried discovery-side information but no out-of-cohort replication evidence — itself only weakly class-informative (gold-real 0.699 vs gold-artifact 0.546) — this arm measures default stance, not discrimination.

To test whether agents produce *graded* claims when replication evidence is present, we added a scaled graded agent arm. Here the agent was shown the discovery AUROC, one external replication cohort, and the covariate increment — with the gold cohort withheld — and asked for the strongest defensible claim ceiling (L0/L1/L2). Scoring is deterministic: an over-claim is an agent ceiling above the gold ceiling, so no judge is used. We ran a generic agent and a checklist agent (the checklist required demonstrated replication and non-trivial incremental value before any L2 claim) on a stratified 120-case sample. The reported subject is a frontier agent (`claude-sonnet-4-6`); evaluating the open subjects on this arm through the GPU harness is a planned extension.

### Statistical reporting

The pilot is reported descriptively as a controlled benchmark pilot, not a powered superiority trial, with Wilson score 95% confidence intervals (CIs) for proportions and no cross-arm hypothesis testing. The scaled benchmark reports deterministic classification metrics and label-reliability summaries with Wilson CIs. Wilson CIs treat cases as independent Bernoulli trials; because the 2,660 non-planted cases derive from only 70 unique ROI features across four endpoints and multiple gold/replication cohort assignments, cases are non-independent, so the reported Wilson intervals are nominal, understate the true width under this clustering, and should be read as descriptive summaries only (a feature-level cluster bootstrap would widen them). The discovery-threshold rule's 0% hard-artifact recall is reported as a definitional consequence of the stratum and rule, not as an empirical headline; the empirical emphasis is the residual difficulty after adding disjoint replication information.

### Reproducibility and scope

Deterministic components (scaled builder, statistical baselines, evidence extraction, verifier modules, ceiling estimation, over-claim detection, post-rewrite enforcement) are fully reproducible; LLM generation and judging are reproducible only conditional on recorded model identifiers, prompts, decoding settings, and saved raw outputs. Released artifacts include benchmark JSONL, prompt manifests, leakage scans, judge prompts and verdicts, token usage, and summary reports. The pilot's OASIS cases and the scaled OASIS cohort may share subjects; as the two components are separate evaluations with no model training, this is a provenance overlap, not train/test leakage, and its extent will be disclosed with the release. `[VERIFY: quantify pilot–scaled OASIS overlap.]` The study evaluates claim calibration over structured neuroimaging research artifacts and does not evaluate clinical deployment, diagnostic decision-making, arbitrary biomedical free text, or model safety in unconstrained settings.

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

The scaled benchmark comprised 2,888 auto-gold cases over six diagnostic cohorts (full composition in Table 2; A4 excluded from contrasts). Reliability analyses used the 2,660 non-planted cases. Labels were invariant for 1,864/2,660 (70.1%; 95% CI, 68.3%–71.8%) across thresholds 0.55–0.65, the remainder forming a near-boundary zone; and 216/280 (77.1%; 95% CI, 71.9%–81.7%) findings evaluable under ≥2 held-out cohorts were unanimous. Internal-consistency checks separated gold-real from gold-artifact on every signal, but the replication and covariate-incremental separations (0.696 vs 0.551; 0.080 vs 0.009) are partly definitional because the gold label derives from out-of-cohort AUROC; the more independent discovery-AUROC separation was modest (0.699 vs 0.546).

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

Within the hard-artifact stratum the replication-rule baseline detected 148/206 artifact-labeled cases (recall 0.718; 95% CI, 0.653–0.775) at precision 0.987 (148/150), but this figure is carried by planted controls built for a replication rule to catch and is not representative of the natural cases. On the genuinely informative natural hard cases the rule fails in both directions: it catches only 42/98 (42.9%; 95% CI, 33.5%–52.7%) of naturally occurring hard-artifact traps while over-rejecting 117/159 (73.6%) of the naturally occurring hard-real findings — cases the gold cohort supports but the tool cohort does not. On the combined natural hard strata (98 artifact + 159 real) the replication rule therefore reaches only precision 0.264, recall 0.429, and accuracy 0.327, and the discovery-threshold rule is worse (accuracy 0.008), each below a trivial constant predictor. The substantive result is negative: no cohort-based rule we tested resolves the natural hard cases, which define the unsaturated core of the benchmark (Table 3).

Where the replication rule does succeed is on planted controls (F1 0.974 vs the discovery-threshold rule's 0.095); on non-planted ROI/model findings the discovery-threshold rule is marginally higher (F1 0.861 vs 0.825) because ordinary findings replicate well enough that discovery AUROC is already informative. The all-cases aggregate (replication-rule F1 0.841 vs discovery-threshold 0.812) is dominated by benchmark composition and should not be read as general superiority of either rule. The headline is the negative result above: neither rule resolves the natural hard strata — precisely where a claim-calibration benchmark must stay discriminating — so the benchmark's value is its unsaturated natural hard core, not any baseline's success on it.

**Table 3. Artifact-detection performance by subset. The hard-artifact and planted rows where the replication rule scores well are planted-carried; on the natural hard strata (both classes) no rule beats a trivial predictor, and the all-cases aggregate is composition-dependent.**

| Evaluation subset | Baseline | Recall | Precision | F1 | Accuracy |
|---|---|---:|---:|---:|---:|
| Hard-artifact stratum | Replication-rule | 0.718 | 0.987 | 0.831 | 0.720 |
| Hard-artifact stratum | Discovery-threshold | 0.000 | NA | NA | 0.037 |
| Non-planted ROI/model cases | Replication-rule | 0.886 | 0.773 | 0.825 | 0.874 |
| Non-planted ROI/model cases | Discovery-threshold | 0.888 | 0.835 | 0.861 | 0.903 |
| Planted controls | Replication-rule | 0.982 | 0.966 | 0.974 | 0.974 |
| Planted controls | Discovery-threshold | 0.053 | 0.500 | 0.095 | 0.500 |
| Natural hard strata (non-planted, both classes; n=257) | Replication-rule | 0.429 | 0.264 | 0.327 | 0.327 |
| Natural hard strata (non-planted, both classes; n=257) | Discovery-threshold | 0.000 | 0.000 | NA | 0.008 |
| All cases (composition-dependent) | Replication-rule | 0.897 | 0.792 | 0.841 | 0.882 |
| All cases (composition-dependent) | Discovery-threshold | 0.794 | 0.831 | 0.812 | 0.872 |

### Agents refuse without replication evidence but over-claim given a single cohort

Given discovery-side inputs with no out-of-cohort replication evidence, both open subjects (Qwen3-32B, MedGemma-27B) declined to affirm generalization for any case (0/960 each; 95% CI upper bound, 0.4%; 0/468 artifact over-claims each) — the ceiling-respecting floor when replication is absent, not discrimination (Supplementary S2.3). Given instead a single external replication cohort and asked for a graded claim ceiling, a frontier agent (`claude-sonnet-4-6`) produced graded claims, not a floor, and frequently over-claimed: its ceiling exceeded the gold ceiling on 58/120 (48.3%), which a verification checklist roughly halved to 23/120 (19.2%) — reproducing the pilot's generic-versus-checklist reduction at scale — at the cost of more under-claiming (2.5%→15.0%). Over-claiming concentrated on the hard-artifact stratum (generic 30/30, 100%; checklist 15/30, 50%), where agents assert generalization from discovery plus one replication cohort that the held-out gold cohort does not support (Table 4; a 120-case frontier-agent pilot, with the open subjects on this arm a planned extension). The two regimes — uniform refusal without replication evidence, graded over-claiming with one cohort — show elicited claim behavior is highly protocol-sensitive.

**Table 4. Scaled graded agent arm (120 stratified cases; subject `claude-sonnet-4-6`; over-claim = agent claim ceiling above the gold ceiling). A frontier-agent pilot; open subjects on this arm are a planned extension. Direct-question stance counts (the refusal-floor arm) are in Supplementary S2.3.**

| Arm | Ceiling L0/L1/L2 | Over-claim | Calibrated | Under-claim | Hard-artifact over-claim |
|---|---|---:|---:|---:|---:|
| Generic | 16 / 66 / 38 | 58/120 (48.3%) | 49.2% | 2.5% | 30/30 (100%) |
| Checklist | 51 / 57 / 12 | 23/120 (19.2%) | 65.8% | 15.0% | 15/30 (50%) |

### Summary of empirical support

Together the arms motivate ClaimTrap-AD as an evaluation benchmark, not as evidence that any method closes the gap: agents over-claimed in both the open-ended pilot and the scaled graded arm, and checklist prompting roughly halved but did not eliminate it (pilot 19/90→3/90; scaled 48.3%→19.2%); no cohort-based rule resolved the natural hard strata at scale (replication rule: 42.9% of natural hard-artifact traps caught, 73.6% of natural hard-real cases over-rejected); and without replication evidence agents refuse uniformly, the ceiling-respecting floor.

---

## Discussion

### Principal findings

Across the evaluated modes, claim calibration was measurable but unsolved. Checklist prompting cut over-claiming — roughly sevenfold in the open-ended pilot and about half in the scaled graded agent arm (48.3%→19.2%) — yet left substantial residual over-claiming, still 50% on the hard-artifact stratum and trading lower over-claiming for more under-claiming. A replication-aware statistical rule recovered the designed planted traps but failed on the natural hard strata in both directions (catching 42.9% of natural artifacts while over-rejecting 73.6% of natural real cases). Without replication evidence, direct-question open LLMs returned the ceiling-respecting refusal floor rather than discrimination. No method demonstrated calibrated discrimination on the hard stratum.

### Relation to prior work

The pilot over-claiming pattern is consistent with prior reports that LLMs over-state and respond inconsistently on biomedical tasks [1,2] and overgeneralize when summarizing findings [3,4]. ClaimTrap-AD differs from literature-grounded claim verification [5,6] and from prose-level exaggeration or in-paper overstatement scoring [4,7] by holding the analysis result fixed and asking whether the stated conclusion exceeds what out-of-cohort replication supports. Relative to biomedical-agent task benchmarks [8,9], the contribution is an explicit, replication-grounded calibration target with an ordinal ceiling and a designed hard stratum. We make no priority claim; the positioning is complementary, and the most conceptually adjacent work scoring conclusion-vs-evidence overstatement [3,7] is recent and either non-clinical or operating on free text rather than an agent over a structured analysis result.

### Why a discovery-threshold "0% recall" is not a straw-man

A reviewer may object that the hard-artifact stratum is rigged against the discovery-threshold rule. It is — by construction, and we report it as such. The stratum's purpose is definitional: it isolates the cases where in-sample performance and out-of-cohort replication diverge. The empirical content is not that thresholding fails there, but that even a replication-aware rule misses 57.1% of natural traps while over-rejecting most natural hard-real findings (Results), leaving the stratum unsaturated. A further caution: the label is defined against a single designated gold cohort, and many such findings replicate in another held-out cohort, so a holistic multi-cohort reading would call some weakly real — the intended trap, but one that makes these labels gold-cohort-specific non-replication rather than cohort-invariant artifacts (cf. the 77.1% cross-cohort unanimity above).

### Limitations

First and most important, neither component yet has complete independent human-expert gold labels: the pilot relies on LLM reviewer-agent labels with one adjudicated case, and the scaled benchmark on auto-gold replication labels. A human-validation protocol is prespecified but not yet executed (Supplementary S5): the clinically qualified (MD) co-author will adjudicate a blinded, stratified 120-case subset (planted objective-truth anchors plus naturally occurring hard cases across all four endpoints), with a strong non-subject LLM as a convergence rater and an optional independent MD for human–human agreement; agreement will be reported with Gwet AC1 as the primary metric given the artifact-prevalence skew, against pre-registered decision rules. A structural caveat applies: non-planted cases have no ground truth independent of the cohort AUROCs, so human validation can confirm the planted objective-truth anchors and unambiguous cases but cannot independently re-adjudicate non-planted hard-artifact labels, which by construction reflect the designated-gold-cohort definition rather than failure across all cohorts; we therefore report agreement separately for planted anchors and for non-planted strata, and read the latter as a calibration of the labeling rule, not as an external oracle. Accordingly, expert disagreement on the hard-artifact stratum is expected and is not in itself evidence of label error; the benchmark's value rests on its labels being a reproducible, cohort-relative operational target rather than on their being ground truth. Second, the replication-rule baseline and the gold label are correlated out-of-cohort signals, so baseline performance reflects recoverability from a related signal, not validation by an independent oracle. Third, the gold cut (AUROC >0.60) is a single conventional threshold applied to a binary real/artifact dichotomy; roughly 30% of non-planted labels lie in a near-boundary zone and are less stable. Fourth, the pilot and scaled tasks measure related but distinct constructs (open-ended ordinal calibration vs replication-prediction proxy) and are not matched in model, format, or judge, so their contrast is descriptive. Fifth, reported CIs treat cases as independent although the 2,888 cases reuse a small set of features and subjects across endpoints and cohort pairings. Sixth, the substrate is restricted to structured neuroimaging artifacts in Alzheimer's-disease–related cohorts and to a small set of generation and subject models; generalization to other domains, modalities, and models is untested.

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

> Vancouver style; ≤3 authors list all, else first 3 + "et al." Final numbering on submission. All 11 references verified against authoritative sources (Crossref, PubMed, ACL Anthology, arXiv, bioRxiv, Oxford Academic / publisher pages) on 2026-06-29; every DOI/ID confirmed to resolve to the cited paper. Entries [7] (arXiv) and [9] (bioRxiv) are preprints with no peer-reviewed version, flagged inline.

1. Guo Y, Ovadje A, Al-Garadi MA, et al. Evaluating large language models for health-related text classification tasks with public social media data. J Am Med Inform Assoc. 2024;31(10):2181–2189. doi:10.1093/jamia/ocae210.
2. Zhang J, Sun K, Jagadeesh A, et al. The potential and pitfalls of using a large language model such as ChatGPT, GPT-4, or LLaMA as a clinical assistant. J Am Med Inform Assoc. 2024;31(9):1884–1891. doi:10.1093/jamia/ocae184.
3. Peters U, Chin-Yee B. Generalization bias in large language model summarization of scientific research. R Soc Open Sci. 2025;12(4):241776. doi:10.1098/rsos.241776.
4. Wright D, Augenstein I. Semi-supervised exaggeration detection of health science press releases. In: Proceedings of the 2021 Conference on Empirical Methods in Natural Language Processing (EMNLP). 2021. p. 10824–36. doi:10.18653/v1/2021.emnlp-main.845.
5. Wadden D, Lin S, Lo K, et al. Fact or fiction: verifying scientific claims. In: Proceedings of the 2020 Conference on Empirical Methods in Natural Language Processing (EMNLP). 2020. p. 7534–50. doi:10.18653/v1/2020.emnlp-main.609.
6. Zhang B, Bornet A, Yazdani A, et al. A dataset for evaluating clinical research claims in large language models. Sci Data. 2025;12(1):86. doi:10.1038/s41597-025-04417-x.
7. James J, Xiao C, Li Y, et al. RIGOURATE: quantifying scientific exaggeration with evidence-aligned claim evaluation. arXiv:2601.04350 [preprint]. 2026. `[preprint — not peer-reviewed; cited contextually only]`
8. Jiang Y, Black KC, Geng G, et al. MedAgentBench: a virtual EHR environment to benchmark medical LLM agents. NEJM AI. 2025;2(9):AIdbp2500144. doi:10.1056/AIdbp2500144.
9. Huang K, Zhang S, Wang H, et al. Biomni: a general-purpose biomedical AI agent. bioRxiv [preprint]. 2025. doi:10.1101/2025.05.30.656746. `[preprint — not peer-reviewed]`
10. Gallifant J, Afshar M, Ameen S, et al. The TRIPOD-LLM reporting guideline for studies using large language models. Nat Med. 2025;31(1):60–9. doi:10.1038/s41591-024-03425-5.
11. Shiferaw KB, Roloff M, Balaur I, et al. Guidelines and standard frameworks for artificial intelligence in medicine: a systematic review. JAMIA Open. 2025;8(1):ooae155. doi:10.1093/jamiaopen/ooae155.

---

## Supplementary files

- **S1.** *(drafted: `docs/JAMIA_SUPPLEMENT_S1.md`)* Completed TRIPOD-LLM checklist (19 items / 50 subitems = 14 core + 5 modular; item → manuscript location). Counts/numbering verified; *item wording is paraphrased and to be reconciled with the official EQUATOR/TRIPOD-LLM checklist before submission*, and a separate TRIPOD-LLM-for-Abstracts checklist (S1b) is still to be completed.
- **S2.** *(drafted: `docs/JAMIA_SUPPLEMENT_S2.md`)* Claim Safety Controller (architecture, verifier modules, rewrite-stability protocol, and results: 0/90 over-claims and hard-fails at completeness 1.878, with the fixed-draft caveat); full auto-gold reliability procedure; direct-question decoding/parsing detail.
- **S3.** *(planned)* Per-stratum and per-endpoint baseline metrics; full Wilson CI table (`outputs/agent_benchmark/claimtrap_scaled/headline_cis.csv`).
- **S4.** *(planned)* Pilot over-claim taxonomy (eight categories) and a dual-view example (generation vs scoring view) with leakage-scan summary.
- **S5.** *(drafted: `docs/JAMIA_HUMAN_VALIDATION_PROTOCOL.md`)* Human-validation protocol: clean stratified 120-unique-case subset, blinding design, convergence rater, primary Gwet AC1, and pre-registered decision rules (design locked; labeling pending).

---

## Figures (≤6 allowed)

- **Figure 1.** *(drafted: `docs/figures/fig1_dualview_protocol.png`)* Dual-view protocol schematic: generation view (agent-visible) vs scoring view (judge-only held-out ceilings + replication evidence), with the no-leakage barrier between the agent path and the scoring view.
- **Figure 2.** *(drafted: `docs/figures/fig2_construction_plane.png` / `.pdf`, generated from the released JSONL by `scripts/make_fig2_construction_plane.py`)* Scaled construction and difficulty plane: discovery-cohort vs held-out gold-cohort AUROC for all 2,888 cases, four difficulty strata, the 0.60 thresholds, the hard-artifact trap quadrant, and planted controls highlighted.
