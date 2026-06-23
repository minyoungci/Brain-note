# G-SURE Protocol Draft

## Task

3D glioma MRI segmentation with visual grounding and reliability localization.

## Research Question

Can a segmentation model localize not only the tumor mask, but also the visual
regions where its prediction is grounded and where it is likely to fail,
especially on held-out consortia?

## Primary Outcome

The primary outcome is not just Dice. The primary evidence should combine:

1. Segmentation quality.
2. Error/reliability localization quality.
3. Cross-consortium generalization.

## Input

Candidate input:

```text
4-channel structural MRI = T1, T1ce/T1-post, T2, FLAIR
```

No clinical metadata should be used by the image model unless explicitly
declared as a separate multimodal ablation.

## Output

The model should produce:

1. Tumor segmentation probability map.
2. Reliability or failure-risk map.
3. Optional visual evidence/grounding map.

## Unit of Analysis

- Subject for train/test splitting and report aggregation.
- Voxel/region for segmentation and grounding metrics.
- Consortium for external generalization.

## Cohort / Filters

Not locked yet.

Candidate cohort:

- Subjects with all four structural MRI channels.
- Usable segmentation mask under the locked taxonomy.
- One selected imaging unit per subject or a clearly defined multi-unit policy.

## Split Policy

Primary:

```text
Leave-One-Consortium-Out (LOCO)
```

Mandatory grouping:

```text
leakage_group_id = dataset::subject_id
```

No unit-level random split is allowed.

## Grounding Labels

Candidate supervision signals:

- Ground-truth tumor mask.
- Tumor boundary band.
- False-negative map from baseline prediction.
- False-positive map from baseline prediction.
- Ensemble/TTA disagreement map as a soft pseudo-label.
- Low-confidence region from probabilistic segmentation.

Grounding labels that depend on a model prediction must be generated using
train-only or out-of-fold predictions when used for model training.

## Primary Metrics

Metric contract:

```text
research_gsure/01_protocol/RELIABILITY_METRIC_CONTRACT.md
```

Segmentation:

- Dice.
- Dice by consortium.
- Dice by lesion-size bin.
- Dice <= 0.8 subject failure rate.

Reliability / grounding:

- Voxel-level error localization AUROC/AUPRC.
- Top-k reliability concentration over actual error voxels.
- Reliability-error calibration curve.
- Region-level overlap between predicted risk map and FP/FN/boundary error.
- Subject-level low-Dice detection AUROC/AUPRC.

Compute-aware optional:

- Dice/reliability versus escalation budget.

## Main Baselines

Minimum baseline set:

1. Plain 3D U-Net / ResUNet segmentation.
2. Entropy/confidence map from the segmentation probability.
3. TTA uncertainty.
4. MC dropout uncertainty, if the architecture supports it.
5. Ensemble disagreement.
6. DeVries-style segmentation quality prediction from image, predicted mask,
   and uncertainty.
7. QCResUNet-style subject-level QC plus voxel-level error-map prediction.
8. Multi-task segmentation + error/reliability head without grounding
   constraint.
9. G-SURE proposed grounded reliability model.

## Literature Status

Initial literature scout:

```text
research_gsure/00_context/20260623_gsure_literature_scout.md
research_gsure/00_context/20260623_gsure_prior_work_matrix.md
research_gsure/03_baselines/UNCERTAINTY_QC_BASELINE_REQUIREMENTS.md
```

Current implication: uncertainty maps, segmentation quality prediction, and
brain tumor segmentation error-map prediction are not novel by themselves.
G-SURE must be evaluated against strong uncertainty/QC baselines and must show
value in LOCO full-volume reliability/error localization, not merely Dice.

## No-Go Criteria

Do not continue a method if:

- It improves reliability maps only by using target leakage.
- It improves Dice but reliability maps do not localize actual error.
- It improves within-source results but collapses on held-out consortium.
- It requires segmentation masks at inference unless the task explicitly allows
  it.
- It relies on post-hoc visualization without quantitative grounding metrics.
