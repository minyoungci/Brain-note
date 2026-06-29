# Decision Log

## 2026-06-28: Create Flagship Workspace

Decision:

- Create `Flagship/` as foundation-model paper workspace separate from `Challenge_Submission/`.

Reason:

- Challenge work involves containers, validators, and submission attempts.
- Flagship work needs architecture novelty, pretraining diagnostics, ablation design, and paper-ready figures/tables.

## 2026-06-28: Scope Correction

Decision:

- `Flagship` should not be organized around FOMO downstream task performance.
- It should be organized around the foundation model itself:
  - anti-leakage S3D-style dense branch
  - InfoNCE-global collapse prevention
  - dense-global objective balance
  - single-checkpoint dense/global representation design

Reason:

- Challenge downstream optimization belongs in `Challenge_Submission/` or task-specific experiment folders.
- `Flagship` is intended to support a paper about technical novelty and strengths of the foundation model.

## 2026-06-28: Treat Task2 as Fine-Tuning Protocol Problem First

Decision:

- Keep Task2 as a risk/secondary diagnostic, not as the main Flagship organizing axis.

Reason:

- Task4 shows strong segmentation transfer.
- Task2 realistic pipeline currently uses full fine-tuning through `transfer_decoder=True`.
- Few-shot literature favors preserving encoder priors.
- However, Flagship's primary deliverable is foundation-level figure/table evidence, not Task2 optimization.

## 2026-06-28: Primary Paper Directions

Decision:

Maintain three manuscript paths:

1. Methods conference paper
2. External consortium SCI validation paper
3. Few-shot segmentation/fine-tuning protocol paper

Reason:

- The final strongest story depends on external data and Task2 R4 outcomes.


## 2026-06-29: Add S3D-VistaAdapter as a Separate Segmentation Adaptation Track

Decision:

- Keep `Brain-JEPA 3D Multimodal` and `S3D-VistaAdapter` as separate Flagship tracks.
- Brain-JEPA remains a future foundation-pretraining candidate.
- S3D-VistaAdapter is a supervised segmentation decoder/adapter that reuses the current ResEnc/S3D foundation checkpoint.

Reason:

- Task2 experiments show that generic fine-tuning, frozen/low-LR, multimodal fusion, and anisotropic preprocessing do not sufficiently improve meningioma segmentation.
- The next meaningful lever is decoder design, not full foundation retraining.
- The adapter should preserve the existing encoder/global branch so Task1/3/5 representations are not unnecessarily disturbed.

Implementation:

- Added `Flagship/v1_evidence/code/s3d_vista_adapter/`.
- Added `Flagship/v1_evidence/plans/Plan_F_S3D_VistaAdapter.md`.
- Added `Flagship/v1_evidence/code_review/Review_Pass_5_S3D_VistaAdapter.md`.

## 2026-06-29: Park Brain-JEPA and Focus Only on Foundation-v1 Decoder Replacement

Decision:

- Do not run or extend `Flagship/v2_jepa/` experiments for now.
- Keep `v2_jepa` as a parked future foundation-pretraining candidate.
- Restrict active Flagship work to `Flagship/v1_evidence/`, specifically decoder replacement for the current foundation model.

Reason:

- The immediate research question is whether the already trained `ResEnc + S3D-style dense + InfoNCE-global` model can gain segmentation strength by changing the decoder/head while preserving the foundation encoder.
- JEPA changes the foundation pretraining objective and would become a separate v2 foundation project.
- Mixing JEPA with the decoder-replacement track would make evidence attribution unclear.
