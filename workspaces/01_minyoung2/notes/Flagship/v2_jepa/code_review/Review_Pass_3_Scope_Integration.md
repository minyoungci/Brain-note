# Review Pass 3: Scope / Integration Review

Date: 2026-06-28

## Scope Boundary

Requirement:

```text
Flagship must be separate from challenge/downstream submission work.
```

Check:

- all new code is under `Flagship/v2_jepa/code/`.
- no files under `Challenge_Submission/` were touched.
- no pretraining or downstream production path was modified.
- model code imports reusable `pretrain.models.ResBlock` and `SimPool`, but does not alter them.

Conclusion:

- scope boundary is respected.

## Integration Surface

The package exposes only:

```python
BrainJEPA
BrainJEPAConfig
BrainJEPAOutput
ResEncFeatureEncoder
```

This is intentionally narrow. Full training concerns such as dataloading, checkpointing, and DDP are not mixed into the model package.

## Design Review

Good:

- context encoder and target encoder are separate modules.
- target encoder is frozen and updated through explicit `ema_update`.
- modality-specific stems support multimodal MRI while sharing higher-level ResEnc stages.
- latent prediction loss supports target-region masks.
- diagnostics expose std/effective-rank collapse signals.
- smoke test verifies one optimizer step and EMA update.

Concerns to address before real training:

1. Add target positional embeddings.
2. Add explicit cross-modal sampling schedule.
3. Add multi-view crop sampler.
4. Add checkpoint save/resume.
5. Add AMP/gradient scaling if training on B200.
6. Add logging for feature variance/effective rank every N steps.

## Decision

The code is acceptable as a Flagship prototype scaffold.

It is not yet a training-ready full Brain-JEPA system, and it should not be represented as such.
