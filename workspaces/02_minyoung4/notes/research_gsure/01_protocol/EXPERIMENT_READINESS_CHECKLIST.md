# Experiment Readiness Checklist

## Research Goal

G-SURE: 3D glioma MRI segmentation as visual grounding and reliability
estimation, not Dice-only segmentation tuning.

Primary first target:

```text
binary whole-lesion / whole-tumor = selected_mask > 0
```

Primary cohort draft:

```text
one selected unit per subject
```

## Current Evidence Status

| area | status | evidence |
|---|---|---|
| data inventory | done | 25,342 NIfTI files inventoried |
| mask taxonomy path audit | done | 3,673 candidate segmentation files |
| mask values and geometry | done | 3,672 / 3,673 masks loaded; geometry issues localized |
| target mapping | draft-ready | binary `selected_mask > 0`; UTSW FeTS-only primary |
| unit-level manifest | draft-ready | 2,070 valid unit candidates |
| subject-level manifest | draft-ready | 1,614 selected subject rows |
| split readiness | done | no subject overlap or secondary-unit leakage in LOCO readiness audit |
| split builder | done | `build_loco_split_manifest.py --write` created 6,456 official fold rows |
| split approval packet | used | Min explicitly approved official split creation |
| split manifest | created | `loco_split_manifest.csv`, `loco_split_summary.csv`, and `loco_split_audit_report.md` exist |
| preprocessing | not created | requires split/cohort lock |
| loader smoke contract | ready | post-split CPU smoke command documented |
| loader/inference policy | draft-ready | RAS canonicalization and full-volume inference policy documented |
| loader transform feasibility | sample-audited | `160x192x160` passes expanded-sample bbox extent but not fixed-center; not locked |
| sliding-window coverage | sample-audited | full-volume coverage passes on quantile20 sample; not accuracy evidence |
| tile budget | official-split audited | `160x192x160@0.50` vs `192x224x160@0.50` evaluated on official LOCO test rows |
| tile grid dry-run | official-split audited | both GPU-preview candidates have 0 coverage failures over 1,614 official test-role rows |
| GPU preview contract | draft-ready | feasibility/memory preview requirements documented |
| B1 GPU preview template | draft-ready | command approval fields and disallowed outputs documented |
| baseline protocol | draft-ready | detailed pre-GPU B1 protocol documented |
| reliability metric contract | draft-ready | ERR/FP/FN, top-k, calibration, QU-BraTS-style metrics documented |
| timing-warning sensitivity contract | draft-ready | keep-all primary split requires no-warning and UCSD high-risk subgroup sensitivity before final claims |
| uncertainty/QC baseline contract | draft-ready | DeVries/QCResUNet/QU-BraTS requirements documented |
| inner-OOF QC label schedule | draft-ready | leakage-safe schedule for Q1/Q2/Q3 train labels documented |
| OOF prediction contract | draft-ready | prediction/reliability manifest requirements documented |
| OOF prediction validator | metadata-only ready | schema/provenance validator self-test passes |
| inner-OOF prediction validator | metadata-only ready | inner-fold provenance validator self-test passes |
| prediction artifact validator | NIfTI-ready | value-range/geometry validator synthetic self-test passes |
| reliability label policy | draft-ready | first labels use fixed 0.5 threshold; boundary labels deferred |
| reliability label generator | synthetic-ready | generator/validator synthetic self-tests pass |
| reliability metric harness | synthetic-ready | metric harness self-test passes; no real metric outputs exist |
| pre-split preflight | completed | passed before official split creation; no longer the active gate after split artifacts exist |
| official split checker | done | split rows, summaries, leakage, lesion burden, and timing-warning fields validated |
| post-split validation runner | done | split checker, all-consortium loader smoke, tile budget, and tile-grid dry-run passed |
| novelty/literature | targeted-scout | uncertainty/QC/error-map prior work plus 2024-2026 QC/foundation-uncertainty risks identified; full systematic review still needed |
| baseline training | not started | requires split, loader smoke, command preview, GPU approval |
| reliability labels | not created | require OOF baseline predictions |

## Current Cohort Draft

| dataset | selected subjects |
|---|---:|
| MU-Glioma-Post | 203 |
| UCSD-PTGBM | 178 |
| UPENN-GBM | 611 |
| UTSW | 622 |
| total | 1,614 |

