# ClaimTrap-AD — paper outline (contribution-locked draft skeleton)

**Status: outline, framing synced with the post-scout drafts (2026-06-22). Uses ONLY measured results (5-case
generic-side exploratory; 30-case blind n=1+n=3, human-corrected). No fabricated numbers. External citations
verified via literature-scout (2026-06); residual [VERIFY] in RELATED_WORK_SCOUT.md. No definitive "first" claims.**

## Title (LOCKED 2026-06-21)
**"ClaimTrap-AD: A Dual-View Benchmark and Claim Safety Controller for Claim-Safe Medical Research Agents"**
- (alt, more ML-flavored) "ClaimTrap-AD: Evaluating and Controlling Biomedical Over-Claims in Medical Research Agents"

## Positioning (LOCKED one line)
An **evaluation + inference-time control** contribution (not a new model / not training): a dual-view benchmark
that measures medical-research-agent claim-safety **without answer-key leakage**, and a Claim Safety Controller
that computes a **claim ceiling from structured evidence** and applies **ceiling-dependent routing** to control
over-claims — what that measurement and control reveal (a persistent safety–completeness trade-off).

## Technical contributions (LOCKED — re-locked post-scout 2026-06-22; order: Benchmark → Leakage → Controller → Finding)
1. **ClaimTrap-AD benchmark.** A dual-view benchmark of biomedical over-claim traps: an **E1–E8** taxonomy +
   **L0/L1/L1.5/L2/L3** claim ceilings with an explicit **safety vs completeness** split (e.g. E4_safety vs
   E4_completeness, E7_safety vs E7_completeness) separating "wrong claim" from "missing caveat." 30 cases,
   independently reviewed and human-locked.
2. **Leakage control (dual-view protocol).** Separates agent-visible artifacts (generation_view) from judge-only
   gold (scoring_view), closing a verification-specific channel in which case-level gold in the verification
   prompt turns a **verification-aware agent into answer-aware** (found in the 5-case harness where
   gold_claim_level/forbidden/required leaked → confounded; fixed in the 30-case adapter; zero-gold-token scan).
   The leakage *family* is known (contamination; BenchJack; judge-side ref bias); the verification-prompt channel
   is the specific, previously-unnamed contribution. ❌ NOT "first leak-free benchmark."
3. **Claim Safety Controller (TECHNICAL CORE, inference-time algorithm).** Deterministic verifier modules (E1–E8)
   → claim-ceiling estimate `L*(e)` → **ceiling-dependent routing** (L0 hard block / L1+ semantic-preserving
   rewrite) → traceable final claim. LLM = propose/rewrite component; control logic = deterministic code.
   Evolution (human-adjudicated/PILOT): v1 (0/30, over-suppressed, completeness 1.633) → v2 (soft rewrite;
   strict-enforce negation bug) → v3 (bug fixed) → **v3 n=3 exposed an L0 soft-rewrite gap** (e4_04 over-claimed
   2/3: "conditionally supportable" survived — discovery enabled by n≥3) → **v4 = L0 hard-block (STOP POINT):
   over-claim 0/90, hard_fail 0/90, completeness 1.878 (> v1 1.633), over-suppression ~14 (NOT eliminated)**.
   Differs from concurrent claim-calibration (CSS, Huang et al. 2026; RIGOURATE, James et al. 2026) by a discrete
   ordered biomedical ceiling that *routes* output; differs from guardrails (AgentSpec, NeMo) which enforce policy
   not claim-strength. ❌ NOT "first claim-ceiling controller."
4. **Empirical findings (blind, reproducible).** On the leak-free 30-case path: global verification guidance
   **reduces but does not eliminate** over-claims (n=3: generic 19/90 → verification 3/90; hard_fail 14 → 1),
   residual **localized to the incremental-value trap (e2_03, 3/3)**; generic negative-control / temporal / L0
   failures **recur 3/3**; the controller reaches **0/90** but reveals a **persistent safety↔completeness
   trade-off** — NOT a clean win, NOT "controller outperforms checklist" (checklist completeness 2.622 >
   controller 1.878). Cross-model over-interpretation is **model-dependent** (exploratory, judges differ).

