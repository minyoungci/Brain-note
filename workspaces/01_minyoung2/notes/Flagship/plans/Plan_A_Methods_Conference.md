# Plan A: Methods Conference Paper

## Target

Medical AI / medical imaging methods venues:

- MICCAI main or workshop
- MIDL
- ISBI
- IPMI
- NeurIPS/ICLR medical imaging workshop

## Central Message

```text
Few-shot 3D brain MRI transfer requires both dense spatial priors and stable
global representations. A single ResEnc checkpoint trained with anti-leakage
dense reconstruction and InfoNCE-global learns both.
```

## Contributions

1. **S3D-style anti-leakage dense branch**
   - Enables skip-based decoder transfer without reconstruction leakage.
   - Directly addresses the skip-free MAE negative-transfer failure.

2. **Dense-global dual objective in one checkpoint**
   - Dense branch targets segmentation transfer.
   - InfoNCE global branch targets classification/regression/embedding transfer.

3. **Local-global trade-off analysis**
   - Compare dense-only, balanced, and global-heavy variants.
   - Show `wg0.5` as a Pareto compromise.

4. **Fine-tuning protocol analysis**
   - Full fine-tuning can be harmful in very small segmentation tasks.
   - Frozen or low-LR encoder protocols are tested as foundation-preserving alternatives.

## Minimum Experiments

### Architecture Ablation

| Variant | Purpose |
|---|---|
| ResEnc scratch | supervised lower bound |
| ResEnc MAE skip-free | dense without skip transfer |
| ResEnc S3D dense only | dense transfer |
| ResEnc InfoNCE global only | global transfer |
| ResEnc S3D + InfoNCE wg0.5 | proposed |
| ResEnc S3D + InfoNCE full/global-heavy | trade-off |

### Downstream Tasks

| Category | Required Metrics |
|---|---|
| Segmentation | Dice, NSD, HD95, lesion recall |
| Classification | AUROC, AUPRC, calibration |
| Regression | MAE, Pearson/Spearman |
| Embedding | frozen linear probe, scanner/fairness analysis |

### Fine-Tuning Protocol

| Protocol | Why |
|---|---|
| full fine-tune | common baseline |
| frozen encoder + decoder/head | few-shot prior preservation |
| low-LR encoder + decoder/head | controlled adaptation |
| layer-wise LR decay | softer preservation |
| scratch matched protocol | true transfer value |

## Must-Fix Before Submission

- Task2 R4 frozen/low-LR result
- Clear distinction between architecture benefit and downstream recipe benefit
- Strong baseline comparison against nnU-Net-style supervised pipeline
- External or held-out consortium validation if available

## Expected Reviewer Questions

1. Is the S3D branch genuinely new or just MAE with masking?
2. Does the method outperform strong supervised nnU-Net when labels are enough?
3. Does Task2 failure weaken the generality claim?
4. Are gains from pretraining or from downstream recipe tuning?
5. Are challenge-style tasks independent from pretraining data?

## Success Criterion

The paper is viable if:

```text
wg0.5 improves at least 3 heterogeneous task families,
S3D anti-leakage improves segmentation transfer over skip-free/dense baselines,
and frozen/low-LR fine-tuning explains or improves the weak Task2 result.
```
