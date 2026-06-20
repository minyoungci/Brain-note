# ClaimTrap-AD — paper outline (contribution-locked draft skeleton)

**Status: outline. Uses ONLY measured results (5-case generic-side exploratory; 30-case blind n=1+n=3,
human-corrected). No fabricated numbers. All external citations are [VERIFY] until confirmed via
literature-scout/academic-search.**

## Title options (by evidence level)
- (current evidence) **"ClaimTrap-AD: A Dual-View Benchmark and Hybrid Evaluator for Claim-Safe Medical Research Agents"**
- (weaker) "ClaimTrap-AD: A Benchmark for Unsupported Biomarker Claims in Medical Research Agents"
- (aspirational — needs a controller or learning, NOT yet supported) "Learning to Calibrate Biomedical Claims: Dual-View Verification for Medical Research Agents"

## Positioning (one line)
The contribution is in **evaluation / harness / verification protocol**, not a new model or training method:
how to measure claim-safety of a medical research agent **without answer-key leakage**, and what that
measurement reveals.

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
1. **Claim Safety Controller (recommended, cheapest, no train-on-eval risk):** an inference-time algorithm —
   artifact → candidate claim → verifier checks → claim-ceiling estimate → reject/rewrite above ceiling →
   safety/completeness trace. Compare **generic LLM vs global-checklist prompt vs controller** on ClaimTrap30.
   Turns "a prompt helped" into "an algorithm that controls claim generation," and targets the residual
   incremental-value failure specifically.
2. **Benchmark scale-up** 30 → 100+, ≥2 domains / artifact sources (de-pilot).
3. **Claim-calibration learning** (DPO/SFT) — requires a SEPARATE large preference corpus; ClaimTrap30 stays
   held-out. Novelty = verification/claim-schema-grounded preference data + generalization, not DPO itself.

## Forbidden in the paper (claim discipline)
"verification-aware outperforms generic" (formal) · "Sonnet worse than GPT-5.5" · "benchmark complete" ·
"general medical-agent safety proven" · any 5-case verification-side number as formal evidence · any
unverified citation.
