# Supplementary File S2 — ClaimTrap-AD

**Manuscript:** ClaimTrap-AD: A Replication-Grounded Benchmark for Claim Calibration in Medical Research Agents
**Target:** *JAMIA — Research and Applications*
**Scope of this file:** (S2.1) the Claim Safety Controller — a deterministic inference-time control method evaluated as a rewrite controller on fixed generic drafts, reported here rather than in the main comparison; (S2.2) the full auto-gold label-reliability procedure summarized in Methods; (S2.3) direct-question decoding and parsing detail.

> **Status:** draft pending completion of human validation (see main-text Limitations). All numbers below are reproduced from committed run artifacts; `[VERIFY]` marks items to confirm against the released archive before submission.

---

## S2.1 Claim Safety Controller (CSC)

### S2.1.1 Why it is reported separately

In the pilot, checklist prompting reduced open-ended over-claiming (19/90 → 3/90) but left a recurrent, case-specific failure on the incremental-value trap (e2_03, over-claimed in 3/3 repeats; main text, Table 1). The Claim Safety Controller was built to test whether moving the safety decision **out of the prompt and into deterministic code** removes that residual failure.

Crucially, in the evaluated configuration the controller did **not** generate claims independently: its proposed claim was the **fixed generic draft** from a locked generic run (`propose = reused locked generic n=1`), and only the rewrite step was re-sampled (temperature 1.0, three repeats). The protocol therefore measures **rewrite stability** on a fixed set of drafts, not independent generation under a third condition. Because the generic and checklist arms in the main pilot were generated independently, the controller is **not** a controlled third arm and is excluded from the main Table 1 comparison; it is reported here as a mechanism study. This is also why no claim of the form "the controller outperforms checklist prompting" is made anywhere in the manuscript — on completeness it does not (S2.1.6).

### S2.1.2 Mechanism

The controller separates an LLM *component* role (propose / extract / constrained rewrite) from a deterministic *safety* role (verify / compute ceiling / detect over-claim / enforce). For a generation-view artifact $A$, a global verifier schema $V$, and global rewrite rules $R$:

1. `proposed ← LLM_propose(A)` — in this evaluation, the fixed generic draft (component).
2. `E ← LLM_extract(A)` — structured evidence units under a fixed extraction schema (component).
3. `F ← ⋃ m(E)` over verifier modules `m ∈ {E1…E8}` — **deterministic** pure functions of `E`.
4. `L* ← min(ceiling_cap)` over all triggered modules — **deterministic** ceiling.
5. `L_prop ← ClaimLevelOf(proposed, E)` — conservative parser of the level implied by the wording.
6. `overclaim ← (L_prop > L*) OR contains_forbidden_pattern(proposed, F)` — **deterministic** detector.
7. if `overclaim`: `C* ← LLM_rewrite(proposed, ceiling=L*, F, R)`; then `C* ← enforce(C*, L*, F)` (post-check; if still `> L*`, fall back to a templated claim). else `C* ← proposed`.
8. `K ← completeness_gaps(F, C*)` — **deterministic** required-caveat check.
9–10. Emit `C*`, `L*`, safety flags, completeness flags, and a full audit trace `T`.

Steps 3, 4, 6, 8 and the `enforce` fallback are deterministic code; steps 1, 2, 7 use the LLM under structural constraints (extraction schema; rewrite bounded by the computed ceiling). Ceiling ordering is L0 < L1 < L1.5 < L2 < L3 by restrictiveness (L1.5 = within-cohort association with a mandatory negative-increment caveat).

**Confidence-tiered routing (v4, frozen).** *high* (an explicit forbidden phrase of a fired verifier) → hard reject / rewrite / fallback; *medium* (a verifier fired, no explicit forbidden phrase) → soft completeness-preserving rewrite; *low* (no verifier fired, surface cue only) → soft rewrite; *clean* (no verifier, no cue) → passthrough. L0 ceilings are hard-blocked; L1+ ceilings use semantic-preserving rewrite. The strict post-check (`enforce_strict`) hard-fails only on (a) global high-risk phrases and (b) the forbidden patterns of verifiers that actually fired, and is negation-aware (so a calibrated negation such as "not a robust biomarker" is not treated as an over-claim).

### S2.1.3 Verifier modules (E1–E8; pure functions of the evidence units, global thresholds)

| Module | Trigger condition | Effect |
|---|---|---|
| **E1** covariate-baseline | ROI-only present, covariate-only baseline absent | flag; require baseline; cap ceiling |
| **E2** incremental value | small ΔAUROC with high feature/subject ratio or no nested CV, and no paired ΔCI/bootstrap excluding 0 | ceiling ≤ L1.5; forbid positive-increment wording (the e2_03 target) |
| **E3** temporal | cross-sectional or window-matched design, or subject-level split on a single timepoint | forbid prediction/longitudinal wording; ceiling ≤ L1 |
| **E4** label-provenance | label undocumented / surrogate / multi-tracer-one-cutoff | ceiling L0 (undocumented) or L1 (surrogate-with-caveat); forbid "ground-truth/clean label" |
| **E5** transportability | no external/leave-one-cohort-out, or pooled with heterogeneous base rates | forbid generalization/transport; ceiling ≤ L1 (L0 if base-rate inflation blocks the claim) |
| **E6** causal | cross-sectional design | forbid causal/mechanistic/directional wording |
| **E7** shortcut / negative-control | site/vendor-only AUROC near chance → "bounds measured axis only"; above chance → "shortcut plausible" | forbid "ruled out / genuine signal" |
| **E8** biomarker | within-cohort only, no calibration/DCA, no external validation | forbid deployable-biomarker wording |

