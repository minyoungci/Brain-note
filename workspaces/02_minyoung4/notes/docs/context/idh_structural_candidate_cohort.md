# IDH Structural MRI Candidate Cohort Audit

This is a draft cohort audit only. No split, preprocessing, or training was created.

## Eligibility Summary

| candidate_cohort            | dataset        | idh_label   |   eligible_subjects | eligible_units_total   | subjects_with_multiple_units   |
|:----------------------------|:---------------|:------------|--------------------:|:-----------------------|:-------------------------------|
| eligible_structural_idh     | MU-Glioma-Post | mutant      |                  28 | 99                     | 24                             |
| eligible_structural_idh     | MU-Glioma-Post | wildtype    |                 161 | 459                    | 121                            |
| eligible_structural_idh     | MU-Glioma-Post | excluded    |                  14 |                        |                                |
| eligible_structural_seg_idh | MU-Glioma-Post | mutant      |                  28 | 97                     | 24                             |
| eligible_structural_seg_idh | MU-Glioma-Post | wildtype    |                 161 | 459                    | 121                            |
| eligible_structural_seg_idh | MU-Glioma-Post | excluded    |                  14 |                        |                                |
| eligible_structural_idh     | UCSD-PTGBM     | mutant      |                  12 | 19                     | 6                              |
| eligible_structural_idh     | UCSD-PTGBM     | wildtype    |                 109 | 146                    | 27                             |
| eligible_structural_idh     | UCSD-PTGBM     | excluded    |                  57 |                        |                                |
| eligible_structural_seg_idh | UCSD-PTGBM     | mutant      |                  12 | 19                     | 6                              |
| eligible_structural_seg_idh | UCSD-PTGBM     | wildtype    |                 109 | 145                    | 27                             |
| eligible_structural_seg_idh | UCSD-PTGBM     | excluded    |                  57 |                        |                                |
| eligible_structural_idh     | UPENN-GBM      | mutant      |                  19 | 19                     | 0                              |
| eligible_structural_idh     | UPENN-GBM      | wildtype    |                 506 | 537                    | 31                             |
| eligible_structural_idh     | UPENN-GBM      | excluded    |                 105 |                        |                                |
| eligible_structural_seg_idh | UPENN-GBM      | mutant      |                  16 | 16                     | 0                              |
| eligible_structural_seg_idh | UPENN-GBM      | wildtype    |                 491 | 491                    | 31                             |
| eligible_structural_seg_idh | UPENN-GBM      | excluded    |                 123 |                        |                                |
| eligible_structural_idh     | UTSW           | mutant      |                 176 | 176                    | 0                              |
| eligible_structural_idh     | UTSW           | wildtype    |                 446 | 446                    | 0                              |
| eligible_structural_idh     | UTSW           | excluded    |                   3 |                        |                                |
| eligible_structural_seg_idh | UTSW           | mutant      |                 176 | 176                    | 0                              |
| eligible_structural_seg_idh | UTSW           | wildtype    |                 446 | 446                    | 0                              |
| eligible_structural_seg_idh | UTSW           | excluded    |                   3 |                        |                                |

## Confound / Stratification Summary

| grouping             | value                          |   eligible_subjects |   mutant |   wildtype |   mutant_pct |
|:---------------------|:-------------------------------|--------------------:|---------:|-----------:|-------------:|
| dataset              | MU-Glioma-Post                 |                 189 |       28 |        161 |        14.81 |
| dataset              | UCSD-PTGBM                     |                 121 |       12 |        109 |         9.92 |
| dataset              | UPENN-GBM                      |                 525 |       19 |        506 |         3.62 |
| dataset              | UTSW                           |                 622 |      176 |        446 |        28.3  |
| scanner_vendor_bin   | ge                             |                 299 |       62 |        237 |        20.74 |
| scanner_vendor_bin   | ge,siemens                     |                   4 |        1 |          3 |        25    |
| scanner_vendor_bin   | hitachi                        |                  15 |        4 |         11 |        26.67 |
| scanner_vendor_bin   | philips                        |                 141 |       49 |         92 |        34.75 |
| scanner_vendor_bin   | philips,siemens                |                   2 |        0 |          2 |         0    |
| scanner_vendor_bin   | siemens                        |                 957 |      110 |        847 |        11.49 |
| scanner_vendor_bin   | siemens,unknown                |                  10 |        0 |         10 |         0    |
| scanner_vendor_bin   | toshiba_or_canon               |                   1 |        1 |          0 |       100    |
| scanner_vendor_bin   | unknown                        |                  28 |        8 |         20 |        28.57 |
| field_strength_bin   | 1.5T                           |                 486 |      114 |        372 |        23.46 |
| field_strength_bin   | 1.5T,3T                        |                 102 |       17 |         85 |        16.67 |
| field_strength_bin   | 1.5T,3T,ultra_high_field_gt_3T |                   1 |        1 |          0 |       100    |
| field_strength_bin   | 3T                             |                 823 |       90 |        733 |        10.94 |
| field_strength_bin   | low_field_lt_1.5T              |                  17 |        5 |         12 |        29.41 |
| field_strength_bin   | unknown                        |                  28 |        8 |         20 |        28.57 |
| sex_harmonized_first | female                         |                 573 |      105 |        468 |        18.32 |
| sex_harmonized_first | male                           |                 884 |      130 |        754 |        14.71 |

## Rule Draft

Inclusion for structural IDH candidate:

- NIfTI representation row exists for the subject.
- At least one unit has core structural MRI.
- Subject-level IDH resolves to `mutant` or `wildtype`.
- Subject has no IDH conflict in `label_harmonization_subject_conflicts.csv`.

Optional structural+segmentation variant additionally requires at least one usable segmentation unit and excludes known zero-byte NIfTI paths.

Split policy draft:

- Split by `dataset + subject_id`, never by unit row.
- Report dataset, scanner vendor bin, field strength bin, age, and sex distribution per split.
- Consider leave-one-consortium-out or external-dataset validation because IDH class balance and scanner/site are strongly coupled.
