# ClaimTrap-AD — Novelty Positioning Matrix (post-literature-scout, 2026-06-22)

Built from the 4-cluster `literature-scout` sweep (see `RELATED_WORK_SCOUT.md`). Each row = one claimed
contribution × its nearest *named* neighbor × honest survival verdict × the differentiation that MUST appear in
the paper × what happens to the related `[VERIFY]` tag. Self-test applied (CLAUDE.md §1 Real-vs-Cosmetic):
"with the named neighbor placed beside our one-sentence delta, can a reviewer say 'already done'?"

| # | Contribution (as drafted) | Nearest named neighbor(s) | Survives? | Required differentiation (verbatim-ready) | `[VERIFY]` action |
|---|---|---|---|---|---|
| C1 | **Central formulation** — claim safety = compute ceiling `L*(e)` from artifact's own evidence, enforce `λ(c) ≤ L*(e)` | **RIGOURATE** (2601.04350, Jan'26), **CSS/Huang** (2604.17487, Apr'26) — both PRIOR preprints | ⚠️ **Partial — "first" is DEAD** | Ours = **discrete ordered** L0–L3 hierarchy, **biomedical-artifact-grounded**, used to **gate/route** output (block vs rewrite). CSS = generic open-domain specificity back-off; RIGOURATE = continuous score over written-paper claims, no control. | **REWRITE** (don't un-tag): delete "first/among the first to formulate"; add explicit cite+contrast to CSS & RIGOURATE. |
| C2 | **ClaimTrap-AD benchmark** — claim-calibration as scored axis, fixed structured artifacts w/ planted confounds, AD domain | BixBench (2503.00096), GIScholarBench (2606.08036), **BiomniBench (PARTIAL_OVERLAP, resolved 2026-06-22)** | ✅ **Yes — combination gap (confirmed)** | No single benchmark scores **claim-calibration vs evidence** on **fixed analysis artifacts** in **medicine**. BiomniBench grades the agent's own *trajectory* (process) with A/B/C rubrics + 1 generic causal-overclaim check; no L0–L3 ceiling, no supplied-artifact→claim, no E1–E8. BixBench = answer correctness; GIScholarBench = GIS generation overconfidence. | **RESOLVED** — add BiomniBench differentiation sentence (VERIFY_CLOSURE_REPORT §1). Residual: human browser-read of BiomniBench full text before submission. |
| C3 | **Dual-view protocol** — generation_view/scoring_view split prevents verification-aware → answer-aware | **BenchJack** (2605.12673, prior preprint), Li et al. DASFAA'26 (judge-side ref bias), contamination line (ICLR'24/NAACL'24) | ⚠️ **Partial — known *family*, novel *channel*** | Category (eval-time gold/rubric leakage) is NOT new. Claim ONLY: (i) the **verification-aware → answer-aware confound** (self-verification prompt built from per-case gold), previously **unnamed**, + (ii) the **generation_view/scoring_view fix w/ zero-gold-token scan**. Cite BenchJack+contamination+judge-bias, then carve the specific channel. | **RESOLVED** — replace `[VERIFY]` with the carved wording. ❌ do NOT say "first leakage-free benchmark" / "first generation-evaluator separation" (BenchJack + blinding discourse occupy it). |
| C4 | **Hybrid evaluator** — rule screen → non-self LLM judge → human spot-check | **PoLL** (2404.18796), Wang et al. ACL'24 (HITL), G-Eval (EMNLP'23) | ❌ **No (as pipeline)** | Reframe: pipeline = standard engineering. Real delta = **the documented failure mode** (rule screen false-positives on calibrated negations) + the **evaluation target** (claim calibration). Cite PoLL+Wang up front. | Un-tag bias citations (peer-reviewed). **Drop "hybrid evaluator" from the contribution list**; move to Methods as engineering. |
| C5 | **Claim Safety Controller** — deterministic evidence→ceiling→ceiling-dependent routing (L0 block / L1+ rewrite) | **AgentSpec** (ICSE'26), NeMo Guardrails (EMNLP'23), + CSS (C1) | ✅ **Yes (mechanistic)** | Within verified guardrail frameworks (AgentSpec/NeMo/Guardrails-AI/Llama Guard) **none computes an evidence-grounded claim-strength ceiling with ceiling-dependent routing.** `L*(e)` = computed graded value driving semantic-preserving downgrade, NOT a boolean trigger→fixed-action (AgentSpec) or canned block (NeMo) or evidence-agnostic reask (Guardrails-AI/Self-Refine). | Un-tag guardrail positioning. Replace "first" with the "within verified frameworks, none does X" wording. |
| C6 | **Empirical safety–completeness trade-off** (+ n≥3 surfaces the L0 hole) | — (it is a finding, not a novelty claim) | ✅ **Stands** | Keep as-is; it is the honest thesis. No literature dependency. | No tag. |

