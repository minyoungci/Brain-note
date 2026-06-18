# Glioma Data EDA Research Handoff

이 문서는 현재까지 생성한 EDA 산출물을 연구/모델 개발 시작 관점에서 묶은 handoff다.
모든 내용은 metadata/path-level EDA 기준이며, image array preprocessing, split 생성, GPU training은 수행하지 않았다.

## 1. Bottom Line

- 다운로드된 primary image/slide package 파일은 853,647개로 확인되었고, partial-like download file은 0개다.
- NIfTI subject-level cohort는 1,636명이다.
- 모든 dataset에서 공통으로 쓸 수 있는 가장 안정적인 입력은 structural MRI core + age + sex + scanner metadata다.
- 첫 supervised target 후보는 IDH다. Conflict 제외 후 1,457 subjects가 사용 가능하다.
- MGMT는 815 subjects로 가능하지만 coverage가 낮아 second-stage가 적절하다.
- Survival/PFS는 값은 있으나 time origin/censor semantics가 달라 아직 pooling하면 안 된다.

## 2. Dataset Status

| dataset               | primary_unit      | subjects   | sessions_timepoints_or_studies   |   primary_data_files | notes   |
|:----------------------|:------------------|:-----------|:---------------------------------|---------------------:|:--------|
| UTSW                  | subject           | 625.0      |                                  |                 6349 |         |
| MU-Glioma-Post        | subject-timepoint | 203.0      | 596.0                            |                 2978 |         |
| UCSD-PTGBM-v1         | subject-session   | 136.0      | 184.0                            |                 4047 |         |
| UCSD-PTGBM-BraTS-test | subject-session   | 42.0       | 59.0                             |                 1322 |         |
| UPENN-GBM-NIfTI       | scan_id           | 630.0      | 671.0                            |                10646 |         |
| UPENN-GBM-DICOM       | series            | 630.0      | 3301.0                           |               828234 |         |
| UPENN-GBM-Histopath   | slide             |            |                                  |                   71 |         |

## 3. Subject-Level Modeling Summary

| dataset        |   subjects |   nifti_units |   subjects_with_multiple_units |   structural_core_subjects |   segmentation_subjects |   diffusion_subjects |   perfusion_subjects |   idh_usable_no_conflict_subjects |   mgmt_usable_binary_no_conflict_subjects |   os_numeric_subjects |
|:---------------|-----------:|--------------:|-------------------------------:|---------------------------:|------------------------:|---------------------:|---------------------:|----------------------------------:|------------------------------------------:|----------------------:|
| MU-Glioma-Post |        203 |           596 |                            155 |                        203 |                     203 |                    0 |                    0 |                               189 |                                       163 |                    96 |
| UCSD-PTGBM     |        178 |           243 |                             49 |                        178 |                     178 |                  178 |                  178 |                               121 |                                       105 |                    71 |
| UPENN-GBM      |        630 |           671 |                             41 |                        630 |                     611 |                  554 |                  497 |                               525 |                                       266 |                   603 |
| UTSW           |        625 |           625 |                              0 |                        625 |                     625 |                    0 |                    0 |                               622 |                                       281 |                     0 |

## 4. Common Data Tiers

| tier   | feature            | role                     |   available_subjects |   total_subjects |   available_pct | recommendation                                                  |
|:-------|:-------------------|:-------------------------|---------------------:|-----------------:|----------------:|:----------------------------------------------------------------|
| Tier 1 | age                | clinical covariate       |                 1636 |             1636 |          100    | Use in all baseline models; document age reference differences. |
| Tier 1 | sex                | clinical covariate       |                 1636 |             1636 |          100    | Use in all baseline models.                                     |
| Tier 1 | structural_core    | imaging input            |                 1636 |             1636 |          100    | Best common MRI input across all datasets.                      |
| Tier 1 | scanner_vendor     | confound/covariate       |                 1608 |             1636 |           98.29 | Required for reporting and split balance.                       |
| Tier 1 | field_strength     | confound/covariate       |                 1608 |             1636 |           98.29 | Required for reporting and split balance.                       |
| Tier 2 | segmentation       | imaging auxiliary/target |                 1617 |             1636 |           98.84 | Near complete; handle zero-byte UCSD segmentation.              |
| Tier 2 | idh_binary_usable  | molecular label          |                 1457 |             1636 |           89.06 | Best first supervised task; conflict-excluded labels.           |
| Tier 2 | mgmt_binary_usable | molecular label          |                  815 |             1636 |           49.82 | Second-stage task; lower coverage.                              |
| Tier 3 | grade              | clinical label           |                  999 |             1636 |           61.06 | Exclude UPENN or treat as GBM-only collection.                  |
| Tier 3 | one_p_19q_usable   | molecular label          |                  473 |             1636 |           28.91 | UPENN missing.                                                  |
| Tier 3 | atrx_usable        | molecular label          |                  232 |             1636 |           14.18 | MU/UCSD only.                                                   |
| Tier 3 | os_numeric         | outcome                  |                  770 |             1636 |           47.07 | Needs time-origin/censor harmonization.                         |
| Tier 3 | pfs_numeric        | outcome                  |                  224 |             1636 |           13.69 | Sparse and semantically heterogeneous.                          |
| Tier 4 | diffusion          | advanced imaging         |                  732 |             1636 |           44.74 | UCSD+UPENN focused.                                             |
| Tier 4 | perfusion          | advanced imaging         |                  675 |             1636 |           41.26 | UCSD+UPENN focused.                                             |
| Tier 4 | linked_histopath   | multimodal               |                   18 |             1636 |            1.1  | UPENN small subset only.                                        |