Each module returns `{flag, ceiling_cap, forbidden_patterns, required_caveats}`; all thresholds are global configuration, not per-case.

### S2.1.4 Dual-view constraint

The controller never receives scoring-view (judge-only) fields — gold claim level, allowed claim, forbidden phrases, required checks, primary error type, or adjudication metadata. Allowed inputs are the generation view plus the global verifier schema, global claim-level definitions, and global rewrite rules, all identical for every case. This is enforced by reusing the benchmark's blinding guard plus a controller-side assertion that its inputs are a subset of `generation_view ∪ global schema`; the dry-run blinding check reported zero gold leakage, and the audit traces contain no gold fields. `[VERIFY: confirm leakage-scan artifact in the released archive.]`

### S2.1.5 Extraction scope (structured artifacts only)

For ClaimTrap-AD, the artifacts are structured key-value records, so evidence extraction is **schema-deterministic**, not learned: 30/30 pilot cases parsed (parse status OK), zero runtime gold leakage, and all required sanity cases fired. Deterministic-rule coverage is **partial**: 22/30 cases trigger at least one verifier; non-triggering cases fall through to the proposed claim, so the deterministic modules are not claimed to catch every over-claim by rule alone — the LLM judge and human spot-check remain the safety net. Free-text extraction over arbitrary biomedical reports is explicitly **not** claimed and would require a separate extraction-accuracy benchmark (future work).

### S2.1.6 Results (v4, frozen; n = 3 over 30 pilot cases = 90 outputs)

The controller was frozen at version 4 (precision routing on; L0 hard-block / L1+ soft rewrite). Decoding for the rewrite step used temperature 1.0; the proposed drafts were fixed. Pooled over 90 outputs:

| Metric | Controller (v4) | Context (main pilot, n=3) |
|---|---:|---|
| Over-claims | **0/90** | generic 19/90; checklist 3/90 |
| Hard-fails | **0/90** | generic 14/90; checklist 1/90 |
| Strict-enforce fallbacks | 0/90 | — |
| Mean completeness (0–3) | **1.878** | generic 1.678; checklist 2.622 |
| Harmful over-suppression / 30 | ~15 (per-repeat 14/15/15; mean 14.67) | — |

Per-repeat completeness was 1.933 / 1.900 / 1.800; the action tally over 90 outputs was accept 31, soft-rewrite 39, fallback 11, L0-block 9 (72 LLM calls for the rewrite/enforce step, i.e. more than one call on some fallback cases; rewrite cost ≈ US$0.46). Across all three repeats the targeted-stability checks passed: e2_03 stayed safe (over-claim False in 3/3), the L0 case e4_04 routed to `l0_block` and was over-claim-free 3/3 (closing a v3 n=3 gap where e4_04 over-claimed 2/3), and no `fallback_strict` fired anywhere.

**Human spot-check.** In the locked full-30 pre-fix adjudication, all 30 cases were upheld against the LLM judge (`ACCEPT_JUDGE`); all 7 generic over-claims were fixed (including e2_03 via the deterministic E2 cap), but the detector was high-recall / low-precision — 20/30 interventions were not safety-required (14 harmful over-suppressions + 6 benign) and 3 were false interventions in which no verifier fired yet a fallback occurred. For v4, the 10 targeted cases were all human-confirmed `ACCEPT_JUDGE` with human over-claim = false (e4_04 = valid safety fix / appropriate L0 block).

### S2.1.7 Interpretation (locked)

The Claim Safety Controller converts prompt-level verification into ceiling-dependent inference-time control and, in this rewrite-stability setting, removed all observed over-claims (0/90) — including on the residual incremental-value trap that checklist prompting cannot — but it operated on fixed generic drafts rather than generating independently, and persistent over-suppression (~15/30) shows that claim safety and claim completeness remain in tension. Its mean completeness (1.878) stayed below the checklist prompt's (2.622 in the main pilot; 2.57 in the locked source run that supplied the controller's drafts), so the controller did **not** recover completeness. We therefore report it as a partial, honest-negative result — a deterministic control that achieves over-claim-free behavior at a measurable completeness cost — and not as a method that closes the calibration gap. The pre-registered weak link is evidence extraction: if the structured artifact is mis-parsed, the deterministic rules receive bad inputs; this is bounded here only because extraction is schema-deterministic on structured artifacts.

---

## S2.2 Full auto-gold label-reliability procedure

