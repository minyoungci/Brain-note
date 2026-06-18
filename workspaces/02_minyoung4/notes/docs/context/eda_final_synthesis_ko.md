# Glioma EDA Final Synthesis

이 문서는 현재 `docs/context`에 생성된 EDA 산출물을 연구 시작 관점에서 압축한 최종 synthesis다.
범위는 metadata/path-level EDA, sample header audit, filesystem stat 기반 storage audit까지다.
Full image header audit, WSI pixel audit, preprocessing, split 생성, training은 Min 승인 전 실행하지 않았다.

## Validation Status

- Automated validation checks: 73.
- PASS: 72.
- WARN: 1.
- FAIL: 0.
- WARN은 approval-gated full audit/preprocessing/training이 아직 의도적으로 미실행이라는 상태 표시다.

## Dataset Inventory

| dataset               | primary_unit      | subjects   | sessions_timepoints_or_studies   |   primary_data_files | notes   |
|:----------------------|:------------------|:-----------|:---------------------------------|---------------------:|:--------|
| UTSW                  | subject           | 625.0      |                                  |                 6349 |         |
| MU-Glioma-Post        | subject-timepoint | 203.0      | 596.0                            |                 2978 |         |
| UCSD-PTGBM-v1         | subject-session   | 136.0      | 184.0                            |                 4047 |         |
| UCSD-PTGBM-BraTS-test | subject-session   | 42.0       | 59.0                             |                 1322 |         |
| UPENN-GBM-NIfTI       | scan_id           | 630.0      | 671.0                            |                10646 |         |
| UPENN-GBM-DICOM       | series            | 630.0      | 3301.0                           |               828234 |         |
| UPENN-GBM-Histopath   | slide             |            |                                  |                   71 |         |

## Common Usable Data

| feature                         |   available_subjects |   denominator_subjects |   available_pct |   min_dataset_available_pct | first_task_relevance   |
|:--------------------------------|---------------------:|-----------------------:|----------------:|----------------------------:|:-----------------------|
| structural_core_available       |                 1636 |                   1636 |          100    |                      100    | core                   |
| structural_plus_age_sex_scanner |                 1608 |                   1636 |           98.29 |                       95.52 | core                   |
| structural_plus_idh             |                 1457 |                   1636 |           89.06 |                       67.98 | recommended_first      |
| structural_segmentation_idh     |                 1439 |                   1636 |           87.96 |                       67.98 | variant_after_first    |
| structural_plus_mgmt            |                  815 |                   1636 |           49.82 |                       42.22 | second_stage           |
| structural_diffusion_perfusion  |                  669 |                   1636 |           40.89 |                        0    | subset                 |
| structural_plus_histopath       |                   18 |                   1636 |            1.1  |                        0    | pilot_only             |

Interpretation:

- 모든 subject에서 공통으로 가장 안정적인 입력은 structural MRI core다.
- age/sex는 전 subject에서 사용 가능하고, scanner vendor/field strength까지 포함하면 1,608/1,636 subjects다.
- 첫 supervised task로는 structural MRI IDH가 가장 현실적이며, MGMT는 second-stage가 적절하다.
- diffusion/perfusion, histopath, survival/PFS는 all-consortium common feature가 아니라 subset/pilot/deferred protocol로 분리해야 한다.

## Candidate Cohorts

