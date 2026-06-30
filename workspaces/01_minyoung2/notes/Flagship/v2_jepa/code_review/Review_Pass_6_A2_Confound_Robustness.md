# Review Pass 6: A2 Confound-Robust Brain-JEPA Pilots

Date: 2026-06-30 UTC

## Scope

Reviewed the A2 changes after A1 source-probe showed:

- A1 `same_crop + source_adv` worsened source predictability.
- A1 `second_crop + source_adv` reduced source predictability but remained above chance.

A2 therefore builds only on the `second_crop + source-balanced + source_adv` branch.

## Implemented

- Foreground-biased crop mode in `source_balanced_data.py`.
- Optional foreground mask return from `SourceBalancedMultiCrop`.
- Foreground-weighted block masking in `brain_jepa/masking.py`.
- MRI style augmentation in `train_brain_jepa.py`:
  - global scale
  - global offset
  - smooth multiplicative bias field
  - noise
- CLI flags:
  - `--crop_mode random|foreground`
  - `--mask_strategy random|foreground`
  - `--style_aug_strength`
- Unit tests for:
  - foreground mask preference
  - style augmentation shape/finite/value-change behavior

## Verification

Commands run:

```bash
python -m py_compile \
  Flagship/v2_jepa/code/train_brain_jepa.py \
  Flagship/v2_jepa/code/source_balanced_data.py \
  Flagship/v2_jepa/code/brain_jepa/masking.py \
  Flagship/v2_jepa/code/tests/test_brain_jepa.py

python -m unittest discover -s Flagship/v2_jepa/code/tests -p 'test_*.py'
```

Result:

```text
Ran 11 tests
OK
```

GPU smoke:

```text
smoke_a2_fgstyle_gpu0
step=1..3 completed
finite loss, finite std/rank, DONE written
```

## Running Experiments

| Run | Purpose |
|---|---|
| `pilot_a2_full_fgcrop_fgmask_style075_adv_anat_seed3200_gpu0_20260630` | Full A2: foreground crop + foreground target mask + MRI style augmentation |
| `pilot_a2_ablate_randommask_fgcrop_style075_adv_anat_seed3201_gpu1_20260630` | Ablation: foreground crop + random target mask + MRI style augmentation |

Early status after launch:

```text
A2 full:   step>2700, pred std ~0.138, rank ~156, no collapse
A2 ablate: step>2900, pred std ~0.136, rank ~170, no collapse
```

## Findings

### 1. Medium: A2 is anatomy-biased, not atlas-anatomy-aware yet

`foreground` here means non-zero brain foreground from the preprocessed NPY crop. It avoids background/padding targets and makes target blocks more anatomical, but it is not yet ROI/tissue/atlas-aware.

Consequence: this is a valid A2 pilot for reducing shortcut learning, but the paper claim should not say atlas-aware or tissue-aware until A3 adds an explicit atlas/tissue/ROI signal.

### 2. Medium: `second_crop` improves shortcut resistance but is not spatially paired

The current best branch uses two independently sampled crops. Foreground target masks are computed on the target crop, while the visible mask is applied to the context crop at the same tensor coordinates. Since the crops are not guaranteed to overlap spatially, this is a hard multi-view invariance task rather than strict local context prediction.

Consequence: keep A2 as a source-probe experiment, but A3 should add paired/overlap crop metadata if the intended claim is anatomy-aware context prediction.

### 3. Low: running A2 manifests have stale `purpose`

The trainer previously wrote `Brain-JEPA A0 real-data pilot foundation pretraining` for all runs. This was fixed in code to a generic purpose string, but the already-running A2 manifests were created before the fix.

Consequence: rely on `args` and run names for these A2 runs. Future manifests will be less ambiguous.

## Final Verdict

A2 is safe from a training-stability perspective. It passed static checks, unit tests, GPU smoke, completed 20k steps for both variants, and had no collapse guard violations.

The success gate was post-hoc source-probe, not training loss. The final result is mixed:

| Model | Source-probe mean over seeds 100/101/102 | Decision |
|---|---:|---|
| A1 `second_crop + source_adv` | 0.1049 | previous best |
| A2 full `foreground crop + foreground mask + style + source_adv` | 0.2463 | reject |
| A2 ablation `foreground crop + random mask + style + source_adv` | 0.0846 | promote |

The foreground target-mask implementation failed the confound gate. It made the JEPA task harder, but the global vector became more source-predictive. This supports the review concern that target-side foreground masking under unpaired `second_crop` may amplify source/FOV-specific foreground structure.

The current mainline should be:

```text
source-balanced sampling
+ second-crop JEPA
+ foreground crop
+ random block target mask
+ independent MRI style augmentation
+ source adversary
```

Next branch:

- A3 paired/overlap crop JEPA, so target masks are spatially meaningful relative to context.
- Or explicit atlas/tissue/ROI targets before making a strong anatomy-aware claim.
