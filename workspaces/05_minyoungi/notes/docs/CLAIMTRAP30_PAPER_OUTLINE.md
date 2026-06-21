# ClaimTrap-AD — paper outline (contribution-locked draft skeleton)

**Status: outline. Uses ONLY measured results (5-case generic-side exploratory; 30-case blind n=1+n=3,
human-corrected). No fabricated numbers. All external citations are [VERIFY] until confirmed via
literature-scout/academic-search.**

## Title (LOCKED 2026-06-21)
**"ClaimTrap-AD: A Dual-View Benchmark and Claim Safety Controller for Claim-Safe Medical Research Agents"**
- (alt, more ML-flavored) "ClaimTrap-AD: Evaluating and Controlling Biomedical Over-Claims in Medical Research Agents"

## Positioning (LOCKED one line)
An **evaluation + inference-time control** contribution (not a new model / not training): a dual-view benchmark
that measures medical-research-agent claim-safety **without answer-key leakage**, and a Claim Safety Controller
that computes a **claim ceiling from structured evidence** and applies **ceiling-dependent routing** to control
over-claims — what that measurement and control reveal (a persistent safety–completeness trade-off).

## Technical contributions (LOCKED)
1. **Dual-view benchmark protocol.** Separates agent-visible analysis artifacts (generation_view) from
   judge-only gold claim constraints (scoring_view), preventing verification-aware prompting from
   degenerating into **answer-aware** prompting. (Discovered in the 5-case harness where gold_claim_level/
   forbidden/required leaked into the verification prompt → confounded; fixed in the 30-case adapter.)
2. **ClaimTrap taxonomy + claim-level calibration.** E1–E8 biomedical over-claim taxonomy + L0/L1/L1.5/L2/L3
   claim ceilings, with an explicit **safety vs completeness** split (e.g. E4_safety vs E4_completeness,
   E7_safety vs E7_completeness) that separates "wrong claim" from "missing caveat."
3. **Hybrid over-claim evaluator.** rule-based screen (catches blatant over-claims) → non-self LLM judge
   (resolves calibrated negation / semantic ambiguity; judge ≠ generation model) → human audit (locks
   safety-critical). Motivated by the observed rule-based false-positives on calibrated prose.
4. **Empirical findings (blind, reproducible).** On the leak-free 30-case path: global verification guidance
   **reduces but does not eliminate** over-claims (n=3: generic 19/90 → verification 3/90; hard_fail 14 → 1),
   with the residual verification failure **localized to the incremental-value trap (e2_03, 3/3)**; generic
   negative-control / temporal / L0 failures **recur 3/3**; cross-model over-interpretation is
   **model-dependent** (exploratory, judges differ).
5. **Claim Safety Controller (depth-adder, inference-time algorithm).** Deterministic verifier modules
   (E1–E8) → claim-ceiling estimate → **ceiling-dependent routing** (L0 hard block / L1+ semantic-preserving
   rewrite) → traceable final claim. Evolution (all human-adjudicated/PILOT): v1 (over-claim 0/30 but high
   over-suppression, completeness 1.63) → v2 (soft rewrite; exposed a strict-enforce negation bug) → v3 (bug
   fixed) → **v3 n=3 exposed an L0 soft-rewrite gap** (e4_04 over-claimed 2/3: "conditionally supportable"
   survived soft rewrite — discovery enabled by n≥3) → **v4 = L0 hard-block (STOP POINT): over-claim 0/90,
   hard_fail 0/90, completeness 1.88 (> v1 1.63), over-suppression ~14 (NOT eliminated)**. Honest framing: an
   algorithm that **controls** claim generation and achieves over-claim-free output checklist cannot (e2_03),
   but reveals a **persistent safety↔completeness trade-off** requiring ceiling-dependent routing — NOT a
   clean win, and NOT "controller outperforms checklist" (checklist completeness 2.57 > controller 1.88).

