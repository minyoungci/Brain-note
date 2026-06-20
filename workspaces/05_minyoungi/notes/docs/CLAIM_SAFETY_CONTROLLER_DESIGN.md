# Claim Safety Controller (CSC) — design (Step 2.9a, design-lock; implement only after review)

## 1. Motivation
On the blind 30-case path (n=3), the GLOBAL-checklist verification agent reduced over-claims
(generic 19/90 → 3/90) but did **not** eliminate them: it failed the **incremental-value trap e2_03 at 3/3**.
A checklist in the prompt leaves the *decision* to the LLM's free-form judgment, so a strong trap still
breaks it. The CSC moves the **safety control out of the prompt and into a deterministic algorithm**: the LLM
proposes/extracts/rewrites, but the verifier checks, the claim-ceiling computation, and the over-claim
rejection are **code, not LLM judgment**. This is the difference between "we told it to be careful" and
"an algorithm that controls what claim is emitted."

## 2. Difference from checklist prompting (the novelty line)
| | checklist-prompt agent | Claim Safety Controller |
|---|---|---|
| where the verifier checks live | inside one LLM prompt (LLM decides) | **deterministic functions** over extracted evidence units |
| claim ceiling | LLM infers, may ignore | **computed** = min over all triggered risk-rules (code) |
| over-claim rejection | none (hope) | **explicit detector**: proposed-level > ceiling → reject |
| failure on e2_03 | recurs 3/3 (LLM still says "+0.04 favorable") | E2 rule HARD-CAPS ceiling at L1.5 + forbids positive-increment wording, regardless of LLM mood |
| auditability | none | full **trace** (evidence → flags → ceiling → rewrite) |
- The LLM is a *component* (claim proposer, evidence parser, constrained rewriter). The *safety logic* is the
  algorithm. Reviewer answer to "isn't this just prompt engineering?": the verifier modules + ceiling
  computation + rejection are deterministic and inspectable; the prompt cannot bypass them.

## 3. Dual-view constraint (NON-NEGOTIABLE)
The CSC must NEVER see case-specific gold (the 5-case answer-aware failure must not return).
- **Allowed inputs:** generation_view (neutral artifact) + GLOBAL verifier schema + GLOBAL claim-level
  definitions + GLOBAL rewrite rules. (All identical for every case.)
- **Forbidden inputs:** gold_allowed_claim, gold_forbidden_phrases, gold_required_checks, gold_claim_level,
  primary_error_type, reviewer/adjudication metadata. (Enforced by reusing the adapter's blinding guard +
  a controller-side assertion that its inputs ⊆ generation_view ∪ global schema.)

## 4. Algorithm
```
Algorithm 1 — Claim Safety Controller
Input:  artifact A (generation_view), global verifier schema V, global rewrite rules R
Output: final calibrated claim C*, claim_level L*, safety_flags S, completeness_flags K, trace T

1. proposed ← LLM_propose(A)                      # free-form candidate claim (component)
2. E ← LLM_extract(A)                              # structured evidence units (component, schema-constrained)
3. F ← {}                                          # verifier flags (DETERMINISTIC)
   for m in VerifierModules(V):                    # E1..E8 modules, pure functions of E
       F ← F ∪ m(E)
4. L* ← CeilingEstimator(F)                        # = min ceiling over all triggered risk-rules (DETERMINISTIC)
5. L_prop ← ClaimLevelOf(proposed, E)              # level implied by the proposed wording (parser; conservative)
6. overclaim ← (L_prop > L*) OR contains_forbidden_pattern(proposed, F)   # DETERMINISTIC detector
7. if overclaim:
       C* ← LLM_rewrite(proposed, ceiling=L*, triggered=F, R)   # constrained rewrite at/below L*
       C* ← enforce(C*, L*, F)                     # post-check; if still > L*, fall back to a templated claim
   else:
       C* ← proposed
8. K ← completeness_gaps(F, C*)                    # required caveats present? (DETERMINISTIC)
9. T ← {proposed, E, F, L*, L_prop, overclaim, rewrite_action, C*}
10. return C*, L*, safety_flags=F_safety(F), completeness_flags=K, trace=T
```
- Steps 3, 4, 6, 8, and the `enforce` fallback are deterministic code. Steps 1, 2, 7 use the LLM but under
  structural constraints (extraction schema; rewrite bounded by the computed ceiling).

## 5. Verifier modules (E1–E8; pure functions of evidence units E)
- **E1 covariate-baseline**: if roi_only present but covariate_only absent → flag E1; require baseline.
- **E2 incremental** (the e2_03 target): if Δ small (|Δ|≤τ_Δ) AND (features/subjects ≥ τ_pn OR no nested CV)
  AND no paired ΔCI/bootstrap excluding 0 → flag `E2_increment_unreliable`, ceiling ≤ **L1.5**, forbid
  positive-increment wording.
