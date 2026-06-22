# CARE-Seg Policy Report

## Purpose

Analysis-only selective-compute report. The cheap path supplies deployable prediction features, and high-risk subjects are escalated to the expensive path.

## Inputs

| system | mean Dice | low<=0.8 |
| --- | --- | --- |
| cheap path | 0.887385 | 0.114409 |
| expensive path | 0.892775 | 0.100186 |

- n subjects: 1617
- n datasets: 4
- deployable feature count: 2

## Deployable Features

- `cheap_pred_voxels`
- `log1p_cheap_pred_voxels`

## Representative Policies

| policy | escalation | n escalated | mean Dice | mean Dice CI95 | low<=0.8 | delta vs cheap | delta CI95 | fraction full gain |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| random_seed29 | 0.1 | 162 | 0.887779 | [0.880674, 0.89481] | 0.111317 | 0.000394 | [-0.000405, 0.001063] | 0.073129 |
| random_seed29 | 0.3 | 485 | 0.888945 | [0.882352, 0.895755] | 0.111317 | 0.00156 | [0.000525, 0.002487] | 0.289418 |
| random_seed29 | 0.5 | 808 | 0.889522 | [0.882656, 0.896545] | 0.108225 | 0.002136 | [0.000871, 0.003338] | 0.396395 |
| random_seed29 | 1.0 | 1617 | 0.892775 | [0.885672, 0.899096] | 0.100186 | 0.00539 | [0.003644, 0.007164] | 1.0 |
| small_cheap_pred_volume | 0.1 | 162 | 0.888843 | [0.882082, 0.895367] | 0.109462 | 0.001457 | [-4e-06, 0.00287] | 0.27037 |
| small_cheap_pred_volume | 0.3 | 485 | 0.890575 | [0.883469, 0.896896] | 0.102659 | 0.00319 | [0.001524, 0.004882] | 0.591867 |
| small_cheap_pred_volume | 0.5 | 808 | 0.89149 | [0.884826, 0.897595] | 0.101422 | 0.004105 | [0.002387, 0.005841] | 0.761551 |
| small_cheap_pred_volume | 1.0 | 1617 | 0.892775 | [0.885529, 0.899459] | 0.100186 | 0.00539 | [0.003705, 0.007148] | 1.0 |
| oracle_gain_not_deployable | 0.1 | 162 | 0.893599 | [0.887099, 0.899621] | 0.096475 | 0.006214 | [0.004896, 0.007691] | 1.152934 |
| oracle_gain_not_deployable | 0.3 | 485 | 0.895827 | [0.888986, 0.902216] | 0.094001 | 0.008441 | [0.007121, 0.009836] | 1.566184 |
| oracle_gain_not_deployable | 0.5 | 808 | 0.896578 | [0.889981, 0.902824] | 0.094001 | 0.009192 | [0.007962, 0.010667] | 1.70555 |
| oracle_gain_not_deployable | 1.0 | 1617 | 0.892775 | [0.885778, 0.89924] | 0.100186 | 0.00539 | [0.003679, 0.007182] | 1.0 |
| loco_cheap_failure_logistic | 0.1 | 162 | 0.888882 | [0.881933, 0.895406] | 0.108844 | 0.001497 | [8.1e-05, 0.00293] | 0.277708 |
| loco_cheap_failure_logistic | 0.3 | 485 | 0.890608 | [0.883548, 0.897049] | 0.102659 | 0.003223 | [0.001539, 0.004862] | 0.598003 |
| loco_cheap_failure_logistic | 0.5 | 808 | 0.891517 | [0.884473, 0.898322] | 0.102041 | 0.004132 | [0.002458, 0.006015] | 0.766592 |
| loco_cheap_failure_logistic | 1.0 | 1617 | 0.892775 | [0.886185, 0.89934] | 0.100186 | 0.00539 | [0.003691, 0.007134] | 1.0 |
| loco_recoverable_failure_gain_logistic | 0.1 | 162 | 0.888811 | [0.881789, 0.895528] | 0.108844 | 0.001425 | [-8.5e-05, 0.00297] | 0.26446 |
| loco_recoverable_failure_gain_logistic | 0.3 | 485 | 0.890579 | [0.883495, 0.897536] | 0.103278 | 0.003194 | [0.001608, 0.004908] | 0.592527 |
| loco_recoverable_failure_gain_logistic | 0.5 | 808 | 0.891466 | [0.884829, 0.897757] | 0.102041 | 0.004081 | [0.002214, 0.005731] | 0.757158 |
| loco_recoverable_failure_gain_logistic | 1.0 | 1617 | 0.892775 | [0.885792, 0.899102] | 0.100186 | 0.00539 | [0.003552, 0.007189] | 1.0 |
| loco_recoverable_failure_nonfailure_logistic | 0.1 | 162 | 0.888792 | [0.881782, 0.895529] | 0.109462 | 0.001407 | [-9.7e-05, 0.00295] | 0.261026 |
| loco_recoverable_failure_nonfailure_logistic | 0.3 | 485 | 0.890601 | [0.883545, 0.897515] | 0.103896 | 0.003215 | [0.001627, 0.004915] | 0.596588 |
| loco_recoverable_failure_nonfailure_logistic | 0.5 | 808 | 0.891504 | [0.884865, 0.897824] | 0.101422 | 0.004118 | [0.002257, 0.005782] | 0.764126 |
| loco_recoverable_failure_nonfailure_logistic | 1.0 | 1617 | 0.892775 | [0.885792, 0.899102] | 0.100186 | 0.00539 | [0.003552, 0.007189] | 1.0 |
| loco_gain_ridge | 0.1 | 162 | 0.8874 | [0.879853, 0.89396] | 0.113173 | 1.5e-05 | [-0.001161, 0.001122] | 0.002755 |
| loco_gain_ridge | 0.3 | 485 | 0.888333 | [0.881747, 0.894625] | 0.11008 | 0.000947 | [-0.000448, 0.002177] | 0.175791 |
| loco_gain_ridge | 0.5 | 808 | 0.888868 | [0.882194, 0.895366] | 0.107607 | 0.001483 | [0.000157, 0.002815] | 0.275174 |
| loco_gain_ridge | 1.0 | 1617 | 0.892775 | [0.88597, 0.899257] | 0.100186 | 0.00539 | [0.003548, 0.007253] | 1.0 |