## 4b. Consortium Common Data Matrix

| category           | feature                          | role                     |   available_subjects |   denominator_subjects |   available_pct |   min_dataset_available_pct | first_task_relevance   |
|:-------------------|:---------------------------------|:-------------------------|---------------------:|-----------------------:|----------------:|----------------------------:|:-----------------------|
| clinical_covariate | age_available                    | covariate                |                 1636 |                   1636 |          100    |                      100    | core                   |
| clinical_covariate | sex_known                        | covariate                |                 1636 |                   1636 |          100    |                      100    | core                   |
| clinical_covariate | scanner_vendor_known             | confounder               |                 1608 |                   1636 |           98.29 |                       95.52 | core_reporting         |
| clinical_covariate | field_strength_known             | confounder               |                 1608 |                   1636 |           98.29 |                       95.52 | core_reporting         |
| imaging_structural | t1_available                     | input                    |                 1636 |                   1636 |          100    |                      100    | core                   |
| imaging_structural | t1ce_or_t1post_available         | input                    |                 1636 |                   1636 |          100    |                      100    | core                   |
| imaging_structural | t2_available                     | input                    |                 1636 |                   1636 |          100    |                      100    | core                   |
| imaging_structural | flair_available                  | input                    |                 1636 |                   1636 |          100    |                      100    | core                   |
| imaging_structural | structural_core_available        | input                    |                 1636 |                   1636 |          100    |                      100    | core                   |
| imaging_annotation | segmentation_available           | auxiliary_label_or_mask  |                 1617 |                   1636 |           98.84 |                       96.98 | high                   |
| imaging_advanced   | diffusion_available              | advanced_input           |                  732 |                   1636 |           44.74 |                        0    | subset                 |
| imaging_advanced   | perfusion_available              | advanced_input           |                  675 |                   1636 |           41.26 |                        0    | subset                 |
| histopath          | histopath_linked_available       | multimodal_input         |                   18 |                   1636 |            1.1  |                        0    | pilot_only             |
| molecular_label    | idh_binary_usable                | supervised_target        |                 1457 |                   1636 |           89.06 |                       67.98 | recommended_first      |
| molecular_label    | mgmt_binary_usable               | supervised_target        |                  815 |                   1636 |           49.82 |                       42.22 | second_stage           |
| outcome            | overall_survival_days_numeric    | outcome                  |                  770 |                   1636 |           47.07 |                        0    | defer                  |
| outcome            | pfs_or_progression_days_numeric  | outcome                  |                  224 |                   1636 |           13.69 |                        0    | defer                  |
| outcome            | overall_survival_event_available | event_indicator          |                  833 |                   1636 |           50.92 |                        0    | defer                  |
| outcome            | progression_event_available      | event_indicator          |                  263 |                   1636 |           16.08 |                        0    | defer                  |
| coavailability     | structural_plus_age_sex_scanner  | minimum_common_schema    |                 1608 |                   1636 |           98.29 |                       95.52 | core                   |
| coavailability     | structural_plus_segmentation     | input_plus_mask          |                 1617 |                   1636 |           98.84 |                       96.98 | high                   |
| coavailability     | structural_plus_idh              | input_plus_target        |                 1457 |                   1636 |           89.06 |                       67.98 | recommended_first      |
| coavailability     | structural_plus_mgmt             | input_plus_target        |                  815 |                   1636 |           49.82 |                       42.22 | second_stage           |
| coavailability     | structural_diffusion_perfusion   | advanced_input_set       |                  669 |                   1636 |           40.89 |                        0    | subset                 |
| coavailability     | structural_plus_os               | input_plus_outcome       |                  770 |                   1636 |           47.07 |                        0    | defer                  |
| coavailability     | structural_plus_pfs              | input_plus_outcome       |                  224 |                   1636 |           13.69 |                        0    | defer                  |
| coavailability     | structural_plus_histopath        | radiology_histopath_pair |                   18 |                   1636 |            1.1  |                        0    | pilot_only             |

## 5. Candidate Co-Availability

| cohort_definition               | required_features                                     |   subjects |   denominator_subjects |   subject_pct |
|:--------------------------------|:------------------------------------------------------|-----------:|-----------------------:|--------------:|
| structural_core                 | structural_core                                       |       1636 |                   1636 |        100    |
| structural_core_with_covariates | structural_core,age,sex,scanner_vendor,field_strength |       1608 |                   1636 |         98.29 |
| structural_plus_segmentation    | structural_core,segmentation                          |       1617 |                   1636 |         98.84 |
| structural_plus_idh             | structural_core,idh_binary_usable                     |       1457 |                   1636 |         89.06 |
| structural_segmentation_idh     | structural_core,segmentation,idh_binary_usable        |       1439 |                   1636 |         87.96 |
| structural_plus_mgmt            | structural_core,mgmt_binary_usable                    |        815 |                   1636 |         49.82 |
| structural_segmentation_mgmt    | structural_core,segmentation,mgmt_binary_usable       |        802 |                   1636 |         49.02 |
| structural_plus_grade           | structural_core,grade                                 |        999 |                   1636 |         61.06 |
| structural_plus_1p19q           | structural_core,one_p_19q_usable                      |        473 |                   1636 |         28.91 |
| structural_plus_atrx            | structural_core,atrx_usable                           |        232 |                   1636 |         14.18 |
| structural_plus_os_numeric      | structural_core,os_numeric                            |        770 |                   1636 |         47.07 |
| structural_plus_pfs_numeric     | structural_core,pfs_numeric                           |        224 |                   1636 |         13.69 |
| structural_diffusion            | structural_core,diffusion                             |        732 |                   1636 |         44.74 |
| structural_perfusion            | structural_core,perfusion                             |        675 |                   1636 |         41.26 |
| structural_diffusion_perfusion  | structural_core,diffusion,perfusion                   |        669 |                   1636 |         40.89 |
| structural_histopath_linked     | structural_core,linked_histopath                      |         18 |                   1636 |          1.1  |

