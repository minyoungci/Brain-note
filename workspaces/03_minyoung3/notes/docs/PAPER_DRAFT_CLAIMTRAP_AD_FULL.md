# ClaimTrap-AD: A Dual-View Benchmark and Claim Safety Controller for Claim-Safe Medical Research Agents

**Full integrated draft (submission-style, 2026-06-22).** Single coherent draft assembled from the synchronized
paper-facing documents (PAPER_DRAFT_CLAIMTRAP_AD, PAPER_DRAFT_METHODS_RESULTS, OUTLINE, FIGURE_TABLE_PLAN,
RELATED_WORK_SCOUT, NOVELTY_POSITIONING_MATRIX, VERIFY_CLOSURE_REPORT, CITATION_CANDIDATES.bib). All quantitative
results are taken verbatim from committed runs; external citations are verified via literature-scout (residual
[VERIFY] limited to BiomniBench full-text and AgentSpec proceedings). This is an **AI-agent evaluation/control**
paper, **not** a biomarker-discovery paper. Controller frozen at v4; ClaimTrap30 dual-view blind path is the only
formal baseline; deprecated 5-case verification-side results are not used as evidence.

---

## Abstract

Medical research agents can inflate weak or confounded biomedical evidence into unsupported biomarker claims —
turning a small unvalidated AUROC gain into "improved discrimination," or a negative-control result into a claim
that scanner confounding has been ruled out. **This is a study of claim safety in medical research agents, not of
biomarker discovery:** we use Alzheimer's amyloid/MRI analysis artifacts as a testbed for whether an agent
overstates what the evidence supports. Existing medical-agent benchmarks largely evaluate clinical task execution
or EHR interaction (Jiang et al. 2025, MedAgentBench; Schmidgall et al. 2026, AgentClinic); we instead evaluate
*scientific claim calibration*. We introduce **ClaimTrap-AD**, a dual-view benchmark of biomedical over-claim
traps — an E1–E8 taxonomy with graded claim ceilings L0–L3 — that separates the artifact an agent sees
(**generation_view**) from the gold claim constraints only a judge sees (**scoring_view**). This separation closes
a verification-specific leakage channel: case-level gold constraints can enter a verification prompt and turn a
**verification-aware agent into an answer-aware** one; we make that leak structurally impossible and confirm it
with a zero-gold-token scan. As the technical core, we formulate research-agent claim safety as an
**evidence-grounded claim-ceiling control problem** and instantiate it with a **Claim Safety Controller** that
extracts structured evidence, estimates the strongest defensible claim level, and applies **ceiling-dependent
routing** (L0 hard-block; L1+ semantic-preserving rewrite). In a blinded pilot, generic agents over-claim
recurrently across temporal, transportability, label-provenance, incremental-value, and negative-control traps
(19/90); a global verification ("checklist") prompt reduces but does not eliminate them (3/90), failing stably on
the incremental-value trap; and the controller removes observed over-claims (0/90) at the cost of lower
completeness (1.878 vs the checklist's 2.622), exposing a persistent **safety–completeness trade-off**. We release
the benchmark, evaluation protocol, controller, and per-case traces. *(No claim of clinical deployment, biomarker
discovery, benchmark completeness, model superiority, or guaranteed safety.)*

---

## 1. Introduction

**The risk.** LLMs are increasingly used as *research* assistants that read the output of a biomedical analysis —
AUROC tables, regression coefficients, label-construction notes, acquisition logs — and write a natural-language
conclusion. When the underlying analysis is weak or confounded, the agent can over-state it: a +0.04 AUROC
increment becomes "improves discrimination," a chance-level site-only control becomes "scanner confounding is
ruled out," a pooled multi-tracer label becomes "a clean amyloid label." This is not fabricated-reference
hallucination; it is a *calibration* failure — turning statistically weak, temporally ambiguous, or
provenance-limited artifacts into strong biomarker claims. The correct output is often a *lower* claim
(association, not prediction; within-cohort, not transportable; surrogate, not validated label), or no claim at
all. LLMs are known to over-generalize scientific findings as a behavioral tendency (Peters & Chin-Yee 2025); our
question is whether that tendency can be *measured* and *controlled* for research agents.

**The gap.** Medical-agent benchmarks largely evaluate clinical *task execution*, diagnosis, or EHR question
answering (Jiang et al. 2025; Schmidgall et al. 2026; Tang et al. 2025). The closest research-agent benchmark,
BiomniBench (Huang et al. 2026), grades an agent's *own* end-to-end analytical trajectory (data handling, method
selection, statistical rigor) and includes only a single generic "avoids causal overclaims" check. We instead
hold the analysis *fixed*: given a structured artifact, does the agent claim only what the evidence licenses?
Concurrent work calibrates a claim to its own evidence in open-domain QA (Huang et al. 2026, CSS) or scores
overstatement in paper text (James et al. 2026, RIGOURATE); standard biomedical claim verification asks whether
*external literature* entails a claim (Wadden et al. 2020; Sarrouti et al. 2021). We differ by computing a
*discrete, ordered, biomedical evidence ceiling* from the artifact and using it to gate the agent's output.

