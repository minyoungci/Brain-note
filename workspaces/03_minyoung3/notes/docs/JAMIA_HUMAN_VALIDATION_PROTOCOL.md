# Human-Validation Protocol — ClaimTrap-AD auto-gold labels

**Manuscript:** ClaimTrap-AD: A Replication-Grounded Benchmark for Claim Calibration in Medical Research Agents (*JAMIA — Research and Applications*)
**Role in paper:** Supplementary methods (planned **S5**) + the gating step before submission (main-text Limitations).

> **STATUS (2026-06-29): design LOCKED; labeling NOT yet performed.** This document pre-registers the procedure and the decision rules *before* any label is collected. No agreement number is reported until the MD co-author has actually labeled the blinded sheet; results will be reported exactly as observed, including disagreement. **Nothing in the manuscript may state a completed agreement figure until this protocol has been executed.**

---

## 1. Purpose and construct

The scaled ClaimTrap-AD labels are **auto-gold**: a non-planted finding is labeled *real* iff its unseen gold-cohort AUROC exceeds 0.60, and *artifact* otherwise; planted controls retain their constructed design label. Auto-gold has internal reliability evidence (threshold robustness 70.1%, cross-cohort unanimity 77.1%, convergent validity; see Supplement S2.2) but **no independent human-expert sign-off**. This protocol tests whether a blinded, clinically qualified expert, judging the same statistical evidence, reaches the same real/artifact verdict and ordinal ceiling as the auto-gold rule.

**Pre-registered hypotheses.**
- H1 (label validity): human real/artifact verdicts agree with auto-gold labels above a substantial threshold (Gwet AC1 ≥ 0.60).
- H2 (anchor sanity): on planted controls (objective constructed truth), both the human and auto-gold achieve high accuracy (≥ 0.90), confirming that the blinded evidence presentation is sufficient for the task.
- H3 (convergence): a strong non-subject LLM rater, given the identical blinded sheet, agrees with the human verdict at a level consistent with auto-gold (reported, not thresholded).

A negative or partial result is an acceptable, reportable outcome: if H1 fails, the auto-gold operationalization is revised or its limits are stated explicitly in the manuscript — the label is **not** adjusted to match a desired conclusion.

**Structural limitation (state in the manuscript regardless of outcome).** Non-planted cases have no ground truth independent of the cohort AUROCs; the human and auto-gold are two aggregations of the same evidence. The auto-gold label privileges one *designated* held-out gold cohort, whereas a blinded expert weighs all cohorts. They therefore diverge by construction in the hard strata (a finding that replicates in discovery and the tool cohort but not the gold cohort). Consequently, human validation can **confirm the planted objective-truth anchors and unambiguous cases** but **cannot independently re-adjudicate non-planted hard-artifact labels**. Agreement is therefore reported **separately for planted anchors and for each non-planted stratum** (§6), and the non-planted figures are read as a calibration of the labeling rule, not as an external oracle.

---

## 2. Validation subset (clean 120 unique)

The subset was rebuilt from the already-built benchmark JSONL by `scripts/build_human_validation_subset.py` (it does **not** re-run the benchmark, so no case_id or metric changes). This fixes a defect in the original export (`human_validation_subset.json`), which concatenated `HARD_artifact[:80] + planted_univar[:40]` and, because 20 planted cases were also hard-artifact, yielded only **100 unique** cases covering **2 of 4** endpoints. The corrected subset is a clean **120 unique** cases, stratified across all four diagnostic endpoints.

**Composition (verified output of the build script; `human_validation_120_composition.md`):**

| | planted (objective anchor) | nat. hard-artifact | nat. hard-real | endpoint total |
|---|--:|--:|--:|--:|
| CN_AD | 15 | 7 | 8 | 30 |
| CN_MCI | 15 | 9 | 6 | 30 |
| MCI_AD | 15 | 9 | 6 | 30 |
| CNMCI_AD | 15 | 9 | 6 | 30 |
| **total** | **60** | **34** | **26** | **120** |

