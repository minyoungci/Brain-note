# Review Pass 9: A6 Stronger GRL Source Adversary

Date: 2026-06-30 UTC

## Scope

A6 tested the most direct response to A5:

```text
A5 global_align_weight=0.10 recovers downstream signal,
but source-probe remains high.
Try stronger GRL source adversary.
```

## Runs

| Run | Change from A5 `w=0.10` |
|---|---|
| `pilot_a6_galign010_adv010_anat_seed3600_gpu0_20260630` | `source_adv_weight=0.10` |
| `pilot_a6_galign010_adv020_anat_seed3601_gpu1_20260630` | `source_adv_weight=0.20` |

No code changes were required beyond A5.

## Training Health

```text
A6 adv=0.10: step=20000 loss=3.7324 global_align=0.1301 std=0.17059 rank=176.28 DONE=True ERROR=False
A6 adv=0.20: step=20000 loss=3.7373 global_align=0.1109 std=0.35094 rank=131.99 DONE=True ERROR=False
```

The `0.20` branch did not collapse, but its representation geometry became less healthy: high `std_mean` and lower effective rank.

## Results

### Source-Probe

| Model | Source-probe acc |
|---|---:|
| A2 mainline | 0.0846 mean over seeds 100/101/102 |
| A5 `w=0.10` | 0.2574 seed100 |
| A6 adv `0.10` | 0.3204 seed100 |
| A6 adv `0.20` | 0.2500 seed100 |
| S3D wg0.5 | 0.3105 mean over seeds 100/101/102 |

A6 does not reduce source leakage. The `0.10` branch is even worse than A5 and reaches S3D-like source predictability.

### Downstream Global Probe

| Task | Metric | A5 `w=0.10` | A6 adv `0.10` | A6 adv `0.20` | S3D wg0.5 |
|---|---:|---:|---:|---:|---:|
| Task1 infarct | AUROC | 0.8077 | 0.2885 | 0.4423 | 0.7212 |
| Task3 brain age | Pearson r | 0.6996 | 0.6867 | 0.7455 | 0.7924 |
| Task5 polymicrogyria | AUROC | 0.8715 | 0.7986 | 0.7865 | 0.9566 |

A6 damages Task1 and Task5. The `0.20` branch improves brain age relative to A5, but it fails the source gate and loses classification signal.

## Diagnostic Finding

Training-time source accuracy is near chance:

```text
A5 tail source_acc mean:       0.025
A6 adv=0.10 tail source_acc:   0.025
A6 adv=0.20 tail source_acc:   0.020
```

But post-hoc linear source-probe is high. This is the key finding.

The current online GRL source head is not detecting the source-predictive directions that the stronger post-hoc probe finds. Therefore, increasing the reverse-gradient weight cannot solve the problem. It only pushes on a weak or mis-specified nuisance detector.

## Verdict

Reject A6.

Next direction should change the source-control mechanism, not just its weight:

```text
A7 candidate:
  A5 w=0.10
  + larger source adversary head
  + longer source-head warmup before full reversal
  + larger batch if memory allows
```

Success gate remains strict:

```text
source-probe must move toward A2 (~0.085), not stay near A5/S3D.
downstream global must not collapse below A2.
```