**Core idea.** We cast claim safety as an **evidence-grounded claim-ceiling control problem**: from a structured
artifact `e` we compute a deterministic upper bound `L*(e)` on the strongest defensible claim level and enforce it
at inference time with a routing policy that depends on `L*` — hard-blocking no-claim (L0) artifacts and
semantically rewriting the rest. The LLM only proposes and rewrites; the safety decision is deterministic,
auditable, and independent of the LLM's own judgment.

**Contributions** (in order of strength):
1. **ClaimTrap-AD benchmark** — a dual-view benchmark of biomedical over-claim traps (E1–E8 taxonomy, graded
   claim ceilings L0–L3); 30 cases, independently reviewed and human-locked.
2. **Leakage control (dual-view protocol)** — we identify and close an answer-aware leakage channel specific to
   verification-aware agents, separating an agent-visible `generation_view` from a judge-only `scoring_view`,
   verified by a zero-gold-token scan. The channel is not AD-specific.
3. **Claim Safety Controller** (technical core) — a deterministic, inference-time algorithm that extracts
   structured evidence, computes a claim ceiling `L*(e)` via verifier modules, and applies **ceiling-dependent
   routing** (Algorithm 1). The LLM is a constrained propose/rewrite component; the control logic is code.
4. **Empirical finding** — in a blinded pilot, generic agents over-claim recurrently, checklist prompting reduces
   but does not eliminate over-claims, and the controller removes observed over-claims while revealing a
   persistent **safety–completeness trade-off**, with a *necessity result*: ceiling-dependent routing is required.

We also use a **hybrid evaluation protocol** (rule screen → non-self LLM judge → human spot-check). We present
this not as a novel evaluator but as a *reliable evaluation protocol*: rule-only scoring false-positively
penalizes calibrated negation, and LLM judges carry known biases (Zheng et al. 2023; Wang et al. 2024), which we
mitigate with a non-self judge (cf. diverse juries, Verga et al. 2024) and human adjudication.

---

## 2. Related Work

**Medical LLM agents & benchmarks.** MedAgentBench (Jiang et al. 2025, NEJM AI), AgentClinic (Schmidgall et al.
2026, npj Digital Medicine), MedAgentsBench (Tang et al. 2025), and FHIR-AgentBench (Lee et al. 2025) evaluate
task execution, diagnosis, or EHR-QA correctness. The research-agent cousins BixBench (Mitchener et al. 2025) and
GIScholarBench (Li et al. 2026) score answer correctness and generation overconfidence. The closest, BiomniBench
(Huang et al. 2026), grades an agent's own end-to-end analytical *trajectory* with task-specific ordinal rubrics
plus a single generic "avoids causal overclaims" check; it has no discrete claim ceiling, no supplied-artifact→
claim design, and none of our E1–E8 traps — a **partial overlap**, not a substitute. *We evaluate research-claim
calibration against the artifact's own evidence (a discrete L0–L3 ceiling + E1–E8 traps), not task or process
correctness.*

