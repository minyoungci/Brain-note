# Stage 44 - Direction Guard Case-Insensitive Matching

## Task

Strengthen the direction-contamination guard so stale research-direction terms
are detected regardless of capitalization.

## Research Question

Could a lowercase or mixed-case stale term such as `idh` or `Brain-Age` enter
active G-SURE documents without being detected by the pre-split readiness gate?

## Why This Matters

The previous guard used token-boundary matching to avoid false positives such as
`age-only` inside `image-only`. Without case-insensitive matching, however, it
could still miss lowercase or mixed-case stale-direction language.

## What Changed

- `check_pre_split_readiness.py` now runs stale-term matching with
  `re.IGNORECASE`.
- `VLM` remains exact-case because the workspace path `/home/vlm/minyoung4`
  legitimately appears in active command/path documentation.
- The direction contamination self-test now injects:
  - uppercase `IDH`,
  - lowercase `idh`,
  - mixed-case `Brain-Age`.
- All injected stale terms must be rejected.

## Guardrails

- This does not modify historical logs.
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

This is a research-direction hygiene check. It does not provide segmentation
performance, reliability, novelty, or GPU feasibility evidence.

## Remaining Gate

Official LOCO split creation still requires explicit Min approval:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```