## 6. Candidate Task Snapshot

| candidate_task                 | dataset        |   eligible_subjects | positive_subjects   | negative_subjects   | conflict_subjects   | scope_note                                                                                    |
|:-------------------------------|:---------------|--------------------:|:--------------------|:--------------------|:--------------------|:----------------------------------------------------------------------------------------------|
| structural_mri_common_baseline | MU-Glioma-Post |                 203 |                     |                     |                     | No outcome label; intended for representation/pretraining/segmentation-aware baseline.        |
| structural_mri_common_baseline | UCSD-PTGBM     |                 178 |                     |                     |                     | No outcome label; intended for representation/pretraining/segmentation-aware baseline.        |
| structural_mri_common_baseline | UPENN-GBM      |                 630 |                     |                     |                     | No outcome label; intended for representation/pretraining/segmentation-aware baseline.        |
| structural_mri_common_baseline | UTSW           |                 625 |                     |                     |                     | No outcome label; intended for representation/pretraining/segmentation-aware baseline.        |
| idh_prediction                 | MU-Glioma-Post |                 189 | 28.0                | 161.0               | 0.0                 | Subject-level known IDH mutant vs wildtype; conflict subjects excluded.                       |
| idh_prediction                 | UCSD-PTGBM     |                 121 | 12.0                | 109.0               | 2.0                 | Subject-level known IDH mutant vs wildtype; conflict subjects excluded.                       |
| idh_prediction                 | UPENN-GBM      |                 525 | 19.0                | 506.0               | 9.0                 | Subject-level known IDH mutant vs wildtype; conflict subjects excluded.                       |
| idh_prediction                 | UTSW           |                 622 | 176.0               | 446.0               | 0.0                 | Subject-level known IDH mutant vs wildtype; conflict subjects excluded.                       |
| mgmt_prediction                | MU-Glioma-Post |                 163 | 66.0                | 97.0                | 0.0                 | Subject-level known MGMT methylated vs unmethylated; conflict/unknown/indeterminate excluded. |
| mgmt_prediction                | UCSD-PTGBM     |                 105 | 53.0                | 52.0                | 1.0                 | Subject-level known MGMT methylated vs unmethylated; conflict/unknown/indeterminate excluded. |
| mgmt_prediction                | UPENN-GBM      |                 266 | 114.0               | 152.0               | 13.0                | Subject-level known MGMT methylated vs unmethylated; conflict/unknown/indeterminate excluded. |
| mgmt_prediction                | UTSW           |                 281 | 114.0               | 167.0               | 0.0                 | Subject-level known MGMT methylated vs unmethylated; conflict/unknown/indeterminate excluded. |

## 6b. Research Cohort Membership / Leakage Snapshot

| cohort_flag                                |   eligible_subjects |   denominator_subjects |   eligible_pct |   eligible_multi_unit_subjects |   eligible_nifti_units | positive_subjects   | negative_subjects   | recommended_use                                 |
|:-------------------------------------------|--------------------:|-----------------------:|---------------:|-------------------------------:|-----------------------:|:--------------------|:--------------------|:------------------------------------------------|
| eligible_T0_structural_common              |                1636 |                   1636 |         100    |                            245 |                   2135 |                     |                     | representation_baseline_or_preprocessing_QA     |
| eligible_T0b_structural_common_covariates  |                1608 |                   1636 |          98.29 |                            245 |                   2107 |                     |                     | baseline_schema_for_reporting_and_split_balance |
| eligible_T1_structural_idh                 |                1457 |                   1636 |          89.06 |                            209 |                   1901 | 235.0               | 1222.0              | recommended_first_supervised_task               |
| eligible_T1b_structural_segmentation_idh   |                1439 |                   1636 |          87.96 |                            209 |                   1883 | 232.0               | 1207.0              | variant_after_T1_baseline                       |
| eligible_T2_structural_mgmt                |                 815 |                   1636 |          49.82 |                            165 |                   1187 | 347.0               | 468.0               | second_stage_supervised_task                    |
| eligible_T3_structural_grade               |                 999 |                   1636 |          61.06 |                            204 |                   1457 |                     |                     | restricted_subset_only                          |
| eligible_T4_structural_os                  |                 770 |                   1636 |          47.07 |                            151 |                   1062 |                     |                     | defer_until_survival_protocol                   |
| eligible_T4b_structural_pfs                |                 224 |                   1636 |          13.69 |                            164 |                    610 |                     |                     | defer_until_survival_protocol                   |
| eligible_T5_structural_diffusion_perfusion |                 669 |                   1636 |          40.89 |                             90 |                    775 |                     |                     | advanced_imaging_subset                         |
| eligible_T6_radiology_histopath            |                  18 |                   1636 |           1.1  |                              8 |                     26 |                     |                     | pilot_multimodal_subset                         |

