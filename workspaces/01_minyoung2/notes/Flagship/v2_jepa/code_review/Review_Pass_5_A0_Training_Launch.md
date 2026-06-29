# Review Pass 5: A0 Brain-JEPA Training Launch

Date: 2026-06-29 UTC

Scope:

```text
Flagship/v2_jepa/code/train_brain_jepa.py
Flagship/v2_jepa/code/brain_jepa/*
Flagship/v2_jepa/scripts/watch_jepa_runs.sh
active runs: pilot_a0_anat_seed2026_gpu0_20260629, pilot_a0_all_seed2027_gpu1_20260629
```

## Verdict

The current code is acceptable for an **A0 real-data JEPA pilot** and for GPU0/1 background execution.

It is **not yet sufficient as the final foundation training code** for the proposed anatomy- and modality-aware BAM-JEPA paper objective.

## Checks Passed

```bash
.venv-train/bin/python -m py_compile \
  Flagship/v2_jepa/code/train_brain_jepa.py \
  Flagship/v2_jepa/code/brain_jepa/*.py \
  Flagship/v2_jepa/code/analysis/*.py

.venv-train/bin/python -m unittest \
  Flagship.v2_jepa.code.tests.test_brain_jepa \
  Flagship.v2_jepa.code.tests.test_loss_geometry
```

Result:

```text
Ran 9 tests
OK
```

Additional manual checks:

- synthetic Brain-JEPA smoke passed
- real `.npy` smoke passed
- crop96 ResEnc-L smoke passed
- GPU0/1 `setsid + nohup` launch verified
- checkpoint creation verified at 1k/2k/3k/4k steps
- no `ERROR.json`
- collapse diagnostics healthy at ~5k steps

## Findings

### High: A0 objective is too easy for a final paper claim

Evidence:

```text
loss falls to ~0.001-0.003 by ~5k steps
feature std/rank remain healthy, so this is not collapse, but the task is likely too easy
```

Interpretation:

```text
same-crop masked context -> same-crop EMA target latent
```

is useful to verify plumbing, EMA, masking, checkpoints, and monitoring. It is not strong enough to claim the full proposed brain-anatomy-aware JEPA novelty.

Required next step:

- multi-view target crops
- anatomy-aware ROI/tissue target sampling
- paired modality latent consistency
- held-out downstream probe

### Medium: Context encoder uses dense convolution on zero-masked voxels

Current code masks input voxels:

```text
context = x * visible_mask
```

This is not true sparse/submanifold masked convolution. Convolutional receptive fields still see zero-coded target regions and nearby visible voxels.

This is acceptable for A0 pilot but should not be described as anti-leakage S3D. For final method, either:

- implement re-mask gates after each encoder stage, or
- explicitly state this is dense masked JEPA, not submanifold masked-conv.

### Medium: No true multimodal pairing yet

The running trainer uses:

```text
modalities=("mri",)
```

`composition=all` means mixed sequence pool, not paired T1/FLAIR/DWI consistency. Therefore the running GPU1 job is "all-sequence single-channel JEPA", not modality-aware consistency training.

Required next step:

- subject/session grouped loader
- missing-modality aware batch collator
- modality-specific stems/tokens
- cross-modal latent target loss

### Medium: Watcher process listing was noisy

`pgrep` captured DataLoader worker processes because workers inherit the same command line. This made the monitor look like dozens of trainers.

Fix applied:

```text
watch_jepa_runs.sh now prints only parent trainer processes with PPID==1.
```

### Low: Resume is statistically continuous but not mid-epoch bit-exact

`infinite_batches` resumes from the epoch inferred by `start_step`, but does not skip already consumed batches inside that epoch.

This matches the existing pretrain loader style and is acceptable for SSL pilot training. It should not be advertised as bit-exact data-order resume.

### Low: Checkpoint atomic save lacks fsync

`torch.save -> os.replace` protects against partial final names but does not fsync the temp file/directory. This is normally acceptable on this filesystem for pilots. For long full-scale runs, add fsync.

## Current Active Snapshot

At review time:

```text
all-sequence: step~4941 loss~0.00165 std~0.1239 rank~149
anat-only:    step~4941 loss~0.00276 std~0.1192 rank~172
```

No immediate collapse detected.

## Recommendation

Let the two A0 pilot runs finish or at least reach 20k steps. Treat them as:

```text
pipeline validation + collapse sanity + data-composition smoke
```

Do not use them as the final Flagship foundation result.

The next engineering milestone should be:

```text
A1/A2 BAM-JEPA:
  anatomy-aware target sampler
  true paired multimodal loader
  harder multi-view latent targets
  downstream frozen probe after checkpoints
```