**Scientific over-claiming & claim calibration.** Peters & Chin-Yee (2025) document LLM over-generalization of
science as a phenomenon. Concurrent work calibrates a claim to its own evidence: CSS (Huang et al. 2026) backs a
claim off to its most-specific admissible level in open-domain QA, and RIGOURATE (James et al. 2026) scores
overstatement in written paper text. *We compute a discrete, ordered, biomedical evidence ceiling from a
structured analysis artifact and use it to gate/route an agent's output, rather than scoring or backing off a
free-text claim.*

**Claim verification.** SciFact (Wadden et al. 2020), HealthVer (Sarrouti et al. 2021), CliniFact (Zhang et al.
2025), MuSciClaims (Lal et al. 2025), and CLAIM-BENCH (Javaji et al. 2025) verify whether *external literature
evidence* entails a claim (support/refute/NEI). *We ask whether the analysis artifact itself permits a claim
level — calibration, not external-evidence entailment.*

**LLM-as-a-judge & reliability.** MT-Bench (Zheng et al. 2023), Wang et al. (2024), and G-Eval (Liu et al. 2023)
establish LLM judging and its position, verbosity, and self-enhancement biases; PoLL (Verga et al. 2024, preprint)
uses diverse non-self juries. *We adopt, not extend, this line: a non-self judge, a rule screen, and human audit.*

**Eval-time leakage / contamination.** Training-corpus contamination (Golchin & Surdeanu 2024; Deng et al. 2024),
shared agent/evaluator environments (Wang et al. 2026, BenchJack, preprint), and judge-side reference bias (Li et
al. 2026, DASFAA) are documented. *We name a distinct channel — gold-in-the-verification-prompt answer-awareness —
and close it with the dual-view split.*

**Guardrails / runtime controllers.** AgentSpec (Wang et al. 2026, accepted ICSE), NeMo Guardrails (Rebedea et al.
2023), and output validators / self-refinement (Madaan et al. 2023) enforce policy, dialogue, format, or reask
rules. *Within these frameworks, none computes an evidence-grounded ceiling on claim strength with
ceiling-dependent block-vs-rewrite routing; `L*(e)` is a computed graded value driving a semantic-preserving
downgrade, not a boolean trigger, a canned block, or an evidence-agnostic reask.*

---

## 3. The ClaimTrap-AD Benchmark

ClaimTrap-AD contains **30 cases**: **10 OASIS-derived** real artifacts (drawn from an actual amyloid-status
analysis whose headline result is null/weak — within OASIS, an ROI model reaches AUROC 0.658 versus a
covariate-only baseline of 0.684, an incremental value near zero) and **20 constructed probes**. The probes are
**controlled evaluation fixtures grounded in observed failure categories** — not fabricated biological findings;
each is built to trigger a specific over-claim trap while remaining individually plausible.

**Taxonomy and ceilings.** Cases span an **E1–E8 over-claim taxonomy** (Table 1): covariate-baseline omission
(E1), incremental over-claim (E2), temporal over-claim (E3), label-provenance over-claim (E4), transportability
over-claim (E5), causal/mechanistic over-claim (E6), negative-control shortcut over-interpretation (E7), and
unsupported-biomarker claims (E8). The locked taxonomy distribution is E1:4, E2:4, E3:4, E4:4, E5:4, E6:3, E7:5,
E8:2. Each case's gold is a claim level on the ordered scale `L0 < L1 < L1.5 < L2 < L3` (no-claim → within-cohort
association → credible incremental value → predictive → transportable/deployable-biomarker), plus forbidden
phrases and required checks, with an explicit **safety-vs-completeness split** distinguishing a *wrong* claim from
a merely *incomplete* one. The locked set has levels L1.5:10 / L1:17 / L0:3.

**Construction and review (Table 2).** Gold was locked by an **independent two-reviewer blind review** (two
reviewers scored every case from neutral input artifacts only, without draft labels or the intended taxonomy)
followed by **human adjudication**. Reviewer agreement was 29/30 on primary error type and 28/30 on exact claim
level; the final set is 30/30 locked. A finding that motivates independent review: the draft-author's self-assigned
gold matched the independent consensus on 23/29 locked cases (≈79%), and independent review still corrected 6
self-authored levels — self-authored gold is unreliable. `scoring_allowed` is set true only after lock, and a
final generation-side leakage scan returned zero leaks.

