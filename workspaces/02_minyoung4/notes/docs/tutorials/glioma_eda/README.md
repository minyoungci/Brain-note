# Glioma EDA Tutorial

This folder is the clean tutorial entry point for the final glioma EDA results.
It intentionally loads final artifacts from `docs/context` instead of raw image
payloads.

## Files

- `glioma_eda_tutorial.ipynb`: notebook tutorial for loading, validating, and reviewing the final EDA.
- `eda_tutorial.py`: shared loader and consistency-check utilities used by the notebook.
- `README.md`: this guide.

## Scope

The tutorial verifies:

- final artifact presence and row counts,
- automated validation status,
- dataset/package inventory,
- common usable clinical/imaging data,
- candidate cohort membership,
- IDH/MGMT target imbalance and shortcut risk,
- quality and approval-gated next steps.

It does not:

- load NIfTI arrays, DICOM pixels, or WSI pixels,
- create splits,
- preprocess images,
- run training,
- modify raw data.

## Run

From the repository root:

```bash
jupyter lab docs/tutorials/glioma_eda/glioma_eda_tutorial.ipynb
```

Quick non-notebook check:

```bash
python - <<'PY'
from docs.tutorials.glioma_eda.eda_tutorial import get_context_dir, validate_final_artifacts, run_core_consistency_checks

context = get_context_dir()
print(validate_final_artifacts(context)["status"].value_counts())
print(run_core_consistency_checks(context)["status"].value_counts())
PY
```

Expected status:

- artifact checks: all `PASS`
- core consistency checks: all `PASS`
- `docs/context/eda_validation_checks.csv`: `PASS 72`, `WARN 1`, `FAIL 0`

The single WARN is expected: full image audits, preprocessing, splits, and
training remain approval-gated.