| cohort_flag                                |   eligible_subjects |   eligible_multi_unit_subjects |   eligible_nifti_units | positive_subjects   | negative_subjects   | recommended_use                                 |
|:-------------------------------------------|--------------------:|-------------------------------:|-----------------------:|:--------------------|:--------------------|:------------------------------------------------|
| eligible_T0_structural_common              |                1636 |                            245 |                   2135 |                     |                     | representation_baseline_or_preprocessing_QA     |
| eligible_T0b_structural_common_covariates  |                1608 |                            245 |                   2107 |                     |                     | baseline_schema_for_reporting_and_split_balance |
| eligible_T1_structural_idh                 |                1457 |                            209 |                   1901 | 235.0               | 1222.0              | recommended_first_supervised_task               |
| eligible_T1b_structural_segmentation_idh   |                1439 |                            209 |                   1883 | 232.0               | 1207.0              | variant_after_T1_baseline                       |
| eligible_T2_structural_mgmt                |                 815 |                            165 |                   1187 | 347.0               | 468.0               | second_stage_supervised_task                    |
| eligible_T3_structural_grade               |                 999 |                            204 |                   1457 |                     |                     | restricted_subset_only                          |
| eligible_T4_structural_os                  |                 770 |                            151 |                   1062 |                     |                     | defer_until_survival_protocol                   |
| eligible_T4b_structural_pfs                |                 224 |                            164 |                    610 |                     |                     | defer_until_survival_protocol                   |
| eligible_T5_structural_diffusion_perfusion |                 669 |                             90 |                    775 |                     |                     | advanced_imaging_subset                         |
| eligible_T6_radiology_histopath            |                  18 |                              8 |                     26 |                     |                     | pilot_multimodal_subset                         |

## Target Bias Snapshot

| task               | dataset        |   subjects |   positive_subjects |   negative_subjects |   positive_pct |   task_subjects |   task_positive_pct |   positive_pct_delta_from_task |   min_class_subjects | risk_level      |
|:-------------------|:---------------|-----------:|--------------------:|--------------------:|---------------:|----------------:|--------------------:|-------------------------------:|---------------------:|:----------------|
| T1_structural_idh  | MU-Glioma-Post |        189 |                  28 |                 161 |          14.81 |            1457 |               16.13 |                          -1.32 |                   28 | ok              |
| T1_structural_idh  | UCSD-PTGBM     |        121 |                  12 |                 109 |           9.92 |            1457 |               16.13 |                          -6.21 |                   12 | small_min_class |
| T1_structural_idh  | UPENN-GBM      |        525 |                  19 |                 506 |           3.62 |            1457 |               16.13 |                         -12.51 |                   19 | small_min_class |
| T1_structural_idh  | UTSW           |        622 |                 176 |                 446 |          28.3  |            1457 |               16.13 |                          12.17 |                  176 | ok              |
| T2_structural_mgmt | MU-Glioma-Post |        163 |                  66 |                  97 |          40.49 |             815 |               42.58 |                          -2.09 |                   66 | ok              |
| T2_structural_mgmt | UCSD-PTGBM     |        105 |                  53 |                  52 |          50.48 |             815 |               42.58 |                           7.9  |                   52 | ok              |
| T2_structural_mgmt | UPENN-GBM      |        266 |                 114 |                 152 |          42.86 |             815 |               42.58 |                           0.28 |                  114 | ok              |
| T2_structural_mgmt | UTSW           |        281 |                 114 |                 167 |          40.57 |             815 |               42.58 |                          -2.01 |                  114 | ok              |

Interpretation:

- IDH는 coverage가 좋지만 UTSW 28.30% vs UPENN 3.62%로 dataset shortcut 위험이 크다.
- IDH는 pooled random split만으로 성능을 주장하면 안 되고, subject-level grouping + dataset/scanner-aware reporting이 필요하다.
- MGMT는 dataset-level rate가 비교적 안정적이지만 eligible subject가 815명으로 더 작다.

## Storage / Quality

- Manifest-mapped NIfTI files: 25,326.
- Manifest-mapped NIfTI total size: 147.2949 GiB.
- Zero-byte mapped NIfTI files: 1.
- Histopath slides: 71, total 148.3012 GiB.

