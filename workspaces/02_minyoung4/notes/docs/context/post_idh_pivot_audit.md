# Post-IDH NO-GO Pivot Audit

Generated from existing context artifacts only. No raw images were loaded and no GPU job was launched.

## IDH Status

- B2_res3dnet_proxy: available=True go=False dAUC=-0.04051352445312639 CI=[-0.05045477975347899, -0.03101906279559618]
- B3_lesion_roi_resnet_proxy: available=True go=False dAUC=-0.036960238640910914 CI=[-0.049694093877189705, -0.024800594702569494]

Interpretation: IDH should not be promoted as a performance-improvement method claim. B3 used an oracle lesion ROI/mask input and still failed to add value over age_sex.

## Next Candidate Ranking

|   rank | candidate                                              | status                                                    |   n_subjects |   n_positive |   clinical_age_sex_auc_mean |   clinical_age_sex_scanner_auc_mean | why                                                                                                    | next_gate                                                                                  |
|-------:|:-------------------------------------------------------|:----------------------------------------------------------|-------------:|-------------:|----------------------------:|------------------------------------:|:-------------------------------------------------------------------------------------------------------|:-------------------------------------------------------------------------------------------|
|      1 | MGMT methylation prediction                            | best_next_ceiling_probe_candidate                         |          815 |          347 |                    0.528191 |                            0.509656 | All four datasets, balanced positives by dataset, and lower age/site shortcut risk than IDH.           | Run MGMT image ceiling probe with same LOCO+nested-OOF protocol before proposing a method. |
|      2 | Self-supervised structural+segmentation representation | method_pretraining_candidate_not_direct_performance_claim |         1617 |          nan |                  nan        |                          nan        | Near-complete segmentation supports a mask-aware representation method, but needs a downstream target. | Use only if paired with MGMT or another validated downstream endpoint.                     |
|      3 | Survival modeling                                      | defer                                                     |          770 |          nan |                  nan        |                          nan        | OS exists but time origin/censor semantics are not harmonized and UTSW has no OS.                      | Raw outcome harmonization before any modeling.                                             |
|      4 | IDH lesion-grounded performance claim                  | stop_or_negative_benchmark_only                           |         1421 |          nan |                  nan        |                          nan        | B3 oracle lesion-ROI failed over age_sex: dAUC=-0.036960238640910914.                                  | Do not promote CTEC/IDH unless the research question is reframed as a negative benchmark.  |

## MGMT Dataset Balance

| value          |   subjects |   positive |   negative |   positive_pct |
|:---------------|-----------:|-----------:|-----------:|---------------:|
| MU-Glioma-Post |        163 |         66 |         97 |        40.4908 |
| UCSD-PTGBM     |        105 |         53 |         52 |        50.4762 |
| UPENN-GBM      |        266 |        114 |        152 |        42.8571 |
| UTSW           |        281 |        114 |        167 |        40.5694 |

## MGMT Clinical Shortcut Floor

| feature_set     |   valid_auc_folds |   auc_mean |   auc_min |   auc_max |   auprc_mean |   brier_mean |
|:----------------|------------------:|-----------:|----------:|----------:|-------------:|-------------:|
| age_only        |                 4 |   0.522215 |  0.462083 |  0.577418 |     0.473901 |     0.250345 |
| age_sex         |                 4 |   0.528191 |  0.504536 |  0.540714 |     0.474429 |     0.250017 |
| age_sex_scanner |                 4 |   0.509656 |  0.484321 |  0.53577  |     0.455552 |     0.257735 |

## Recommendation

The next GPU experiment should not be another IDH run. The strongest data-grounded pivot is an MGMT ceiling probe using the same LOCO + nested-OOF protocol. The method claim should remain unlocked until the MGMT image model shows incremental value over the age_sex clinical floor.

Pre-GPU blockers for MGMT:

- Generalize image runner and ceiling harness from IDH-only labels to configurable binary targets.
- Lock MGMT label semantics: methylated=1, unmethylated=0, exclude unknown/indeterminate/conflict.
- Reuse subject-level LOCO and nested OOF; do not use pooled random split.
- Report age/sex/scanner clinical floors as mandatory baselines.
- Keep CTEC/IDH stopped unless reframed as negative benchmark.