## Best Eligible Policy By Budget

Oracle and random policies are excluded from this table.

| escalation | policy | n escalated | mean Dice | mean Dice CI95 | low<=0.8 | delta vs cheap | delta CI95 | fraction full gain |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 0.05 | loco_expensive_failure_logistic | 81 | 0.888227 | [0.881228, 0.895075] | 0.112554 | 0.000842 | [-0.000491, 0.002256] | 0.156222 |
| 0.1 | loco_cheap_failure_logistic | 162 | 0.888882 | [0.881933, 0.895406] | 0.108844 | 0.001497 | [8.1e-05, 0.00293] | 0.277708 |
| 0.2 | loco_expensive_failure_logistic | 323 | 0.889819 | [0.882852, 0.896449] | 0.103896 | 0.002434 | [0.000746, 0.004086] | 0.451596 |
| 0.3 | loco_cheap_failure_logistic | 485 | 0.890608 | [0.883548, 0.897049] | 0.102659 | 0.003223 | [0.001539, 0.004862] | 0.598003 |
| 0.5 | loco_cheap_failure_logistic | 808 | 0.891517 | [0.884473, 0.898322] | 0.102041 | 0.004132 | [0.002458, 0.006015] | 0.766592 |

## Notes

- `target_voxels` and all target-derived values are excluded from deployable features.
- Oracle rows are upper bounds and must not be used as a method result.
- If this report was generated from a single-dataset smoke run, LOCO supervised policies are absent by design.
