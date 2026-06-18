# exp05: Domain Generalization Under LOCO

Status: scaffold only.

## Objective

Improve held-out consortium performance instead of only pooled random-split performance.

## Prior-Work Gap

Prior studies often report external validation, but robustness is not usually the
explicit optimization target. Our cohort has strong consortium-level IDH imbalance.

## Candidate Methods

- ERM baseline.
- Group DRO by consortium.
- CORAL or MMD feature alignment.
- Domain adversarial loss.
- Domain-specific normalization.

## Model Selection

Use validation from training consortia only.
Do not tune on the held-out consortium.

Potential selection criteria:

- mean validation AUC;
- worst-training-consortium AUC;
- validation MCC;
- calibration-aware score.

## Metrics

- Held-out consortium AUC, AUPRC, MCC.
- Worst-consortium performance.
- Scanner/vendor subgroup performance.
- ECE and Brier score.

## Main Risk

Domain regularization may reduce pooled AUC.
This is acceptable only if worst-consortium reliability improves.

