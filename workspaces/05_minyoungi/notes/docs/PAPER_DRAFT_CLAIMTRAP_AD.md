# PAPER DRAFT — ClaimTrap-AD (AAAI main-track target)

**Status: DRAFT skeleton + drafted Abstract/Intro/Contributions + Methods/Results outlines + figure/table
plan. All numbers verified against committed artifacts (see "Verified numbers" block). External citations are
[VERIFY] until confirmed via literature-scout. No fabricated numbers. Controller FROZEN at v4.**

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
Medical research agents increasingly summarize biomedical analyses, but they can transform weak or confounded
associations into unsupported biomarker claims. Existing medical-agent benchmarks focus mainly on clinical task
execution or EHR interaction, leaving *scientific claim safety* underexplored [VERIFY: MedAgentBench,
arXiv:2501.14654]. We introduce **ClaimTrap-AD**, a dual-view benchmark that separates the analysis artifact an
agent sees from the gold claim constraints only a judge sees — preventing verification-aware prompting from
silently becoming answer-aware — together with an over-claim taxonomy (E1–E8) and graded claim ceilings
(L0–L3). We further propose a **Claim Safety Controller**, an inference-time algorithm that extracts structured
evidence from an artifact, computes a deterministic claim ceiling via verifier modules, and applies
ceiling-dependent routing (hard block for no-claim cases, semantic-preserving rewrite otherwise) to control
over-claims. In a blinded pilot, generic agents over-claim repeatedly across temporal, transportability,
label-provenance, incremental-value, and negative-control shortcut traps (19/90); a global verification
("checklist") prompt reduces but does not eliminate over-claims (3/90), failing stably on the incremental-value
trap; and the controller eliminates observed over-claims (0/90) while exposing a persistent
**safety–completeness trade-off** (completeness 1.878 vs the checklist's 2.622). We release the benchmark,
evaluator, controller, and per-case traces. *(No claim of clinical deployment, biomarker discovery, benchmark
completeness, or model superiority.)*

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
interaction [VERIFY: MedAgentBench]. We instead evaluate *scientific claim calibration*: given an analysis
artifact, does the agent claim only what the evidence licenses? Standard biomedical claim verification asks
whether *literature evidence* entails a claim [VERIFY: BioNLP claim-verification works]; we ask whether the
*analysis artifact itself* permits the claim level.

**¶3.5 (core technical idea — emphasize early).** Our central technical claim is that **claim safety for a
research agent can be cast as a claim-ceiling control problem**: from a structured artifact `e` we compute a
deterministic upper bound `L*(e)` on the strongest defensible claim level, and we *enforce* it at inference time
with a routing policy that depends on `L*` — hard-blocking no-claim (L0) artifacts and semantically rewriting
the rest. The LLM only proposes and rewrites; the safety decision is deterministic, auditable, and independent
of the LLM's own judgment. **We formulate biomedical research-agent safety as an evidence-grounded
claim-ceiling control problem and instantiate it with a dual-view benchmark and an inference-time Claim Safety
Controller.** [VERIFY: "first / among the first" framing held until literature-scout; if "first" is unclear
after related-work, keep only the formulation+instantiation wording above.]

**¶4 (contributions; tagged by type).**
1. *[Benchmark]* We define biomedical **over-claim traps** (E1–E8) for medical research agents and build
   **ClaimTrap-AD**, a 30-case, independently-reviewed, human-locked benchmark.
2. *[Protocol — generalizable]* A **dual-view evaluation protocol** (generation_view vs scoring_view) that
   prevents a verification-aware agent from silently becoming **answer-aware**. This answer-leakage mechanism is
   not AD-specific: it applies to any verification-prompted agent evaluated against per-case gold.
3. *[Evaluator]* A **hybrid evaluator** (rule screen → non-self LLM judge → human spot-check) motivated by
   rule-based false-positives on calibrated negation and known LLM-judge biases [VERIFY: MT-Bench, arXiv:2306.05685].
4. *[Algorithm — TECHNICAL CORE]* A **Claim Safety Controller**: a deterministic, inference-time algorithm that
   extracts evidence, computes a claim ceiling `L*(e)` via verifier modules, and applies **ceiling-dependent
   routing** (Algorithm 1). The LLM is a constrained component; the control logic is code, not a prompt.
5. *[Empirical finding]* Controller-based control removes observed over-claims in the pilot (0/90) but reveals a
   persistent **safety–completeness trade-off**, and a *necessity result*: ceiling-dependent routing is required
   — L0 cases need hard blocking (semantic-preserving rewrite breaches a no-claim ceiling), L1+ cases need rewrite.

## 2. Related Work (DRAFT skeleton — ALL [VERIFY] before submission)
- **Medical LLM agents & benchmarks** [VERIFY: MedAgentBench arXiv:2501.14654; EHR-agent benchmarks]. Position:
  they evaluate task execution; we evaluate research-claim safety.
- **LLM-as-a-judge & evaluation reliability** [VERIFY: MT-Bench arXiv:2306.05685; position/verbosity/self-
  enhancement bias]. Motivates non-self judge + human audit + rule screen.
- **Biomedical claim verification** [VERIFY: BioNLP 2025 claim-verification; CliniFact]. Contrast:
  evidence-entailment vs artifact-permits-claim-level.
- **Guardrails / controllers for LLM agents** [VERIFY: VeriGuard arXiv:2510.05156; AgentSpec; Guardrails AI].
  Contrast: generic safety policy vs biomedical claim-ceiling control.
→ literature-scout must confirm each (existence + exact cite) before any [VERIFY] is removed.

## 3. ClaimTrap-AD Benchmark (METHODS outline)
- **Dual-view.** `generation_view` = neutral artifact only (no gold). `scoring_view` (judge-only) = gold
  allowed-claim, forbidden phrases, required checks, claim ceiling, reviewer metadata. Motivation: the earlier
  5-case harness fed case gold into the verification prompt → answer-aware → confounded; deprecated. ClaimTrap30
  dual-view blind path is the first valid baseline (generation-side leakage scan = 0).
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
**safety–completeness trade-off** as the central tension. [VERIFY: novelty of this formulation for biomedical
research-claim generation — confirm via literature-scout before any "novel/first" wording.]

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
- Reproducibility: structured-artifact inputs (no free-text clinical notes — by design, biomedical analyses are
  reported as metrics/tables/logs); constructed probes = fixtures; **no DPO/SFT**; controller config + traces
  released. [VERIFY: AAAI reproducibility checklist items].

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
(cross-model = recurrence only).
