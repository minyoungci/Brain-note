# Review Pass 19: A14/A15 Pseudo-Tissue Dense Target

Date: 2026-07-01 UTC

Scope:

```text
Flagship/v2_jepa/code/train_brain_jepa.py
Flagship/v2_jepa/code/tests/test_brain_jepa.py
Flagship/v2_jepa/runs/pilot_a14_s3ddense005_pseudotissue005_anat_seed4401_gpu0_20260701
Flagship/v2_jepa/runs/pilot_a15_s3ddense005_pseudotissue002_anat_seed4402_gpu0_20260701
```

## What Changed

A14/A15 added a dense pseudo-tissue auxiliary target on top of the current best JEPA research branch, A10:

```text
A10 = source-balanced/style-robust JEPA
    + masked S3D dense/local bottleneck distillation w=0.05

A14/A15 = A10
        + pseudo-tissue dense target
            foreground occupancy
            soft tissue-intensity bins
            local gradient/edge magnitude
        + masked SmoothL1 at JEPA target locations
```

Implementation added:

- `PseudoTissueDenseHead`
- `pseudo_tissue_dense_target`
- `pseudo_tissue_dense_loss`
- checkpoint save/load for the pseudo-tissue head
- CLI controls for weight, warmup, number of bins, and masked-only loss
- unit test coverage for pseudo-tissue target and loss shapes/finite values

## Validation

Static and unit validation:

```text
python -m py_compile Flagship/v2_jepa/code/train_brain_jepa.py Flagship/v2_jepa/code/tests/test_brain_jepa.py
python Flagship/v2_jepa/code/tests/test_brain_jepa.py
Ran 15 tests OK
```

GPU smoke:

```text
smoke_a14_pseudotissue_dense_gpu0
DONE
ckpt_step5.pt written
no ERROR
```

The first reduced-channel smoke exposed a teacher-channel mismatch, which was expected because the S3D teacher bottleneck is 320 channels. The full-channel smoke passed.

## Step1000 Gate

| Branch | Source-probe | Task1 AUROC | Brain-age Pearson | Task5 AUROC | Decision |
|---|---:|---:|---:|---:|---|
| A10 dense `0.05` reference | 0.0778 | 0.8077 | 0.6085 | 0.8976 | best JEPA research branch |
| A14 pseudo-tissue `0.05` | 0.1574 | 0.6346 | 0.7770 | 0.9201 | reject as final |
| A15 pseudo-tissue `0.02` | 0.1648 | 0.4038 | 0.7591 | 0.9462 | reject as final |
| S3D+InfoNCE wg0.5 reference | 0.3105 | 0.7212 | 0.7924 | 0.9566 | production reference |

## Findings

1. No implementation blocker was found in the pseudo-tissue target path.

   The code compiles, the unit tests cover the new tensor path, and the full-channel GPU smoke completed with checkpoint writing.

2. Pseudo-tissue dense prediction is a useful morphology signal.

   A14/A15 recovered brain-age from A10 `0.6085` to `0.7770`/`0.7591`, close to the S3D reference `0.7924`. Task5 also improved from A10 `0.8976` to `0.9201`/`0.9462`.

3. The same target damages the shared representation for Task1.

   Task1 fell from A10 `0.8077` to A14 `0.6346` and A15 `0.4038`. Lowering the pseudo-tissue weight did not fix the problem; it worsened Task1.

4. Longer training is not the right next move.

   Both pilots failed the first downstream gate in the same direction. Continuing to 20k steps would spend GPU on a branch whose early representation already violates the hard Task1 floor.

## Verdict

```text
Do not promote A14 or A15.
Do not continue pseudo-tissue scalar weight sweeps.
Keep A10 dense=0.05 as the best JEPA research branch.
```

The next valid JEPA experiment must structurally separate morphology-sensitive features from task/global classification features. A reasonable design is:

```text
shared A10 feature
  + morphology head trained with pseudo-tissue/atlas/tissue targets
  + downstream feature spaces evaluated separately:
      shared
      morphology
      shared + morphology
```

The first checkpoint gate should require:

```text
source <= 0.17 hard max, <= 0.10 preferred
Task1 >= 0.72 hard floor, >= 0.80 preferred
brain-age > 0.6085 minimum, > 0.672 preferred
Task5 >= 0.88 minimum
```
