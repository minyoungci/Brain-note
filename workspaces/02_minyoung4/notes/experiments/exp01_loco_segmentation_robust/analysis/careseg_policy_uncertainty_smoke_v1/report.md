# CARE-Seg Policy Report

## Purpose

Analysis-only selective-compute report. The cheap path supplies deployable prediction features, and high-risk subjects are escalated to the expensive path.

## Inputs

| system | mean Dice | low<=0.8 |
| --- | --- | --- |
| cheap path | 0.012209 | 1.0 |
| expensive path | 0.012209 | 1.0 |

- n subjects: 2
- n datasets: 1
- deployable feature count: 17

## Deployable Features

- `cheap_entropy_mean_all`
- `cheap_entropy_mean_pred_region`
- `cheap_entropy_p95_all`
- `cheap_n_prob_samples`
- `cheap_near_threshold_frac`
- `cheap_pred_voxels`
- `cheap_prob_max_all`
- `cheap_prob_mean_all`
- `cheap_prob_mean_pred_region`
- `cheap_prob_p95_all`
- `cheap_prob_std_mean_all`
- `cheap_prob_std_mean_pred_region`
- `cheap_prob_std_p95_all`
- `cheap_vote_disagreement_mean_all`
- `cheap_vote_disagreement_mean_pred_region`
- `cheap_vote_disagreement_p95_all`
- `log1p_cheap_pred_voxels`

## Representative Policies

| policy | escalation | n escalated | mean Dice | low<=0.8 | delta vs cheap | fraction full gain |
| --- | --- | --- | --- | --- | --- | --- |
| random_seed29 | 0.1 | 0 | 0.012209 | 1.0 | 0.0 | 0.0 |
| random_seed29 | 0.3 | 1 | 0.012209 | 1.0 | 0.0 | 0.0 |
| random_seed29 | 0.5 | 1 | 0.012209 | 1.0 | 0.0 | 0.0 |
| random_seed29 | 1.0 | 2 | 0.012209 | 1.0 | 0.0 | 0.0 |
| small_cheap_pred_volume | 0.1 | 0 | 0.012209 | 1.0 | 0.0 | 0.0 |
| small_cheap_pred_volume | 0.3 | 1 | 0.012209 | 1.0 | 0.0 | 0.0 |
| small_cheap_pred_volume | 0.5 | 1 | 0.012209 | 1.0 | 0.0 | 0.0 |
| small_cheap_pred_volume | 1.0 | 2 | 0.012209 | 1.0 | 0.0 | 0.0 |
| oracle_gain_not_deployable | 0.1 | 0 | 0.012209 | 1.0 | 0.0 | 0.0 |
| oracle_gain_not_deployable | 0.3 | 1 | 0.012209 | 1.0 | 0.0 | 0.0 |
| oracle_gain_not_deployable | 0.5 | 1 | 0.012209 | 1.0 | 0.0 | 0.0 |
| oracle_gain_not_deployable | 1.0 | 2 | 0.012209 | 1.0 | 0.0 | 0.0 |

## Best Eligible Policy By Budget

Oracle and random policies are excluded from this table.

| escalation | policy | n escalated | mean Dice | low<=0.8 | delta vs cheap | fraction full gain |
| --- | --- | --- | --- | --- | --- | --- |
| 0.05 | small_cheap_pred_volume | 0 | 0.012209 | 1.0 | 0.0 | 0.0 |
| 0.1 | small_cheap_pred_volume | 0 | 0.012209 | 1.0 | 0.0 | 0.0 |
| 0.2 | small_cheap_pred_volume | 0 | 0.012209 | 1.0 | 0.0 | 0.0 |
| 0.3 | small_cheap_pred_volume | 1 | 0.012209 | 1.0 | 0.0 | 0.0 |
| 0.5 | small_cheap_pred_volume | 1 | 0.012209 | 1.0 | 0.0 | 0.0 |

## Notes

- `target_voxels` and all target-derived values are excluded from deployable features.
- Oracle rows are upper bounds and must not be used as a method result.
- If this report was generated from a single-dataset smoke run, LOCO supervised policies are absent by design.
