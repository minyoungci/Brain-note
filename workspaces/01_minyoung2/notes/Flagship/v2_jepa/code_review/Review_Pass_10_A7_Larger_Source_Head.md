# Review Pass 10: A7 Larger Source Head + Batch 8

Date: 2026-06-30 UTC

## Scope

A7 was designed after A6 showed that increasing GRL weight alone does not reduce post-hoc source leakage. The new hypothesis was:

```text
The source adversary is too weak or too noisy.
Make it more learnable before expecting GRL to remove source directions.
```

## Runs

Both runs use:

```text
A5 global_align_weight=0.10
source_adv_hidden=1024
source_adv_warmup=5000
batch=8
```

| Run | Source adversary |
|---|---:|
| `pilot_a7_galign010_adv005_h1024_warm5000_b8_anat_seed3700_gpu0_20260630` | `source_adv_weight=0.05` |
| `pilot_a7_galign010_adv010_h1024_warm5000_b8_anat_seed3701_gpu1_20260630` | `source_adv_weight=0.10` |

## Training Health

```text
A7 adv=0.05: step=20000 loss=3.9531 global_align=0.0548 std=0.18480 rank=178.35 DONE=True ERROR=False
A7 adv=0.10: step=20000 loss=3.9435 global_align=0.0851 std=0.13061 rank=167.27 DONE=True ERROR=False
```

The runs were stable. Batch 8 also stayed well within B200 memory limits.

## Results

### Source-Probe

| Model | Source-probe acc |
|---|---:|
| A2 mainline | 0.0846 mean over seeds 100/101/102 |
| A5 `w=0.10` | 0.2574 seed100 |
| A6 adv `0.20` | 0.2500 seed100 |
| A7 adv `0.05` | 0.1722 seed100 |
| A7 adv `0.10` | 0.2222 seed100 |
| S3D wg0.5 | 0.3105 mean over seeds 100/101/102 |

A7 `adv=0.05` is the first post-A2 branch that meaningfully lowers source-probe while keeping the global-alignment branch. It does not reach A2, but it improves over A5/A6.

### Downstream Global Probe

| Task | Metric | A5 `w=0.10` | A7 adv `0.05` | A7 adv `0.10` | S3D wg0.5 |
|---|---:|---:|---:|---:|---:|
| Task1 infarct | AUROC | 0.8077 | 0.4423 | 0.7788 | 0.7212 |
| Task3 brain age | Pearson r | 0.6996 | 0.5119 | 0.6720 | 0.7924 |
| Task5 polymicrogyria | AUROC | 0.8715 | 0.7726 | 0.7847 | 0.9566 |

The improved source-probe came with downstream damage. A7 `adv=0.05` lowers source leakage but removes too much useful global signal. A7 `adv=0.10` keeps Task1 high but does not reduce source leakage enough and loses brain age / Task5.

## Verdict

A7 is not a final foundation candidate.

It is still informative:

```text
larger head + batch 8 can lower source-probe,
but adversarial pressure on the shared global vector removes biology with nuisance.
```

The next branch should stop treating the shared global vector as both the biological representation and the nuisance-removal target.

Recommended A8 direction:

```text
factorized global representation
  z_shared = context encoder output
  z_bio    = biological/global projection for downstream
  z_src    = nuisance/source projection for source adversary

loss:
  JEPA latent loss
  + positive global alignment on z_bio
  + source adversary on z_src
  + orthogonality/covariance penalty between z_bio and z_src
```

This explicitly tests whether useful global signal and source signal can be separated rather than fighting over one vector.
