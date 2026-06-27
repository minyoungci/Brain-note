# Stage 24 Pre-Split Readiness Preflight

## Scope

Add a CPU-only preflight that checks whether the G-SURE workspace is still in a
consistent pre-official-split state. This stage did not create official split
files, run GPU, preprocess data, run inference, generate real predictions, or
generate real reliability labels.

## Goal Reminder

G-SURE requires a strict chain before training:

```text
official split -> loader smoke -> tile budget/grid checks -> GPU preview ->
OOF prediction -> prediction validation -> reliability label generation
```

The preflight verifies that the current workspace is prepared for the next
approval-gated action without accidentally crossing that gate.

## Added Script

```text
research_gsure/02_audits/scripts/check_pre_split_readiness.py
```

## Checks

The preflight checks:

- required protocol, baseline, audit, and script files exist,
- core research direction documents exist,
- active direction documents have no stale IDH/CTEC/exp-style contamination,
- direction contamination self-test rejects an injected stale term,
- split, target, subject-unit, loader, OOF prediction, reliability-label,
  reliability-metric, inner-OOF, baseline, uncertainty/QC, and GPU-preview
  contracts exist,
- official split artifacts are absent,
- subject-level draft cohort has 1,614 rows,
- subject counts are `203 / 178 / 611 / 622` for MU/UCSD/UPENN/UTSW,
- subject-level draft cohort semantic checks pass:
  - one selected unit per `dataset::subject_id`,
  - target mapping policy is `binary_whole_lesion_fets_only`,
  - target definition is `selected_mask > 0`,
  - selection policy is `one_unit_per_subject_earliest_numeric_order`,
  - selected mask key matches the dataset-specific primary source,
  - selected masks have positive nonzero voxel/fraction fields,
  - MRI/mask geometry-match flag is set for every selected row,
- subject manifest semantic self-test rejects in-memory negative controls for
  target drift, selection-policy drift, mask-key drift, duplicate subject group,
  invalid mask burden, geometry flag drift, and missing mask path,
- document invariant self-test rejects missing-document and missing-text
  negative controls,
- Stage audit coverage self-test rejects missing Stage required-file entries,
- output evidence coverage self-test rejects missing pre-split output
  required-file entries,
- subject rows have MRI and selected-mask paths,
- LOCO readiness reports 0 subject overlap and 0 secondary-unit leakage,
- tile-grid dry-run summary has 0 coverage failures for first preview patches,
- official split builder dry-run succeeds,
- official split builder write-safety self-test passes, proving validation-error
  writes are refused,
- official split artifacts absent check passes,
- official split checker dry-run self-test passes, including lesion-burden
  mismatch negative control,
- tile-audit overwrite-safety self-tests pass,
- post-split validation runner preview succeeds,
- post-split validation runner dry-run self-test passes, including
  all-consortium loader-smoke expansion and absent-split refusal,
- OOF prediction metadata validator synthetic self-test passes,
- inner-OOF prediction validator synthetic self-test passes,
- prediction artifact validator synthetic self-test passes,
- reliability label generator synthetic self-test passes,
- reliability label validator synthetic self-test passes,
- reliability metric harness synthetic self-test passes.
- selected document invariants are present and negative-control tested,
  including the exact official split approval wording, no-GPU approval wording,
  no-`--force` overwrite guard, oracle-only `soft_error_map_path` warning, and
  G-SURE novelty/baseline guardrails.

## Validation Performed

Compile:

```bash
python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py
```

Preflight:

```bash
python research_gsure/02_audits/scripts/check_pre_split_readiness.py
```

Observed:

```text
[OK] direction contamination self-test
[OK] subject manifest semantic self-test
[OK] document invariant self-test
[OK] Stage audit coverage self-test
[OK] output evidence coverage self-test
[OK] official split builder dry-run
[OK] official split builder write-safety self-test
[OK] official split artifacts absent check
[OK] official split checker dry-run self-test
[OK] sliding-window tile budget overwrite-safety self-test
[OK] tile-grid dry-run overwrite-safety self-test
[OK] post-split validation runner preview
[OK] post-split validation runner dry-run self-test
[OK] OOF prediction manifest validator synthetic self-test
[OK] inner-OOF prediction manifest validator synthetic self-test
[OK] prediction artifact validator synthetic self-test
[OK] reliability label generator synthetic self-test
[OK] reliability label validator synthetic self-test
[OK] reliability metric harness synthetic self-test
Pre-split readiness: PASS
Official split artifacts: absent
Draft subject cohort rows: 1614
Required next gate: explicit official LOCO split approval
```

## Interpretation

The workspace is internally consistent for the next approval-gated action. This
does not mean GPU training is ready; it means the pre-split preparation chain is
coherent and official split creation remains the next gate.

## Guardrails

- The preflight must not be modified to run `--write`.
- PASS is not approval for official split creation.
- PASS is not approval for GPU work.
- PASS is not evidence of segmentation performance or publishability.

## Next Action

If Min accepts the current subject-level cohort and LOCO split policy, request
explicit approval:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```
