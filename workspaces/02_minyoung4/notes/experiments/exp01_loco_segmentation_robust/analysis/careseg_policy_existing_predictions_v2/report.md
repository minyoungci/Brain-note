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

## Confirmatory Decision

- primary policy: `loco_cheap_failure_logistic`
- primary budget: 0.3
- support budget: 0.5
- hard folds: UCSD-PTGBM, MU-Glioma-Post
- GO: True

| check | pass |
| --- | --- |
| primary_policy_present | True |
| primary_budget_delta_vs_cheap_ci_positive | True |
| primary_budget_delta_vs_random_expected_ci_positive | True |
| support_budget_delta_vs_random_expected_ci_positive | True |
| primary_budget_failure_rate_not_increased | True |
| support_budget_failure_rate_not_increased | True |
| hard_folds_no_point_estimate_collapse | True |

## Deployable Features

- `cheap_pred_voxels`
- `log1p_cheap_pred_voxels`

## Representative Policies

| policy | escalation | n escalated | mean Dice | mean Dice CI95 | low<=0.8 | delta vs cheap | delta CI95 | delta vs random | random delta CI95 | delta vs expected random | expected random delta CI95 | fraction full gain |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| random_seed29 | 0.1 | 162 | 0.887779 | [0.880688, 0.894998] | 0.111317 | 0.000394 | [-0.00039, 0.001044] | 0.0 | [0.0, 0.0] | -0.000145 | [-0.000899, 0.000465] | 0.073129 |
| random_seed29 | 0.3 | 485 | 0.888945 | [0.882212, 0.895451] | 0.111317 | 0.00156 | [0.000553, 0.002481] | 0.0 | [0.0, 0.0] | -5.7e-05 | [-0.000942, 0.000702] | 0.289418 |
| random_seed29 | 0.5 | 808 | 0.889522 | [0.882431, 0.896545] | 0.108225 | 0.002136 | [0.000862, 0.003323] | 0.0 | [0.0, 0.0] | -0.000558 | [-0.001434, 0.000269] | 0.396395 |
| random_seed29 | 1.0 | 1617 | 0.892775 | [0.885498, 0.899185] | 0.100186 | 0.00539 | [0.003653, 0.006968] | 0.0 | [0.0, 0.0] | 0.0 | [-0.0, 0.0] | 1.0 |
| small_cheap_pred_volume | 0.1 | 162 | 0.888843 | [0.882095, 0.895319] | 0.109462 | 0.001457 | [1.5e-05, 0.00286] | 0.001063 | [-0.000255, 0.002549] | 0.000918 | [-0.000461, 0.002165] | 0.27037 |
| small_cheap_pred_volume | 0.3 | 485 | 0.890575 | [0.88329, 0.896957] | 0.102659 | 0.00319 | [0.001446, 0.004952] | 0.00163 | [0.000213, 0.003135] | 0.001573 | [0.000407, 0.002782] | 0.591867 |
| small_cheap_pred_volume | 0.5 | 808 | 0.89149 | [0.884503, 0.897632] | 0.101422 | 0.004105 | [0.002437, 0.005689] | 0.001968 | [0.000682, 0.003381] | 0.00141 | [0.000552, 0.002282] | 0.761551 |
| small_cheap_pred_volume | 1.0 | 1617 | 0.892775 | [0.885463, 0.899423] | 0.100186 | 0.00539 | [0.003718, 0.007195] | 0.0 | [0.0, 0.0] | 0.0 | [-0.0, 0.0] | 1.0 |
| oracle_gain_not_deployable | 0.1 | 162 | 0.893599 | [0.887356, 0.899243] | 0.096475 | 0.006214 | [0.004922, 0.007635] | 0.00582 | [0.004421, 0.007384] | 0.005675 | [0.004535, 0.006998] | 1.152934 |
| oracle_gain_not_deployable | 0.3 | 485 | 0.895827 | [0.888934, 0.902403] | 0.094001 | 0.008441 | [0.007124, 0.009843] | 0.006881 | [0.005627, 0.008303] | 0.006824 | [0.005848, 0.007899] | 1.566184 |
| oracle_gain_not_deployable | 0.5 | 808 | 0.896578 | [0.890334, 0.902825] | 0.094001 | 0.009192 | [0.007984, 0.01068] | 0.007056 | [0.005826, 0.008568] | 0.006498 | [0.005743, 0.007431] | 1.70555 |
| oracle_gain_not_deployable | 1.0 | 1617 | 0.892775 | [0.885667, 0.89936] | 0.100186 | 0.00539 | [0.003684, 0.007227] | 0.0 | [0.0, 0.0] | 0.0 | [-0.0, 0.0] | 1.0 |
| loco_cheap_failure_logistic | 0.1 | 162 | 0.888882 | [0.8823, 0.895526] | 0.108844 | 0.001497 | [6.8e-05, 0.002991] | 0.001103 | [-0.000262, 0.002631] | 0.000958 | [-0.000419, 0.002245] | 0.277708 |
| loco_cheap_failure_logistic | 0.3 | 485 | 0.890608 | [0.883611, 0.897108] | 0.102659 | 0.003223 | [0.00163, 0.004896] | 0.001663 | [0.000181, 0.003115] | 0.001606 | [0.000387, 0.00282] | 0.598003 |
| loco_cheap_failure_logistic | 0.5 | 808 | 0.891517 | [0.884429, 0.898412] | 0.102041 | 0.004132 | [0.002403, 0.005995] | 0.001995 | [0.000706, 0.003366] | 0.001437 | [0.000559, 0.002323] | 0.766592 |
| loco_cheap_failure_logistic | 1.0 | 1617 | 0.892775 | [0.886116, 0.899637] | 0.100186 | 0.00539 | [0.003678, 0.007025] | 0.0 | [0.0, 0.0] | 0.0 | [-0.0, 0.0] | 1.0 |
| loco_recoverable_failure_gain_logistic | 0.1 | 162 | 0.888811 | [0.881789, 0.895586] | 0.108844 | 0.001425 | [-0.000121, 0.002973] | 0.001031 | [-0.000352, 0.002363] | 0.000886 | [-0.000455, 0.002153] | 0.26446 |
| loco_recoverable_failure_gain_logistic | 0.3 | 485 | 0.890579 | [0.883764, 0.89714] | 0.103278 | 0.003194 | [0.001623, 0.004838] | 0.001634 | [0.000115, 0.003163] | 0.001577 | [0.000397, 0.002744] | 0.592527 |
| loco_recoverable_failure_gain_logistic | 0.5 | 808 | 0.891466 | [0.884917, 0.897499] | 0.102041 | 0.004081 | [0.002153, 0.005715] | 0.001944 | [0.00067, 0.003383] | 0.001386 | [0.000553, 0.002276] | 0.757158 |
| loco_recoverable_failure_gain_logistic | 1.0 | 1617 | 0.892775 | [0.885408, 0.898962] | 0.100186 | 0.00539 | [0.003591, 0.007124] | 0.0 | [0.0, 0.0] | 0.0 | [-0.0, 0.0] | 1.0 |
| loco_recoverable_failure_nonfailure_logistic | 0.1 | 162 | 0.888792 | [0.881782, 0.895571] | 0.109462 | 0.001407 | [-0.000125, 0.002941] | 0.001013 | [-0.00042, 0.002363] | 0.000868 | [-0.000501, 0.002112] | 0.261026 |
| loco_recoverable_failure_nonfailure_logistic | 0.3 | 485 | 0.890601 | [0.883764, 0.897156] | 0.103896 | 0.003215 | [0.001673, 0.004814] | 0.001656 | [0.000118, 0.003201] | 0.001599 | [0.000404, 0.002763] | 0.596588 |
| loco_recoverable_failure_nonfailure_logistic | 0.5 | 808 | 0.891504 | [0.884983, 0.897497] | 0.101422 | 0.004118 | [0.002192, 0.005742] | 0.001982 | [0.000682, 0.003478] | 0.001424 | [0.000556, 0.002299] | 0.764126 |
| loco_recoverable_failure_nonfailure_logistic | 1.0 | 1617 | 0.892775 | [0.885408, 0.898962] | 0.100186 | 0.00539 | [0.003591, 0.007124] | 0.0 | [0.0, 0.0] | 0.0 | [-0.0, 0.0] | 1.0 |
| loco_gain_ridge | 0.1 | 162 | 0.8874 | [0.879609, 0.893775] | 0.113173 | 1.5e-05 | [-0.001085, 0.001126] | -0.000379 | [-0.00138, 0.000679] | -0.000524 | [-0.001612, 0.000472] | 0.002755 |
| loco_gain_ridge | 0.3 | 485 | 0.888333 | [0.88149, 0.894822] | 0.11008 | 0.000947 | [-0.000278, 0.002164] | -0.000612 | [-0.001859, 0.000758] | -0.000669 | [-0.001698, 0.000294] | 0.175791 |
| loco_gain_ridge | 0.5 | 808 | 0.888868 | [0.882199, 0.895336] | 0.107607 | 0.001483 | [0.000222, 0.002863] | -0.000653 | [-0.001893, 0.000491] | -0.001212 | [-0.002142, -0.000322] | 0.275174 |
| loco_gain_ridge | 1.0 | 1617 | 0.892775 | [0.885462, 0.899153] | 0.100186 | 0.00539 | [0.003537, 0.007277] | 0.0 | [0.0, 0.0] | 0.0 | [-0.0, 0.0] | 1.0 |

