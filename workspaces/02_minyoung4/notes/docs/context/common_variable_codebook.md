# Common Variable Codebook

Generated from `canonical_manifest.csv` NIfTI rows. Counts include both unit rows and unique subjects.

## Dataset Summary

| dataset        |   nifti_units |   unique_subjects |   age_subjects_nonmissing |   age_mean |   age_median |   age_min |   age_max |   sex_known_subjects |   structural_units |   segmentation_units |   dti_or_diffusion_units |   perfusion_units | top_scanner_manufacturers                                        | top_field_strengths                    |
|:---------------|--------------:|------------------:|--------------------------:|-----------:|-------------:|----------:|----------:|---------------------:|-------------------:|---------------------:|-------------------------:|------------------:|:-----------------------------------------------------------------|:---------------------------------------|
| MU-Glioma-Post |           596 |               203 |                       203 |      57.88 |        61    |     19    |      87   |                  203 |                596 |                  594 |                        0 |                 0 | siemens=198; ge=1                                                | 1.5T=117; 3T=86                        |
| UCSD-PTGBM     |           243 |               178 |                       178 |      55.72 |        56    |     20    |      88   |                  178 |                243 |                  243 |                      243 |               243 | ge=178                                                           | 3T=178                                 |
| UPENN-GBM      |           671 |               630 |                       630 |      62.67 |        63.42 |     18.65 |      88.5 |                  630 |                671 |                  611 |                      592 |               534 | siemens=622; ge=8                                                | 3T=557; 1.5T=73                        |
| UTSW           |           625 |               625 |                       625 |      55.04 |        58    |     18    |      85   |                  625 |                625 |                  625 |                        0 |                 0 | siemens=268; ge=172; philips=141; hitachi=15; toshiba_or_canon=1 | 1.5T=383; 3T=197; low_field_lt_1.5T=17 |

## Raw-to-Harmonized Highlights

### sex
| variable   | dataset        | raw_value   | harmonized_value   |   unit_rows |   unique_subjects | is_unknown_or_missing   |
|:-----------|:---------------|:------------|:-------------------|------------:|------------------:|:------------------------|
| sex        | MU-Glioma-Post | Male        | male               |         340 |               119 | False                   |
| sex        | MU-Glioma-Post | Female      | female             |         256 |                84 | False                   |
| sex        | UCSD-PTGBM     | Male        | male               |         166 |               129 | False                   |
| sex        | UCSD-PTGBM     | Female      | female             |          77 |                49 | False                   |
| sex        | UPENN-GBM      | M           | male               |         405 |               378 | False                   |
| sex        | UPENN-GBM      | F           | female             |         266 |               252 | False                   |
| sex        | UTSW           | M           | male               |         371 |               371 | False                   |
| sex        | UTSW           | F           | female             |         254 |               254 | False                   |

