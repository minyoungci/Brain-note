# ClaimTrap-AD — Methods & Results (submission-style prose, DRAFT)

**Status: full-prose §3–§8, framing rewritten post-literature-scout (2026-06; strong-but-defensible, no "first"
claims). No experiments / no LLM calls / no code changes. All numbers verified against committed artifacts.
Literature claims verified via literature-scout; residual [VERIFY] items in RELATED_WORK_SCOUT.md. Controller
FROZEN at v4. Companion: PAPER_DRAFT_CLAIMTRAP_AD.md (abstract/intro/contributions), FIGURE_TABLE_PLAN.md.**

Framing note: this is an **LLM-agent evaluation/control** paper for claim-safe biomedical research agents, not a
medical-application paper.

---

## 3. Problem Formulation and the ClaimTrap-AD Benchmark

### 3.1 Claim safety as a claim-ceiling control problem
We cast biomedical claim safety as a **claim-ceiling control problem**. A medical research agent reads a
structured analysis artifact `e` — a set of evidence units such as AUROCs and their confidence intervals,
incremental deltas, sample and feature counts, cross-validation protocol, label-construction provenance, and
acquisition/temporal facts — and emits a natural-language claim `c`. Each claim has an *implied claim level*
`λ(c)` on an ordered scale
`L0 < L1 < L1.5 < L2 < L3`,
ranging from *no defensible claim* (L0), through *within-cohort association* (L1) and *credible incremental
value* (L1.5), to *predictive* (L2) and *transportable / deployable-biomarker* (L3) claims. Every artifact
admits a **claim ceiling** `L*(e)`: the strongest level its evidence licenses. An output is a **safety
violation** (an over-claim) iff `λ(c) > L*(e)`. The agent's objective is to maximize claim **completeness**
— informativeness up to the ceiling — subject to the hard safety constraint `λ(c) ≤ L*(e)`.

Standard prompting optimizes neither term explicitly: it neither computes `L*(e)` nor enforces the constraint,
and instead asks the model to self-regulate. Our contribution is to make `L*(e)` an **explicit, deterministic
quantity** and to enforce `λ(c) ≤ L*(e)` at inference time (§5). This formulation also makes the central
empirical tension precise: reducing violations (lowering `λ(c)`) can reduce completeness, producing a
**safety–completeness trade-off** that we quantify in §7. Concurrent work calibrates a claim to its own evidence —
back-off to the most-specific admissible level in open-domain QA (Huang et al. 2026) and a continuous
overstatement score over paper text (James et al. 2026, RIGOURATE); our formulation differs in computing a
**discrete, ordered, biomedical evidence ceiling** from a structured analysis artifact and *enforcing* it as a
routing decision (§5), rather than scoring or backing off a free-text claim.

### 3.2 Dual-view evaluation (preventing answer-key leakage)
A subtle hazard arises when one evaluates a *verification-aware* agent — an agent prompted to check its own
claims. If the verification prompt is built from the same per-case gold used to score the output (the allowed
claim level, the forbidden phrases, the required caveats), the agent effectively *reads the answer key*: a
verification-aware agent silently becomes an **answer-aware** agent, and any apparent benefit of "verification"
is confounded. We encountered exactly this in an early 5-case harness, where case-specific gold leaked into the
verification prompt; those verification-side results are therefore **deprecated and not used as formal
evidence**. Eval-time gold leakage is itself documented — for training-corpus contamination (Golchin &
Surdeanu 2024; Deng et al. 2024), for shared agent/evaluator environments (Wang et al. 2026, BenchJack), and as
judge-side reference bias (Li et al. 2026) — but the *verification-prompt* channel we describe, in which a
verification-aware agent is turned answer-aware by gold-derived caveats, is distinct and, to our knowledge,
previously unnamed.

ClaimTrap-AD enforces a **dual-view** separation. Every case exposes two disjoint views:
- **`generation_view`** — the neutral artifact the agent sees (metrics, facts, the focus question), containing
  no gold;
- **`scoring_view`** — judge-only fields: the gold allowed-claim level, forbidden phrases, required checks, the
  claim ceiling, and reviewer metadata.

Agents (generic, checklist, and the controller) read only `generation_view`; the scoring_view is visible only to
the judge, which is legitimate because the judge *is* the answer key. A generation-side leakage scan confirms
zero gold tokens reach any agent prompt. ClaimTrap30's dual-view blind path is thus our leak-free baseline;
the deprecated 5-case verification-side numbers are reported, if at all, only as exploratory context. Crucially, the
answer-leakage mechanism is **not AD-specific**: it applies to any verification-prompted agent evaluated against
per-case gold, which makes the dual-view protocol a generalizable evaluation contribution (Figure 2).