| area                    | severity                    | issue                                       | count   | evidence                                                                                                                                                  | recommended_action                                                                      |
|:------------------------|:----------------------------|:--------------------------------------------|:--------|:----------------------------------------------------------------------------------------------------------------------------------------------------------|:----------------------------------------------------------------------------------------|
| nifti_file_integrity    | high_for_segmentation_tasks | zero_byte_nifti_files                       | 1.0     | data/UCSD-PTGBM/PKG - UCSD-PTGBM-BraTS-2024-test-set/UCSD-PTGBM-BraTS-2024-test-set/UCSD-PTGBM-0149_02/UCSD-PTGBM-0149_02_total_cellular_tumor_seg.nii.gz | Repair or exclude these files before preprocessing.                                     |
| manifest_mapping        | medium                      | upenn_duplicate_structural_old_nonold_paths | 16.0    | UPENN NIfTI files present on disk but not selected in canonical path_json due duplicate keys.                                                             | Choose old or non-old structural path preference before preprocessing.                  |
| outcome_semantics       | high_for_outcome_modeling   | negative_numeric_duration                   | 1.0     | UCSD-PTGBM progression_or_pfs min=-8.0                                                                                                                    | Inspect raw metadata and define outcome-specific cleaning before survival/PFS modeling. |
| outcome_semantics       | medium                      | duration_available_but_not_pool_ready       | 96.0    | MU-Glioma-Post overall_survival                                                                                                                           | Harmonize time origin, event/censor definition, and unit of analysis first.             |
| outcome_semantics       | medium                      | duration_available_but_not_pool_ready       | 152.0   | MU-Glioma-Post progression_or_pfs                                                                                                                         | Harmonize time origin, event/censor definition, and unit of analysis first.             |
| outcome_semantics       | medium                      | duration_available_but_not_pool_ready       | 71.0    | UCSD-PTGBM overall_survival                                                                                                                               | Harmonize time origin, event/censor definition, and unit of analysis first.             |
| outcome_semantics       | medium                      | duration_available_but_not_pool_ready       | 72.0    | UCSD-PTGBM progression_or_pfs                                                                                                                             | Harmonize time origin, event/censor definition, and unit of analysis first.             |
| outcome_semantics       | medium                      | duration_available_but_not_pool_ready       | 603.0   | UPENN-GBM overall_survival                                                                                                                                | Harmonize time origin, event/censor definition, and unit of analysis first.             |
| image_header_validation | approval_gated              | full_nifti_and_dicom_header_audits_not_run  |         | Only sample NIfTI and sample DICOM header audits exist.                                                                                                   | Run full header audits only after Min approval.                                         |

## Objective Evidence Matrix

| objective_requirement                              | status                                 | primary_evidence                                                                                                          | validated_by                                                                             | scope                                                                                                      | remaining_risk                                                                                          |
|:---------------------------------------------------|:---------------------------------------|:--------------------------------------------------------------------------------------------------------------------------|:-----------------------------------------------------------------------------------------|:-----------------------------------------------------------------------------------------------------------|:--------------------------------------------------------------------------------------------------------|
| download completion and consortium inventory       | complete                               | eda_dataset_status_master.csv; eda_master_report.md                                                                       | primary_data_file_total; dataset_status_rows; partial_like_files_excluding_tools=0       | primary file counts, subjects, sessions/timepoints/studies/series/slides                                   | If new downloads are started, rerun inventory.                                                          |
| raw clinical metadata profiling                    | complete                               | eda_variable_profile.csv; common_variable_codebook.csv; modeling_subject_label_distributions.csv                          | eda_completion_audit.csv; eda_validation_checks.csv                                      | metadata missingness, top values, harmonized subject-level distributions                                   | Source-specific semantics still matter for survival/PFS.                                                |
| imaging modality/path-level profiling              | complete_with_approval_gated_extension | eda_imaging_inventory.csv; modeling_imaging_coverage.csv; canonical_manifest.csv; nifti_header_audit_sample.csv           | canonical_manifest_rows; canonical_manifest_mapped_files; coavailability checks          | NIfTI/DICOM/histopath unit rows, structural/segmentation/diffusion/perfusion coverage, sample header audit | Full NIfTI/DICOM header audit remains approval-gated before preprocessing.                              |
| common usable clinical/imaging data identification | complete                               | deep_common_data_tiers.csv; consortium_common_data_matrix.csv; common_data_dictionary.csv                                 | common_matrix_* checks; coavailability_* checks                                          | common age/sex/scanner/structural core/segmentation/label/outcome feature availability                     | Use caveats before promoting restricted/subset fields into a protocol.                                  |
| candidate research cohort readiness                | complete_without_split                 | research_cohort_membership.csv; research_cohort_summary.csv; research_leakage_group_audit.csv                             | research_cohort_* checks; research_leakage_* checks                                      | subject-level cohort membership and split grouping key; no split file generated                            | Actual split requires Min approval of task, cohort, metric, and split policy.                           |
| supervised target confounding and imbalance audit  | complete                               | candidate_task_bias_group_distribution.csv; candidate_task_bias_group_summary.csv; candidate_task_bias_dataset_matrix.csv | bias_* checks                                                                            | IDH/MGMT positive-rate variation by dataset, scanner, field strength, age, sex                             | Future performance claims need dataset/scanner-aware reporting and leave-one-consortium-out evaluation. |
| storage and file-size burden                       | complete                               | eda_storage_size_audit.md; nifti_file_size_inventory.csv; histopath_size_summary.csv                                      | nifti_file_size_*; dicom_series_image_count_total_images; histopath_size_* checks        | filesystem stat for mapped NIfTI/NDPI and DICOM series image-count burden                                  | Individual DICOM file-size stat intentionally not run over 828k files.                                  |
| quality blockers and approval-gated next steps     | complete                               | deep_data_quality_flags.csv; eda_next_audit_plan.md; eda_next_gate_checklist.csv                                          | known_zero_byte_nifti_count; upenn_nifti_manifest_gap_rows; approval_gated_items_present | known zero-byte file, UPENN duplicate structural path preference, full audit gates                         | Approval needed before full audits, preprocessing, split, or training.                                  |