## Minimum Evidence Before First GPU Training

Still required:

1. Min approval of subject-level primary cohort policy.
2. LOCO split manifest with subject isolation.
3. Split validation:
   - no subject overlap,
   - no secondary-unit leakage,
   - dataset fold counts,
   - lesion-volume distribution by fold,
   - timing warning distribution by fold.
4. Data loader smoke test:
   - reads selected 4-channel MRI and mask,
   - verifies channel/mask shape, affine, orientation, and voxel spacing match,
   - verifies loaded arrays contain only finite values,
   - confirms tensor convention `[B, C, D, H, W]`,
   - confirms binary target creation `mask > 0`,
   - no preprocessing artifact written to raw data.
5. Loader/inference policy:
   - in-memory closest-canonical orientation only,
   - train-split-only mask-aware patch sampling,
   - no held-out mask use for crop/tile placement,
   - validation/test full-volume sliding-window assembly,
   - probability map shape matches canonical input shape.
6. Baseline training contract:
   - model,
   - input shape,
   - normalization,
   - augmentation,
   - loss,
   - optimizer,
   - batch size,
   - epochs,
   - early stopping,
   - checkpoint policy,
   - expected runtime.
7. Orientation and shape handling:
   - UCSD is `256x256x256 / ILA`,
   - MU/UPENN/UTSW are `240x240x155 / LPS`,
   - all selected masks have `1x1x1` spacing,
   - loader must standardize orientation and document crop/pad/resize policy,
   - sample audit rejects `128x160x128` as unsafe,
   - expanded sample shows `160x192x160` can miss off-center UCSD under
     fixed-center crop,
   - test-time inference must use full-volume coverage, not GT-centered crops,
   - reliability labels must come from assembled full-volume predictions.
8. GPU command preview and Min approval.
9. GPU memory preview must compare:
   - `160x192x160`, overlap `0.50`,
   - `192x224x160`, overlap `0.50`.
10. GPU preview must not use Dice as a selection criterion; it is a feasibility
   and memory/runtime gate only.
11. The first B1 GPU preview approval packet must use
   `research_gsure/03_baselines/B1_GPU_PREVIEW_COMMAND_TEMPLATE.md` and must
   list disallowed outputs as well as files to be written.
12. Split-aware tile-grid dry-run must be rerun after official split creation;
    the draft-cohort dry-run is not a substitute for post-split validation.
13. OOF prediction artifacts must follow the prediction/reliability contract
    before reliability labels are generated.
14. OOF prediction manifest validator must pass before reliability/error label
    generation.
15. Prediction artifact validator must pass before reliability/error label
    generation.
16. Reliability label generation must follow the fixed-threshold first-label
    policy unless a train-only threshold policy is approved before prediction
    inspection.
17. Reliability label generator and label manifest validator must be run only
    after OOF prediction metadata/artifact validators pass.
18. Pre-split readiness preflight should pass before requesting or executing
    official LOCO split creation.
19. Official split artifact checker must pass after official split creation and
    before post-split loader smoke.
20. Post-split validation runner should pass after official split creation and
    before GPU preview command preparation.
21. Uncertainty/QC baselines must follow
    `research_gsure/03_baselines/UNCERTAINTY_QC_BASELINE_REQUIREMENTS.md`;
    QC labels for train rows must come from inner-OOF or another approved
    train-only protocol.
22. Inner-OOF QC labels must follow
    `research_gsure/01_protocol/INNER_OOF_QC_LABEL_SCHEDULE_DRAFT.md`;
    real inner-OOF prediction manifests must pass
    `research_gsure/02_audits/scripts/validate_inner_oof_prediction_manifest.py`
    plus artifact-level probability-map validation before QC labels are
    generated.
23. Reliability/error-localization reporting must follow
    `research_gsure/01_protocol/RELIABILITY_METRIC_CONTRACT.md`; aggregate ERR
    metrics alone are insufficient without FP/FN, top-k, calibration, and
    consortium-stratified reporting.
24. Reliability metric computation must use
    `research_gsure/02_audits/scripts/compute_reliability_metrics.py` or a
    reviewed replacement. `soft_error_map_path` is oracle diagnostic only and
    cannot be reported as a method prediction.