### 3.3 The benchmark
ClaimTrap-AD contains **30 cases**: **10 OASIS-derived** real artifacts (drawn from an actual amyloid-status
analysis whose headline result is null/weak) and **20 constructed probes**. The probes are **controlled
evaluation fixtures grounded in observed failure categories** — not fabricated biological findings; each is built
to trigger a specific over-claim trap while remaining individually plausible. Cases span an **E1–E8 over-claim
taxonomy** (Table 1): covariate-baseline omission (E1), incremental over-claim (E2), temporal over-claim (E3),
label-provenance over-claim (E4), transportability over-claim (E5), causal/mechanistic over-claim (E6),
negative-control shortcut over-interpretation (E7), and unsupported-biomarker claims (E8). Gold for each case is
a claim level in `{L0, L1, L1.5, L2, L3}` plus forbidden phrases and required checks, with an explicit
**safety-vs-completeness split** distinguishing a *wrong* claim from a merely *incomplete* one. The locked set
has levels L1.5:10 / L1:17 / L0:3.

Gold was locked by an **independent two-reviewer blind review** followed by **human adjudication** (Table 2).
A notable finding motivating independent review: the draft-author's self-assigned gold disagreed with the
independent consensus on a substantial fraction of cases (self-bias ≈79%; 6/30 levels corrected), i.e.,
self-authored gold is unreliable and independent review materially changes the labels. A final generation-side
leakage scan returned zero leaks.

## 4. Hybrid Evaluation Protocol
We present this as a *reliability protocol*, not a novel evaluator: each stage is established practice (Zheng et
al. 2023; Wang et al. 2024; Verga et al. 2024), assembled to avoid over-counting calibrated negation as
over-claiming. Scoring calibrated scientific prose is itself error-prone, so we combine three stages. (1) A **rule-based
screen** catches blatant over-claims with high recall but **false-positively penalizes calibrated negations** —
e.g., "this is *not* a robust biomarker" or "should *not* be interpreted as predictive" superficially contain
the forbidden tokens; in development, rule-only scoring mislabeled such calibrated prose, and several
rule-based hard-fails had to be reclassified as *judge-required*. (2) Ambiguous cases therefore pass to a
**reference-guided, non-self LLM judge** (the judge model differs from the generation model) that reads the
scoring_view gold and resolves calibrated negation / semantic nuance; LLM judges are useful but carry known
position, verbosity, and self-enhancement biases (Zheng et al. 2023; Wang et al. 2024), which we mitigate by
using a non-self judge (cf. diverse juries, Verga et al. 2024) and never treating the judge as the sole authority. (3) A **human spot-check** locks
safety-critical decisions. We report judge-side numbers and flag where human adjudication changed a verdict.

## 5. The Claim Safety Controller
### 5.1 Overview and design principle
The controller operationalizes §3.1. **Unlike checklist prompting, the Claim Safety Controller does not rely on
the model to self-police its own claim strength; it computes verifier-triggered ceilings from structured
evidence and routes claims through hard blocking or semantic-preserving rewriting.** The LLM is used only as a
constrained component — it *proposes* an initial claim and, when asked, *rewrites* one — while the safety logic
(evidence extraction, verifier firing, ceiling estimation, over-claim detection, routing, and final
enforcement) is **deterministic code** that produces an auditable trace. This is the distinction between a
prompt that requests caution and an *algorithm that controls claim generation*. Within current agent-guardrail
frameworks — programmable rails (Rebedea et al. 2023, NeMo Guardrails), runtime action enforcement (Wang et al.
2026, AgentSpec), and output validators / self-refinement (Madaan et al. 2023) — none computes an
evidence-grounded ceiling on *claim strength*: `L*(e)` is a computed graded value that drives a
semantic-preserving downgrade, not a boolean policy trigger, a canned block, or an evidence-agnostic reask.

### 5.2 Algorithm (Algorithm 1; Figure 3)
Given a `generation_view` artifact `A`, a global verifier schema `V`, and a base LLM `M`, the controller:
1. **proposes** a candidate claim `c0 = M.propose(A)`;
2. **extracts** structured evidence `e` from `A` deterministically (schema parse of the structured artifact —
   no learned extractor; free-text extraction is out of scope, §8);
3. **fires verifier modules** `f_1..f_k ∈ V` on `e` — each `f_i` is a deterministic function encoding one
   over-claim trap (e.g., E2 fires when a small positive ΔAUROC under high feature-to-sample ratio lacks nested
   CV or a paired ΔCI excluding zero);
4. **estimates the ceiling** `L*(e)` as the strictest cap among triggered modules (default L1);
5. **detects over-claim**: whether `c0` asserts a forbidden pattern of a fired module, an affirmative cue above
   the ceiling, or an implied level `λ(c0) > L*`;
