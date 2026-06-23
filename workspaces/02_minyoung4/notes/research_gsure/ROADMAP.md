# G-SURE Pre-Research Roadmap

This roadmap defines the evidence required before committing to GPU training or
claiming a research direction.

## Current Research Question

Can glioma segmentation be reframed as visual grounding reliability, where a
model predicts a tumor mask and estimates where that segmentation is supported
by image evidence and where it is likely to fail under cross-consortium shift?

## Why This Matters

The workspace has multi-consortium MRI and near-complete tumor segmentation
masks. A publishable direction should use that strength directly. Improving Dice
alone is unlikely to be enough; the technical claim should focus on grounded
segmentation reliability, cross-site failure prediction, or uncertainty that is
spatially tied to the lesion and image evidence.

## Required Stages

### Stage 1. Mask Path and Taxonomy Inventory

Goal: establish what segmentation files exist and what each appears to mean.

Minimum evidence:
- one row per NIfTI file path,
- segmentation keys by dataset,
- subject/session/unit identifiers inferred from paths,
- candidate mask semantics,
- missing or ambiguous taxonomy flags.

Stop rule:
- do not proceed to modeling if mask taxonomy cannot support a common target.

Artifact:
- `02_audits/outputs/mask_path_inventory.csv`
- `02_audits/outputs/mask_path_summary_by_dataset.csv`
- `02_audits/outputs/mask_path_summary_by_key.csv`
- `02_audits/outputs/mask_path_audit_report.md`

### Stage 2. Mask Value and Geometry Audit

Goal: verify labels and image-mask compatibility by reading only headers and
mask value samples.

Minimum evidence:
- observed label values per segmentation key,
- empty/all-zero masks,
- shape and affine compatibility with structural MRI,
- voxel spacing and orientation summary,
- candidate official target definition.

Stop rule:
- do not define a segmentation task until target labels and geometry are
  auditable across all included datasets.

### Stage 3. Cohort and Unit Lock

Goal: choose the analysis unit before split creation.

Minimum evidence:
- subject ID policy,
- session/timepoint policy,
- pre-treatment/post-treatment ambiguity report,
- selected unit per subject,
- inclusion/exclusion table.

Stop rule:
- do not split data until repeated visits and near-duplicate image leakage are
  handled.

### Stage 4. Baseline Segmentation Contract

Goal: define naive and strong segmentation baselines without claiming novelty.

Minimum evidence:
- baseline architecture,
- input channels,
- target mask definition,
- split policy,
- Dice/HD95/surface Dice metrics,
- calibration and uncertainty metrics.

Stop rule:
- do not implement G-SURE until a conventional segmentation baseline is
  trustworthy.

### Stage 5. Grounding and Reliability Baselines

Goal: measure whether existing uncertainty signals predict segmentation failure.

Minimum evidence:
- lesion-size, predicted-volume, and image-difficulty proxy baselines,
- entropy, ensemble variance, test-time augmentation variance, and distance-to
  lesion boundary baselines,
- per-voxel and per-region failure labels from baseline segmentation errors,
- inner-OOF train labels for DeVries-style and QCResUNet-style QC baselines,
- consortium-wise reliability curves.

Stop rule:
- if simple uncertainty baselines already solve the reliability task, the method
  needs a sharper contribution.
- if QC baselines require leakage-prone labels, do not proceed to method work.

### Stage 6. G-SURE Method Definition

Goal: propose a technically defensible method only after the data and baseline
failure modes are visible.

Candidate claim:
- predict segmentation plus spatial reliability/failure risk under domain shift,
  using mask-derived supervision and image evidence consistency.

Required ablations:
- segmentation-only,
- uncertainty-only,
- reliability head without grounding constraint,
- full method,
- cross-consortium evaluation.

### Stage 7. Cross-Consortium Evaluation

Goal: test whether reliability generalizes across consortium shift.

Minimum evidence:
- leave-one-consortium-out segmentation metrics,
- failure prediction AUC/AUPRC,
- reliability calibration,
- subgroup reports by dataset and mask key.

Stop rule:
- if reliability fails under held-out consortium shift, do not claim robust
  grounding.

### Stage 8. Paper Decision

Decision options:
- method paper: only if G-SURE beats strong reliability baselines under LOCO,
- benchmark/protocol paper: if the main contribution is the audit and evaluation,
- stop/pivot: if mask semantics or cohort unit issues prevent a clean task.

## Current Stage

Stage 4 has crossed the official split gate. The subject-level official LOCO
split was written, checked, and passed consolidated post-split CPU validation.
The validation included official split artifact checking, all-consortium bounded
loader smoke, split-aware tile budget, and split-aware tile-grid dry-run with 0
coverage failures.

Stage 5 is protocol-ready only. It cannot start until an out-of-fold
segmentation baseline produces validated full-volume predictions and error maps.
QC baselines require the inner-OOF schedule in
`01_protocol/INNER_OOF_QC_LABEL_SCHEDULE_DRAFT.md`.

Immediate next gate:

1. Prepare a reviewed first-baseline GPU command preview.
2. Confirm expected outputs, runtime, stop criteria, and checkpoint policy.
3. Run GPU only after separate explicit approval.
