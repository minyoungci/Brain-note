# exp01 Failure Risk Audit

## Purpose

Analysis-only audit using existing subject-level predictions. No GPU training, new inference, or raw data mutation was performed.

## Dataset Summary

| dataset | n | ResUNet Dice | Best Dice | Best-ResUNet | ResUNet low<=0.8 | Best low<=0.8 |
| --- | --- | --- | --- | --- | --- | --- |
| MU-Glioma-Post | 203 | 0.85561 | 0.865013 | 0.009403 | 0.187192 | 0.152709 |
| UCSD-PTGBM | 178 | 0.793146 | 0.816679 | 0.023533 | 0.331461 | 0.275281 |
| UPENN-GBM | 611 | 0.92651 | 0.927747 | 0.001238 | 0.03928 | 0.031097 |
| UTSW | 625 | 0.886297 | 0.889275 | 0.002978 | 0.1024 | 0.1008 |

## Failure Prediction Signals

Target: best-artifact Dice <= 0.8. Features marked diagnostic use ground-truth target size or target mismatch and are not deployable at inference.

| score | AUC | AP | positives | n |
| --- | --- | --- | --- | --- |
| small_resunet_pred_volume | 0.845936 | 0.444914 | 162 | 1617 |
| small_best_pred_volume | 0.83226 | 0.4336 | 162 | 1617 |
| resunet_vs_tta_pred_disagreement | 0.832608 | 0.553557 | 162 | 1617 |
| resunet_tta_vs_student_tta_pred_disagreement | 0.81714 | 0.514172 | 162 | 1617 |
| resunet_tta_vs_best_pred_disagreement | 0.778149 | 0.432085 | 162 | 1617 |
| diagnostic_small_target_volume_not_deployable | 0.8487 | 0.518669 | 162 | 1617 |
| diagnostic_pred_target_mismatch_not_deployable | 0.942845 | 0.855375 | 162 | 1617 |

## LOCO Failure Model

A logistic risk model was trained on non-held-out consortia and evaluated on the held-out consortium. Features are deployable predicted-volume and model-disagreement summaries from completed predictions, not ground-truth target size.

| held-out | AUC | AP | positives | n |
| --- | --- | --- | --- | --- |
| MU-Glioma-Post | 0.902663 | 0.715936 | 31 | 203 |
| UCSD-PTGBM | 0.872805 | 0.724679 | 49 | 178 |
| UPENN-GBM | 0.901316 | 0.494033 | 19 | 611 |
| UTSW | 0.926114 | 0.661051 | 63 | 625 |

Overall OOF AUC: 0.9238
Overall OOF AP: 0.662324

## Selective Escalation Simulation

Policy simulation: start from single-pass ResUNet-DS, escalate the highest-risk subjects to the full best two-model all-flip TTA artifact. The risk score is trained LOCO to predict ResUNet low-Dice failure using only ResUNet predicted volume.

| escalation rate | n escalated | mean Dice | low<=0.8 | delta vs ResUNet | fraction of full gain |
| --- | --- | --- | --- | --- | --- |
| 0.0 | 0 | 0.887385 | 0.114409 | 0.0 | 0.0 |
| 0.05 | 81 | 0.888 | 0.112554 | 0.000615 | 0.114112 |
| 0.1 | 162 | 0.888882 | 0.108844 | 0.001497 | 0.277708 |
| 0.2 | 323 | 0.889721 | 0.103896 | 0.002335 | 0.433286 |
| 0.3 | 485 | 0.890601 | 0.102659 | 0.003216 | 0.596717 |
| 0.5 | 808 | 0.891517 | 0.102041 | 0.004132 | 0.766592 |
| 1.0 | 1617 | 0.892775 | 0.100186 | 0.00539 | 1.0 |

## Interpretation

The audit supports a compute-aware reliability direction only if the selective escalation curve captures a meaningful fraction of the full best-artifact gain at substantially less than 100% escalation. It does not by itself prove a new method.

Hard limitation: the current predictions do not contain voxel-level entropy, TTA variance, or model disagreement maps, so this audit is a lower-bound reliability probe.

Recommended next step: if this direction is selected, implement explicit uncertainty/disagreement export during inference before any new GPU training sweep.
