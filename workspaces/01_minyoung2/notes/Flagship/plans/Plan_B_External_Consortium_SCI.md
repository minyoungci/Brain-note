# Plan B: External Consortium SCI Paper

## Target

SCI / clinical AI journals:

- Medical Image Analysis
- IEEE TMI
- Radiology: Artificial Intelligence
- NeuroImage / NeuroImage: Clinical
- Computerized Medical Imaging and Graphics
- Scientific Reports / npj Digital Medicine, depending on strength

## Central Message

```text
A 3D brain MRI foundation model trained without downstream consortium data
improves few-shot transfer across independent multi-center clinical tasks.
```

## Why This Can Be Strong

For SCI venues, the strongest novelty can be **external validation quality**, not only algorithm novelty.

Key strengths if proven:

- consortium data not used in foundation pretraining
- multi-center/scanner/protocol heterogeneity
- few-shot label setting
- task diversity: segmentation, classification, regression, embedding
- practical fine-tuning protocol recommendations

## Required Data Audits

Before any claim:

- subject overlap check
- institution/site overlap check
- acquisition protocol overlap summary
- label source and annotation protocol
- whether any consortium data appeared in pretraining, even unlabeled

## Experimental Design

### Label-Efficiency Curves

For each downstream task:

```text
1 case / 5 cases / 10 cases / 25% / 50% / 100%
```

Use repeated splits:

- subject-disjoint
- site-stratified if possible
- fixed random seeds
- paired comparison between pretrained and scratch

### Baselines

| Baseline | Purpose |
|---|---|
| scratch supervised | minimum necessary |
| nnU-Net style supervised | strong segmentation baseline |
| MedicalNet/Med3D if feasible | 3D medical transfer baseline |
| SwinUNETR/UNETR if feasible | transformer medical baseline |
| frozen feature linear probe | representation quality |

### Evaluation

Segmentation:

- Dice
- NSD
- HD95
- lesion recall
- volume error
- false negative rate

Classification:

- AUROC
- AUPRC
- sensitivity at fixed specificity
- calibration error

Regression:

- MAE
- Pearson/Spearman
- Bland-Altman plot
- site-stratified MAE

Fairness/site:

- scanner/vendor subgroup
- sex/age subgroup if available
- site-held-out validation

## Paper Shape

This paper should emphasize:

1. strict independence
2. few-shot clinical generalization
3. robust statistics and confidence intervals
4. failure analysis
5. practical fine-tuning protocol

## Success Criterion

The paper is strong if:

```text
pretrained transfer improves label efficiency across independent consortium data,
especially in low-label regimes, and remains stable across sites/scanners.
```

## Main Risk

If external data performance is mixed, the paper can still work as:

```text
When do 3D brain MRI foundation models transfer?
```

but the tone must become diagnostic rather than promotional.