- Ground truth: 66 artifact / 54 real (planted anchors: 32 artifact / 28 real).
- Ordinal ceilings: L0 69 / L1 38 / L2 13.
- **planted** = constructed objective-truth anchors; **nat. hard-artifact** = non-planted high-discovery / failed-replication traps (the stratum where auto-gold is most consequential); **nat. hard-real** = non-planted weak-real cases (tests over-rejection).

**Files (in `outputs/agent_benchmark/claimtrap_scaled/`):**
- `human_validation_subset_120.json` — canonical list of 120 unique case_ids.
- `human_validation_120_blinded.csv` — the **rater's working file** (evidence only; see §4).
- `human_validation_120_key.csv` — **held-out answer key** (blind_id → case_id, ground_truth, gold_ceiling, difficulty, kind, pool, finding). Not opened until labeling is complete.
- `human_validation_120_composition.md` — composition report.

---

## 3. Rater(s)

- **Primary rater:** the study's clinically qualified (MD) co-author, performing the labeling **directly** (this resolves the rater-feasibility question; an independent recruited MD is *not* required for the primary analysis).
- **Optional second rater:** an independent MD may be added on the identical blinded sheet to obtain human–human inter-rater agreement; if added, human–human Gwet AC1 is reported as a secondary metric. The primary analysis does not depend on this.
- **Convergence rater (automated):** a strong LLM that is **not** one of the evaluated subjects — explicitly **not Qwen3-32B and not MedGemma-27B** (using a tested subject as the rater would be circular). The exact model/version is recorded at run time `[TODO: record model id + version]`.

---

## 4. Blinding design (what the rater sees)

The rater works only from `human_validation_120_blinded.csv`, in randomized order (fixed seed 42), with these columns and **no answer fields**:

`blind_id, modality, endpoint, discovery_auroc, heldout_cohort_A_auroc, heldout_cohort_B_auroc, covariate_incremental_auroc, cohort_A, cohort_B, rater_label, rater_ceiling, rater_notes`

Three blinding rules are enforced by the build script and were leakage-scanned (0 leak tokens):
1. **Finding identity is withheld.** The raw `finding` is dropped because planted names encode the answer (`plant_p_*` = real, `plant_n_*` = artifact, `_d#` = effect size). All cases are presented uniformly as `univariate association` or `multivariate model`, so the rater cannot tell planted from natural cases.
2. **The oracle signal is not flagged.** The gold-cohort AUROC that *defines* the auto-gold label (`gt_auc`) is shown only as `heldout_cohort_B_auroc`; the rater is not told that one held-out cohort is the labeling oracle. The judgment is therefore holistic over the full evidence (discovery + two held-out cohorts + covariate increment) rather than a trivial re-application of the >0.60 rule — this is what makes the agreement informative rather than circular.
3. **No stratum / design metadata.** `difficulty`, `kind`, `ground_truth`, `gold_ceiling`, and `pool` never appear in the rater file.

---

## 5. Labeling task

For each `blind_id`, the rater fills three fields from the statistical evidence and clinical judgment:
- `rater_label` ∈ {`real`, `artifact`} — does this association reflect a genuine, generalizable effect, or a discovery-set artifact that does not replicate out-of-cohort?
- `rater_ceiling` ∈ {`L0`, `L1`, `L2`} — strongest defensible claim: L0 = no defensible claim / does not replicate; L1 = within-cohort association; L2 = internal predictive validity. (L1.5/L3 collapse into this scaled scheme, matching the scaled benchmark.)
- `rater_notes` — optional one-line rationale (used only for disagreement adjudication).

The rater may also record per-case confidence `[TODO: add confidence column if desired]`. No time limit; cases may be reviewed in any order within the fixed sheet.

---

## 6. Metrics

Computed by an analysis script (`scripts/analyze_human_validation.py` `[TODO: write after labels exist]`) that joins the rater file to the held-out key by `blind_id`.

**Primary**
- **Gwet AC1** (human verdict vs auto-gold label) over all 120 cases — chosen over Cohen's κ because of class-prevalence skew. Reported with 95% CI.