We use a **hybrid evaluation protocol** (rule screen → non-self LLM judge → human audit), presented as a
*reliable evaluation protocol* — NOT a standalone novelty (components are established: Zheng et al. 2023; Wang et
al. 2024; Verga et al. 2024). Motivated by rule-based false-positives on calibrated negation.

## Section-by-section evidence map (what goes where; all from committed artifacts)
- **§ Governance / benchmark construction**: endpoint feasibility audit, amyloid label audit, OASIS Task3A
  null (the real seed), independent blind 2-reviewer gold lock + human sign-off; draft↔gold self-bias 79%
  (vs 40% on 5-case) → motivates independent review. (claimtrap30_gold.jsonl, CLAIMTRAP30_FORMAL_REVIEW_REPORT.md)
- **§ Dual-view protocol + leakage**: the 5-case gold-leak; generation_view/scoring_view; dry-run leakage=0.
  (claimtrap30_adapter.py, VERIFIER_SPEC V7/V8, CLAIMTRAP30_CONSOLIDATION.md)
- **§ Taxonomy + evaluator**: E1–E8, L0–L3, safety/completeness split, hybrid screen+judge+human.
  (VERIFIER_SPEC V4–V8, BENCHMARK_LABEL_REVIEW)
- **§ Results**: n=1 (generic 7/30 vs verification 2/30) + n=3 (19/90 vs 3/90), completeness 1.678 vs 2.622,
  per-repeat stability, failure-mode recurrence table, the e2_03 localization, the e7_02 within-case contrast.
  (CLAIMTRAP30_N3_RECURRENCE_RESULT.md, human_corrected_scores.csv)
- **§ Limitations** (honest, must be explicit): single domain (amyloid/MRI), single real analysis seed
  (OASIS Task3A); 30 cases (10 real + 20 constructed probes); single generation model per run + single judge
  per direction (cross-model is judge-confounded → failure-mode recurrence only); **no training**, **no
  agentic system** (single-prompt agents); PILOT scale.

## Related work (VERIFIED 2026-06 — see RELATED_WORK_SCOUT.md + CLAIMTRAP_AD_CITATION_CANDIDATES.bib)
6 grounded bundles: medical-agent benchmarks (MedAgentBench/NEJM AI, AgentClinic/npj, BixBench, GIScholarBench,
BiomniBench=PARTIAL_OVERLAP) · scientific over-claim & claim calibration (Peters & Chin-Yee 2025; CSS/Huang 2026;
RIGOURATE 2026) · claim verification (SciFact, HealthVer, CliniFact, MuSciClaims, CLAIM-BENCH) · LLM-judge bias
(MT-Bench, Wang 2024, G-Eval; PoLL) · eval-time leakage (Golchin 2024, Deng 2024, BenchJack, Li DASFAA 2026) ·
guardrails (AgentSpec, NeMo, Self-Refine). Per-bundle positioning + deltas in RELATED_WORK_SCOUT.md.
Residual [VERIFY] = BiomniBench full-text/authors + AgentSpec proceedings only (VERIFY_CLOSURE_REPORT.md).

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

## NOVELTY DEFENSE & POSITIONING (LOCKED 2026-06-21; re-locked post-scout 2026-06-22)
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
- "this is CSS/RIGOURATE (concurrent claim calibration)" → cite both; we differ by a discrete biomedical
  artifact-grounded ceiling that *routes* output (block vs rewrite), not generic specificity back-off / continuous score.
- "just another guardrail (AgentSpec/NeMo)" → within verified guardrail frameworks none computes an
  evidence-grounded claim-strength ceiling; `L*(e)` is a graded value driving semantic-preserving downgrade.
- "you found benchmark leakage first (BenchJack)" → no; the leakage family is known, we name a distinct
  verification-prompt channel and close it.

**Forbidden claims (unchanged):** "controller outperforms checklist" (it does NOT — checklist completeness
2.622 > controller 1.878; the controller's win is over-claim-free generation + the e2_03 residual, at a
completeness cost), "controller proves safety", "benchmark complete", "Sonnet<GPT", "first leak-free benchmark",
"first claim-ceiling controller".

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