| scope          |   subjects |   subjects_with_multiple_nifti_units |   nifti_units |   max_units_per_subject | split_rule                                                                                          |
|:---------------|-----------:|-------------------------------------:|--------------:|------------------------:|:----------------------------------------------------------------------------------------------------|
| MU-Glioma-Post |        203 |                                  155 |           596 |                       6 | Keep all units from the same dataset::subject_id in one split.                                      |
| UCSD-PTGBM     |        178 |                                   49 |           243 |                       4 | Keep all units from the same dataset::subject_id in one split.                                      |
| UPENN-GBM      |        630 |                                   41 |           671 |                       2 | Keep all units from the same dataset::subject_id in one split.                                      |
| UTSW           |        625 |                                    0 |           625 |                       1 | Keep all units from the same dataset::subject_id in one split.                                      |
| ALL            |       1636 |                                  245 |          2135 |                       6 | Subject-level split only; never split multiple visits/scans from one subject across train/val/test. |

## 6c. Candidate Task Bias / Shortcut Snapshot

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

| task               | grouping                               |   groups |   subjects_total |   min_group_subjects |   max_group_subjects |   single_class_groups |   very_small_min_class_groups |   small_min_class_groups |   positive_pct_min |   positive_pct_max |   positive_pct_spread |   positive_pct_spread_groups_ge20 |
|:-------------------|:---------------------------------------|---------:|-----------------:|---------------------:|---------------------:|----------------------:|------------------------------:|-------------------------:|-------------------:|-------------------:|----------------------:|----------------------------------:|
| T1_structural_idh  | dataset                                |        4 |             1457 |                  121 |                  622 |                     0 |                             0 |                        2 |               3.62 |              28.3  |                 24.68 |                             24.68 |
| T1_structural_idh  | scanner_vendor_bin                     |        8 |             1457 |                    1 |                  967 |                     2 |                             3 |                        0 |               0    |             100    |                100    |                             23.37 |
| T1_structural_idh  | field_strength_bin                     |        6 |             1457 |                    1 |                  823 |                     1 |                             2 |                        1 |              10.94 |             100    |                 89.06 |                             17.63 |
| T1_structural_idh  | age_bin                                |        4 |             1457 |                  191 |                  498 |                     1 |                             0 |                        1 |               0    |              65.97 |                 65.97 |                             65.97 |
| T1_structural_idh  | sex_subject                            |        2 |             1457 |                  573 |                  884 |                     0 |                             0 |                        0 |              14.71 |              18.32 |                  3.61 |                              3.61 |
| T1_structural_idh  | dataset__scanner_vendor_bin            |       12 |             1457 |                    1 |                  518 |                     3 |                             3 |                        2 |               0    |             100    |                100    |                             31.08 |
| T1_structural_idh  | dataset__field_strength_bin            |       12 |             1457 |                    1 |                  462 |                     2 |                             5 |                        3 |               0    |             100    |                100    |                             25.62 |
| T1_structural_idh  | scanner_vendor_bin__field_strength_bin |       17 |             1457 |                    1 |                  601 |                     7 |                             3 |                        2 |               0    |             100    |                100    |                             33.78 |
| T2_structural_mgmt | dataset                                |        4 |              815 |                  105 |                  281 |                     0 |                             0 |                        0 |              40.49 |              50.48 |                  9.99 |                              9.99 |
| T2_structural_mgmt | scanner_vendor_bin                     |        7 |              815 |                    2 |                  550 |                     0 |                             3 |                        1 |              25    |              50    |                 25    |                              8.36 |
| T2_structural_mgmt | field_strength_bin                     |        6 |              815 |                    1 |                  461 |                     1 |                             1 |                        1 |               0    |              50    |                 50    |                             12.07 |
| T2_structural_mgmt | age_bin                                |        4 |              815 |                   83 |                  266 |                     0 |                             0 |                        0 |              39.47 |              48.54 |                  9.07 |                              9.07 |
| T2_structural_mgmt | sex_subject                            |        2 |              815 |                  293 |                  522 |                     0 |                             0 |                        0 |              41.19 |              45.05 |                  3.86 |                              3.86 |
| T2_structural_mgmt | dataset__scanner_vendor_bin            |       11 |              815 |                    2 |                  263 |                     0 |                             4 |                        1 |              25    |              66.67 |                 41.67 |                             20.18 |
| T2_structural_mgmt | dataset__field_strength_bin            |       11 |              815 |                    1 |                  224 |                     1 |                             1 |                        3 |               0    |              50.48 |                 50.48 |                             12.55 |
| T2_structural_mgmt | scanner_vendor_bin__field_strength_bin |       13 |              815 |                    1 |                  314 |                     2 |                             3 |                        4 |               0    |              50.82 |                 50.82 |                             25.82 |

## 7. Outcome Status