## Section-by-section evidence map (what goes where; all from committed artifacts)
- **§ Governance / benchmark construction**: endpoint feasibility audit, amyloid label audit, OASIS Task3A
  null (the real seed), independent blind 2-reviewer gold lock + human sign-off; draft↔gold self-bias 79%
  (vs 40% on 5-case) → motivates independent review. (claimtrap30_gold.jsonl, CLAIMTRAP30_FORMAL_REVIEW_REPORT.md)
- **§ Dual-view protocol + leakage**: the 5-case gold-leak; generation_view/scoring_view; dry-run leakage=0.
  (claimtrap30_adapter.py, VERIFIER_SPEC V7/V8, CLAIMTRAP30_CONSOLIDATION.md)
- **§ Taxonomy + evaluator**: E1–E8, L0–L3, safety/completeness split, hybrid screen+judge+human.
  (VERIFIER_SPEC V4–V8, BENCHMARK_LABEL_REVIEW)
- **§ Results**: n=1 (generic 7/30 vs verification 2/30) + n=3 (19/90 vs 3/90), completeness 1.68 vs 2.62,
  per-repeat stability, failure-mode recurrence table, the e2_03 localization, the e7_02 within-case contrast.
  (CLAIMTRAP30_N3_RECURRENCE_RESULT.md, human_corrected_scores.csv)
- **§ Limitations** (honest, must be explicit): single domain (amyloid/MRI), single real analysis seed
  (OASIS Task3A); 30 cases (10 real + 20 constructed probes); single generation model per run + single judge
  per direction (cross-model is judge-confounded → failure-mode recurrence only); **no training**, **no
  agentic system** (single-prompt agents); PILOT scale.

## Related work (slots — ALL [VERIFY] before use)
- medical LLM agent evaluation / virtual-EHR agent benchmarks [VERIFY: MedAgentBench]
- evaluation contamination / answer leakage in agent eval [VERIFY: search-time contamination paper; arXiv id]
- LLM-as-judge biases (self-preference, position, verbosity) [VERIFY: self-preference bias paper]
- claim verification / hallucination in scientific & medical text [VERIFY: survey + key works]
→ run literature-scout to confirm each exists + exact cite; replace [VERIFY] with verified entries only.

## Honest venue read
- As-is → **good workshop / benchmark-eval paper** (AAAI workshop; or NeurIPS D&B / ACL-BioNLP / EMNLP Findings
  / ML4H, which fit benchmark+eval better than AAAI main).
- AAAI **main/special (technical)** → needs ONE depth-adder below (current = prompt + evaluator, reviewer
  will ask "isn't this just a checklist?").

## To reach top-tier main track (pick one; do NOT train on the locked benchmark)
1. **Claim Safety Controller (recommended, cheapest, no train-on-eval risk) — IMPLEMENTED + PILOTED:** an
   inference-time algorithm — artifact → candidate claim → verifier checks → claim-ceiling estimate →
   reject/rewrite above ceiling → safety/completeness trace. 3-way pilot done (see contribution 5):
   controller 0/30 over-claim, fixes e2_03, but over-suppresses (high recall / low precision). Turns "a prompt
   helped" into "an algorithm that controls claim generation." **Remaining for main-track strength:** raise
   detector precision (fallback gating when no verifier fires; soft caveat-insertion rewrite; confidence
   tiers; completeness-preserving rewrite) → re-run 3-way → show safety held AND completeness recovered.
   (design+future work: CLAIM_SAFETY_CONTROLLER_DESIGN.md §12–13)
2. **Benchmark scale-up** 30 → 100+, ≥2 domains / artifact sources (de-pilot).
3. **Claim-calibration learning** (DPO/SFT) — requires a SEPARATE large preference corpus; ClaimTrap30 stays
   held-out. Novelty = verification/claim-schema-grounded preference data + generalization, not DPO itself.

## Forbidden in the paper (claim discipline)
"verification-aware outperforms generic" (formal) · "Sonnet worse than GPT-5.5" · "benchmark complete" ·
"general medical-agent safety proven" · any 5-case verification-side number as formal evidence · any
unverified citation.

