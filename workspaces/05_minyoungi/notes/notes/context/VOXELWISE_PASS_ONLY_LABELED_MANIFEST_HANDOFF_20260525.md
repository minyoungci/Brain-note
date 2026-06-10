# Voxel-wise PASS-only labeled manifest handoff

Created: 2026-05-25 KST

## Final recommended manifests

Latest pointer:

`/home/vlm/data/preprocessed_official/v2/_reports/roi_transfer_option_b_full_subjectlocal_20260522T034648Z/voxelwise_roi_readiness_draft_20260523T143000Z/v2-QCpass/visual_qc_policy_v1/final_pass_only_training_manifest_v1/LATEST_LABELED_PASS_ONLY_MANIFEST.json`

Recommended classifiable MRI manifest:

`/home/vlm/data/preprocessed_official/v2/_reports/roi_transfer_option_b_full_subjectlocal_20260522T034648Z/voxelwise_roi_readiness_draft_20260523T143000Z/v2-QCpass/visual_qc_policy_v1/final_pass_only_training_manifest_v1/final_labeled_manifest_v1/voxelwise_pass_only_labeled_classifiable_mri_manifest.csv`

Recommended classifiable ROI-pair manifest:

`/home/vlm/data/preprocessed_official/v2/_reports/roi_transfer_option_b_full_subjectlocal_20260522T034648Z/voxelwise_roi_readiness_draft_20260523T143000Z/v2-QCpass/visual_qc_policy_v1/final_pass_only_training_manifest_v1/final_labeled_manifest_v1/voxelwise_pass_only_labeled_classifiable_roi_pair_manifest.csv`

Summary:

`/home/vlm/data/preprocessed_official/v2/_reports/roi_transfer_option_b_full_subjectlocal_20260522T034648Z/voxelwise_roi_readiness_draft_20260523T143000Z/v2-QCpass/visual_qc_policy_v1/final_pass_only_training_manifest_v1/final_labeled_manifest_v1/voxelwise_labeled_manifest_summary.json`

## Sources

PASS-only source:

`/home/vlm/data/preprocessed_official/v2/_reports/roi_transfer_option_b_full_subjectlocal_20260522T034648Z/voxelwise_roi_readiness_draft_20260523T143000Z/v2-QCpass/visual_qc_policy_v1/final_pass_only_training_manifest_v1/`

Label source:

`/home/vlm/minyoungi/manifests/v2_integrated/canonical/vlm_ready_manifest_v2_integrated_oasis_included_v0.csv`

Join key:

`cohort, subject_id, session_id_norm`, where `session_id_norm` strips trailing `.0`.

## Counts

All PASS-only after label join:

- MRI rows: 11,096
- ROI-pair rows: 55,480
- label joined: 100%

Recommended classifiable CN/MCI/AD subset:

- MRI rows: 10,623
- ROI-pair rows: 53,115
- ROI-pairs per MRI: exactly 5
- excluded non-classifiable MRI rows: 473
- excluded non-classifiable ROI-pairs: 2,365

Class counts, MRI rows:

- CN: 5,716
- MCI: 3,613
- AD: 1,294

Class counts, ROI-pairs:

- CN: 28,580
- MCI: 18,065
- AD: 6,470

ROI counts in classifiable ROI-pair manifest:

- hippocampus: 10,623
- amygdala: 10,623
- thalamus: 10,623
- lateral_ventricle: 10,623
- parahippocampal_cortex: 10,623

Label ID mapping:

- CN: 0
- MCI: 1
- AD: 2

## Validation

- `validation_pass=True`
- all classifiable rows joined to label source
- missing diagnosis_label_id: 0
- all classifiable rows have `diagnosis_3class in {CN, MCI, AD}` and `is_classifiable=True`
- every classifiable MRI has exactly five ROI-pair rows
- expected ROI set complete for all 10,623 MRI rows
- referenced path existence check passed during manifest creation

## Notes

The recommended manifest is ready for label-aware voxel-wise feature training or downstream supervised probes. REVIEW rows and non-classifiable rows are excluded from the recommended classifiable manifest but preserved in explicit exclusion manifests under the same output directory.