---

## 4. Dual-View Protocol

A subtle hazard arises when one evaluates a *verification-aware* agent — an agent prompted to check its own
claims. If the verification prompt is built from the same per-case gold used to score the output (the allowed
claim level, the forbidden phrases, the required caveats), the agent effectively reads the answer key: a
**verification-aware agent silently becomes an answer-aware** agent, and any apparent benefit of "verification" is
confounded. We encountered exactly this in an early 5-case harness, where case-specific gold leaked into the
verification prompt; those verification-side results are therefore deprecated and not used as formal evidence.
Eval-time gold leakage is itself a known family — training-corpus contamination (Golchin & Surdeanu 2024; Deng et
al. 2024), shared agent/evaluator environments (Wang et al. 2026, BenchJack), and judge-side reference bias (Li et
al. 2026) — but the *verification-prompt* channel we describe, in which gold-derived caveats make a
verification-aware agent answer-aware, is distinct and, to our knowledge, previously unnamed.

ClaimTrap-AD enforces a **dual-view** separation. Every case exposes two disjoint views:
- **`generation_view`** — the neutral artifact the agent sees (metrics, facts, the focus question), with no gold;
- **`scoring_view`** — judge-only fields: the gold allowed-claim level, forbidden phrases, required checks, the
  claim ceiling, and reviewer metadata.

All agents (generic, checklist, controller) read only `generation_view`; the scoring_view is visible only to the
judge, which is legitimate because the judge *is* the answer key. A generation-side leakage scan confirms zero
gold tokens reach any agent prompt. ClaimTrap30's dual-view blind path is thus our leak-free baseline. The
mechanism is not AD-specific: it applies to any verification-prompted agent evaluated against per-case gold, which
makes the dual-view protocol a generalizable evaluation contribution (Figure 2).

---

## 5. Hybrid Evaluation Protocol

Scoring calibrated scientific prose is itself error-prone, so we combine three stages — presented as a
*reliability protocol*, not a novel evaluator (each component is established practice; Zheng et al. 2023; Wang et
al. 2024; Verga et al. 2024). (1) A **rule-based screen** catches blatant over-claims with high recall but
false-positively penalizes calibrated negations — e.g., "this is *not* a robust biomarker" superficially contains
the forbidden tokens; in development, rule-only scoring mislabeled such calibrated prose and several rule-based
hard-fails had to be reclassified as judge-required. (2) Ambiguous cases pass to a **reference-guided, non-self
LLM judge** (the judge model differs from the generation model) that reads the scoring_view gold and resolves
calibrated negation and semantic nuance. (3) A **human spot-check** locks safety-critical decisions. We report
judge-side numbers and flag where human adjudication changed a verdict; the non-self judge and human audit mitigate
known LLM-judge biases, and we never treat the judge as the sole authority.

---

## 6. The Claim Safety Controller

### 6.1 Problem formulation
An artifact `e` is a structured set of evidence units (AUROCs and confidence intervals, incremental deltas, sample
and feature counts, cross-validation protocol, label provenance, acquisition/temporal facts). A claim `c` has an
*implied claim level* `λ(c) ∈ {L0 < L1 < L1.5 < L2 < L3}`. Each artifact admits a **claim ceiling** `L*(e)`: the
strongest level its evidence licenses. An output is a **safety violation** (an over-claim) iff `λ(c) > L*(e)`. The
agent's objective is to maximize claim **completeness** — informativeness up to the ceiling — subject to the hard
safety constraint `λ(c) ≤ L*(e)`. Standard prompting optimizes neither term explicitly; we make `L*(e)` an
explicit, deterministic quantity and enforce the constraint at inference time. This framing makes the central
tension precise: reducing violations can reduce completeness — a **safety–completeness trade-off**.

### 6.2 Algorithm
Given a `generation_view` artifact `A`, a global verifier schema `V`, and a base LLM `M`:

**Algorithm 1 (Claim Safety Controller).**
```
1. c0 ← M.propose(A)                  # LLM proposes a candidate claim
2. e  ← extract(A)                    # DETERMINISTIC structured-evidence extraction (schema parse)
3. F  ← {f_i(e) : f_i ∈ V}            # DETERMINISTIC verifier modules (E1–E8) fire on evidence
4. L* ← strictest_cap(F), default L1  # DETERMINISTIC claim ceiling
5. over ← detect_overclaim(c0, F, L*) # forbidden patterns / ceiling-keyed cues / implied level λ(c0) > L*
6. route by (L*, confidence):
     L0                       → HARD BLOCK (no claim permitted)
     high (explicit forbidden)→ reject → constrained rewrite → enforce → templated fallback
     medium / low             → SEMANTIC-PRESERVING rewrite (keep content, lower only the over-claim, add caveat)
     clean (no over-claim)    → pass-through
7. enforce_strict: hard-fail only on EXPLICIT multi-word assertive patterns, clause-level negation aware
8. return final claim, claim level L*, verifier trace
```

The LLM is only a propose/rewrite component; the control logic (extraction, verifier firing, ceiling estimation,
over-claim detection, routing, enforcement) is deterministic code that produces an auditable trace. This is the
distinction between a prompt that requests caution and an *algorithm that controls claim generation* — it is not
checklist prompting, not preference learning, and not model fine-tuning. **Worked trace (Figure 3, inset, e2_03):**
evidence `{ΔAUROC=+0.04, n=300, features=40, nested_cv=false, paired_ΔCI=absent}` fires the E2 module, which caps
the ceiling at L1.5 and rejects positive-increment wording; the controller rewrites "ROI features improve
discrimination" into a statement that the increment is not credible without nested validation.

### 6.3 Ceiling-dependent routing (the key design finding)
The routing policy is **ceiling-dependent**, and this is not cosmetic. A *hard* templated fallback applied
everywhere is safe but over-suppresses L1+ cases (it discards defensible content). A *semantic-preserving rewrite*
applied everywhere recovers L1+ completeness but is unsafe at L0: because a no-claim artifact permits no claim,
"preserving content" leaves a mild endorsement (e.g., "the pooled label is conditionally supportable") that
breaches the L0 ceiling. The controller therefore routes **L0 to hard blocking and L1+ to semantic-preserving
rewrite**. The strict-enforcement guard (step 7) uses only explicit multi-word assertive patterns, because bare
single tokens (e.g., "deployable", "predict") recur in legitimate caveats and a token-level guard reintroduces
over-suppression. Within the v4 n=3 run the realized routing was: 39 semantic-preserving rewrites, 31 pass-through
accepts, 11 fallbacks, and 9 L0 hard-blocks (3 L0 cases × 3 repeats).

---

## 7. Experimental Setup

We compare three arms on ClaimTrap-AD: **Generic** (an unguided agent), **Checklist** (a global
verification/checklist prompt, identical for all cases, derived from the claim schema — never per-case gold), and
the **Claim Safety Controller (v4)**. The base generation model is Sonnet 4.6; the judge is GPT-5.5, a non-self
judge. We make no model-superiority claim; cross-model differences are reported only as failure-mode recurrence,
since the judge differs across directions and is stochastic. We evaluate at **n=3** (90 outputs per arm). Metrics:
**safety** (over-claim rate, hard-fail rate); **completeness** (a 0–3 claim-quality score and required-caveat
coverage); and **controller diagnostics** (verifier triggers, estimated ceiling, action route, trace).

Two methodological honesty notes are stated explicitly. **(i) Generation-base mismatch.** Generic and checklist
n=3 are three *independent* generation draws; the controller arm holds the *propose* claim fixed (the generic n=1
output) and re-samples only the rewrite across three repeats — so its n=3 measures rewrite-stability on a fixed
proposal, not three independent generations. The over-claim comparison remains meaningful (the controller acts on
the proposal), but the three arms are not a perfectly matched trial. **(ii) Mixed n in the evolution table** (§9,
RQ5): v1–v3 single runs are n=1 (30 outputs); v3 n=3 and v4 are n=3 (90 outputs) — a development narrative, not a
constant-n head-to-head.