## Best Eligible Policy By Budget

Oracle and random policies are excluded from this table.

| escalation | policy | n escalated | mean Dice | mean Dice CI95 | low<=0.8 | delta vs cheap | delta CI95 | delta vs random | random delta CI95 | delta vs expected random | expected random delta CI95 | fraction full gain |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 0.05 | loco_expensive_failure_logistic | 81 | 0.888227 | [0.8815, 0.895063] | 0.112554 | 0.000842 | [-0.000568, 0.002256] | 0.000978 | [-0.000408, 0.002352] | 0.000573 | [-0.000735, 0.001916] | 0.156222 |
| 0.1 | loco_cheap_failure_logistic | 162 | 0.888882 | [0.8823, 0.895526] | 0.108844 | 0.001497 | [6.8e-05, 0.002991] | 0.001103 | [-0.000262, 0.002631] | 0.000958 | [-0.000419, 0.002245] | 0.277708 |
| 0.2 | loco_expensive_failure_logistic | 323 | 0.889819 | [0.882948, 0.896704] | 0.103896 | 0.002434 | [0.000736, 0.004055] | 0.001216 | [-0.000232, 0.002779] | 0.001356 | [-2.6e-05, 0.002591] | 0.451596 |
| 0.3 | loco_cheap_failure_logistic | 485 | 0.890608 | [0.883611, 0.897108] | 0.102659 | 0.003223 | [0.00163, 0.004896] | 0.001663 | [0.000181, 0.003115] | 0.001606 | [0.000387, 0.00282] | 0.598003 |
| 0.5 | loco_cheap_failure_logistic | 808 | 0.891517 | [0.884429, 0.898412] | 0.102041 | 0.004132 | [0.002403, 0.005995] | 0.001995 | [0.000706, 0.003366] | 0.001437 | [0.000559, 0.002323] | 0.766592 |

## Primary Hard-Fold Rows

| dataset | escalation | n | n escalated | mixed Dice | delta vs cheap | mixed low<=0.8 | delta low vs cheap |
| --- | --- | --- | --- | --- | --- | --- | --- |
| MU-Glioma-Post | 0.3 | 203 | 73 | 0.859465 | 0.003855 | 0.162562 | -0.024631 |
| UCSD-PTGBM | 0.3 | 178 | 129 | 0.814841 | 0.021696 | 0.269663 | -0.061798 |
| MU-Glioma-Post | 0.5 | 203 | 108 | 0.861593 | 0.005983 | 0.162562 | -0.024631 |
| UCSD-PTGBM | 0.5 | 178 | 159 | 0.816193 | 0.023047 | 0.269663 | -0.061798 |

## Notes

- `target_voxels` and all target-derived values are excluded from deployable features.
- Oracle rows are upper bounds and must not be used as a method result.
- If this report was generated from a single-dataset smoke run, LOCO supervised policies are absent by design.