25. Timing-warning sensitivity reporting must follow
    `research_gsure/01_protocol/TIMING_WARNING_SENSITIVITY_CONTRACT.md`;
    primary keep-all results require no-warning and UCSD high-risk subgroup
    sensitivity before final claims.

## Minimum Baselines

For the first research claim, do not jump directly to G-SURE. Required order:

1. Plain 3D U-Net/ResUNet segmentation baseline.
2. TTA uncertainty baseline.
3. Ensemble or repeated-seed disagreement baseline.
4. DeVries-style segmentation quality prediction baseline.
5. QCResUNet-style subject-level QC plus voxel-level error-map baseline.
6. Lesion-size, predicted-volume, and image-difficulty proxy baselines.
7. Failure/error localization evaluation from OOF predictions.
8. Reliability head baseline.
9. G-SURE method.

## Reviewer Attack Points

Likely attacks:

- "This is just segmentation with another uncertainty head."
- "Longitudinal/post-treatment scans leak subject or treatment effects."
- "Mask labels differ across datasets."
- "Reliability maps are post-hoc explanations, not quantitatively grounded."
- "The model learns dataset-specific annotation style."
- "The proposed method does not beat TTA/ensemble uncertainty baselines."
- "Existing segmentation QC/error-map predictors already solve this."
- "Case difficulty, lesion size, or predicted volume explains reliability without
  G-SURE."
- "Foundation medical segmentation uncertainty papers already cover the
  reliability framing."

Required defenses:

- subject-level split,
- one-unit-per-subject primary cohort,
- all-units sensitivity analysis,
- timing-warning disclosure and sensitivity analysis,
- binary target rather than unsupported subregion harmonization,
- LOCO evaluation,
- quantitative error-localization metrics,
- strong uncertainty and QC baselines.
- lesion-size, predicted-volume, and difficulty-proxy controls.

## Decision Rule Before Method Work

Proceed to G-SURE method implementation only if:

1. baseline segmentation achieves non-degenerate Dice on held-out consortia,
2. error maps from baseline predictions are meaningful enough to supervise or
   evaluate reliability,
3. simple uncertainty and QC baselines leave measurable room for improvement.

Stop or pivot if:

- conventional segmentation fails due data/label instability,
- reliability target is dominated by lesion size only,
- held-out consortium failure is too severe for meaningful grounding analysis,
- mask-source effects dominate measured reliability.

## Next Gate

Create the official primary LOCO split manifest only after approval of:

```text
primary cohort = subject_level_cohort_manifest_draft.csv
selection policy = one_unit_per_subject_earliest_numeric_order
target = binary selected_mask > 0
split policy = Leave-One-Consortium-Out
unit of split = dataset::subject_id
```

The all-unit/sensitivity cohort remains a documented later analysis path, but
it is not part of the first official primary split approval.

Current readiness evidence:

- LOCO readiness audit has no subject-overlap failure.
- LOCO readiness audit has no secondary-unit leakage.
- UCSD lesion burden and timing warning concentration must be disclosed and
  stratified in reports.
- Official split builder dry-run validates expected fold rows but has not
  written `loco_split_manifest.csv`.

Approval review packet:

```text
research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md
```

Post-approval runbook:

```text
research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md
```

Inner-OOF QC label schedule:

```text
research_gsure/01_protocol/INNER_OOF_QC_LABEL_SCHEDULE_DRAFT.md
```

Loader/inference policy draft:

```text
research_gsure/01_protocol/LOADER_INFERENCE_POLICY_DRAFT.md
```

Reliability metric contract:

```text
research_gsure/01_protocol/RELIABILITY_METRIC_CONTRACT.md
```

OOF prediction and reliability label contract:

```text
research_gsure/01_protocol/OOF_PREDICTION_RELIABILITY_CONTRACT.md
```

Reliability label generation policy draft:

```text
research_gsure/01_protocol/RELIABILITY_LABEL_POLICY_DRAFT.md
```

Pre-split readiness preflight:

```bash
python research_gsure/02_audits/scripts/check_pre_split_readiness.py
```

Official split artifact checker:

```bash
python research_gsure/02_audits/scripts/check_official_split_artifacts.py
```

Post-split validation runner:

```bash
python research_gsure/02_audits/scripts/run_post_split_validation.py --preview
```