**Reproducibility (AAAI-26 checklist).** We separate **deterministic reproducibility** (controller, verifiers,
scoring — released code + fixed config) from **conditional replicability** of the LLM components (generation
Sonnet 4.6, judge GPT-5.5 are closed hosted models; we report model IDs, API dates, decoding settings, and token
usage/cost). We report per-repeat variation over the n=3 runs, claim no statistical significance (pilot,
descriptive), perform no training or hyperparameter search (rule-based controller; config released verbatim), and
use structured-artifact inputs only (no free-text clinical notes — by design). We release the benchmark JSONL,
controller, verifiers, judge prompts, and per-case traces under a free-research license; we do not claim full
end-to-end reproducibility of closed-model outputs.

---

## 8. Results

### RQ1 — Do generic medical research agents over-claim?
Yes, and not at random. The generic agent over-claims on **19/90** outputs and hard-fails on **14/90**
(completeness 1.678). Failures localize to the taxonomy traps: temporal prediction from cross-sectional windows
(E3), transportability from pooled cohorts (E5), clean-label assertions over multi-tracer pooled labels (E4),
positive incremental value from a tiny unvalidated ΔAUROC (E2), and shortcut over-interpretation of negative
controls (E7) — e.g., reading a chance-level site-only AUROC of 0.497 as "scanner confounding is ruled out." Four
cases fail 3/3 (e7_negcontrol_01 with E7+E6, e7_negcontrol_02, e3_temporal_overclaim_04, e5_transportability_02).
We emphasize *failure localization*, not model-bashing: these are the specific evidence-to-claim steps where
calibration breaks (Figure 5).

### RQ2 — Does checklist prompting help?
Partly. A global verification prompt reduces over-claims to **3/90** (hard-fail 1/90) and raises completeness to
**2.622**. But it does not eliminate over-claims: it fails *stably* on the incremental-value trap (e2_03, 3/3),
repeatedly reading a small unvalidated ΔAUROC as a genuine improvement. We claim only that checklist prompting
reduces but leaves a structured residual.

### RQ3 — Does the controller control over-claims?
The controller (v4) reaches **0/90 over-claim and 0/90 hard-fail**. It blocks the residual that checklist
prompting cannot — the e2_03 incremental trap — via the deterministic E2 ceiling, and it closes the L0 failure
(e4_04) via hard blocking. Per the dual-view discipline we do not claim the controller "outperforms" the
checklist: as RQ4 shows, the controller produces terser claims, and the comparison is also subject to the
generation-base mismatch (§7).

### RQ4 — What trade-off remains?
The controller's completeness (1.878) sits between the generic agent (1.678) and the checklist (2.622): safety is
bought at a measurable completeness cost. Over-suppression at the L1+ level persists. This **safety–completeness
trade-off** — not a clean win — is the central empirical finding (Figure 4).

### RQ5 — Why is ceiling-dependent routing necessary?
The version study (Table 4) is itself the evidence. A uniform hard fallback (v1) is safe but over-suppresses
(completeness 1.633). A uniform soft rewrite (v2/v3) recovers completeness but is unsafe at L0: at n=3, v3
over-claims 2/90, both on the L0 case e4_04, where the soft rewrite left a "conditionally supportable"
endorsement. Routing L0 to a hard block and L1+ to semantic-preserving rewrite (v4) restores 0/90 while keeping
completeness at 1.878. The necessity of *different actions at different ceilings* — not a single rewrite policy —
is the core design finding. We note that **n≥3 was necessary to surface the L0 failure**, a methodological point
about evaluating stochastic generation.

---

## 9. Limitations

