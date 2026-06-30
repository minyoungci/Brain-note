# Review Pass 7: A4 Weak Global InfoNCE Hybrid

Date: 2026-06-30 UTC

## Scope

Reviewed the A4 branch after A2 showed the key trade-off:

```text
A2 Brain-JEPA:
  source shortcut exposure: strong improvement
  downstream global signal: weaker than previous S3D+InfoNCE foundation
```

A4 tested whether a weak global InfoNCE loss could recover global downstream signal without giving up the A2 source/confound gains.

## Implemented

- Added `global_infonce_loss(student, teacher, temperature)` in `train_brain_jepa.py`.
- Added CLI flags:
  - `--global_infonce_weight`
  - `--global_infonce_temp`
  - `--global_infonce_warmup`
- Added status logging:
  - `global_infonce_loss`
  - `global_infonce_weight`
- Added unit test coverage for global InfoNCE finite/lower-diagonal behavior.
- Ran two 20k-step A4 branches:
  - `global_infonce_weight=0.05`
  - `global_infonce_weight=0.10`

## Verification

Unit tests:

```text
python -m unittest discover -s Flagship/v2_jepa/code/tests -p 'test_*.py'
Ran 12 tests
OK
```

GPU smoke:

```text
smoke_a4_hybrid_gpu0
3 steps completed
finite loss, finite source/global losses, DONE written
```

Full training:

```text
A4 w=0.05: step=20000 loss=3.5676 global_InfoNCE=0.8828 std=0.19461 rank=146.58 DONE=True ERROR=False
A4 w=0.10: step=20000 loss=3.6402 global_InfoNCE=0.6006 std=0.14658 rank=187.62 DONE=True ERROR=False
```

## Findings

### 1. High: A4 fails the downstream gate

| Task | Metric | A2 | A4 `w=0.05` | A4 `w=0.10` | S3D wg0.5 |
|---|---:|---:|---:|---:|---:|
| Task1 infarct | AUROC | 0.6731 | 0.2308 | 0.2692 | 0.7212 |
| Task3 brain age | Pearson r | 0.6720 | 0.5648 | 0.4669 | 0.7924 |
| Task5 polymicrogyria | AUROC | 0.8681 | 0.8073 | 0.4965 | 0.9566 |

The weak global InfoNCE add-on did not recover global signal. It degraded all three downstream global tasks relative to A2, and it remains far below the previous selected S3D+InfoNCE foundation.

### 2. High: A4 gives back source/confound robustness

| Model | Source-probe acc |
|---|---:|
| A2 mainline | 0.0846 mean over seeds 100/101/102 |
| A4 `w=0.05` | 0.2185 seed100 |
| A4 `w=0.10` | 0.1704 seed100 |
| S3D wg0.5 | 0.3105 mean over seeds 100/101/102 |

A4 is still less source-predictive than S3D, but it is much worse than A2. This means the global contrastive term reintroduced source/cohort information without improving the downstream global tasks.

### 3. Medium: the loss design couples instance discrimination to the main context vector

The current implementation applies global InfoNCE directly to the same global vector used by downstream probes. In brain MRI, instance identity can be entangled with site/scanner/cohort, protocol, FOV, and demographics. A direct in-batch contrastive objective can therefore reward nuisance uniqueness rather than robust anatomy/biology.

Consequence: do not simply increase the InfoNCE weight. If global signal is revisited, use a decoupled projection head, source-balanced negatives, source-stratified negatives, teacher-only global targets, or explicit nuisance-invariant constraints.

### 4. Low: source-probe A4 uses one seed so far

A4 already fails downstream strongly, so repeating source-probe seeds is not necessary for the reject decision. If A4 is later used as a diagnostic baseline, repeat seeds 101/102 for symmetry.

## Final Verdict

A4 is technically stable but scientifically rejected.

It answers a useful question: the missing downstream signal in A2 is not fixed by a simple weak global InfoNCE add-on. The previous S3D+InfoNCE foundation likely benefits from the specific combination of dense reconstruction, segmentation-transferable decoder pressure, and global contrastive learning. Directly grafting global InfoNCE onto JEPA changes the shortcut/global trade-off in the wrong direction.

Current recommendation:

```text
Keep previous ResEnc + S3D + InfoNCE wg0.5 as the best validated foundation.
Keep A2 Brain-JEPA as a confound-robust research branch.
Reject A4 as a replacement.
Do not launch another JEPA branch automatically until the next objective is redesigned.
```
