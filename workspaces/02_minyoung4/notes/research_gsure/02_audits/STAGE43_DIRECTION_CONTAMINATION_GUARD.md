# Stage 43 - Direction Contamination Guard

## Task

Add a CPU-only guard so active G-SURE planning documents cannot silently drift
back into older IDH/VLM/exp-style research directions.

## Research Question

Can the pre-split readiness check detect stale-direction contamination in the
active protocol, baseline, roadmap, approval, and method documents before
official split creation?

## Why This Matters

G-SURE is a segmentation reliability and visual-grounding study. If older
classification or VLM direction language re-enters the active gate documents,
the official split, metrics, or model planning could become misaligned with the
current research goal.

## What Changed

`check_pre_split_readiness.py` now checks selected active documents for forbidden
stale-direction terms using case-insensitive token-boundary matching, so normal
terms such as `image-only` are not confused with stale `age-only` language and
lowercase stale terms such as `idh` are still rejected. Forbidden terms include:

```text
IDH
CTEC
exp02 / exp03
Res3D / Res3DNet
Glio-LLaMA
brain-age / age-only
clinical-adjusted
mutant
VLM / MLLM
JEPA
PET
```

`VLM` is checked exact-case because the local workspace path contains
`/home/vlm/`; treating that path as stale research direction would be a false
positive.

The checked documents are current G-SURE direction, protocol, baseline, approval,
and method files. Historical audit notes and `SCRATCHPAD.md` are intentionally
excluded because they may mention prior rejected directions as research memory.

## Self-Test

The preflight also exposes:

```bash
python research_gsure/02_audits/scripts/check_pre_split_readiness.py \
  --direction-contamination-self-test
```

The self-test:

- confirms the current active direction documents are clean,
- injects uppercase `IDH`, lowercase `idh`, and mixed-case `Brain-Age` into
  in-memory copies,
- confirms the validator rejects all injected stale terms,
- writes no files.

## Guardrails

- This does not modify or delete historical research logs.
- This does not create official split artifacts.
- This does not run GPU work.
- This does not generate predictions, reliability labels, metrics, checkpoints,
  or preprocessing arrays.

## Validation

Required validation:

```bash
python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py
python research_gsure/02_audits/scripts/check_pre_split_readiness.py --direction-contamination-self-test
python research_gsure/02_audits/scripts/check_pre_split_readiness.py
```

Expected self-test output includes:

```text
Direction contamination self-test: PASS
Baseline active direction documents: clean
Injected stale direction terms: rejected (3)
```

## Interpretation

This is a research-direction hygiene check. It is not evidence of segmentation
performance, reliability generalization, novelty, or GPU feasibility.

## Remaining Gate

Official LOCO split creation still requires explicit Min approval:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```