ClaimTrap-AD is a **focused diagnostic benchmark** (30 cases), not a broad medical-QA benchmark; 20/30 are
constructed fixtures (grounded in observed failure modes, individually plausible). It covers a **single domain**
(Alzheimer's amyloid/MRI analysis) and a single real analysis seed (OASIS), with **10 OASIS-derived real artifacts
and 20 constructed probes**. The controller's deterministic verifier coverage is **targeted, not universal**
(≈22/30 cases trigger ≥1 module; non-triggering cases fall through to the proposal, with the hybrid evaluator as
the safety net). We use **closed, hosted LLMs** (a single generation model and a single judge per direction;
cross-model results are failure-mode recurrence only, judge-confounded), and a **PILOT scale** (n=3). We apply
**no preference learning** (no DPO/SFT); a preference-learning extension must use a corpus disjoint from the
held-out ClaimTrap30 to avoid training on the evaluation set. We make no claim of clinical deployment, biomarker
discovery, benchmark completeness, model superiority, or guaranteed safety. **Future work:** a free-text
evidence-extraction benchmark (to move beyond structured artifacts), a larger and multi-domain benchmark, a
structured preference corpus for calibrated-rewriter learning with strict train/test separation, and a learned
rewriter aimed at closing the safety–completeness trade-off.

---

## 10. Conclusion

ClaimTrap-AD evaluates whether medical research agents claim only what their evidence licenses. A dual-view
protocol prevents answer-key leakage in verification-aware evaluation; an inference-time Claim Safety Controller
enforces evidence-grounded claim ceilings via ceiling-dependent routing. In a blinded pilot, observed over-claims
can be removed, but a persistent safety–completeness trade-off remains — the honest center of the result, and the
target of future calibrated-rewriter work.

---

## Figures
- **Figure 1 — Problem & benchmark overview.** Weak/confounded artifact → generic agent → unsupported claim
  ("ROI is a deployable amyloid biomarker") vs ClaimTrap-AD dual-view → safety evaluation (`λ(c) > L*(e)`?).
  Worked example: site-only AUROC 0.497 → wrong "scanner confounding ruled out" vs calibrated "measured site-label
  shortcut unsupported; feature-level site effects remain possible."
- **Figure 2 — Dual-view design & gold-leak correction.** Old confounded path (gold in the verification prompt →
  answer-aware) vs the new generation_view→agent / scoring_view→judge split; leakage scan = 0.
- **Figure 3 — Claim Safety Controller (Algorithm 1) + e2_03 trace.**
- **Figure 4 — Main safety/completeness results** (n=3, 90/arm): over-claim 19/3/0, hard-fail 14/1/0, completeness
  1.678/2.622/1.878. Message: the controller maximizes safety but does not dominate completeness.
- **Figure 5 — Failure-mode heatmap** (rows = key cases/E-types; cols = generic/checklist/controller): e2_03
  (checklist over-claim → controller safe), e7 negative-control (generic hard-fail → safe), e4_04 (v3 soft fail →
  v4 L0 block fixed).

## Tables
- **Table 1 — E1–E8 over-claim taxonomy and L0–L3 ceilings** (error, name, example wrong claim, correct
  restriction).
- **Table 2 — Benchmark construction & review** (endpoint feasibility → label audit → quality-critic QC → blind
  2-reviewer review → human adjudication → self-authored gold correction 6/30, self-bias ≈79% → leakage scan = 0).
- **Table 3 — Main results** (Generic 19/90, 14/90, 1.678 | Checklist 3/90, 1/90, 2.622 | Controller v4 0/90,
  0/90, 1.878). Footnotes: safety prioritized; completeness below checklist; generation-base mismatch.
- **Table 4 — Controller evolution** (explicit n): v1 hard fallback n=1 0/30 1.633 (over-suppressed) → v2 soft
  rewrite n=1 0/30 1.80 (negation bug) → v3 bugfix n=1 0/30 1.833 → v3 n=3 2/90 1.878 (L0 soft-rewrite hole, e4_04)
  → v4 L0 hard-block + L1+ rewrite n=3 0/90 1.878 (ceiling-dependent routing, final).

---

## Residual [VERIFY] (camera-ready)
- BiomniBench full-text + author list (browser read; verdict PARTIAL_OVERLAP confirmed via lab/analysis blogs).
- AgentSpec final ICSE 2026 proceedings page numbers (accepted; not yet published).
- PoLL / BenchJack: non-archival workshop status cannot be 100% excluded (cited as preprints; low risk).
All other citations verified (see CLAIMTRAP_AD_CITATION_CANDIDATES.bib, VERIFY_CLOSURE_REPORT.md).