## Start-Here Artifacts

| group       | artifact                           | exists   | path                                            | description                                           |
|:------------|:-----------------------------------|:---------|:------------------------------------------------|:------------------------------------------------------|
| start_here  | eda_final_synthesis_ko.md          | True     | docs/context/eda_final_synthesis_ko.md          | Compact final Korean synthesis for the EDA phase.     |
| start_here  | eda_research_handoff_ko.md         | True     | docs/context/eda_research_handoff_ko.md         | Detailed Korean research handoff.                     |
| start_here  | eda_completion_evidence_matrix.csv | True     | docs/context/eda_completion_evidence_matrix.csv | Objective-to-evidence matrix for completion auditing. |
| start_here  | eda_validation_report.md           | True     | docs/context/eda_validation_report.md           | Automated consistency checks across EDA artifacts.    |
| inventory   | eda_dataset_status_master.csv      | True     | docs/context/eda_dataset_status_master.csv      | Dataset/package counts by consortium/package.         |
| inventory   | canonical_manifest.csv             | True     | docs/context/canonical_manifest.csv             | Canonical unit manifest across NIfTI/DICOM/histopath. |
| common_data | consortium_common_data_matrix.md   | True     | docs/context/consortium_common_data_matrix.md   | Readable common-data matrix by consortium.            |
| common_data | deep_common_data_tiers.csv         | True     | docs/context/deep_common_data_tiers.csv         | Tiered feature readiness table.                       |
| cohorts     | research_cohort_membership.md      | True     | docs/context/research_cohort_membership.md      | Subject-level candidate cohort and leakage summary.   |
| bias        | candidate_task_bias_audit.md       | True     | docs/context/candidate_task_bias_audit.md       | IDH/MGMT shortcut and imbalance audit.                |
| storage     | eda_storage_size_audit.md          | True     | docs/context/eda_storage_size_audit.md          | NIfTI/DICOM/histopath storage burden.                 |
| next        | eda_next_audit_plan.md             | True     | docs/context/eda_next_audit_plan.md             | Approval-gated next audit commands and gates.         |

## Next Gate

가장 합리적인 다음 단계는 `T1_structural_idh_prediction` protocol 확정 여부를 정하고, 승인 후 full NIfTI header audit을 실행하는 것이다.
그 전에는 preprocessing, split 생성, training을 진행하지 않는다.