6. **routes by `(L*, confidence)`**:
   - `L* = L0` → **hard block** (a no-claim ceiling permits no claim; see §5.3);
   - high confidence (an explicit forbidden phrase is asserted) → reject → constrained rewrite → enforce →
     templated fallback if the rewrite still violates;
   - medium/low confidence → **semantic-preserving rewrite** (keep the defensible content, lower only the
     over-claiming phrasing, add the missing caveat);
   - clean (no over-claim) → pass-through;
7. **enforces strictly**: the final claim hard-fails only on *explicit, multi-word, assertive* forbidden
   patterns, checked with clause-level negation awareness (so a calibrated caveat such as "not a deployable
   biomarker" is never penalized);
8. **returns** the final claim, the claim level `L*`, and the verifier trace.

A worked trace (Figure 3, inset): for case e2_03, evidence `{ΔAUROC=+0.04, n=300, features=40, nested_cv=false,
paired_ΔCI=absent}` fires the E2 module, which caps the ceiling at L1.5 and rejects positive-increment wording;
the controller rewrites "ROI features improve discrimination" to a statement that the increment is not credible
without nested validation.

### 5.3 Ceiling-dependent routing (the key design finding)
The routing policy is **ceiling-dependent**, and this is not a cosmetic choice. We found empirically (§7, RQ4)
that a single rewrite policy fails at the extremes. A *hard* templated fallback applied everywhere is safe but
**over-suppresses** L1+ cases (it discards defensible content). A *semantic-preserving rewrite* applied
everywhere recovers L1+ completeness but is **unsafe at L0**: because a no-claim artifact permits no claim,
"preserving content" leaves a mild endorsement (e.g., "the pooled label is conditionally supportable") that
breaches the L0 ceiling. The controller therefore routes **L0 to hard blocking and L1+ to semantic-preserving
rewrite**. The strict-enforcement guard (step 7) uses only explicit multi-word assertive patterns, because bare
single tokens (e.g., "deployable", "predict") recur in legitimate caveats and a token-level guard reintroduces
over-suppression.

### 5.4 Controller versions (development narrative)
We summarize the development that produced the v4 policy (full numbers in Table 4): **v1** used a hard fallback
— safe but heavily over-suppressing; **v2** introduced soft rewrite and exposed a strict-enforce negation bug
(a bare-token guard hard-failed negated caveats); **v3** fixed the guard (multi-word, clause-negation-aware);
running **v3 at n=3** then surfaced an L0 soft-rewrite failure that a single run had hidden (the "conditionally
supportable" breach on e4_04); **v4** added L0 hard blocking, giving the final ceiling-dependent policy. The
controller is frozen at v4. We note that **n≥3 was necessary to surface the L0 failure**, a methodological point
about evaluating stochastic generation.

## 6. Experimental Setup
We compare three arms on ClaimTrap-AD: **Generic** (an unguided agent), **Checklist** (a global
verification/checklist prompt, identical for all cases, derived from the claim schema — never per-case gold),
and the **Claim Safety Controller (v4)**. The base generation model is Sonnet 4.6; the judge is GPT-5.5, a
non-self judge. We make **no model-superiority claim**; cross-model differences are reported only as
failure-mode recurrence, since the judge differs across directions and is stochastic. We evaluate at **n=3**
(90 outputs per arm) to average generation/judge stochasticity. Metrics: **safety** (over-claim rate, hard-fail
rate); **completeness** (a 0–3 claim-quality score and required-caveat coverage); and **controller
diagnostics** (verifier triggers, estimated ceiling, action route, trace). Two reproducibility caveats are
stated explicitly: (i) the controller arm holds the *propose* claim fixed (the generic n=1 output) and
re-samples only the rewrite across repeats, so its n=3 measures rewrite-stability on a fixed proposal rather
than three independent generations — the over-claim comparison remains meaningful because the controller acts on
the proposal, but the three arms are not a perfectly matched trial; (ii) inputs are structured artifacts, not
free-text clinical notes (§8). No learning (DPO/SFT) is used. For reproducibility (AAAI-26 checklist), we separate the deterministic components
(controller, verifiers, scoring — released with a fixed config) from the LLM components (generation Sonnet 4.6,
judge GPT-5.5), which are closed hosted models replicable only conditioned on the reported model IDs, API dates,
and decoding settings; we report per-repeat variation over the n=3 runs, claim no statistical significance (pilot,
descriptive), perform no training or hyperparameter search, and release the benchmark, controller, verifiers,
judge prompts, and per-case traces. We do not claim full reproducibility of closed-model outputs.

## 7. Results
### RQ1 — Do generic medical research agents over-claim?
Yes, and not at random. The generic agent over-claims on **19/90** outputs and hard-fails on **14/90**
(completeness 1.678). Failures are not random: they localize to the taxonomy traps — temporal prediction from
cross-sectional windows (E3), transportability from pooled cohorts (E5), clean-label assertions over
multi-tracer pooled labels (E4), positive incremental value from a tiny unvalidated ΔAUROC (E2), and
shortcut over-interpretation of negative controls (E7), e.g., reading a chance-level site-only AUROC as
"scanner confounding is ruled out." We emphasize *failure localization*, not model-bashing: these are the
specific evidence-to-claim steps where calibration breaks (Figure 5).

### RQ2 — Does checklist prompting fix it?
Partly. A global verification ("checklist") prompt reduces over-claims to **3/90** (hard-fail 1/90) and raises
completeness to **2.622**. But it does **not** eliminate over-claims: it fails *stably* on the incremental-value
trap (e2_03), repeatedly reading a small unvalidated ΔAUROC as a genuine improvement. We do not claim checklist
prompting is universally safe; we claim it reduces but leaves a structured residual.

### RQ3 — Does the Claim Safety Controller reduce the residual failures?
The controller (v4) reaches **0/90 over-claim and 0/90 hard-fail**. It blocks exactly the residual that
checklist prompting cannot — the e2_03 incremental trap — via the deterministic E2 ceiling, and it closes the
L0 failure (e4_04) via hard blocking. However, **the controller does not dominate checklist prompting on
completeness** (1.878 vs 2.622): it removes observed over-claims while producing terser claims, **revealing a
safety–completeness trade-off rather than a simple win** (Figure 4). Per the dual-view discipline we explicitly
do *not* claim the controller "outperforms" the checklist.

### RQ4 — Why is ceiling-dependent routing necessary?
The version study (Table 4) is itself the evidence. A uniform hard fallback (v1) is safe but over-suppresses
(completeness 1.633); a uniform soft rewrite (v2/v3) recovers completeness but is unsafe at L0 — at n=3, v3
over-claims 2/90, both on the L0 case e4_04 where the soft rewrite left a "conditionally supportable"
endorsement. Routing L0 to a hard block and L1+ to semantic-preserving rewrite (v4) restores **0/90** while
keeping completeness at 1.878. The necessity of *different actions at different ceilings* — not a single rewrite
policy — is the core design finding.

### RQ5 — What remains?
A persistent **over-suppression** at the L1+ level: the controller's completeness (1.878) sits between the
generic agent (1.678) and the checklist (2.622), so safety is bought at a measurable completeness cost. The
controller improves safety but does not "solve" claim generation; closing the trade-off (e.g., learning a
calibrated rewriter) is future work (§8).

## 8. Limitations
ClaimTrap-AD is a **focused diagnostic benchmark** (30 cases), not a broad medical-QA benchmark; 20/30 are
constructed fixtures (grounded in observed failure modes, individually plausible). It covers a **single domain**
(Alzheimer's amyloid/MRI analysis) and a single real analysis seed. **ClaimTrap-AD currently evaluates
structured biomedical analysis artifacts, not arbitrary free-text clinical notes; extending the controller to
free-text settings requires a separate evidence-extraction benchmark.** Deterministic verifier coverage is
partial (≈22/30 cases trigger ≥1 module; non-triggering cases fall through to the proposal, with the hybrid
evaluator as the safety net). We use a single main generation model and a single judge per direction
(cross-model = failure-mode recurrence only, judge-confounded), and a PILOT scale (n=3). We apply **no learning**
(DPO/SFT); a preference-learning extension must use a corpus disjoint from the held-out ClaimTrap30 to avoid
train-on-eval. We make no claim of clinical deployment, biomarker discovery, benchmark completeness, model
superiority, or guaranteed safety.

---

## Figure / Table callouts (used above)
- Figure 1 (Problem & benchmark overview) — Intro / §3.1.
- Figure 2 (Dual-view design & gold-leak correction) — §3.2.
- Figure 3 (Claim Safety Controller algorithm + e2_03 trace) — §5.2.
- Figure 4 (Main safety/completeness results) — §7 RQ3.
- Figure 5 (Failure-mode heatmap) — §7 RQ1/RQ3.
- Table 1 (E1–E8 taxonomy) — §3.3. Table 2 (construction & review) — §3.3.
- Table 3 (main results: generic 19/90·14/90·1.678 | checklist 3/90·1/90·2.622 | controller v4 0/90·0/90·1.878) — §7.
- Table 4 (controller evolution v1–v4, with explicit n) — §5.4 / §7 RQ4.