**Secondary**
- Raw percent agreement (human vs auto-gold), overall and by stratum (planted / nat. hard-artifact / nat. hard-real) and by endpoint.
- **Planted-anchor accuracy** (objective truth): human accuracy and auto-gold accuracy on the 60 planted controls (H2 sanity check).
- **Ordinal-ceiling agreement:** quadratic-weighted κ (human vs auto-gold ceiling).
- **Convergence:** Gwet AC1 of human vs LLM rater, and auto-gold vs LLM rater (H3).
- If a second MD is added: human–human Gwet AC1.

---

## 7. Pre-registered decision rules (set before unblinding)

| Primary AC1 (human vs auto-gold) | Interpretation | Action |
|---|---|---|
| ≥ 0.60 | substantial agreement | auto-gold labels reported as expert-validated |
| 0.40–0.60 | moderate | reported as a stated reliability limitation; manuscript tone unchanged (benchmark already framed honest-negative) |
| < 0.40 | poor | auto-gold operationalization revisited (e.g., threshold, near-boundary handling) and the failure reported; no claim of validated labels |

- If planted-anchor accuracy (H2) is < 0.90 for the human, the evidence-presentation/instructions are reviewed before interpreting H1 (a low anchor score would indicate the blinded sheet is under-informative, not that auto-gold is wrong).
- All thresholds are fixed here, before any label is collected.

---

## 8. Disagreement adjudication

Human↔auto-gold disagreements are listed (blind_id, evidence, human verdict + note, auto-gold) and reviewed after metrics are computed. For planted cases, the objective truth arbitrates. Adjudication outcomes are recorded but do **not** retroactively change the pre-registered primary AC1.

---

## 9. Integrity statement

- The rater is blinded; the answer key is held out until labeling is complete.
- The convergence LLM rater is **not** a tested subject (not Qwen3-32B / MedGemma-27B).
- Results are reported as observed. No agreement figure is written into the manuscript until this protocol is executed on real labels; numbers are never inferred or back-filled.
- This protocol, the build script, the blinded sheet, the key, and the (future) analysis script and results are released with the benchmark artifacts.

---

## 10. Reporting in the manuscript (after execution)

On completion, replace the Limitations "human-validation pending" language with the observed AC1 (95% CI), planted-anchor accuracy, and convergence figures, and add the completed analysis to Supplement S2.2 / S5. Until then, the manuscript states that the protocol is **prespecified and pending** and that scaled labels are auto-gold with reliability checks only.

---

## 11. Methods dry-run (completed 2026-06-29 — LLM panel, NOT human; internal only)

Before requesting MD time, the full pipeline was rehearsed with LLM panels (Sonnet-4.6) labeling the identical blinded sheet: first a 3-persona panel (conservative biostatistician, AD neuroimaging researcher, translational skeptic), then a 5 medical-expert ensemble (behavioral neurologist, neuroradiologist, geriatric psychiatrist, clinical epidemiologist/biostatistician, translational biomarker scientist) — 8 LLM raters total. Purpose: validate the pipeline and pressure-test the design. Outcome (directional only; **not** reported as human validation, **not** in the manuscript): the panels scored 95–100% on the planted objective-truth anchors (presentation/pipeline sound), but agreement with auto-gold was concentrated by stratum — high on planted (AC1 0.97; 5-expert 1.00) and hard-real (0.71; 5-expert 1.00), and strongly negative on non-planted hard-artifact (AC1 −0.74 for the 3-persona panel, −0.81 for the 5-expert ensemble; inter-rater AC1 0.93–1.00), exactly the structural divergence in §1. This is why the structural-limitation language and per-stratum reporting were added. Artifacts: `human_validation_LLM_DRYRUN_report.md`, `human_validation_LLM_ENSEMBLE_5expert_report.md`, `..._8rater_report.md`, `..._INTERPRETATION.md`, `rater_R{1,2,3}_LLM_DRYRUN.json`, `rater_M{1..5}_LLM_ENSEMBLE.json`. The real MD labeling supersedes this dry-run for any reported result.

*End of human-validation protocol.*
