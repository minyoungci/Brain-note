# Review Pass 24: A19 Disentangled Auxiliary Modality Branches

Date: 2026-07-01 UTC

## Motivation

A18 showed a useful but incomplete result:

```text
paired-modality JEPA -> source-safe and better brain-age
paired-modality JEPA directly on shared representation -> protocol-heldout Task1 collapse
```

Therefore A19 changes the structure rather than continuing A18 longer. The paired-modality target is no longer the main shared JEPA target. It is routed through a separate anatomy branch.

## Implemented Structure

Added `A19DisentangledHeads`:

```text
shared global vector
  -> anatomy projection
  -> pathology projection
  -> nuisance projection
```

Training mode:

```text
base JEPA:
  context = modality A
  target  = modality A

auxiliary paired-modality anatomy:
  anatomy(context A) -> anatomy(EMA target B)

pathology/global preservation:
  pathology(context A) -> pathology(EMA target A)

regularization:
  orthogonality(anatomy, pathology, nuisance)
  source adversary on anatomy+pathology task vector
  masked S3D dense/local distillation on shared local path
```

This directly addresses A18's failure mode: cross-modality consistency is kept, but not allowed to overwrite the whole shared representation.

## Code Changes

Files changed:

```text
Flagship/v2_jepa/code/train_brain_jepa.py
Flagship/v2_jepa/code/eval_source_probe.py
Flagship/v2_jepa/code/eval_jepa_downstream_probe.py
Flagship/v2_jepa/code/tests/test_brain_jepa.py
```

New train arguments:

```text
--paired_modality_mode shared|aux_anatomy
--a19_heads
--a19_hidden
--a19_dim
--a19_align_hidden
--a19_pair_weight
--a19_pathology_weight
--a19_orth_weight
--source_adv_space a19_anatomy|a19_pathology|a19_nuisance|a19_task
```

New evaluation feature spaces:

```text
a19_anatomy
a19_pathology
a19_nuisance
a19_task
shared_plus_a19_task
shared_plus_a19_all
```

## Validation

Compile:

```text
python -m py_compile \
  Flagship/v2_jepa/code/train_brain_jepa.py \
  Flagship/v2_jepa/code/eval_source_probe.py \
  Flagship/v2_jepa/code/eval_jepa_downstream_probe.py \
  Flagship/v2_jepa/code/tests/test_brain_jepa.py
```

Unit tests:

```text
python Flagship/v2_jepa/code/tests/test_brain_jepa.py
Ran 18 tests OK
```

GPU smoke:

```text
Flagship/v2_jepa/runs/smoke_a19_disentangled_aux_gpu0_20260701
step=5
finite loss
ckpt_step5.pt written
A19 heads, pair align, pathology align present in checkpoint
```

Eval smoke:

```text
eval_source_probe.py --feature_space shared_plus_a19_task
  wrote smoke_a19_shared_plus_task_source_probe.json

eval_jepa_downstream_probe.py --feature_space a19_task --tasks task3_brainage --max_subj 8
  wrote smoke_a19_task_task3_max8.json
```

## Launched Pilots

| GPU | Run | Pair | Seed | Status |
|---:|---|---|---:|---|
| 0 | `pilot_a19_aux_t1flair_taskadv_seed5000_gpu0_20260701` | T1-FLAIR | 5000 | stopped after step5000 Task1 hard fail |
| 1 | `pilot_a19_aux_t1t2_taskadv_seed5001_gpu1_20260701` | T1-T2 | 5001 | stopped after step5000 Task1 hard fail |

Initial health at step 261:

| Branch | Loss | JEPA | A19 pair | A19 pathology | A19 orth | Source acc | Pred std | Pred rank | ERROR |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| T1-FLAIR | 2.5886 | 0.1129 | 0.1263 | 0.0666 | 0.4042 | 0.000 | 0.1985 | 71.86 | false |
| T1-T2 | 2.6184 | 0.1288 | 0.0288 | 0.0218 | 0.3555 | 0.000 | 0.2124 | 70.56 | false |

## Gate

Evaluate at step5000:

```text
source-probe:
  shared
  a19_task
  shared_plus_a19_task

random downstream:
  Task1, Task3, Task5

protocol-group downstream:
  Task1, Task5
```

Promotion thresholds:

```text
source <= 0.17 hard, near A17 0.113 preferred
random Task1 >= 0.80 preferred
brain-age > A18 0.756 preferred, > A17 0.712 minimum
random Task5 >= 0.90
protocol Task1 >= 0.817 preferred, no lower than 0.72 hard floor
protocol Task5 >= 0.897
```

Stop immediately if protocol Task1 fails below `0.72`, even if brain-age improves.

## Step5000 Gate Result

Source-probe:

| Branch | Feature | Source acc | Gate |
|---|---|---:|---|
| T1-FLAIR | shared | 0.1815 | fail |
| T1-FLAIR | a19_task | 0.1796 | fail |
| T1-FLAIR | shared_plus_a19_task | 0.1685 | pass, borderline |
| T1-T2 | shared | 0.1500 | pass |
| T1-T2 | a19_task | 0.1352 | pass |
| T1-T2 | shared_plus_a19_task | 0.1537 | pass |

Task1 hard gate:

| Branch | Feature | Task1 AUROC | Decision |
|---|---|---:|---|
| T1-FLAIR | shared_plus_a19_task | 0.4712 | stop |
| T1-T2 | shared_plus_a19_task | 0.4712 | stop |

Verdict:

- A19 succeeds only on part of the intended correction: T1-T2 source predictability is below the hard gate across all evaluated features.
- It still fails the task that A18 failed: multi-modal pathology classification. Task1 remains `0.4712`, far below A17 and S3D.
- This rejects the hypothesis that "separating paired-modality anatomy into an auxiliary branch" is sufficient to preserve Task1.
- Do not continue these A19 branches to 10k/20k.

Next implication:

```text
Anatomy/modality consistency alone is not enough.
The next positive branch needs a pathology-preserving SSL signal
or the project should promote A17 as the best JEPA research candidate
and move to stronger external/source-heldout validation.
```