Auto-gold labels for the scaled benchmark were assigned from the unseen gold-cohort AUROC (real if > 0.60 for non-planted findings; planted controls retained their design label). Reliability was assessed on the 2,660 non-planted cases with a gold-cohort AUROC, in three consistency analyses plus a human-validation export.

**(1) Threshold robustness.** Labels were recomputed as the real/artifact cut varied over REAL_T ∈ {0.55, 0.58, 0.60, 0.62, 0.65}. Labels were invariant for **1,864/2,660 (70.1%)** of cases across all five thresholds; the remaining ~30% form a near-boundary zone that should not be read as equally stable.

**(2) Cross-gold-cohort agreement.** For findings evaluable under ≥2 held-out gold cohorts (**280** findings), the real/artifact verdict was **unanimous for 216/280 (77.1%)** — i.e., for most multi-cohort findings the verdict did not depend on which cohort was held out.

**(3) Internal consistency (label–signal coherence).** Gold-real and gold-artifact groups separated on every signal: gold-real (n = 1,766) had mean held-out replication AUROC 0.696, covariate-incremental AUROC 0.080, and discovery AUROC 0.699; gold-artifact (n = 894) had 0.551, 0.009, and 0.546, respectively. We do not call this "convergent validity": the replication and covariate-incremental separations are partly **definitional**, because the gold label is itself derived from an out-of-cohort AUROC correlated with these signals. Only the discovery-AUROC separation (0.699 vs 0.546) is comparatively independent of the labeling rule, and it is modest. This check therefore shows label–signal coherence, not external validation.

**(4) Human-validation subset.** A clean, stratified **120-unique-case** subset (`human_validation_subset_120.json`: 60 planted objective-truth anchors + 34 natural hard-artifact + 26 natural hard-real cases, balanced across the four endpoints) is prespecified for blinded sign-off; planted controls carry objective constructed truth as a built-in accuracy anchor. The blinded rater file withholds finding identity and does not flag which held-out cohort is the labeling oracle, so the expert verdict is holistic over the evidence rather than a re-application of the auto-gold rule (full design, pre-registered decision rules, and integrity statement in the human-validation protocol, Supplementary S5). Blinded adjudication by the clinically qualified (MD) co-author, with a strong non-subject LLM as a convergence rater, is pending; agreement will be reported with Gwet AC1 as the primary metric given the artifact-prevalence skew. `[VERIFY: human-validation completion before submission.]`

**Caveat (carried from the main text).** The replication-rule baseline and the gold label are both out-of-cohort replication estimates on disjoint cohorts and are therefore correlated; (1)–(3) test internal stability and label–signal coherence, not validation by an independent oracle.

---

## S2.3 Direct-question LLM evaluation — decoding and parsing detail

Open LLMs were evaluated as direct-question subjects on a stratified sample of the scaled benchmark (`scripts/run_agent_eval_scaled.py`): up to 120 cases per difficulty stratum at a fixed seed, yielding 480 cases; each case was run under a generic prompt and a checklist prompt, for 960 outputs per model. Of the 480 cases per arm, 234 were artifact-labeled (115 hard-artifact + 119 easy-artifact), i.e., 468 artifact outputs per model across the two arms.

**Models and decoding.** Qwen3-32B (`Qwen/Qwen3-32B`, thinking mode disabled) and MedGemma-27B (`google/medgemma-27b-it`), each decoded at **temperature 0** with a short JSON-only token budget. Each response was parsed to one of "yes" / "no" / "uncertain" for the question of whether the finding generalizes. An over-claim was defined as answering "yes" (generalizes) on an artifact (non-replicating) case.

**Ceiling-respecting default (why this is a floor, not a discrimination test).** The prompt showed discovery-side information but no out-of-cohort replication evidence. Because the claim ceiling is defined by out-of-cohort replication, affirming generalization would exceed the licensed ceiling regardless of discovery strength, so uniform refusal is ceiling-respecting. Discovery AUROC is only weakly class-informative (gold-real 0.699 vs gold-artifact 0.546), so the arm measures default stance, not whether models exploit that weak signal. (The complementary graded arm — agents shown one replication cohort and asked for a graded ceiling — is in the main text; there agents do produce graded, frequently over-claiming, behavior.)

**Results (Supplementary Table S2.3-1).** Neither model affirmed generalization for any case, so the artifact over-claim rate was 0/468 for each model in both strata (hard-artifact and easy-artifact). Declining to affirm generalization absent replication evidence is the conservative, ceiling-respecting response — the floor — so this arm is read as a ceiling-respecting floor check rather than as evidence of discrimination.

**Supplementary Table S2.3-1. Direct-question LLM stances (960 outputs per model; inputs carry no out-of-cohort replication evidence).**

| Model | Outputs | Yes | No | Uncertain | Artifact over-claims |
|---|---:|---:|---:|---:|---:|
| Qwen3-32B | 960 | 0 | 701 | 259 | 0/468 |
| MedGemma-27B | 960 | 0 | 901 | 59 | 0/468 |

---

*End of Supplementary File S2.*