| dataset        | outcome            |   subjects_with_numeric_duration |   subject_denominator |   subjects_with_numeric_duration_pct |   unit_rows_with_numeric_duration |   unit_rows_denominator | duration_days_median   | duration_days_min   | duration_days_max   | event_values_json                                                                               | pooling_status                                              |
|:---------------|:-------------------|---------------------------------:|----------------------:|-------------------------------------:|----------------------------------:|------------------------:|:-----------------------|:--------------------|:--------------------|:------------------------------------------------------------------------------------------------|:------------------------------------------------------------|
| MU-Glioma-Post | overall_survival   |                               96 |                   203 |                                47.29 |                               300 |                     596 | 402.0                  | 10.0                | 1326.0              | {"1": 302, "0": 294}                                                                            | not_pool_ready_without_time_origin_and_censor_harmonization |
| MU-Glioma-Post | progression_or_pfs |                              152 |                   203 |                                74.88 |                               493 |                     596 | 183.0                  | 4.0                 | 2126.0              | {"1.0": 493, "0.0": 103}                                                                        | not_pool_ready_without_time_origin_and_censor_harmonization |
| UCSD-PTGBM     | overall_survival   |                               71 |                   178 |                                39.89 |                                86 |                     243 | 448.0                  | 64.0                | 1660.0              | {}                                                                                              | not_pool_ready_without_time_origin_and_censor_harmonization |
| UCSD-PTGBM     | progression_or_pfs |                               72 |                   178 |                                40.45 |                                87 |                     243 | 188.0                  | -8.0                | 1620.0              | {}                                                                                              | not_pool_ready_without_time_origin_and_censor_harmonization |
| UPENN-GBM      | overall_survival   |                              603 |                   630 |                                95.71 |                               644 |                     671 | 376.0                  | 3.0                 | 6109.0              | {"Deceased": 644, "Alive": 17, "Lost to Follow-up": 7, "Deceased - uncertain date of death": 3} | not_pool_ready_without_time_origin_and_censor_harmonization |
| UPENN-GBM      | progression_or_pfs |                                0 |                   630 |                                 0    |                                 0 |                     671 |                        |                     |                     | {"6.0": 20, "5.0": 14, "3.0": 9, "4.0": 9, "2.0": 5, "1.0": 3}                                  | not_pool_ready_without_time_origin_and_censor_harmonization |
| UTSW           | overall_survival   |                                0 |                   625 |                                 0    |                                 0 |                     625 |                        |                     |                     | {}                                                                                              | not_pool_ready_without_time_origin_and_censor_harmonization |
| UTSW           | progression_or_pfs |                                0 |                   625 |                                 0    |                                 0 |                     625 |                        |                     |                     | {}                                                                                              | not_pool_ready_without_time_origin_and_censor_harmonization |

## 8. Scanner/Confounding Snapshot

| dataset        | scanner_vendor_bin   | field_strength_bin             |   subjects |   subject_pct |   idh_mutant |   idh_wildtype |   mgmt_methylated |   mgmt_unmethylated | example_models                                                                                                  |
|:---------------|:---------------------|:-------------------------------|-----------:|--------------:|-------------:|---------------:|------------------:|--------------------:|:----------------------------------------------------------------------------------------------------------------|
| MU-Glioma-Post | siemens              | 1.5T,3T                        |        101 |         49.75 |           16 |             78 |                31 |                  51 | Aera; Avanto; Avanto_fit; Espree; MAGNETOM Vida; Skyra; Skyra_fit; Sonata                                       |
| MU-Glioma-Post | siemens              | 1.5T                           |         49 |         24.14 |            2 |             43 |                15 |                  20 | Aera; Avanto; Avanto_fit; Espree; Symphony; SymphonyTim                                                         |
| MU-Glioma-Post | siemens              | 3T                             |         46 |         22.66 |            8 |             35 |                18 |                  21 | MAGNETOM Vida; Skyra                                                                                            |
| MU-Glioma-Post | ge,siemens           | 1.5T,3T                        |          3 |          1.48 |            1 |              2 |                 1 |                   2 | Aera; DISCOVERY MR750w; MAGNETOM Sola; Optima MR450w; SIGNA Architect; Signa HDxt; Skyra                        |
| MU-Glioma-Post | philips,siemens      | 1.5T,3T                        |          2 |          0.99 |            0 |              2 |                 1 |                   1 | Ingenia Ambition X; Skyra                                                                                       |
| MU-Glioma-Post | ge,siemens           | 1.5T                           |          1 |          0.49 |            0 |              1 |                 0 |                   1 | Aera; SIGNA HDe                                                                                                 |
| MU-Glioma-Post | siemens              | 1.5T,3T,ultra_high_field_gt_3T |          1 |          0.49 |            1 |              0 |                 0 |                   1 | Aera; MAGNETOM Vida; Terra                                                                                      |
| UCSD-PTGBM     | ge                   | 3T                             |        178 |        100    |           12 |            110 |                53 |                  52 | DISCOVERY MR750; Signa HDxt                                                                                     |
| UPENN-GBM      | siemens              | 3T                             |        551 |         87.46 |           17 |            448 |                93 |                 137 | MAGNETOM Vida; NUMARIS/4; Skyra; Skyra_fit; Trio; TrioTim; Verio; syngo.via.VB10A TrioTim                       |
| UPENN-GBM      | siemens              | 1.5T                           |         67 |         10.63 |            2 |             56 |                21 |                  21 | Aera; Avanto; Avanto_fit; Espree; SymphonyTim                                                                   |
| UPENN-GBM      | ge                   | 3T                             |          5 |          0.79 |            0 |              5 |                 2 |                   1 | DISCOVERY MR750w                                                                                                |
| UPENN-GBM      | siemens              | 1.5T,3T                        |          4 |          0.63 |            0 |              4 |                 1 |                   0 | Avanto; Espree; TrioTim; Verio                                                                                  |
| UPENN-GBM      | ge                   | 1.5T                           |          3 |          0.48 |            0 |              2 |                 0 |                   0 | GENESIS_SIGNA; Optima MR450w                                                                                    |
| UTSW           | siemens              | 1.5T                           |        164 |         26.24 |           44 |            118 |                32 |                  44 | Aera; Avanto; Avanto_DOT; Avanto_fit; Espree; MAGNETOM Aera; MAGNETOM Altea; MAGNETOM Sola                      |
| UTSW           | ge                   | 1.5T                           |        139 |         22.24 |           43 |             95 |                13 |                  39 | Brivo MR355; GENESIS_SIGNA; Optima MR450w; SIGNA Artist; SIGNA EXCITE; SIGNA Explorer; SIGNA HDe; SIGNA Voyager |
| UTSW           | siemens              | 3T                             |        101 |         16.16 |           20 |             81 |                21 |                  33 | MAGNETOM Vida; Prisma; Skyra; TrioTim; Verio; Verio_DOT                                                         |
| UTSW           | philips              | 1.5T                           |         77 |         12.32 |           22 |             55 |                17 |                  17 | Achieva; Eclipse 1.5T; Gyroscan NT Intera; Ingenia; Ingenia Ambition X; Intera                                  |
| UTSW           | philips              | 3T                             |         63 |         10.08 |           26 |             37 |                11 |                  14 | Achieva; Ingenia; Ingenia Elition X                                                                             |
| UTSW           | ge                   | 3T                             |         33 |          5.28 |            7 |             26 |                 7 |                   7 | DISCOVERY MR750; DISCOVERY MR750w; SIGNA Architect; SIGNA EXCITE; Signa HDxt                                    |
| UTSW           | unknown              | unknown                        |         28 |          4.48 |            8 |             20 |                11 |                  11 |                                                                                                                 |
| UTSW           | hitachi              | low_field_lt_1.5T              |         13 |          2.08 |            4 |              9 |                 2 |                   2 | AIRIS II; Altaire; OASIS                                                                                        |
| UTSW           | siemens              | low_field_lt_1.5T              |          3 |          0.48 |            0 |              3 |                 0 |                   0 | Harmony                                                                                                         |
| UTSW           | hitachi              | 1.5T                           |          2 |          0.32 |            0 |              2 |                 0 |                   0 | ECHELON_OVAL                                                                                                    |
| UTSW           | philips              | low_field_lt_1.5T              |          1 |          0.16 |            1 |              0 |                 0 |                   0 | Intera                                                                                                          |
| UTSW           | toshiba_or_canon     | 1.5T                           |          1 |          0.16 |            1 |              0 |                 0 |                   0 | Titan                                                                                                           |