- **E3 temporal**: if design ∈ {cross-sectional, window-matched} or split=subject-level on single-timepoint
  → forbid prediction/longitudinal wording; ceiling ≤ L1.
- **E4 label-provenance**: if label undocumented/surrogate/multi-tracer-one-cutoff → ceiling L0 (undocumented)
  or L1 (surrogate-with-caveat); forbid "canonical/ground-truth/clean label".
- **E5 transportability**: if no external/LOCO OR pooled with heterogeneous base rates → forbid
  generalization/transport; ceiling ≤ L1 (or L0 if pooled-base-rate-inflation blocks the claim).
- **E6 causal**: if cross-sectional → forbid causal/mechanistic/directional wording.
- **E7 shortcut/NC**: if site/vendor-only AUROC ≈ chance → "bounds measured axis only" (not "ruled out"); if
  above-chance (CI excludes 0.5) → "shortcut plausible, cannot dismiss". forbid "ruled out / genuine signal".
- **E8 biomarker**: if within-cohort only / no calibration-DCA / no external → forbid deployable-biomarker.
Each module returns: {flag, ceiling_cap, forbidden_patterns, required_caveats}. All thresholds are GLOBAL
config, NOT per-case.

## 6. Claim-ceiling rules
`L* = min(ceiling_cap over all triggered modules)`; default L1 if an association is supportable, L0 if the
endpoint/label is unverifiable. (L0<L1<L1.5<L2<L3 by restrictiveness; L1.5 = association + mandatory
negative-increment caveat.)

## 7. Rewrite rules (controlled, examples)
- "predicts amyloid pathology" → "shows a within-cohort association with the cohort-specific amyloid label"
- "rules out scanner confounding" → "does not support a simple measured-site-label shortcut; latent
  feature-level site effects remain possible"
- "+0.04 is a favorable increment" → "the apparent +0.04 gain is not credible incremental value without
  nested/held-out validation"
- "the pooled model is more accurate" → "the pooled AUROC gain is consistent with base-rate inflation, not
  demonstrated transportability"

## 8. Audit trace schema (per case)
```json
{"case_id":"e2_incremental_overclaim_03",
 "proposed_claim":"... +0.04 positive increment ...",
 "evidence_units":{"delta_auroc":0.04,"n_subjects":300,"n_features":40,"nested_cv":false,"paired_delta_ci":null},
 "verifier_flags":["E2_increment_unreliable"],
 "estimated_claim_ceiling":"L1.5","proposed_claim_level":"L2","overclaim_detected":true,
 "rewrite_action":"downgrade_incremental_claim",
 "final_claim":"The apparent +0.04 AUROC gain should not be interpreted as credible incremental value without nested validation.",
 "completeness_flags":[]}
```

## 9. Primary success criterion
On ClaimTrap30 blind: **checklist-prompt fails e2_03 (3/3); the controller must NOT emit a positive-increment
claim on e2_03** (and must not regress on the cases checklist already handles, e.g. e7_01/e7_02/e5_02 stay 0).

## 10. Pre-registered risks / honest limits
- **Evidence extraction is the weak link**: if `LLM_extract` mis-parses the artifact, deterministic rules get
  bad inputs → must measure extraction accuracy (vs hand-labeled evidence units) and report it.
- The rewriter could over-suppress (emit L0 when L1 is allowed) → measure over-suppression (false downgrades).
- The controller is still validated by an LLM judge + human spot-check (same blind protocol).
- This is an inference-time control method, NOT learning; DPO/SFT is a later step (separate corpus, never
  trained on the locked benchmark).

## 11. Two extraction tracks (claim scope) — implemented decision
- **Track A — structured artifacts (THIS paper's claim).** ClaimTrap30 `input_artifacts` are structured
  key-value records, so extraction is **schema-deterministic** (`src/controllers/evidence_extractor.py`),
  not learned. We therefore evaluate **schema coverage + parser correctness + verifier-trigger readiness**,
  NOT free-text extraction accuracy. Allowed wording: *"the controller operates on structured biomedical
  analysis artifacts; for ClaimTrap-AD, evidence extraction is deterministic."*
- **Track B — free-text reports (future work, NOT claimed).** Arbitrary free-text would need an LLM extractor
  + a separate extraction-accuracy benchmark. Forbidden wording: *"robustly parses arbitrary free-text
  biomedical reports."*
- **Implemented audit (Step 3, NO LLM):** 30/30 parsed (parse_status OK 30/30), runtime gold-leakage 0,
  all 6 required sanity cases fire correctly. **Deterministic-rule coverage is partial: 22/30 cases trigger
  ≥1 verifier** — the deterministic modules cover the main failure modes but not every trap variant (e.g.
  window cherry-picking, some E3/E4 variants). Non-triggering cases fall through to the proposed claim, so
  the controller does NOT claim to catch every over-claim by rules alone; the LLM judge + human spot-check
  remain the safety net. (artifacts: outputs/controllers/evidence_extraction_report.md)