### diagnosis
| variable   | dataset        | raw_value                        | harmonized_value   |   unit_rows |   unique_subjects | is_unknown_or_missing   |
|:-----------|:---------------|:---------------------------------|:-------------------|------------:|------------------:|:------------------------|
| diagnosis  | MU-Glioma-Post | GBM                              | glioblastoma       |         447 |               157 | False                   |
| diagnosis  | MU-Glioma-Post | Astrocytoma                      | astrocytic         |          82 |                28 | False                   |
| diagnosis  | MU-Glioma-Post | Diffuse glioma                   | diffuse_glioma     |          45 |                10 | False                   |
| diagnosis  | MU-Glioma-Post | Oligodendro-glioma               | oligodendroglial   |          11 |                 4 | False                   |
| diagnosis  | MU-Glioma-Post | Pilocytic astrocytoma            | astrocytic         |           9 |                 3 | False                   |
| diagnosis  | MU-Glioma-Post | Glioma w/ GBM features           | glioblastoma       |           2 |                 1 | False                   |
| diagnosis  | UCSD-PTGBM     | Glioblastoma                     | glioblastoma       |         235 |               172 | False                   |
| diagnosis  | UCSD-PTGBM     | Astrocytoma, IDH-Mutant, Grade 4 | astrocytic         |           4 |                 2 | False                   |
| diagnosis  | UCSD-PTGBM     | Oligoastrocytoma                 | oligodendroglial   |           2 |                 2 | False                   |
| diagnosis  | UCSD-PTGBM     | Anaplastic Astrocytoma           | astrocytic         |           1 |                 1 | False                   |
| diagnosis  | UCSD-PTGBM     | Astrocytoma, IDH-Mutant, Grade 5 | astrocytic         |           1 |                 1 | False                   |
| diagnosis  | UPENN-GBM      | GBM collection                   | gbm_collection     |         671 |               630 | False                   |
| diagnosis  | UTSW           | GLIOBLASTOMA                     | glioblastoma       |         387 |               387 | False                   |
| diagnosis  | UTSW           | ASTROCYTOMA, ANAPLASTIC          | astrocytic         |          34 |                34 | False                   |
| diagnosis  | UTSW           | OLIGODENDROGLIOMA GRADE 2        | oligodendroglial   |          32 |                32 | False                   |
| diagnosis  | UTSW           | ASTROCYTOMA, NOS                 | astrocytic         |          31 |                31 | False                   |
| diagnosis  | UTSW           | ASTROCYTOMA, INFILTRATING        | astrocytic         |          26 |                26 | False                   |
| diagnosis  | UTSW           | OLIGODENDROGLIOMA, ANAPLASTIC    | oligodendroglial   |          20 |                20 | False                   |
| diagnosis  | UTSW           | ASTROCYTOMA, HIGH-GRADE          | astrocytic         |          13 |                13 | False                   |
| diagnosis  | UTSW           | OLIGOASTROCYTOMA GRADE 2         | oligodendroglial   |          13 |                13 | False                   |
| diagnosis  | UTSW           | OLIGODENDROGLIOMA, NOS           | oligodendroglial   |          13 |                13 | False                   |
| diagnosis  | UTSW           | OLIGOASTROCYTOMA, ANAPLASTIC     | oligodendroglial   |          12 |                12 | False                   |
| diagnosis  | UTSW           | OTHER                            | other              |          12 |                12 | False                   |
| diagnosis  | UTSW           | ASTROCYTOMA, DIFFUSE             | astrocytic         |           7 |                 7 | False                   |
| diagnosis  | UTSW           | GLIOMA, HIGH-GRADE               | other              |           7 |                 7 | False                   |
| diagnosis  | UTSW           | DIFFUSE MIDLINE GLIOMA           | other              |           6 |                 6 | False                   |
| diagnosis  | UTSW           | GLIOMA, NOS                      | other              |           4 |                 4 | False                   |
| diagnosis  | UTSW           | INFILTRATING GLIOMA, HIGH-GRADE  | other              |           4 |                 4 | False                   |
| diagnosis  | UTSW           | OLIGOASTROCYTOMA                 | oligodendroglial   |           4 |                 4 | False                   |

### grade
| variable   | dataset        | raw_value   | harmonized_value   |   unit_rows |   unique_subjects | is_unknown_or_missing   |
|:-----------|:---------------|:------------|:-------------------|------------:|------------------:|:------------------------|
| grade      | MU-Glioma-Post | 4           | 4                  |         494 |               168 | False                   |
| grade      | MU-Glioma-Post | 2           | 2                  |          85 |                28 | False                   |
| grade      | MU-Glioma-Post | 1           | 1                  |           9 |                 3 | False                   |
| grade      | MU-Glioma-Post | 3           | 3                  |           6 |                 2 | False                   |
| grade      | MU-Glioma-Post | 3 vs 4      | 3_vs_4             |           2 |                 2 | False                   |
| grade      | UCSD-PTGBM     | 4           | 4                  |         240 |               175 | False                   |
| grade      | UCSD-PTGBM     | 3           | 3                  |           2 |                 2 | False                   |
| grade      | UCSD-PTGBM     | 2           | 2                  |           1 |                 1 | False                   |
| grade      | UPENN-GBM      | <missing>   | unknown            |         671 |               630 | True                    |
| grade      | UTSW           | 4.0         | 4                  |         420 |               420 | False                   |
| grade      | UTSW           | 2.0         | 2                  |         101 |               101 | False                   |
| grade      | UTSW           | 3.0         | 3                  |          97 |                97 | False                   |
| grade      | UTSW           | <missing>   | unknown            |           7 |                 7 | True                    |