## 9. Quality Flags

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

## 10. Storage / File-Size Burden

Manifest-mapped NIfTI와 NDPI slide는 filesystem stat로 확인했고, DICOM은 828k개 개별 파일 stat 대신 series image-count burden만 요약했다.

### NIfTI file-size summary

| dataset        | modality_group   |   files |   existing_files |   missing_files |   zero_byte_files |   total_gib |   median_mib |   p95_mib |   max_mib |
|:---------------|:-----------------|--------:|-----------------:|----------------:|------------------:|------------:|-------------:|----------:|----------:|
| MU-Glioma-Post | flair            |     596 |              596 |               0 |                 0 |      2.7612 |       4.7608 |    5.5984 |    6.2535 |
| MU-Glioma-Post | segmentation     |     594 |              594 |               0 |                 0 |      0.0193 |       0.0291 |    0.057  |    0.1631 |
| MU-Glioma-Post | t1               |     596 |              596 |               0 |                 0 |      2.7538 |       4.7491 |    5.4893 |    6.2828 |
| MU-Glioma-Post | t1ce_or_t1post   |     596 |              596 |               0 |                 0 |      2.7451 |       4.7286 |    5.5266 |    6.2384 |
| MU-Glioma-Post | t2               |     596 |              596 |               0 |                 0 |      2.794  |       4.803  |    5.6811 |    6.3415 |
| UCSD-PTGBM     | diffusion        |    1937 |             1937 |               0 |                 0 |     25.3224 |       5.3323 |   81.4087 |   83.1874 |
| UCSD-PTGBM     | flair            |     243 |              243 |               0 |                 0 |      1.2668 |       5.3773 |    6.1447 |    6.5022 |
| UCSD-PTGBM     | other            |     243 |              243 |               0 |                 0 |      1.2471 |       5.2866 |    6.0549 |    6.4781 |
| UCSD-PTGBM     | perfusion        |    1245 |             1245 |               0 |                 0 |     12.5645 |       5.1169 |   35.9747 |   39.3107 |
| UCSD-PTGBM     | segmentation     |     972 |              972 |               0 |                 1 |      0.0528 |       0.0623 |    0.0709 |    0.0904 |
| UCSD-PTGBM     | t1               |     243 |              243 |               0 |                 0 |      1.279  |       5.4248 |    6.203  |    6.574  |
| UCSD-PTGBM     | t1ce_or_t1post   |     243 |              243 |               0 |                 0 |      1.2679 |       5.385  |    6.1223 |    6.5204 |
| UCSD-PTGBM     | t2               |     243 |              243 |               0 |                 0 |      1.2057 |       5.3206 |    6.1279 |    6.5358 |
| UPENN-GBM      | diffusion        |    2368 |             2368 |               0 |                 0 |     11.7019 |       5.0801 |    5.8273 |    6.674  |
| UPENN-GBM      | flair            |    1342 |             1342 |               0 |                 0 |      5.4804 |       4.9095 |    6.7203 |   20.3103 |
| UPENN-GBM      | perfusion        |    2136 |             2136 |               0 |                 0 |     34.0264 |       1.2279 |   69.7758 |  107.736  |
| UPENN-GBM      | segmentation     |     758 |              758 |               0 |                 0 |      0.0192 |       0.0251 |    0.0408 |    0.1219 |
| UPENN-GBM      | t1               |    1342 |             1342 |               0 |                 0 |      5.9363 |       5.1462 |    7.3739 |   21.3259 |
| UPENN-GBM      | t1ce_or_t1post   |    1342 |             1342 |               0 |                 0 |      6.1809 |       5.1892 |    7.7848 |   21.2768 |
| UPENN-GBM      | t2               |    1342 |             1342 |               0 |                 0 |      5.6973 |       4.1721 |    7.1973 |   21.3602 |
| UTSW           | flair            |    1250 |             1250 |               0 |                 0 |      5.7406 |       4.7209 |    5.597  |    6.7141 |
| UTSW           | segmentation     |    1349 |             1349 |               0 |                 0 |      0.0273 |       0.0185 |    0.0391 |    0.0566 |
| UTSW           | t1               |    1250 |             1250 |               0 |                 0 |      5.7152 |       4.6974 |    5.5512 |    6.5364 |
| UTSW           | t1ce_or_t1post   |    1250 |             1250 |               0 |                 0 |      5.7019 |       4.6919 |    5.5524 |    6.5083 |
| UTSW           | t2               |    1250 |             1250 |               0 |                 0 |      5.788  |       4.7658 |    5.6537 |    6.7332 |

