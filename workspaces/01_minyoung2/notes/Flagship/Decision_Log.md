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