### idh
| variable   | dataset        | raw_value     | harmonized_value   |   unit_rows |   unique_subjects | is_unknown_or_missing   |
|:-----------|:---------------|:--------------|:-------------------|------------:|------------------:|:------------------------|
| idh        | MU-Glioma-Post | IDH1=0;IDH2=0 | wildtype           |         459 |               161 | False                   |
| idh        | MU-Glioma-Post | IDH1=1;IDH2=2 | mutant             |          71 |                21 | False                   |
| idh        | MU-Glioma-Post | IDH1=2;IDH2=2 | unknown            |          35 |                13 | True                    |
| idh        | MU-Glioma-Post | IDH1=1;IDH2=0 | mutant             |          28 |                 7 | False                   |
| idh        | MU-Glioma-Post | IDH1=0;IDH2=2 | unknown            |           3 |                 1 | True                    |
| idh        | UCSD-PTGBM     | Wild type     | wildtype           |         148 |               111 | False                   |
| idh        | UCSD-PTGBM     | <missing>     | unknown            |          75 |                56 | True                    |
| idh        | UCSD-PTGBM     | Mutant        | mutant             |          20 |                13 | False                   |
| idh        | UPENN-GBM      | Wildtype      | wildtype           |         546 |               515 | False                   |
| idh        | UPENN-GBM      | NOS/NEC       | unknown            |         106 |               105 | True                    |
| idh        | UPENN-GBM      | Mutated       | mutant             |          19 |                19 | False                   |
| idh        | UTSW           | wild type     | wildtype           |         446 |               446 | False                   |
| idh        | UTSW           | mutated       | mutant             |         176 |               176 | False                   |
| idh        | UTSW           | <missing>     | unknown            |           3 |                 3 | True                    |

### mgmt
| variable   | dataset        | raw_value     | harmonized_value   |   unit_rows |   unique_subjects | is_unknown_or_missing   |
|:-----------|:---------------|:--------------|:-------------------|------------:|------------------:|:------------------------|
| mgmt       | MU-Glioma-Post | 0             | unmethylated       |         295 |                97 | False                   |
| mgmt       | MU-Glioma-Post | 1             | methylated         |         188 |                66 | False                   |
| mgmt       | MU-Glioma-Post | 4             | unknown            |          77 |                29 | True                    |
| mgmt       | MU-Glioma-Post | 2             | indeterminate      |          36 |                11 | False                   |
| mgmt       | UCSD-PTGBM     | <missing>     | unknown            |          94 |                72 | True                    |
| mgmt       | UCSD-PTGBM     | Methylated    | methylated         |          76 |                54 | False                   |
| mgmt       | UCSD-PTGBM     | Unmethylated  | unmethylated       |          73 |                53 | False                   |
| mgmt       | UPENN-GBM      | Not Available | unknown            |         348 |               333 | True                    |
| mgmt       | UPENN-GBM      | Unmethylated  | unmethylated       |         170 |               162 | False                   |
| mgmt       | UPENN-GBM      | Methylated    | methylated         |         121 |               118 | False                   |
| mgmt       | UPENN-GBM      | Indeterminate | indeterminate      |          32 |                30 | False                   |
| mgmt       | UTSW           | <missing>     | unknown            |         344 |               344 | True                    |
| mgmt       | UTSW           | unmethylated  | unmethylated       |         167 |               167 | False                   |
| mgmt       | UTSW           | methylated    | methylated         |         114 |               114 | False                   |

