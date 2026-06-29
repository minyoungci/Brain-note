# Flagship Scope

## One-Sentence Definition

`Flagship` is the workspace for proving and presenting the **technical novelty of the foundation model itself**, not for optimizing FOMO downstream submission tasks.

## In Scope

- Architecture explanation
- Objective design
- Module-level novelty
- Failure modes solved by the model
- Pretraining diagnostics
- Ablation design for foundation-level claims
- Paper-ready figures and tables
- Claims that are true before looking at any specific challenge task score

## Out of Scope

- Task-specific submission strategy
- SIF/container packaging
- Validator logs
- Synapse submission attempts
- Task1-v2, Task2 R4, or other challenge-targeted optimization as the main story
- Any raw downstream label dump

## Allowed Use of Downstream Results

Downstream results can be referenced only as:

1. motivation,
2. sanity check,
3. secondary validation,
4. later external evidence.

They should not drive the `Flagship` folder structure.

## Foundation-Level Claims To Prove

### Claim A: Anti-Leakage Dense Pretraining

The S3D-style dense branch preserves skip/decoder transfer capacity while preventing masked-region leakage through re-mask/submanifold-style masking.

### Claim B: Dense-Global Co-Training

Dense reconstruction and global contrastive objectives can coexist in a single ResEnc checkpoint if the global objective uses contrastive negatives and the dense branch uses leakage-safe skip paths.

### Claim C: CNN Global Collapse Control

InfoNCE-global stabilizes CNN global representation learning where DINO/Sinkhorn-style objectives showed collapse in our experiments.

### Claim D: Single-Checkpoint Design

The model is not a task-specific collection of heads; it is one foundation checkpoint with dense and global representations available from the same shared backbone.

## Immediate Deliverable

Create a paper-ready evidence packet:

```text
figures/
tables/
manuscript/claim text
experiment matrix for missing foundation-only ablations
```
