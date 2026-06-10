# TASKS

## 2026-05-27 — Gate04d KDRC transfer diagnostic

### Current goal
- Implement and run `vlm_gate_04d_kdrc_transfer_diagnostic_v0` to localize why KDRC Teacher-S signal does not stably transfer into the T1w-only student representation.

### Task packet
- Goal: Diagnose whether the KDRC failure sits mainly in the predicted ROI head, the global CLS/frozen embedding, or both, using the existing Gate04c KDRC seed 42/43/44 checkpoints.
- Inputs:
  - Features CSV: `experiments/voxelwise_feature_learning_v1/results/baseline_03_roi_summary_logreg_cn_vs_ad/features.csv`
  - Source run root: `experiments/voxelwise_feature_learning_v1/results/vlm_gate_04c_kdrc_reproducibility_v0`
  - Seeds: `42`, `43`, `44`
  - Variant: `ce0.1_plus_teacher_kl`
  - Cohort: `KDRC` only
- Files to change:
  - Create: `experiments/voxelwise_feature_learning_v1/scripts/vlm_gate_04d_kdrc_transfer_diagnostic_v0.py`
  - Create: `experiments/voxelwise_feature_learning_v1/results/vlm_gate_04d_kdrc_transfer_diagnostic_v0/*`
  - Update: `docs/context/TASKS.md`
  - Update: `docs/context/VALIDATION_LOG.md`
  - Create/update Korean note under `/home/vlm/minyoung/Official/sky/`
- Outputs:
  - `diagnostic_summary.csv`
  - `row_level_diagnostics.csv`
  - class-wise cosine summary and figure
  - seed-level embedding projection figure(s)
  - `REPORT_KO.md`
- Assumptions:
  - Gate04c KDRC seed directories contain compatible `teacher_s_model.pt`, variant checkpoint, and summary JSON.
  - CPU-only inference is sufficient and preferred.
  - Logistic probe evaluation on train rows -> heldout KDRC rows remains the correct transfer readout for frozen/predicted-ROI comparisons.
- Steps:
  1. Reuse Gate03/Gate02 loader and model code; do not re-invent data contract.
  2. Load KDRC-only heldout rows and the corresponding train rows from the same global features CSV.
  3. For each seed, compute 5-way diagnostics: true ROI teacher, predicted ROI probe, frozen probe, direct head, teacher-vs-student row agreement.
  4. Add teacher confidence band analysis and CN/AD cosine alignment split.
  5. Add embedding projection for one representative seed.
  6. Write a Korean report that explicitly classifies the result into Path A/B/C or mixed.
- Validation:
  - Confirm row counts match KDRC heldout summary (`n_test=581`) for each seed.
  - Confirm train/test subject and path overlap remain zero.
  - Confirm seed 42/43/44 frozen AUCs from the diagnostic script reproduce the source summaries within floating-point tolerance.
  - Confirm artifacts exist and report references actual numeric outputs.
- Done when:
  - Script runs end-to-end on CPU for seeds 42/43/44 and writes all required artifacts.
  - Report states a defensible next-step decision grounded in the produced diagnostics.
- Needs Min approval:
  - None for CPU-only read-only diagnostic execution.

### Status
- In progress
- Scope fixed to KDRC-only Gate04c reproducibility checkpoints before any architectural change.