## NOVELTY DEFENSE & POSITIONING (LOCKED 2026-06-21)
The Claim Safety Controller is NOT automatically novel. It is novel ONLY when framed as an inference-time
control algorithm on a leakage-free benchmark — NOT as "a better checklist prompt" or "a few rule-based
guardrails." Strong framing (use this):
> We propose an inference-time Claim Safety Controller that converts structured biomedical analysis artifacts
> into evidence units, computes a deterministic claim ceiling via verifier modules, and applies
> ceiling-dependent routing to rewrite or block unsupported claims.

**The strongest contributions are the EMPIRICAL findings, not the controller mechanism:**
(i) dual-view answer-leakage discovery (verification-aware → answer-aware) and its fix; (ii) the
failure-driven safety↔completeness trade-off and the discovery that **ceiling-dependent routing** (L0 hard
block / L1+ semantic-preserving rewrite) is required. The E1–E8 rules are an *instantiation*; the novelty is
the evidence→ceiling→routing framework + the leakage-free evaluation, NOT the specific rules.

**5 conditions that MUST hold for the controller to read as novel (all currently satisfied):**
1. Catch a residual failure checklist prompting cannot — e2_03 incremental trap (deterministic E2 cap).
2. Emit per-case traces (evidence → triggered verifiers → ceiling → action), not just final scores.
3. Present on top of the dual-view benchmark (answer-leakage prevented + demonstrated).
4. Justify the hybrid evaluator (rule screen → non-self LLM judge → human spot-check) with the rule-based
   false-positive on calibrated negation that motivated it.
5. Report the controller's imperfection honestly (v1→v4 evolution, the trade-off).

**5 reviewer attacks to pre-empt (and the defense):**
- "domain-specific rule-based guardrail" → contribution = the framework + leakage-free eval, rules are an instantiation.
- "human-made rules, not LLM" → that is the point: the *control logic* is deterministic/auditable; the LLM only proposes/rewrites.
- "small, AD-specific benchmark" → acknowledged limitation; 30 independently-locked cases + dual-view protocol generalize.
- "prompt vs controller difference unclear" → e2_03: checklist fails 3/3, controller fixes it deterministically.
- "only final scores" → traces + failure localization (incremental / L0 / negative-control traps).

**Forbidden claims (unchanged):** "controller outperforms checklist" (it does NOT — checklist completeness
2.57 > controller 1.88; the controller's win is over-claim-free generation + the e2_03 residual, at a
completeness cost), "controller proves safety", "benchmark complete", "Sonnet<GPT".

**Locked results message (3 sentences):**
> Global checklist prompting reduces over-claims but leaves a stable incremental-value failure.
> The Claim Safety Controller eliminates this residual failure through deterministic claim-ceiling enforcement,
> but reveals a safety–completeness trade-off.
> Ceiling-dependent routing is required: L0 hard block, L1+ semantic-preserving rewrite.

**Figures (target):** (1) dual-view benchmark; (2) gold-leakage failure + correction; (3) Claim Safety
Controller algorithm + a trace; (4) safety–completeness trade-off across v1→v4; (5) failure localization
(incremental trap / L0 trap / negative-control trap).

**Honest venue read (LOCKED):** good fit = workshop / NeurIPS D&B / ACL-BioNLP / EMNLP Findings / ML4H.
AAAI main = a stretch given PILOT scale (n=1/n=3, single domain, single gen model, single judge) — only with
the controller as the central contribution AND scale stated as a limitation. Do NOT over-target ICLR/ICML/NeurIPS main.

**DPO:** future extension only (see DPO_DATA_CANDIDATE_PLAN.md = DPO_POSSIBLE_AFTER_AUDIT). ClaimTrap30 stays held-out.

**STOP POINT (LOCKED):** controller frozen at v4 (over-claim 0/90; ceiling-dependent routing). After the v4
targeted human spot-check, NO further controller changes → paper draft. No v5/Gemini/DPO/case-50 expansion now.
