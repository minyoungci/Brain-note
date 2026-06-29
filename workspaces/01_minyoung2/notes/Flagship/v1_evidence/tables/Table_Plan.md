# Table Plan

Tables should make the foundation model's novelty and evidence structure explicit.

## Table 1: Module-Level Design Rationale

Columns:

```text
Module | Problem Addressed | Alternative Tried | Observed Failure | Proposed Solution | Evidence Source
```

Rows:

- ResEnc backbone
- S3D-style dense branch
- re-mask/submanifold-style anti-leakage
- skip-enabled decoder transfer
- InfoNCE global branch
- KoLeo regularization
- `wg0.5` dense-global balance

## Table 2: Foundation Failure Modes and Fixes

Columns:

```text
Failure Mode | Symptom | Why It Matters | Fix | Verification
```

Rows:

- skip leakage in naive MAE
- skip-free negative transfer
- CNN global collapse with DINO/Sinkhorn
- dense/global imbalance
- spconv/B200 incompatibility
- downstream full-finetune prior erosion, optional later

## Table 3: Ablation Matrix for Technical Claims

Columns:

```text
Claim | Required Ablation | Metric | Existing Result | Missing Result | Priority
```

Example rows:

- anti-leakage dense branch
- dense-global balance
- InfoNCE vs DINO/Sinkhorn
- S3D-style vs skip-free
- ResEnc vs ViT for dense representation

## Table 4: Pretraining Diagnostics

Columns:

```text
Run | Dense Loss | Global Loss | Representation Variance | Effective Rank | Collapse Flag | Leakage Flag
```

Purpose:

- Show model behavior before downstream task adaptation.

## Table 5: Single-Checkpoint Capability Summary

Columns:

```text
Representation | Extracted From | Intended Use | Trained By | Evidence
```

Rows:

- dense stage features
- bottleneck features
- decoder features
- SimPool global vector
- projection head output

## Table 6: Optional Downstream Support

Use only after foundation tables are done.

Columns:

```text
Task Family | Metric | Pretrained | Baseline | Interpretation
```

Important:

- This table is supporting evidence.
- It should not be the main Flagship table.
