# PAPER DRAFT — ClaimTrap-AD (AAAI main-track target)

**Status: DRAFT — Abstract/Intro/Contributions/Related-Work rewritten post-literature-scout (2026-06; framing =
strong-but-defensible, no "first" claims). All numbers verified against committed artifacts (see "Verified
numbers" block). External citations verified via literature-scout; residual [VERIFY] items listed in §2 and
RELATED_WORK_SCOUT.md. No fabricated numbers. Controller FROZEN at v4.**

Working title: **ClaimTrap-AD: A Dual-View Benchmark and Claim Safety Controller for Claim-Safe Medical
Research Agents**

---

## Verified numbers (single source of truth for the paper)
From committed runs (GPT-5.5 judge; PILOT):
- **generic** n=3 (claimtrap30_n3): over-claim **19/90**, hard_fail **14/90**, completeness **1.678**.
- **checklist** (= verification_aware) n=3: over-claim **3/90**, hard_fail **1/90**, completeness **2.622**.
- **controller v4** n=3 (L0 hard-block): over-claim **0/90**, hard_fail **0/90**, completeness **1.878**.
- controller evolution (per best available eval): v1 n=1 0/30 / 1.633 (human=judge) · v2 n=1 0/30 / 1.80 ·
  v3 n=1 0/30 / 1.833 · **v3 n=3 2/90 / 1.878** (L0 gap exposed) · **v4 n=3 0/90 / 1.878**.
- ClaimTrap-AD: 30 LOCKED cases (10 real_oasis_derived + 20 constructed_probe); levels L1.5:10 / L1:17 / L0:3.

### ⚠️ Two methodological honesty notes (MUST appear as footnotes)
1. **Generation-base mismatch in the 3-way.** generic and checklist n=3 are 3 *independent* generation draws;
   the controller arm holds the *propose* claim fixed (the generic n=1 output) and re-samples only the rewrite
   across 3 repeats. So the controller's "n=3" measures rewrite-stability on a fixed proposal, not 3 independent
   generations. The over-claim comparison is still meaningful (the controller acts on the proposal), but the
   table is NOT a perfectly matched 3-arm trial — state this.
2. **Mixed n in the evolution table.** v1–v3 single = n=1 (30); v3 n=3 and v4 = n=3 (90). Report the `n` column
   explicitly; the v1→v4 story is a development narrative, not a controlled head-to-head at constant n.
3. Judge (GPT-5.5) is stochastic; flagged over-claims were human-confirmed; cross-model = failure-mode
   recurrence only. PILOT scale.

---

## Abstract (DRAFT)
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

## 1. Introduction (DRAFT)
**¶1 (rise + risk).** LLMs are increasingly used as *research* assistants that read the output of a biomedical
analysis — AUROC tables, regression coefficients, label-construction notes, acquisition logs — and write a
natural-language conclusion. When the analysis is weak or confounded, the agent can over-state it: a +0.04
AUROC increment becomes "improves discrimination," a chance-level site-only control becomes "scanner
confounding is ruled out," a pooled multi-tracer label becomes "a clean amyloid label."

**¶2 (the failure is not citation hallucination).** This is not fabricated-reference hallucination. It is the
*calibration* failure of turning statistically weak, temporally ambiguous, or provenance-limited artifacts into
strong biomarker claims. The correct output is often a *lower* claim (association, not prediction; within-cohort,
not transportable; surrogate, not validated label), or no claim at all.

**¶3 (gap vs existing benchmarks).** Medical-agent benchmarks largely evaluate clinical *task execution* / EHR
interaction (Jiang et al. 2025, MedAgentBench; Schmidgall et al. 2026, AgentClinic; Tang et al. 2025). We instead
evaluate *scientific claim calibration*: given an analysis artifact, does the agent claim only what the evidence
licenses? Standard biomedical claim verification asks whether *literature evidence* entails a claim (Wadden et al.
2020, SciFact; Sarrouti et al. 2021, HealthVer); we ask whether the *analysis artifact itself* permits the claim
level. Concurrent work calibrates a claim's specificity to its own evidence in open-domain QA (Huang et al. 2026)
or scores scientific overstatement in paper text (James et al. 2026, RIGOURATE); we differ by computing a
**discrete, ordered, biomedical evidence ceiling** from a structured analysis artifact and using it to *gate and
route an agent's output* (§3.1, §5).

**¶3.5 (core technical idea — emphasize early).** Our central technical idea is that **claim safety for a
research agent can be cast as an evidence-grounded claim-ceiling control problem**: from a structured artifact `e`
we compute a deterministic upper bound `L*(e)` on the strongest defensible claim level, and we *enforce* it at
inference time with a routing policy that depends on `L*` — hard-blocking no-claim (L0) artifacts and
semantically rewriting the rest. The LLM only proposes and rewrites; the safety decision is deterministic,
auditable, and independent of the LLM's own judgment. **We formulate biomedical research-agent claim safety as an
evidence-grounded claim-ceiling control problem and instantiate it with a dual-view benchmark and an
inference-time Claim Safety Controller.** Unlike concurrent claim-calibration work (Huang et al. 2026; James et al.
2026), the ceiling here is a discrete biomedical evidence hierarchy (L0–L3) read off a structured artifact and
used to *route* the output (block vs semantic-preserving rewrite), not a generic specificity back-off or a
continuous overstatement score.

**¶4 (contributions).**
1. *[Benchmark]* We introduce **ClaimTrap-AD**, a dual-view benchmark for evaluating biomedical **over-claim
   traps** (an E1–E8 taxonomy with graded claim ceilings L0–L3) in medical research agents — 30 cases,
   independently reviewed and human-locked.
2. *[Leakage control]* We identify and correct an **answer-aware leakage channel specific to verification-aware
   agents**: case-level gold constraints can enter a verification prompt, turning a verification-aware agent into
   an answer-aware one. We close it with a **generation_view/scoring_view separation** verified by a
   zero-gold-token scan. The channel is not AD-specific — it applies to any verification-prompted agent scored
   against per-case gold.
3. *[Algorithm — TECHNICAL CORE]* We propose a **Claim Safety Controller**: a deterministic, inference-time
   algorithm that extracts structured evidence, computes a claim ceiling `L*(e)` via verifier modules, and applies
   **ceiling-dependent routing** (Algorithm 1) — L0 hard-block, L1+ semantic-preserving rewrite. The LLM is a
   constrained propose/rewrite component; the control logic is code, not a prompt.
4. *[Empirical finding]* In a blinded pilot, generic agents over-claim recurrently; checklist prompting reduces
   but does not eliminate over-claims; the controller removes observed over-claims (0/90) while revealing a
   persistent **safety–completeness trade-off**, with a *necessity result* — ceiling-dependent routing is required
   (L0 needs hard blocking, since semantic-preserving rewrite breaches a no-claim ceiling; L1+ needs rewrite).

We also use a **hybrid evaluation protocol** (rule screen → non-self LLM judge → human spot-check). We present
this not as a novel evaluator but as a *reliable evaluation protocol*: rule-only scoring false-positively
penalizes calibrated negation, and LLM judges carry known biases (Zheng et al. 2023; Wang et al. 2024), which we
mitigate with a non-self judge (cf. juries, Verga et al. 2024) and human adjudication (§4).

## 2. Related Work (verified via literature-scout 2026-06; cites in CLAIMTRAP_AD_CITATION_CANDIDATES.bib)
- **Medical LLM agents & benchmarks.** MedAgentBench (Jiang et al. 2025, NEJM AI), AgentClinic (Schmidgall et al.
  2026, npj Digital Medicine), MedAgentsBench (Tang et al. 2025), FHIR-AgentBench (2025) evaluate task execution /
  diagnosis / EHR-QA correctness. Research-agent cousins BixBench (Mitchener et al. 2025) and GIScholarBench (Li
  et al. 2026) score answer correctness / generation overconfidence. The closest, BiomniBench (Huang et al. 2026),
  grades an agent's own end-to-end analytical *trajectory* (data handling, method selection, statistical rigor)
  with task-specific ordinal rubrics and a single generic "avoids causal overclaims" check; it has no discrete
  claim ceiling, no supplied-artifact→claim design, and none of our E1–E8 traps. *Position: they evaluate task /
  process execution; we hold the analysis fixed and evaluate research-claim calibration against the artifact's own
  evidence (a discrete L0–L3 ceiling + E1–E8 traps).*
- **Scientific over-claiming & claim calibration.** Peters & Chin-Yee (2025, Royal Society Open Science) document
  LLM over-generalization of science as a phenomenon. Two concurrent works calibrate a claim to its own evidence:
  CSS (Huang et al. 2026) backs a claim off to its most-specific admissible level in open-domain QA; RIGOURATE
  (James et al. 2026) scores overstatement in paper text. *Contrast: we compute a discrete, ordered, biomedical
  evidence ceiling from a structured artifact and use it to gate/route an agent's output.*
- **Claim verification.** SciFact (Wadden et al. 2020), HealthVer (Sarrouti et al. 2021), CliniFact (2025),
  MuSciClaims (Lal et al. 2025), CLAIM-BENCH (Javaji et al. 2025) verify whether *external literature evidence*
  entails a claim. *Contrast: evidence-entailment vs artifact-permits-claim-level.*
- **LLM-as-a-judge & reliability.** MT-Bench (Zheng et al. 2023), Wang et al. (2024), G-Eval (Liu et al. 2023)
  establish LLM judging and its position/verbosity/self-enhancement biases; PoLL (Verga et al. 2024) uses diverse
  non-self juries. *We adopt, not extend, this line: non-self judge + rule screen + human audit (§4).*
- **Eval-time leakage / contamination.** Training-corpus contamination (Golchin & Surdeanu 2024; Deng et al.
  2024), shared agent/evaluator environments (Wang et al. 2026, BenchJack), and judge-side reference bias (Li et
  al. 2026, DASFAA) are documented. *Contrast: we name a distinct channel — gold-in-the-verification-prompt
  answer-awareness — and close it with the dual-view split.*
- **Guardrails / controllers.** AgentSpec (Wang et al. 2026, ICSE), NeMo Guardrails (Rebedea et al. 2023), output
  validators (Guardrails AI; Self-Refine, Madaan et al. 2023) enforce policy / dialogue / format / reask rules.
  *Contrast: within these frameworks none computes an evidence-grounded ceiling on claim strength with
  ceiling-dependent block-vs-rewrite routing.*

Remaining [VERIFY] (closed 2026-06, see VERIFY_CLOSURE_REPORT.md): only BiomniBench full-text + author list
(browser read) and AgentSpec final ICSE 2026 proceedings page numbers remain; all other citations are verified.

## 3. ClaimTrap-AD Benchmark (METHODS outline)
- **Dual-view.** `generation_view` = neutral artifact only (no gold). `scoring_view` (judge-only) = gold
  allowed-claim, forbidden phrases, required checks, claim ceiling, reviewer metadata. Motivation: the earlier
  5-case harness fed case gold into the verification prompt → answer-aware → confounded; deprecated. ClaimTrap30's
  dual-view blind path is our leak-free baseline; the earlier 5-case verification-side results are gold-leak
  confounded and not used as formal evidence (generation-side leakage scan = 0).
- **Cases.** 30 = 10 OASIS-derived real artifacts + 20 constructed probes. Probes are *controlled evaluation
  fixtures grounded in observed failure categories*, NOT fabricated biological findings.
- **Taxonomy & ceilings.** E1–E8 (Table 1); L0/L1/L1.5/L2/L3 with a safety-vs-completeness split.
- **Construction & review (Table 2).** endpoint feasibility → label audit → quality-critic QC → blind 2-reviewer
  review → human sign-off → self-authored gold correction (6/30; self-bias 79%) → leakage scan.

## 4. Hybrid Evaluator (METHODS outline)
- Rule-only screening false-penalizes calibrated negations ("not a robust biomarker"); LLM-only judging is
  bias-prone. Hybrid = high-recall rule screen → reference-guided **non-self** LLM judge (judge ≠ generation
  model) → human spot-check on safety-critical. Evidence: rule-based false-positives reclassified to
  judge_required; all flagged over-claims human-confirmed.

## 5. Claim Safety Controller (METHODS — the AAAI core; include Algorithm 1)

**5.1 Problem formulation (formal).** Let an artifact `e` be a structured set of evidence units (AUROCs, deltas,
n, CV protocol, label provenance, acquisition/temporal facts). A claim `c` has an *implied claim level*
`λ(c) ∈ {L0 < L1 < L1.5 < L2 < L3}` (no-claim ⊂ within-cohort association ⊂ incremental ⊂ predictive ⊂
transportable/biomarker). Each artifact admits a **claim ceiling** `L*(e)` = the strongest level its evidence
licenses. An output is a **safety violation** iff `λ(c) > L*(e)` (an over-claim). The agent's objective is to
maximize claim *completeness* (informativeness up to `L*`) subject to the hard safety constraint
`λ(c) ≤ L*(e)`. Standard prompting optimizes neither explicitly; the controller makes `L*(e)` an explicit,
deterministic quantity and enforces the constraint at inference time. This framing exposes the
**safety–completeness trade-off** as the central tension. Concurrent claim-calibration work (Huang et al. 2026;
James et al. 2026) shares the spirit of matching a claim to its evidence; our instantiation differs in computing a
*discrete ordered biomedical ceiling* from a structured artifact and *routing* the output by it (block vs
semantic-preserving rewrite), rather than a generic specificity back-off or a continuous overstatement score.

**5.2 Algorithm.**
**Algorithm 1 (Claim Safety Controller).**
```
Input: generation_view artifact A; global verifier schema V; base LLM M
1. c0 ← M.propose(A)                         # LLM proposes a candidate claim
2. e  ← extract(A)                           # DETERMINISTIC structured-evidence extraction
3. F  ← {f_i(e) : f_i ∈ V}                   # DETERMINISTIC verifier modules (E1–E8) fire on evidence
4. L* ← strictest_cap(F), default L1         # DETERMINISTIC claim ceiling
5. over ← detect_overclaim(c0, F, L*)        # forbidden patterns / ceiling-keyed cues / implied level
6. route by (L*, confidence):
     L0                      → HARD BLOCK (deterministic; no claim permitted)
     high (explicit forbidden)→ reject → constrained rewrite → enforce → fallback
     medium/low              → SEMANTIC-PRESERVING rewrite (keep content, lower only the over-claim)
     clean (no over-claim)   → pass-through
7. enforce_strict: hard-fail only on EXPLICIT multi-word assertive patterns (negation-aware)
8. return final claim, claim level L*, verifier trace
```
- **Key:** the LLM is only a propose/rewrite *component*; the *control logic* (extraction, verifiers, ceiling,
  routing, enforcement) is deterministic and auditable → "an algorithm that controls claim generation," not a
  checklist prompt. Include a trace box (e2_03: ΔAUROC=+0.04, n=300, 40 features, no nested CV → E2 fires →
  ceiling L1.5 → positive-increment rejected).
- **Ceiling-dependent routing (the v4 finding):** L0 = hard block (a semantic-preserving rewrite leaves a mild
  endorsement that breaches a no-claim ceiling — discovered when "conditionally supportable" survived on e4_04);
  L1+ = semantic-preserving rewrite (a hard template over-suppresses). enforce_strict uses multi-word assertive
  patterns only (bare tokens like "deployable" recur in legitimate caveats).

## 6. Experimental Setup
- Arms: **Generic**, **Checklist** (global verification prompt = verification_aware), **Claim Safety
  Controller (v4)**. Base generation = Sonnet 4.6; judge = GPT-5.5 (non-self). NO model-superiority claim.
- Metrics: safety (over-claim rate, hard-fail rate); completeness (0–3 claim-quality score, required-caveat
  coverage); controller diagnostics (verifier trigger, ceiling, action route, trace). PILOT n=3 (90 outputs).
- Reproducibility (AAAI-26 checklist): we separate **deterministic reproducibility** (controller, verifiers,
  scoring — released code + fixed config) from **conditional replicability** of the LLM components (generation
  Sonnet 4.6, judge GPT-5.5 are closed hosted models; we pin and report model IDs, API dates, decoding settings,
  token usage/cost). n=3 runs/case with per-repeat variation reported; **no significance tests claimed (pilot,
  descriptive)**; **no training / no hyperparameter search** (rule-based controller; config released verbatim).
  Structured-artifact inputs (no free-text clinical notes — by design); constructed probes = fixtures. We release
  benchmark JSONL + controller + verifiers + judge prompts + per-case traces under a free-research license. We do
  NOT claim full end-to-end reproducibility of closed-model outputs.

## 7. Results (outline with verified numbers)
- **RQ1 — do generic agents over-claim?** Generic n=3: **19/90 over-claim, 14/90 hard-fail**. Failure types:
  temporal prediction, transportability, label provenance, incremental value, negative-control shortcut.
- **RQ2 — does checklist prompting fix it?** Checklist n=3: **3/90 over-claim, 1/90 hard-fail** — reduced, NOT
  eliminated; stable residual failure on the incremental-value trap (e2_03).
- **RQ3 — does the controller reduce residual failures?** Controller v4 n=3: **0/90 over-claim, 0/90 hard-fail**.
  *Immediately pair with:* completeness 1.878 < checklist 2.622 → **safety–completeness trade-off** (NOT
  "controller wins"). [footnote: generation-base mismatch].
- **RQ4 — why ceiling-dependent routing?** Evolution (Table 4): v1 hard fallback (safe, over-suppressed) → v2
  soft rewrite (negation bug) → v3 (bug fixed) → v3 n=3 exposes L0 soft-rewrite hole (e4_04 over-claims 2/3) →
  v4 L0 hard block + L1+ rewrite (0/90). n≥3 was necessary to surface the L0 hole.
- **RQ5 — limitations** (see §8).

## 8. Limitations (DRAFT)
30 cases (focused diagnostic benchmark, not broad medical QA); 20/30 are constructed probes (controlled
fixtures grounded in observed failure modes); single domain (AD amyloid/MRI); structured-artifact inputs only
(no clinical free-text exists in our data — intentional, but limits free-text generalization); deterministic
verifier coverage is partial (≈22/30 cases trigger ≥1 rule); single main generation model + single judge per
direction (cross-model = failure-mode recurrence only, judge-confounded); **no learning** (DPO/SFT is future
work requiring a ClaimTrap-disjoint preference corpus to avoid train-on-eval); PILOT scale (n=3). We make no
claim of clinical deployment, biomarker discovery, benchmark completeness, model superiority, or guaranteed
safety.

## 9. Figure plan (≤5)
- **Fig 1 — Problem & benchmark overview.** artifact → generic agent → unsupported claim vs artifact →
  ClaimTrap-AD dual-view → safety eval. Worked example: site-only AUROC 0.497 → wrong "scanner confounding ruled
  out" vs calibrated "measured shortcut unsupported; feature-level site effects remain possible."
- **Fig 2 — Dual-view design & gold-leak correction.** left: old answer-aware path (gold in verification prompt);
  right: generation_view→agent / scoring_view→judge.
- **Fig 3 — Claim Safety Controller (Algorithm 1) + trace box** (e2_03).
- **Fig 4 — Main quantitative results.** panels: over-claim (19/3/0 per 90), hard-fail (14/1/0), completeness
  (1.678/2.622/1.878). Message: controller maximizes safety, does NOT dominate completeness.
- **Fig 5 — Failure-mode heatmap.** rows E1–E8 / key case IDs; cols generic/checklist/controller; cells
  {ok, completeness-gap, over-claim, hard-fail}. Highlights: e2_03 (checklist over-claim → controller safe),
  e7 negative-control (generic hard-fail → safe), e4_04 (v3 soft fail → v4 L0 block fixed).

## 10. Table plan (4)
- **Table 1 — E1–E8 taxonomy** (error, name, example wrong claim, correct restriction).
- **Table 2 — benchmark construction & review** (stage → output; incl. self-bias 79%, leakage 0).
- **Table 3 — main results** (Generic 19/90, 14/90, 1.678 | Checklist 3/90, 1/90, 2.622 | Controller v4 0/90,
  0/90, 1.878). Footnote: safety prioritized; completeness below checklist; generation-base mismatch.
- **Table 4 — controller evolution** (version, policy, safety, completeness, n, lesson) with explicit n column
  (v1–v3 n=1; v3n3/v4 n=3).

## 11. Tone (do / don't)
DO: "We introduce / identify / show / provide evidence that"; "The controller exposes a safety–completeness
trade-off." DON'T: "solve", "guarantee", "clinical-grade", "discovers biomarkers", "outperforms all baselines",
"benchmark complete", "controller outperforms checklist".

## 12. Pre-empted reviewer attacks (defenses)
small (focused diagnostic benchmark) · probes synthetic (controlled fixtures from observed failures) · one
domain (mechanism-level evaluation goal) · no free-text (analyses are reported as metrics/tables; intentional) ·
no learning (future; avoid train-on-eval) · handcrafted rules (the contribution is the evidence→ceiling→routing
framework + leakage-free eval; rules are an instantiation; LLM does propose/rewrite) · one gen model
(cross-model = recurrence only) · **"this is CSS/RIGOURATE" (concurrent claim calibration)** → we cite both;
differ by a discrete biomedical artifact-grounded ceiling that *routes* the output, not generic specificity
back-off / continuous score · **"just another guardrail" (AgentSpec/NeMo)** → within verified guardrail
frameworks none computes an evidence-grounded claim-strength ceiling with ceiling-dependent routing; `L*(e)` is a
computed graded value driving semantic-preserving downgrade, not a boolean trigger→fixed-action · **"you found
benchmark leakage first" (BenchJack)** → no; the leakage *family* is known, we name a distinct
verification-prompt channel and close it.
