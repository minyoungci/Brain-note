# Experiment Ladder: Shift-Aware Glioma IDH Modeling

Created: 2026-06-18

This directory is the experiment work area for the new glioma MRI IDH modeling track.
It is intentionally organized as a ladder: each experiment must justify the next one.

No GPU training, preprocessing, split finalization, raw-data writes, or shared-artifact overwrites
are allowed from this scaffold alone. Those actions require explicit Min approval.

## Primary Goal

Develop and test modeling/training improvements that can beat strong 3D CNN baselines,
especially Res3DNet-style segmentation-free 3D CNNs, under subject-isolated and
leave-one-consortium-out evaluation.

## Default Task Definition

- Outcome: IDH mutant vs wildtype.
- Primary cohort: `eligible_T1_structural_idh`.
- Input MRI: T1, T1ce/T1post, T2, FLAIR.
- Unit of analysis: subject, keyed by `dataset::subject_id`.
- Primary split policy: subject-isolated, leave-one-consortium-out.
- Secondary split policy: internal train/validation within non-held-out consortia only.
- Required reporting: AUC, AUPRC, balanced accuracy, MCC, sensitivity/specificity,
  ECE, Brier score, worst-consortium metric, scanner/vendor subgroup metrics.

## Experiment Order

| Order | Stable ID | Directory | Purpose | Gate to next |
|---:|---|---|---|---|
| 00 | `G0_protocol_gate` | `exp00_protocol_and_leakage_gate` | Lock cohort/split/preprocessing/mask policies before modeling. | No unresolved leakage or file-quality blocker. |
| 01 | `B0_clinical_only` | `exp01_clinical_shortcut_baseline` | Measure age/sex/scanner/site shortcut strength. | Image models must beat this under LOCO. |
| 02 | `B1_3d_resnet_image_only` | `exp02_res3dnet_proxy_baseline` | Establish standard 3D CNN baseline. | Res3DNet proxy must beat this. |
| 03 | `B2_res3dnet_proxy` | `exp02_res3dnet_proxy_baseline` | Establish strong segmentation-free 3D CNN baseline. | Main model must beat this, not only weak ResNet. |
| 04 | `N0_modality_fusion` | `exp03_modality_dropout_fusion` | Test robust sequence fusion vs early 4-channel concat. | Show stability under modality/protocol variation. |
| 05 | `N2_tumor_context` | `exp04_tumor_context_mask_dropout` | Main tumor/context token and mask-dropout novelty. | Improve over Res3DNet proxy and reduce mask dependency. |
| 06 | `N3_shift_aware` | `exp05_domain_generalization_loco` | Optimize for consortium/scanner shift. | Improve worst-consortium metric and calibration. |
| 07 | `N1_prompt_film` | `exp06_clinical_prompt_conditioning` | Test controlled prompt conditioning vs tabular concat. | Prompt must beat concat and prompt-shuffle controls. |
| 08 | `R0_calibration` | `exp07_calibration_abstention` | Add reliability and safe-failure analysis. | ECE/Brier/selective risk improve on held-out consortia. |

See `EXPERIMENT_REGISTRY.csv` for the stable experiment IDs used in configs, runs,
reports, and code review records.

## Code Review Procedure

Each experiment implementation must pass two reviews before it is used for reported results:

1. Leakage/reproducibility review
   - subject grouping is enforced;
   - no train statistics are computed on validation/test;
   - held-out consortium is not used for model selection;
   - masks, scanners, and repeated visits cannot leak label or split identity;
   - all outputs are written to an experiment-local run directory.

2. Code correctness review
   - config values are explicit and logged;
   - random seeds and deterministic settings are documented;
   - metrics are computed at subject level;
   - class imbalance handling is train-only;
   - tests/smoke checks cover manifests, loaders, metrics, and split isolation.

When implementation begins, use sub-agents for independent review of each experiment's
changed files. The main agent integrates findings and keeps final artifacts in the exp directory.

The review protocol is in `CODE_REVIEW_PROTOCOL.md`.

## Future Code Layout After Approval

Do not create a broad source tree until exp00 is approved. Once approved, use this minimal
layout:

- `configs/idh_loco/`: immutable configs, one per model or ablation.
- `src/data/`: manifest loading, path validation, modality and mask availability checks.
- `src/splits/`: LOCO split generation and split leakage validators.
- `src/models/`: 3D ResNet, Res3DNet proxy, prompt model, tumor-context model.
- `src/eval/`: metrics, subgroup reports, calibration, bootstrap confidence intervals.
- `experiments/<exp_id>/runs/`: per-model/per-seed outputs, no overwrite by default.
- `experiments/<exp_id>/reports/`: aggregate tables and review reports.
- `experiments/<exp_id>/reviews/`: one review file per stable ID, e.g. `B2_res3dnet_proxy_review.md`.

No raw data should ever be copied into the experiment directories.

## Shared Source Documents

- Prior work model/training summary: `docs/context/prior_work_model_training_methods.csv`
- Mechanistic gap analysis: `docs/context/prior_work_mechanistic_gap_analysis.md`
- Improvement hypotheses: `docs/context/prior_work_improvement_hypotheses.csv`
- EDA synthesis: `docs/context/eda_final_synthesis_ko.md`
- Competitive strategy: `docs/context/research_competitive_strategy.md`

## Forbidden Without Approval

- Writing, deleting, moving, or renaming files under `/home/vlm/data/raw/`.
- Full preprocessing or full image header audit.
- GPU training or long inference.
- Creating final split files used for reported experiments.
- Deleting checkpoints/logs/raw/preprocessed outputs.
