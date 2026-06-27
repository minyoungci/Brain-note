# Uncertainty vs Volume Gate Decision

Scope: CPU-only, existing calibrated probability maps, no new training, no TTA.

Primary deployable uncertainty: `mean_entropy_pred_mask`. Deployable volume baseline: `-pred_voxels`.

Important caveat: `20260624_1015_uncertainty_vs_volume_gate` is invalid because target masks were loaded without canonical orientation. Use only this canonical run.

## Decision Table

| model   | score                          |   pooled_auc |   fold_mean_auc |   fold_min_auc |   fold_MU_auc |   fold_UCSD_auc |
|:--------|:-------------------------------|-------------:|----------------:|---------------:|--------------:|----------------:|
| B1A     | primary_mean_entropy_pred_mask |        0.669 |           0.754 |          0.713 |         0.795 |           0.713 |
| B1A     | mean_entropy_all               |        0.744 |           0.749 |          0.730 |         0.730 |           0.768 |
| B1A     | deployable_neg_pred_volume     |        0.736 |           0.739 |          0.736 |         0.742 |           0.736 |
| B1B     | primary_mean_entropy_pred_mask |        0.699 |           0.832 |          0.819 |         0.819 |           0.845 |
| B1B     | mean_entropy_all               |        0.779 |           0.785 |          0.753 |         0.753 |           0.816 |
| B1B     | deployable_neg_pred_volume     |        0.735 |           0.738 |          0.720 |         0.720 |           0.756 |

## Interpretation

- Pooled primary entropy does not beat predicted volume for either model.

- Fold-wise B1B primary entropy beats predicted volume on both MU and UCSD, indicating a real uncertainty signal but poor cross-fold/site scale calibration.

- Exploratory `mean_entropy_all` beats predicted volume in pooled B1B (0.779 vs 0.735), but it was not the preregistered primary feature and may partly track foreground/volume behavior.

- Method direction should shift from segmentation-loss tuning to uncertainty calibration / reliability under consortium shift, with predicted-volume and entropy-only baselines as mandatory controls.
