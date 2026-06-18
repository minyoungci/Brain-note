# Leakage Checklist

Status: draft.

Use this checklist before each experiment is considered valid.

## Subject and Split

- [ ] Unit of analysis is subject.
- [ ] Split key is `dataset::subject_id`.
- [ ] No subject appears in more than one split.
- [ ] Multi-unit subjects are grouped.
- [ ] Held-out consortium is absent from model selection.

## Labels and Cohort

- [ ] IDH labels are harmonized.
- [ ] Unknown/ambiguous IDH labels are excluded by policy.
- [ ] Cohort inclusion is not determined by post-label artifacts.
- [ ] Positive/negative counts are reported by consortium.

## Imaging and Preprocessing

- [ ] Image paths exist.
- [ ] Known zero-byte files are handled.
- [ ] Shape convention is `[B, C, D, H, W]`.
- [ ] Normalization statistics are per-volume or train-only.
- [ ] Augmentations are train-only.

## Clinical and Scanner Variables

- [ ] Age/sex usage is explicit.
- [ ] Scanner/vendor/site variables have approved roles.
- [ ] Dataset identity is diagnostic-only unless explicitly approved otherwise.

## Masks

- [ ] Mask availability is reported by split and label.
- [ ] Missing masks are handled explicitly.
- [ ] Mask dropout/corruption ablations are documented.
- [ ] No hidden mask-required path is used for a mask-free claim.

## Metrics

- [ ] Metrics are subject-level.
- [ ] AUC/AUPRC/MCC/balanced accuracy are reported.
- [ ] ECE/Brier are reported for reliability claims.
- [ ] Thresholds are not chosen on test data.

