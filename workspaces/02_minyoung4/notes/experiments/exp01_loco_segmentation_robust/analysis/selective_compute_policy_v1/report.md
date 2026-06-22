# exp01 Selective Compute Policy Prototype

## Purpose

Analysis-only policy prototype. It asks whether a cheap first-pass ResUNet-DS prediction can decide which subjects should be escalated to the expensive two-model all-flip TTA artifact.

No GPU training, new inference, or raw data mutation was performed.

## Baselines

| system | mean Dice | low<=0.8 |
| --- | --- | --- |
| ResUNet-DS single-pass | 0.887385 | 0.114409 |
| Full best ensemble-TTA | 0.892775 | 0.100186 |

## Representative Policies

| policy | escalation rate | n escalated | mean Dice | low<=0.8 | delta vs ResUNet | fraction full gain |
| --- | --- | --- | --- | --- | --- | --- |
| random_seed17 | 0.1 | 162 | 0.887779 | 0.113791 | 0.000394 | 0.073061 |
| random_seed17 | 0.3 | 485 | 0.889336 | 0.109462 | 0.001951 | 0.361897 |
| random_seed17 | 0.5 | 808 | 0.890717 | 0.108225 | 0.003332 | 0.618247 |
| random_seed17 | 1.0 | 1617 | 0.892775 | 0.100186 | 0.00539 | 1.0 |
| cheap_small_resunet_pred_volume | 0.1 | 162 | 0.888843 | 0.109462 | 0.001457 | 0.27037 |
| cheap_small_resunet_pred_volume | 0.3 | 485 | 0.890575 | 0.102659 | 0.00319 | 0.591867 |
| cheap_small_resunet_pred_volume | 0.5 | 808 | 0.89149 | 0.101422 | 0.004105 | 0.761551 |
| cheap_small_resunet_pred_volume | 1.0 | 1617 | 0.892775 | 0.100186 | 0.00539 | 1.0 |
| cheap_loco_resunet_failure_logistic | 0.1 | 162 | 0.888882 | 0.108844 | 0.001497 | 0.277708 |
| cheap_loco_resunet_failure_logistic | 0.3 | 485 | 0.890601 | 0.102659 | 0.003216 | 0.596717 |
| cheap_loco_resunet_failure_logistic | 0.5 | 808 | 0.891517 | 0.102041 | 0.004132 | 0.766592 |
| cheap_loco_resunet_failure_logistic | 1.0 | 1617 | 0.892775 | 0.100186 | 0.00539 | 1.0 |
| cheap_loco_gain_ridge | 0.1 | 162 | 0.887274 | 0.114409 | -0.000111 | -0.020585 |
| cheap_loco_gain_ridge | 0.3 | 485 | 0.888414 | 0.109462 | 0.001028 | 0.190795 |
| cheap_loco_gain_ridge | 0.5 | 808 | 0.889084 | 0.108225 | 0.001699 | 0.315177 |
| cheap_loco_gain_ridge | 1.0 | 1617 | 0.892775 | 0.100186 | 0.00539 | 1.0 |
| oracle_gain_not_deployable | 0.1 | 162 | 0.893599 | 0.096475 | 0.006214 | 1.152934 |
| oracle_gain_not_deployable | 0.3 | 485 | 0.895827 | 0.094001 | 0.008441 | 1.566184 |
| oracle_gain_not_deployable | 0.5 | 808 | 0.896578 | 0.094001 | 0.009192 | 1.70555 |
| oracle_gain_not_deployable | 1.0 | 1617 | 0.892775 | 0.100186 | 0.00539 | 1.0 |

## Best Cheap Policy By Escalation Rate

Only policies whose score is available after the cheap ResUNet-DS pass are eligible for this table. Oracle and diagnostic policies are excluded.

| escalation rate | policy | n escalated | mean Dice | low<=0.8 | delta vs ResUNet | fraction full gain |
| --- | --- | --- | --- | --- | --- | --- |
| 0.05 | cheap_loco_best_failure_logistic | 81 | 0.888287 | 0.111936 | 0.000902 | 0.167308 |
| 0.1 | cheap_loco_resunet_failure_logistic | 162 | 0.888882 | 0.108844 | 0.001497 | 0.277708 |
| 0.2 | cheap_loco_best_failure_logistic | 323 | 0.889737 | 0.103896 | 0.002352 | 0.436411 |
| 0.3 | cheap_loco_best_failure_logistic | 485 | 0.890627 | 0.102659 | 0.003242 | 0.601458 |
| 0.5 | cheap_loco_resunet_failure_logistic | 808 | 0.891517 | 0.102041 | 0.004132 | 0.766592 |

## Interpretation

The current cheap gate is intentionally minimal: it uses only predicted tumor volume from single-pass ResUNet-DS. If it already captures a useful fraction of the full ensemble-TTA gain, the next method should export richer uncertainty and disagreement signals rather than train another generic segmentation loss.

Non-deployable oracle rows are upper bounds only and must not be used as a method claim.
