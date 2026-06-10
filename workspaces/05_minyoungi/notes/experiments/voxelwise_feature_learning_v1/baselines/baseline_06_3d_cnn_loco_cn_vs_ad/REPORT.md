# Baseline 06 — image-only 3D CNN LOCO CN vs AD

## Question

image-only 3D CNN CN vs AD 성능이 leave-one-cohort-out에서도 유지되는가, 그리고 결과가 명백한 leakage로 설명되지 않는가?

## Summary

- heldout cohorts: 6
- mean ROC-AUC: **0.8087**
- min ROC-AUC: **0.7572**
- max ROC-AUC: **0.8576**
- mean balanced accuracy: **0.7146**
- leakage audit pass: **True**

## Input policy

Only final_tensor voxel arrays are fed to the model. ROI features/masks, cohort/scanner metadata, age/sex, and diagnosis text are not model inputs.

## Remaining risks

- LOCO strongly reduces explicit cohort leakage, but does not prove absence of preprocessing/site signal encoded in image voxels.
- Publication-level leakage assessment still needs seed-repeat and scanner/protocol audit.