### DICOM series image-count summary

| series_concept    |   series |   subjects |   total_images |   median_images_per_series |   p95_images_per_series |   max_images_per_series |   series_dirs_existing |
|:------------------|---------:|-----------:|---------------:|---------------------------:|------------------------:|------------------------:|-----------------------:|
| perfusion         |      489 |        455 |         437885 |                        900 |                   900   |                    1035 |                    489 |
| t1                |      680 |        597 |         120034 |                        192 |                   192   |                     248 |                    680 |
| t1ce_or_t1post    |      605 |        566 |         111411 |                        192 |                   192   |                     208 |                    605 |
| dti_or_diffusion  |      580 |        542 |          65815 |                         93 |                    93   |                    3720 |                    580 |
| t2                |      653 |        613 |          51510 |                         64 |                   192   |                     192 |                    653 |
| flair             |      655 |        614 |          38547 |                         60 |                    60   |                      78 |                    655 |
| secondary_capture |        9 |          8 |           1744 |                        192 |                   201.6 |                     208 |                      9 |
| other_mr          |        9 |          8 |           1288 |                        176 |                   192   |                     192 |                      9 |

### Histopath slide size summary

| slide_group          |   slides |   unique_radiology_subjects |   total_gib |   median_gib |   p95_gib |   max_gib |
|:---------------------|---------:|----------------------------:|------------:|-------------:|----------:|----------:|
| all_slides           |       71 |                          18 |    148.301  |       2.0472 |    3.7708 |    3.963  |
| linked_to_radiology  |       38 |                          18 |     76.7422 |       2.0711 |    3.1747 |    3.9214 |
| missing_radiology_id |       33 |                           0 |     71.5591 |       2.0381 |    3.9261 |    3.963  |

## 11. Recommended First Research Direction

권장 첫 task:

1. Input: structural MRI core, 최소 T1/T1c/T2/FLAIR 공통 입력.
2. Label: IDH mutant vs wildtype, subject-level conflict 제외.
3. Unit: subject-level split. MU/UCSD/UPENN multi-unit은 같은 split에 묶는다.
4. Evaluation: pooled internal split만으로 충분하지 않다. Dataset/scanner-aware reporting과 leave-one-consortium-out 평가를 포함한다.
5. Covariates/reporting: age, sex, scanner vendor, field strength, dataset을 반드시 split/report에 포함한다.

왜 IDH 먼저인가:

- 모든 dataset에서 usable label이 존재한다.
- conflict 제외 후 1,457 subjects로 규모가 가장 좋다.
- MGMT보다 missingness가 낮고, survival/PFS보다 semantics harmonization 부담이 작다.

주의:

- IDH mutant rate가 dataset/scanner와 강하게 얽혀 있으므로 random split만 사용하면 shortcut 위험이 크다.
- full image header audit과 preprocessing policy 없이 바로 training으로 넘어가면 안 된다.

## 12. Completion Audit

