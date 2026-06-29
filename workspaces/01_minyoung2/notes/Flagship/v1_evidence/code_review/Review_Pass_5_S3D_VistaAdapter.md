# Review Pass 5. S3D-VistaAdapter

Date: 2026-06-29
Scope: `Flagship/v1_evidence/code/s3d_vista_adapter/`, smoke test, unit tests, training protocol.

## Verdict

Pass after fixes. The module is suitable as a Flagship research prototype, isolated from challenge submission code. It is not yet a production Task2 trainer. A real CV runner, checkpoint saving, EMA, threshold/postprocess sweep, and result aggregation are still required before claiming performance.

## Critical findings fixed

### C1. Learned multimodal fusion silently accepted missing modalities

Problem: `fusion="learned"` was initialized for all configured modalities, but a single available modality could bypass the learned fusion path and return raw features. That would make multimodal ablations incomparable and hide missing-modality data bugs.

Fix: `FeatureFusion.forward()` now fails fast when learned fusion receives fewer modalities than configured.

Test: `test_learned_fusion_requires_all_modalities`.

### C2. Lesion query dimension was assumed to match bottleneck feature channels

Problem: `voxel_query_contrastive_loss()` compared feature vectors with `lesion_query`. Full settings can use `query_dim=128` and bottleneck `320`, so the contrastive branch would crash or silently force bad configs.

Fix: model now includes `query_to_feature`, projecting conditioning query into bottleneck feature space. Loss also checks query-feature channel agreement explicitly.

Tests: query_dim differs from feature dim in the default unit-test config; smoke also exercises this projection.

### C3. Tiny lesions could disappear during contrast-mask downsampling

Problem: a one-voxel or very small lesion can vanish when the input mask is interpolated down to bottleneck feature resolution, causing contrast loss to return 0. This is dangerous for Task2 because missed small lesions are exactly the failure mode.

Fix: `make_coarse_target()` now uses foreground-preserving adaptive max pooling. Tiny lesion preservation is covered by test.

Test: `test_contrast_and_distill_losses` checks a 1-voxel lesion remains positive after resize and yields a positive contrast loss.

## Additional checks

- zero-init residual adapter is identity at initialization
- forward shape matches target mask shape
- spacing embedding exists and is batch-compatible
- SSL ResEnc encoder loading maps only `backbone.stem.*` and `backbone.enc.*`
- optimizer groups separate encoder and adapter/decoder LR
- py_compile passes
- S3D-VistaAdapter smoke forward/backward/optimizer step passes

## Training and optimization review

Recommended initial run:

```text
encoder_lr = 1e-5
adapter_decoder_lr = 1e-3
loss = Tversky(beta=0.8) + 0.25 coarse focal + 0.01 contrast
EMA = 0.999 in trainer
CV = 4 folds x 3 seeds, subject-disjoint
selection = validation Dice + NSD, with scratch/current-best controls
```

Do not start with all knobs at maximum. Use this order:

1. adapter only, encoder frozen
2. low-LR encoder
3. add coarse loss
4. add contrast loss
5. add spacing FiLM ablation
6. add feature distillation only if fold variance or overfit appears

## Remaining risks

- No real Task2 dataloader/trainer is implemented in Flagship yet.
- Feature distillation needs a frozen teacher feature source in the trainer.
- Binary loss only; multiclass Task4 would need extension.
- No threshold sweep or largest-component postprocess in this package.
- No inference speed profiling yet.

## Commands run

```bash
python -m unittest Flagship.v1_evidence.code.tests.test_s3d_vista_adapter
python Flagship/v1_evidence/code/smoke_s3d_vista_adapter.py
python -m py_compile Flagship/v1_evidence/code/s3d_vista_adapter/config.py Flagship/v1_evidence/code/s3d_vista_adapter/model.py Flagship/v1_evidence/code/s3d_vista_adapter/losses.py Flagship/v1_evidence/code/s3d_vista_adapter/weight_loading.py Flagship/v1_evidence/code/smoke_s3d_vista_adapter.py Flagship/v1_evidence/code/tests/test_s3d_vista_adapter.py
```
