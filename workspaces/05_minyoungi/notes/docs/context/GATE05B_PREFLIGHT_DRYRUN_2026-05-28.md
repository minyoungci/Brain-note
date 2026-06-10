# Gate05b preflight and CPU dry-run note

Date: 2026-05-28
Workspace: `/home/vlm/minyoungi`
Experiment family: `experiments/voxelwise_feature_learning_v1`
Status: CPU-only preflight complete; no GPU training launched

## Commands executed

```bash
cd /home/vlm/minyoungi
pwd && git status --short && git branch --show-current
python experiments/voxelwise_feature_learning_v1/scripts/vlm_gate_05b_preflight_caption_split_audit_v0.py
python -m py_compile experiments/voxelwise_feature_learning_v1/scripts/vlm_gate_05b_preflight_caption_split_audit_v0.py
python experiments/voxelwise_feature_learning_v1/scripts/vlm_gate_05b_cpu_manifest_dryrun_v0.py
python -m py_compile experiments/voxelwise_feature_learning_v1/scripts/vlm_gate_05b_cpu_manifest_dryrun_v0.py
```

## Artifacts created

Scripts:

- `experiments/voxelwise_feature_learning_v1/scripts/vlm_gate_05b_preflight_caption_split_audit_v0.py`
- `experiments/voxelwise_feature_learning_v1/scripts/vlm_gate_05b_cpu_manifest_dryrun_v0.py`

Results:

- `experiments/voxelwise_feature_learning_v1/results/vlm_gate_05b_preflight_caption_split_audit_v0/summary.json`
- `experiments/voxelwise_feature_learning_v1/results/vlm_gate_05b_preflight_caption_split_audit_v0/REPORT_KO.md`
- `experiments/voxelwise_feature_learning_v1/results/vlm_gate_05b_preflight_caption_split_audit_v0/artifact_audit_summary.csv`
- `experiments/voxelwise_feature_learning_v1/results/vlm_gate_05b_cpu_manifest_dryrun_v0/summary.json`
- `experiments/voxelwise_feature_learning_v1/results/vlm_gate_05b_cpu_manifest_dryrun_v0/REPORT_KO.md`
- `experiments/voxelwise_feature_learning_v1/results/vlm_gate_05b_cpu_manifest_dryrun_v0/dryrun_sample_rows.csv`

## Preflight caption/split audit result

Source result:

- `experiments/voxelwise_feature_learning_v1/results/vlm_gate_05b_preflight_caption_split_audit_v0/summary.json`

Observed:

- CPU-only: `true`
- GPU required: `false`
- Overall pass: `true`
- Hard failures: `[]`

Caption artifacts checked:

- `roi_quality_text_v0`
  - Rows: `53,115`
  - Unique subjects: `5,702`
  - Missing expected columns: `[]`
  - Forbidden caption term hits: `{}`
- `roi_local_text_v1`
  - Rows: `179,184`
  - Unique subjects: `5,958`
  - Missing expected columns: `[]`
  - Forbidden caption term hits: `{}`
- `roi_pair_text_v1`
  - Rows: `100,791`
  - Unique subjects: `5,958`
  - Missing expected columns: `[]`
  - Forbidden caption term hits: `{}`
- `roi_row_text_v1`
  - Rows: `11,199`
  - Unique subjects: `5,958`
  - Missing expected columns: `[]`
  - Forbidden caption term hits: `{}`

Split reuse / subject disjointness:

- Split manifest: `manifests/v2_integrated/splits/subject_disjoint_split_v0.csv`
- Rows: `11,750`
- Unique row IDs: `11,750`
- Duplicate row IDs: `0`
- Split counts: train `7,838`, val `1,681`, internal_test `1,680`, not_core_training `551`
- Disjoint gate checked only `train`, `val`, `internal_test`; `not_core_training` excluded from the disjoint training/eval gate.
- Subject overlap counts: internal_test×train `0`, internal_test×val `0`, train×val `0`
- Subject-disjoint pass: `true`
- ROI text row-id coverage: `11,199` artifact row IDs; artifact-not-in-split `0`; split labels mismatches `0`; split-not-in-artifact `551` equals `not_core_training` rows.

## CPU manifest dry-run result

Source result:

- `experiments/voxelwise_feature_learning_v1/results/vlm_gate_05b_cpu_manifest_dryrun_v0/summary.json`

Observed:

- CPU-only: `true`
- GPU required: `false`
- Training launched: `false`
- Pass: `true`
- Core rows: `11,199`
- Core unique subjects: `5,958`
- Split counts: train `7,838`, val `1,681`, internal_test `1,680`
- Label counts: CN `6,000`, MCI `3,841`, AD `1,358`
- Row text missing rows: `0`
- Sample T1w paths all exist: `true`
- Sample minimum local ROI texts: `16`
- Sample minimum pair texts: `9`

Important limitation:

- Official ROI quality summary is missing for `576 / 11,199` core rows.
- This is not a CPU dry-run failure, but it is a real design constraint: any Gate05b `quality_status` variant must either restrict to quality-joined rows or report quality missingness explicitly. Severity-only `roi_text_v1` supervision covers the full `11,199` core rows.

## GPU status

No GPU was required for these steps. No GPU training was launched.

Before any real Gate05b model run, required gate remains:

```bash
cd /home/vlm/minyoungi
nvidia-smi
pwd
git status --short
git branch --show-current
```

Then present the exact command preview and wait for Min approval.

## Interpretation

This clears only the **pre-training audit/scaffold layer**:

- forbidden generated-caption term audit passed;
- train/val/internal_test subject disjointness passed;
- row-level ROI text joins passed;
- tiny CPU manifest dry-run passed.

It does **not** make Gate05b VLM-scaling-ready. It only means a future, Min-approved GPU command can be prepared without an immediate caption/split blocker.

## Remaining risks / constraints

- `quality_status` supervision has incomplete official ROI quality coverage: `576` core rows missing.
- Baseline07 comparison remains mandatory; Gate05b must beat Baseline06 image-only LOCO and Baseline07-compatible CN/MCI/AD shortcut evaluation with image-only inference.
- The current scripts are preflight/dry-run scaffolds, not the actual Gate05b model training implementation.
- Existing large caption CSV artifacts remain untracked and should not be committed by default unless an explicit artifact-versioning/LFS policy is chosen.