| requirement                                           | status                              | evidence                                                                                                                                                | scope_verified                                                                                                               | remaining_gap                                                                               |
|:------------------------------------------------------|:------------------------------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------|:-----------------------------------------------------------------------------------------------------------------------------|:--------------------------------------------------------------------------------------------|
| downloaded package inventory and consortium status    | complete                            | eda_dataset_status_master.csv; eda_master_report.md                                                                                                     | primary package file counts, subjects/sessions/studies/series/slides                                                         |                                                                                             |
| clinical metadata distribution profiling              | complete                            | eda_variable_profile.csv; modeling_subject_label_distributions.csv; common_variable_codebook.csv                                                        | raw metadata column missingness/top values and subject-level harmonized distributions                                        |                                                                                             |
| imaging modality coverage profiling                   | complete                            | eda_imaging_inventory.csv; modeling_imaging_coverage.csv; deep_coavailability_matrix.csv                                                                | NIfTI unit and subject-level structural/segmentation/diffusion/perfusion availability                                        | Full image header audit remains approval-gated.                                             |
| common usable data summary                            | complete                            | deep_common_data_tiers.csv; clinical_imaging_deep_dive.md                                                                                               | tiered common clinical/imaging/label/outcome/multimodal readiness                                                            |                                                                                             |
| consortium-level common data matrix                   | complete                            | consortium_common_data_matrix.csv; consortium_common_data_wide.csv; consortium_selected_distribution.csv; consortium_common_data_matrix.md              | subject-level feature availability by consortium for clinical, imaging, molecular label, outcome, and co-availability fields |                                                                                             |
| canonical modeling unit manifest                      | complete                            | canonical_manifest.csv; manifest_harmonization_summary.md                                                                                               | NIfTI/DICOM/histopath unit rows and path mappings                                                                            | UPENN duplicate structural old/non-old path preference must be chosen before preprocessing. |
| label harmonization and conflict audit                | complete                            | label_harmonization_audit.csv; label_harmonization_counts.csv; label_harmonization_subject_conflicts.csv                                                | IDH/MGMT/1p19q/ATRX/diagnosis/grade harmonized labels and subject conflicts                                                  | Task-specific conflict exclusion or resolution rule needed before split creation.           |
| modeling-oriented subject table and candidate cohorts | complete                            | modeling_subject_table.csv; candidate_task_feasibility.csv; modeling_eda_detail.md                                                                      | subject-level covariate/label/imaging availability and candidate task counts                                                 | No split/preprocessing/training has been created.                                           |
| research cohort membership and leakage grouping       | complete                            | research_cohort_membership.csv; research_cohort_summary.csv; research_leakage_group_audit.csv; research_cohort_membership.md                            | subject-level candidate cohort flags and dataset::subject_id split grouping risk                                             | No actual split file created; split policy still requires Min approval.                     |
| candidate supervised task bias audit                  | complete                            | candidate_task_bias_group_distribution.csv; candidate_task_bias_group_summary.csv; candidate_task_bias_dataset_matrix.csv; candidate_task_bias_audit.md | IDH/MGMT positive-rate variation by dataset, scanner, field strength, age, sex, and small-cell strata                        | Use this audit when approving split/reporting policy; no split file created.                |
| final EDA synthesis and objective evidence matrix     | complete                            | eda_final_synthesis_ko.md; eda_completion_evidence_matrix.csv; eda_start_here_index.csv                                                                 | start-here synthesis and objective-to-evidence completion mapping                                                            | Approval-gated full audits and modeling remain outside this EDA synthesis.                  |
| co-availability and pairwise feature readiness        | complete                            | deep_coavailability_matrix.csv; deep_pairwise_feature_availability.csv                                                                                  | feature combinations such as structural+IDH, structural+segmentation+IDH, structural+MGMT                                    |                                                                                             |
| scanner/confound distribution                         | complete                            | deep_scanner_distribution.csv; modeling_label_confound_summary.csv                                                                                      | dataset/scanner/field/sex/age-bin associations with IDH/MGMT labels                                                          | Use these fields in split balance and reporting.                                            |
| outcome availability and semantics warning            | complete_with_caveat                | deep_outcome_availability.csv; deep_data_quality_flags.csv                                                                                              | OS/PFS numeric duration availability and not-pool-ready status                                                               | Outcome modeling requires time-origin/censor harmonization and raw inspection.              |
| image header quality audit                            | sample_complete_full_approval_gated | nifti_header_audit_sample.csv; nifti_zero_byte_files.csv                                                                                                | sample NIfTI header geometry and full-manifest zero-byte NIfTI scan                                                          | Full NIfTI header audit not run without approval.                                           |
| DICOM and histopath audit                             | sample_complete_full_approval_gated | dicom_series_inventory.csv; dicom_header_audit_sample.csv; histopath_slide_inventory.csv                                                                | UPENN DICOM series inventory, sample DICOM headers, NDPI slide inventory                                                     | Full DICOM header audit and WSI pixel audit not run without approval/environment.           |
| storage and file-size audit                           | complete                            | eda_storage_size_audit.md; nifti_file_size_inventory.csv; nifti_file_size_summary.csv; dicom_series_image_count_summary.csv; histopath_size_summary.csv | filesystem stat for manifest-mapped NIfTI and NDPI slides, plus DICOM series image-count burden                              | Individual DICOM file-size stat intentionally not run over 828k files.                      |
| preprocessing/split/training status                   | not_started_by_design               | No split/preprocessing/training artifacts were created in this EDA phase.                                                                               | EDA-only guardrail respected                                                                                                 | Needs Min approval and explicit task/split/metric/compute scope.                            |

## 13. Next Gate

다음 단계로 넘어가기 전 Min이 명시적으로 정해야 하는 항목:

- 첫 task를 IDH prediction으로 확정할지 여부.
- full NIfTI header audit 실행 여부.
- UCSD zero-byte segmentation 1개 repair/exclude 정책.
- UPENN duplicate structural old/non-old path preference.
- split policy: leave-one-consortium-out 포함 여부, validation/test 비율, scanner stratification.
- preprocessing target geometry/orientation/normalization policy.
