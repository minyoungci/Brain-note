# Stage 23 Reliability Label Generator and Validator

## Scope

Add CPU-only scripts for future reliability/error label generation and validation
under the fixed-threshold first-label policy. This stage did not create official
split files, generate real prediction labels, run inference, run GPU, preprocess
data, or train a model.

## Goal Reminder

G-SURE reliability labels must be generated reproducibly from validated
full-volume OOF prediction maps. The first label policy uses `fixed_0.5`,
generates `FN`, `FP`, `ERR`, and `SOFT_ERROR`, and defers boundary labels.

## Added Scripts

```text
research_gsure/02_audits/scripts/generate_reliability_labels.py
research_gsure/02_audits/scripts/validate_reliability_label_manifest.py
```

## Generator Behavior

For each prediction row:

```text
GT = selected_mask > 0
P  = full-volume OOF probability map
B  = P >= 0.5
FN = GT and not B
FP = not GT and B
ERR = FN or FP
SOFT_ERROR = abs(GT - P)
```

It writes:

- binary prediction mask,
- FN map,
- FP map,
- ERR map,
- SOFT_ERROR map,
- reliability label manifest,
- label generation config JSON.

The generator refuses to overwrite existing outputs unless `--force` is used.

## Validator Behavior

The validator checks:

- required reliability label manifest columns,
- threshold is `0.5`,
- boundary radius is `0`,
- boundary map path is empty,
- label maps load,
- label maps match target geometry,
- binary maps are 0/1,
- `FN` and `FP` are disjoint,
- `ERR == FN or FP`,
- `SOFT_ERROR == abs(GT - P)`,
- optional `source_prediction_id` link to a prediction manifest.

## Validation Performed

Compile:

```bash
python -m py_compile \
  research_gsure/02_audits/scripts/generate_reliability_labels.py \
  research_gsure/02_audits/scripts/validate_reliability_label_manifest.py
```

Synthetic label generation:

```bash
python research_gsure/02_audits/scripts/generate_reliability_labels.py \
  --synthetic-self-test
```

Observed:

```text
Synthetic label rows: 1
Synthetic label generation errors: 0
```

Synthetic label validation:

```bash
python research_gsure/02_audits/scripts/validate_reliability_label_manifest.py \
  --synthetic-self-test
```

Observed:

```text
Synthetic reliability label rows: 1
Synthetic reliability label validation errors: 0
```

Synthetic tests use temporary NIfTI files only.

## Guardrails

- These scripts are not approval to generate real labels.
- Real label generation still requires official split, OOF prediction manifest
  validation, prediction artifact validation, and Min approval for the relevant
  generation step.
- The generator does not create boundary labels.
- The validator does not prove clinical relevance or model quality.

## Required Future Command Pattern

After validated OOF predictions exist:

```bash
python research_gsure/02_audits/scripts/generate_reliability_labels.py \
  --prediction-manifest <prediction_manifest.csv> \
  --out-dir <approved_output_dir>

python research_gsure/02_audits/scripts/validate_reliability_label_manifest.py \
  --label-manifest <approved_output_dir>/reliability_label_manifest.csv \
  --prediction-manifest <prediction_manifest.csv>
```

Do not run these on real data until the prior gates pass.