### 1p19q
| variable   | dataset        | raw_value      | harmonized_value        |   unit_rows |   unique_subjects | is_unknown_or_missing   |
|:-----------|:---------------|:---------------|:------------------------|------------:|------------------:|:------------------------|
| 1p19q      | MU-Glioma-Post | 10             | unknown                 |         415 |               145 | True                    |
| 1p19q      | MU-Glioma-Post | 0              | intact_or_not_codeleted |         141 |                45 | False                   |
| 1p19q      | MU-Glioma-Post | 1              | codeleted               |          17 |                 5 | False                   |
| 1p19q      | MU-Glioma-Post | 2              | other_abnormal          |           6 |                 2 | False                   |
| 1p19q      | MU-Glioma-Post | 8              | other_abnormal          |           5 |                 1 | False                   |
| 1p19q      | MU-Glioma-Post | 4              | other_abnormal          |           4 |                 1 | False                   |
| 1p19q      | MU-Glioma-Post | 7              | other_abnormal          |           4 |                 2 | False                   |
| 1p19q      | MU-Glioma-Post | 6              | other_abnormal          |           3 |                 1 | False                   |
| 1p19q      | MU-Glioma-Post | 5              | other_abnormal          |           1 |                 1 | False                   |
| 1p19q      | UCSD-PTGBM     | <missing>      | unknown                 |         131 |                98 | True                    |
| 1p19q      | UCSD-PTGBM     | Intact         | intact_or_not_codeleted |         103 |                75 | False                   |
| 1p19q      | UCSD-PTGBM     | Codeleted      | codeleted               |           9 |                 6 | False                   |
| 1p19q      | UPENN-GBM      | <missing>      | unknown                 |         671 |               630 | True                    |
| 1p19q      | UTSW           | <missing>      | unknown                 |         290 |               290 | True                    |
| 1p19q      | UTSW           | non co-deleted | intact_or_not_codeleted |         272 |               272 | False                   |
| 1p19q      | UTSW           | co-deleted     | codeleted               |          63 |                63 | False                   |

### atrx
| variable   | dataset        | raw_value   | harmonized_value      |   unit_rows |   unique_subjects | is_unknown_or_missing   |
|:-----------|:---------------|:------------|:----------------------|------------:|------------------:|:------------------------|
| atrx       | MU-Glioma-Post | 0           | intact_or_no_mutation |         347 |               122 | False                   |
| atrx       | MU-Glioma-Post | 4           | unknown               |         152 |                55 | True                    |
| atrx       | MU-Glioma-Post | 1           | altered_or_loss       |          90 |                23 | False                   |
| atrx       | MU-Glioma-Post | 2           | mosaic_or_possible    |           7 |                 3 | False                   |
| atrx       | UCSD-PTGBM     | <missing>   | unknown               |         129 |                94 | True                    |
| atrx       | UCSD-PTGBM     | Intact      | intact_or_no_mutation |          95 |                70 | False                   |
| atrx       | UCSD-PTGBM     | Loss        | altered_or_loss       |          19 |                14 | False                   |
| atrx       | UPENN-GBM      | <missing>   | unknown               |         671 |               630 | True                    |
| atrx       | UTSW           | <missing>   | unknown               |         625 |               625 | True                    |