## Cross-cluster strategic read (the honest synthesis)
- **The strongest defensible contribution is C2 (the benchmark), not C5 (the controller).** This inverts the
  current draft, which frames the controller as the "AAAI TECHNICAL CORE." Post-scout, the controller is
  threatened on two sides (CSS on the formulation, AgentSpec on the mechanism), while the benchmark's
  combination gap is clean against *peer-reviewed* work.
- **C3 (dual-view) — RESOLVED to a precise methodological observation, NOT a clean novel pillar.** The leakage
  *family* is occupied (BenchJack 2605.12673 = agent/evaluator share an environment; contamination line =
  training-corpus channel; Li et al. DASFAA'26 = judge-side reference bias). What is unclaimed is the *specific
  channel*: a verification-aware agent becoming answer-aware because its self-verification prompt is built from the
  per-case gold used to score it. So C3 is a strong *named-confound + fix*, second-tier support to C2 — it sharpens
  the benchmark's validity story but cannot itself headline novelty.
- **C1 "first" is gone.** Two prior preprints calibrate claims to their own evidence. This is the single biggest
  change from the pre-scout positioning — the paper must *cite into* this line of work, not *open* it.

## Venue implication (updates the LOCKED read in CLAIMTRAP30_PAPER_OUTLINE.md)
The post-scout picture **reinforces** the conservative venue read and **weakens** AAAI-main:
- Controller-as-core pitch is now harder (CSS prior + AgentSpec peer-reviewed in the same mechanism space).
- Benchmark+dual-view-core pitch fits **NeurIPS D&B / ACL-BioNLP / ML4H / EMNLP Findings** cleanly and sidesteps
  the C1/C4/C5 threats.
- **Recommendation:** reframe to **benchmark + protocol primary, controller as a depth-adder**, target D&B/BioNLP/ML4H.
  AAAI-main only if (a) C3 were a clean novel pillar AND (b) the controller's edge over CSS is demonstrated, not just
  asserted. **Post-scout, (a) did NOT hold** — C3 is a named-confound+fix, not a clean pillar — and (b) is unmet.
  So AAAI-main is now weaker than the pre-scout read; lead with the benchmark for D&B/BioNLP/ML4H.

## What must change in the drafts (action list)
1. `PAPER_DRAFT_CLAIMTRAP_AD.md` ¶3.5 + §5.1 + contribution #4: strip "first/among the first"; insert CSS+RIGOURATE cite & contrast (C1).
2. Contribution list: demote "hybrid evaluator" from a numbered contribution to Methods engineering (C4); add PoLL/Wang cites.
3. Re-order contributions: **benchmark → dual-view → controller** (lead with C2/C3, not C5).
4. Related Work: replace every `[VERIFY: ...]` slot with the verified entries in `CLAIMTRAP_AD_CITATION_CANDIDATES.bib`;
   keep `[VERIFY]` ONLY on the 5 open items (RELATED_WORK_SCOUT §"Open verification items").
5. Add a "Concurrent/prior work" paragraph distinguishing CSS, RIGOURATE, AgentSpec, BixBench, GIScholarBench.
6. Do NOT remove any honesty footnote; these novelty changes are independent of the methodological caveats.
