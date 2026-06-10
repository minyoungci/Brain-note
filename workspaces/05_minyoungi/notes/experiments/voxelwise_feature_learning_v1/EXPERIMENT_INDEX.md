# Experiment index — voxelwise_feature_learning_v1

Updated UTC: 2026-05-27T00:56:41Z

## Current decision

The current evidence does not support moving directly to large VLM scaling.

Latest completed gate:

- `vlm_gate_04c_kdrc_reproducibility_v0`
- Status: fail
- Result dir: `results/vlm_gate_04c_kdrc_reproducibility_v0/`
- Report: `results/vlm_gate_04c_kdrc_reproducibility_v0/REPORT_KO.md`
- Summary: `results/vlm_gate_04c_kdrc_reproducibility_v0/summary_seed_repeat.json`

Gate04 full LOCO showed a partial-pass recipe, but Gate04c did not reproduce the
KDRC rescue across seeds. Treat `Teacher-S KL + small CE` as a useful diagnostic
direction, not as a locked default recipe.

## Canonical baselines

### `baseline_02_roi_mean_logreg_cn_vs_ad`

- Type: ROI mean voxel feature logistic regression
- Task: CN vs AD binary classification
- Split: subject-disjoint random split
- Primary metric: ROC-AUC `0.7018`
- Baseline snapshot dir: `baselines/baseline_02_roi_mean_logreg_cn_vs_ad/`

### `baseline_03_roi_summary_logreg_cn_vs_ad`

- Type: ROI summary voxel feature logistic regression
- Task: CN vs AD binary classification
- Features: 5 ROIs x 8 summary stats
- Random split ROC-AUC: `0.9004`
- LOCO mean ROC-AUC: `0.8732`
- Baseline snapshot dir: `baselines/baseline_03_roi_summary_logreg_cn_vs_ad/`

### `baseline_04_roi_summary_ablation_logreg_cn_vs_ad`

- Type: ROI summary ablation logistic regression
- Task: identify which ROI summary families drive baseline_03 performance
- Result: ROI summary signal is strong; voxel_count/volume shortcut remains a caveat.
- Baseline snapshot dir: `baselines/baseline_04_roi_summary_ablation_logreg_cn_vs_ad/`

### `baseline_05_3d_cnn_cn_vs_ad_smoke`

- Type: image-only 3D CNN random subject-disjoint split
- Task: CN vs AD binary classification
- Primary metric: random split ROC-AUC `0.8906`
- Baseline snapshot dir: `baselines/baseline_05_3d_cnn_cn_vs_ad_smoke/`

### `baseline_06_3d_cnn_loco_cn_vs_ad`

- Type: image-only 3D CNN leave-one-cohort-out
- Task: CN vs AD binary classification
- LOCO mean ROC-AUC: `0.8087`
- Leakage audit: pass
- Baseline snapshot dir: `baselines/baseline_06_3d_cnn_loco_cn_vs_ad/`

## VLM gate sequence

### `vlm_gate_02_roi_to_image_distillation_v0_selected_no_voxel_count`

- Status: partial pass
- Result dir: `results/vlm_gate_02_roi_to_image_distillation_v0_selected_no_voxel_count/`
- Teacher target: no-voxel-count ROI summary z-vector
- Student input: T1w final_tensor voxels only
- Mean frozen-probe AUC: `0.7501`
- Mean delta vs baseline06 AUC: `-0.0515`
- Interpretation: ROI imitation works, but class-relevant frozen representation remains weak.

### `vlm_gate_03_teacher_logit_latent_distillation_v0_selected`

- Status: selected-fold partial / near pass
- Result dir: `results/vlm_gate_03_teacher_logit_latent_distillation_v0_selected/`
- Best mean variant: `teacher_kl`
- Mean frozen AUC: `0.8118`
- Interpretation: Teacher-S logit distillation improves Gate02, but KDRC remains below baseline06.

### `vlm_gate_03b_ce_teacher_kl_mixed_v0_selected`

- Status: KDRC-specific improvement, not global replacement
- Result dir: `results/vlm_gate_03b_ce_teacher_kl_mixed_v0_selected/`
- KDRC best frozen AUC: `0.8440`
- Interpretation: hard CE anchor helps KDRC, but ADNI/AJU tradeoffs make the objective fold-dependent.

### `vlm_gate_03c_objective_robustness_v0_selected`

- Status: selected-fold strong pass
- Result dir: `results/vlm_gate_03c_objective_robustness_v0_selected/`
- Best robust variant: `ce0.1_plus_teacher_kl`
- Mean frozen AUC: `0.8307`
- Interpretation: selected ADNI/AJU/KDRC folds all exceed baseline06, motivating full LOCO expansion.

### `vlm_gate_04_full_loco_teacher_s_kl_ce01_v0_seed42_stable`

- Status: full LOCO partial pass
- Result dir: `results/vlm_gate_04_full_loco_teacher_s_kl_ce01_v0_seed42_stable/`
- Variant: `ce0.1_plus_teacher_kl`
- Mean frozen AUC: `0.8159`
- Mean delta vs baseline06 AUC: `+0.0071`
- Pass/near-pass: ADNI, AIBL, KDRC, OASIS
- Weak/fail folds: AJU, NACC
- Interpretation: average improves slightly, but NACC/AJU remain unresolved.

### `vlm_gate_04b_nacc_aju_robustness_teacher_b_v0_seed42_workers0`

- Status: robustness diagnostic, unresolved
- Result dir: `results/vlm_gate_04b_nacc_aju_robustness_teacher_b_v0_seed42_workers0/`
- Best 4-fold mean variant: `ce0.05_plus_teacher_kl`
- Mean frozen AUC: `0.8116`
- Mean delta vs baseline06 AUC: `+0.0022`
- Teacher-B diagnostic: ROI + age/sex teacher raised ceiling but did not improve student transfer.
- Interpretation: AJU can be rescued, but NACC and KDRC are not simultaneously solved.

### `vlm_gate_04c_kdrc_reproducibility_v0`

- Status: fail
- Result dir: `results/vlm_gate_04c_kdrc_reproducibility_v0/`
- Heldout fold: KDRC only
- Seeds: `42`, `43`, `44`
- Best variant: `ce0.1_plus_teacher_kl`
- Best variant mean frozen AUC: `0.8080`
- Baseline06 KDRC AUC: `0.8395`
- Baseline pass count: `0 / 3`
- Interpretation: KDRC rescue observed in Gate04 full stable is not reproducible under this seed-repeat check.

## Cleanup note

On 2026-05-27, regenerated cache and superseded smoke/non-stable result directories
were removed to keep the workspace small. Preserved result directories contain the
reports and summary CSV/JSON files needed for current interpretation.

Removed classes:

- `cache/baseline_05_downsampled_tensors/`
- `cache/final_tensor_downsampled_ds2_fp16/`
- Gate02/Gate03/Gate03b/Gate03c smoke result dirs
- Non-stable `vlm_gate_04_full_loco_teacher_s_kl_ce01_v0_seed42/`

## Pointers

- Latest result pointer: `results/LATEST.json`
- Baseline registry: `baselines/BASELINE_INDEX.json`
- Baseline comparison table: `comparisons/baseline_comparison.csv`