### field_strength
| variable       | dataset        | raw_value    | harmonized_value       |   unit_rows |   unique_subjects | is_unknown_or_missing   |
|:---------------|:---------------|:-------------|:-----------------------|------------:|------------------:|:------------------------|
| field_strength | MU-Glioma-Post | 3.0          | 3T                     |         305 |               153 | False                   |
| field_strength | MU-Glioma-Post | 1.5          | 1.5T                   |         290 |               157 | False                   |
| field_strength | MU-Glioma-Post | 7.0          | ultra_high_field_gt_3T |           1 |                 1 | False                   |
| field_strength | UCSD-PTGBM     | 3            | 3T                     |         243 |               178 | False                   |
| field_strength | UPENN-GBM      | 3.0          | 3T                     |         596 |               559 | False                   |
| field_strength | UPENN-GBM      | 1.5          | 1.5T                   |          74 |                74 | False                   |
| field_strength | UPENN-GBM      | 2.893620014  | 3T                     |           1 |                 1 | False                   |
| field_strength | UTSW           | 1.5          | 1.5T                   |         383 |               383 | False                   |
| field_strength | UTSW           | 3            | 3T                     |         197 |               197 | False                   |
| field_strength | UTSW           | Not Reported | unknown                |          28 |                28 | True                    |
| field_strength | UTSW           | 0.7          | low_field_lt_1.5T      |           6 |                 6 | False                   |
| field_strength | UTSW           | 1.16         | low_field_lt_1.5T      |           5 |                 5 | False                   |
| field_strength | UTSW           | 1            | low_field_lt_1.5T      |           3 |                 3 | False                   |
| field_strength | UTSW           | 0.3          | low_field_lt_1.5T      |           2 |                 2 | False                   |
| field_strength | UTSW           | 0.94999999   | low_field_lt_1.5T      |           1 |                 1 | False                   |

### scanner_manufacturer
| variable             | dataset        | raw_value               | harmonized_value   |   unit_rows |   unique_subjects | is_unknown_or_missing   |
|:---------------------|:---------------|:------------------------|:-------------------|------------:|------------------:|:------------------------|
| scanner_manufacturer | MU-Glioma-Post | SIEMENS                 | siemens            |         471 |               198 | False                   |
| scanner_manufacturer | MU-Glioma-Post | Siemens Healthineers    | siemens            |          55 |                31 | False                   |
| scanner_manufacturer | MU-Glioma-Post | Siemens                 | siemens            |          34 |                24 | False                   |
| scanner_manufacturer | MU-Glioma-Post | <missing>               | unknown            |          17 |                11 | True                    |
| scanner_manufacturer | MU-Glioma-Post | GE MEDICAL SYSTEMS      | ge                 |           9 |                 4 | False                   |
| scanner_manufacturer | MU-Glioma-Post | Siemens HealthCare GmbH | siemens            |           8 |                 5 | False                   |
| scanner_manufacturer | MU-Glioma-Post | Philips                 | philips            |           2 |                 2 | False                   |
| scanner_manufacturer | UCSD-PTGBM     | GE MEDICAL SYSTEMS      | ge                 |         243 |               178 | False                   |
| scanner_manufacturer | UPENN-GBM      | SIEMENS                 | siemens            |         663 |               622 | False                   |
| scanner_manufacturer | UPENN-GBM      | GE MEDICAL SYSTEMS      | ge                 |           8 |                 8 | False                   |
| scanner_manufacturer | UTSW           | Siemens                 | siemens            |         268 |               268 | False                   |
| scanner_manufacturer | UTSW           | GE                      | ge                 |         172 |               172 | False                   |
| scanner_manufacturer | UTSW           | Philips                 | philips            |         141 |               141 | False                   |
| scanner_manufacturer | UTSW           | Not Reported            | unknown            |          28 |                28 | True                    |
| scanner_manufacturer | UTSW           | Hitachi                 | hitachi            |          15 |                15 | False                   |
| scanner_manufacturer | UTSW           | Toshiba                 | toshiba_or_canon   |           1 |                 1 | False                   |

## Interpretation Notes

- `unit_rows` can exceed `unique_subjects` for longitudinal/multi-scan datasets.
- Scanner manufacturer/model values are not harmonized beyond raw string grouping; they should be normalized before covariate modeling.
- Molecular labels use conservative harmonization from the local codebooks and should still be checked against task-specific inclusion rules.
