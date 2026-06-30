# Next A8 Design: Factorized Global Representation

Date: 2026-06-30 UTC

## Why A8 Is Needed

The A2-A7 sequence established a consistent trade-off:

| Branch | What improved | What failed |
|---|---|---|
| A2 | source-probe very low | downstream global signal weak |
| A5 | downstream global signal partly recovered | source-probe high |
| A7 | source-probe reduced again | downstream global signal damaged |

This means the current shared global vector entangles:

```text
biology / phenotype / age signal
source / scanner / cohort signal
```

Adversarial pressure on the same vector removes both. Global alignment on the same vector restores both. The next architecture should stop forcing both objectives through one representation.

## Proposed Architecture

```text
context encoder global vector: z_shared

z_bio = biological projection head(z_shared)
z_src = nuisance projection head(z_shared)
```

Use separate heads:

- `z_bio`: used for global alignment and downstream probes.
- `z_src`: used by the source adversary.

The foundation encoder still produces a single checkpoint, but training separates objectives in projection space.

## Proposed Loss

```text
L_total =
    L_JEPA_latent
  + w_bio * L_global_align(z_bio_student, z_bio_teacher)
  + L_source_adv(z_src)
  + w_orth * L_orth(z_bio, z_src)
```

Where:

- `L_JEPA_latent`: existing masked latent JEPA loss.
- `L_global_align`: positive-only EMA global alignment from A5.
- `L_source_adv`: source classification with GRL on `z_src`.
- `L_orth`: batch covariance or cosine decorrelation between `z_bio` and `z_src`.

## Rationale

A7 proved that a stronger source-control mechanism can reduce post-hoc source-probe, but doing that on the shared vector damages downstream signal. A factorized design gives the model capacity to separate:

```text
what should transfer downstream
vs.
what should be recognized and controlled as nuisance
```

## Minimal A8 Pilot

Start with two runs:

| Run | `w_bio` | `source_adv_weight` | `w_orth` | Batch |
|---|---:|---:|---:|---:|
| A8-a | 0.10 | 0.05 | 0.05 | 8 |
| A8-b | 0.10 | 0.05 | 0.10 | 8 |

Keep A7 stable settings:

```text
source_adv_hidden=1024
source_adv_warmup=5000
global_align_hidden=512
target_view=second_crop
crop_mode=foreground
mask_strategy=random
style_aug_strength=0.75
```

## Gates

A8 should only be considered useful if it satisfies both:

```text
source-probe <= 0.17
brain age r >= 0.67
Task1 AUROC >= 0.67
Task5 AUROC >= 0.86
```

Stronger target:

```text
source-probe close to A2 (~0.085)
downstream close to or above A5 w=0.10
```

## Implementation Notes

This requires code changes:

- Add `BioProjectionHead`.
- Add `NuisanceProjectionHead`.
- Save/restore both heads in checkpoints.
- Apply `global_alignment_loss` to `z_bio`.
- Apply `SourceAdversary` to `z_src`.
- Add an orthogonality/covariance penalty.
- Update status logging with:
  - `bio_align_loss`
  - `source_loss`
  - `orth_loss`
  - `z_bio_stats`
  - `z_src_stats`

Do not launch A8 until these changes pass unit tests and GPU smoke.
