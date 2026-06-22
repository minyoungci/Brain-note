# ClaimTrap-AD → Learned Claim-Safety: DPO/Variant Direction Proposal (2026-06-22)

**Status: DIRECTION PROPOSAL.** Pivot candidate from inference-time controller (frozen v4) to a *learned*
claim-safety policy on open models, to convert the inference-time finding into a stronger ML contribution.
Novelty here is a **candidate, NOT verified** — gated by a 4-cluster literature-scout (launched 2026-06-22).
Honesty gate (CLAUDE.md §2): no "first" claim until the scout confirms the gap; if no defensible delta survives,
this direction is reclassified as exploration, not contribution.

---

## 1. Data we hold (verified by direct inspection)
- canonical manifest `/home/vlm/data/preprocessed_official/official_manifest_full_n4_real_final.parquet`:
  **13,022 sessions / 7,231 subjects, 7 cohorts**, **112 harmonized common fields** (ROI volumes 100%, cdr 100%,
  age/sex ~97%, apoe/mmse ~87%, scanner ~97%). Binding constraint = **amyloid label (39%)**.
- usable claim-artifact pool (common fields + amyloid label, minus A4 single-class): **~3,100 sessions /
  ~2,275 subjects** (OASIS immediate; AJU/KDRC after PHI/temporal audit; NACC/ADNI/AIBL = non-amyloid endpoints
  or scanner/site pools). Scanner diversity (E7) best in AJU (8 models) / KDRC (4).
- **held-out, training-FORBIDDEN**: ClaimTrap30 (30 cases) + all existing agent runs.
- resources: B200 GPU (bf16) → open-weight training feasible (Llama / MedGemma / Qwen, etc.).

## 2. What we would train (precise)
Learn a generation policy `π(claim | artifact)` on an **open LLM** that keeps the implied claim level within the
evidence ceiling (`λ(c) ≤ L*(e)`) while maximizing completeness — i.e., **internalize, in the weights, the
ceiling constraint the controller currently enforces externally.**

| element | definition |
|---|---|
| base | open LLM (Llama / MedGemma / …) — Sonnet is closed, no gradient access |
| input | `generation_view` artifact (AUROC, delta, n, CV, label provenance, scanner) |
| output | calibrated NL claim |
| **training signal** | the **deterministic controller as an automatic labeler**: compute `L*(e)`, tag candidate claims {λ≤L\* & complete = chosen} / {λ>L\* = rejected} → preference pairs (no human pairwise labels) |
| objective | SFT (chosen) vs DPO (chosen/rejected) vs **ceiling-constrained variant** (penalize λ>L\*) — compared |
| train data | **ClaimTrap30-disjoint** artifact pool from the manifest (30 held-out cases excluded) |
| eval | held-out ClaimTrap30, dual-view, non-self GPT judge (fully disjoint from train) |

## 3. Pipeline
disjoint artifact pool → controller auto-labels `L*(e)`/over-claim → preference pairs → open-LLM train
(SFT/DPO/variant) → eval on held-out ClaimTrap30 → compare {generic, checklist, inference-controller, learned}.

## 4. Candidate novelty (⚠️ pending literature-scout)
"Applying DPO" is not novel. Defensible candidates, each as "prior assumes X → we do Y":
- **(A) Ceiling-grounded preference signal.** Honesty/calibration DPO uses human/heuristic correctness labels; we
  use an **evidence ceiling `L*(e)` computed from a structured artifact** as the *automatic* preference signal.
- **(B) Controller distillation (strongest candidate).** Distill a deterministic claim-safety guardrail into the
  weights → remove inference-time machinery AND close the **safety–completeness trade-off the controller cannot**.
  Reuses every existing asset.
- **(C) Ceiling-constrained objective (the "variant").** A structured preference objective over an *ordered*
  claim-level scale that penalizes `λ(c) > L*(e)`, vs scalar-preference DPO.

**Real vs cosmetic (self-test).** Cosmetic = "DPO'd Llama, over-claim dropped." Real requires: an ablation
showing the *ceiling-grounding* (not generic preference) is what matters; the trade-off actually **closed**
(completeness recovered at equal safety); and **transfer across bases** (Llama + MedGemma + 1).

**Named prior work the gap must clear** (scout targets): CSS (Huang 2026, inference-time backoff), RIGOURATE
(James 2026, scoring), honesty/uncertainty/refusal tuning (crowded), process supervision / verifier-as-reward /
RLAIF-with-rule-rewards, guardrail/constraint distillation, constrained/ordinal DPO variants.

## 5. Synthesis mandate (my role, per Min's instruction)
Not just to report literature — to **locate the unoccupied gap between prior work and our data+resources and
deliver a defensible technical novelty.** After the scouts return I will: (i) map each candidate (A/B/C) to its
nearest named prior work, (ii) identify the precise gap our assets uniquely fill (ceiling auto-labeling at scale
across 7 cohorts; controller-as-teacher; multi-base transfer on B200), (iii) propose the single strongest
defensible novel claim + the minimal experiment set that proves it — or, if no gap survives, say so plainly.

## 6. Gates before any training (no GPU yet)
- **Step 0** lit-scout (this doc's trigger): do (A)/(B)/(C) survive vs prior work?
- **Step 1** open-base baseline eval (inference only): do Llama/MedGemma over-claim like Sonnet? pick base.
- **Step 2+** disjoint preference corpus → pilot DPO → scale + multi-base + ablation.
Controller v4 stays frozen; ClaimTrap30 stays held-out throughout.
