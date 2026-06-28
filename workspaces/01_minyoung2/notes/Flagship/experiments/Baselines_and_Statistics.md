# Baselines and Statistics Plan

## Baseline Hierarchy

### Mandatory

| Baseline | Why |
|---|---|
| scratch same architecture | isolates pretraining value |
| same checkpoint with frozen encoder | tests prior preservation |
| same checkpoint full fine-tune | common downstream protocol |
| constant/empty prior for segmentation | detects shortcut/metric floor |

### Strong Segmentation Baselines

| Baseline | Notes |
|---|---|
| nnU-Net-style supervised | strongest practical supervised reference |
| Asparagus official baseline if runnable | challenge-aligned comparison |
| MedicalNet/Med3D | 3D medical transfer reference |
| SwinUNETR/UNETR | transformer-based reference if feasible |

### Foundation Comparisons

Use only if implementation cost is justified:

- Swin UNETR SSL
- VoCo-style 3D SSL
- SAM-Med3D / VISTA3D for segmentation-only context

## Statistical Rules

### Splits

- subject-disjoint always
- site-disjoint if external consortium metadata allow
- repeated seeds for small-n tasks
- fixed split manifests stored in `Flagship/logs/` or experiment output folders

### Confidence Intervals

- bootstrap by subject
- paired bootstrap for pretrained vs scratch
- report 95% CI
- for n<50, do not overclaim small deltas with overlapping CI

### Segmentation Metrics

Mandatory:

- Dice
- NSD
- lesion recall
- false negative count
- volume error

Optional:

- HD95
- precision/false positive volume
- threshold sensitivity curve

### Classification Metrics

Mandatory:

- AUROC
- AUPRC for imbalanced data
- sensitivity at fixed specificity
- calibration curve or ECE

### Regression Metrics

Mandatory:

- MAE
- Pearson
- Spearman
- site-stratified error

## Reporting Rule

Every result table should include:

```text
model / checkpoint / fine-tuning protocol / data split / n / metric / CI / source path
```

Do not report a single best number without the protocol and split.
