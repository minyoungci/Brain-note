# DPO Data Candidate Plan (read-only audit, 2026-06-21)

Question audited: not "is there DPO-ready data" but "can we build a preference corpus safely?"
Machine-readable: `outputs/data_audit/dpo_candidate_assets.csv`.

## Verdict: **DPO_POSSIBLE_AFTER_AUDIT**
The raw **structured** material to *construct* a preference corpus is abundant and clean enough, but no
preference pairs exist yet, generating them needs LLM (currently paused) + human verification, and the corpus
must be **disjoint from the held-out ClaimTrap30**. Real clinical free-text is absent, so DPO would operate on
**structured artifacts** (the same modality as the controller), optionally with neutralized templated captions.

## Why not DPO-ready now
1. **No preference pairs.** The only preference-shaped data (generic over-claim vs calibrated, in `runs/*`) is
   on ClaimTrap30 → using it for DPO would **contaminate the held-out test** (FORBIDDEN).
2. **No realistic clinical text.** Only templated captions exist; a "clinical-note DPO" is not viable.
3. **Generation gate.** Building pairs requires LLM calls + human verification, currently paused.
4. **Provenance gaps.** Amyloid labels are LABEL_UNVERIFIED for NACC/AJU/KDRC; AJU raw has PHI/temporal risk.

## DPO source data that DOES exist (to generate pairs from)
- **Canonical manifest, ClaimTrap-disjoint rows** (≫ thousands of sessions across ADNI/NACC/AIBL/OASIS/AJU/KDRC):
  synthesize neutral artifacts → `rejected` (over-claim) vs `preferred` (calibrated at ceiling) using the E1–E8
  taxonomy + L0–L3 ceilings already defined.
- **Korean structured** (`korean_clinical_subject_level.csv`): Korean-cohort artifacts → Korean preference
  pairs / cross-population stress.
- **AJU raw** (`aju_final_v2_3841.csv`): per-visit dx + visit dates → **temporal over-claim (E3)** pairs
  (rejected = "predicts/longitudinal" vs preferred = cross-sectional caveat) — AFTER PHI strip + temporal control.

## Preference-pair schema (target)
```
input:    neutral structured artifact + neutral metadata + task instruction   (NO gold, NO target-proximal dx phrase)
rejected: unsupported biomarker / temporal / label-provenance / shortcut / causal / transportability over-claim
preferred: calibrated claim respecting the computed claim ceiling, with required caveats, no unsupported wording
```
The Claim Safety Controller already produces both poles deterministically-guided (generic propose = candidate;
controller final = calibrated) — so the **controller can be the pair generator on the disjoint pool**, with
human verification. This connects controller and preference learning (Q7).

## Q-answers
- **Q1 — most promising clinical text for DPO**: none as *text*. The most promising **source** is the canonical
  structured manifest (ClaimTrap-disjoint rows); among clinical-text assets, only the templated Korean captions,
  and only as neutralized inputs.
- **Q4 — train/eval split with ClaimTrap30 held out**: ClaimTrap30 (30 cases: 10 OASIS-derived seeds + 20
  probes) = **frozen TEST**. Train/val = a **disjoint** artifact pool drawn from manifest rows that are NOT the
  OASIS seeds and do NOT reuse the probe constructions. Enforce subject-level disjointness (no OASIS subject
  used in a ClaimTrap seed may appear in train). Add a leakage scan asserting zero overlap of (subject_id,
  artifact-construction) between train and ClaimTrap30.
- **Q5 — how many pairs / feasibility**: DPO on a narrow, well-specified behavior (claim-ceiling calibration)
  typically needs **~500–2,000 verified preference pairs** to move behavior without overfitting [VERIFY: cite a
  DPO sample-size study before use]. Feasible to generate from the disjoint manifest pool (thousands of source
  rows), but each pair needs human/structured verification → realistic first batch ≈ **300–500 pairs**, scaling
  if it helps. Not feasible *today* (generation paused, pool not defined).
- **Q6 — data cleaning BEFORE DPO**: (1) define ClaimTrap-disjoint pool + subject-level disjointness scan;
  (2) AJU PHI strip + temporal-leakage control; (3) KDRC `데이터` parse + amyloid threshold lock; (4) neutralize
  label-proximal phrasing; (5) per-cohort amyloid label provenance lock (NACC/AJU/KDRC).
- **Q7 — connect controller + preference learning**: use the controller as the **pair generator/labeler** on the
  disjoint pool (propose=over-claim pole, controller-final=preferred pole), human-verify, then DPO-train a model
  to internalize ceiling-respecting calibration — evaluated on the untouched ClaimTrap30 + the controller as a
  baseline. This keeps ClaimTrap30 held-out and turns the inference-time controller into training signal.

## Minimum conditions before DPO
1. ClaimTrap30 frozen as test; subject-level-disjoint train pool defined + leakage scan = 0.
2. AJU/KDRC provenance + PHI/temporal audits done (see LEAKAGE_AND_TEMPORAL_RISK_REPORT.md).
3. ≥300 human-verified preference pairs from the disjoint pool.
4. A held-out-contamination check before any training run.

## Standing prohibitions (unchanged)
ClaimTrap30 NEVER in train. No raw clinical text to external APIs. No PHI in artifacts. DPO/SFT not started.
