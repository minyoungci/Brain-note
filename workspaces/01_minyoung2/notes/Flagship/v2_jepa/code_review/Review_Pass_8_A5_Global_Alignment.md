# Review Pass 8: A5 Positive-Only Global Alignment

Date: 2026-06-30 UTC

## Scope

A5 was launched after A4 showed that direct global InfoNCE is the wrong global-signal recovery mechanism for Brain-JEPA.

Hypothesis:

```text
If in-batch negatives reintroduce source/cohort shortcuts,
then positive-only global alignment may recover global task signal
without contrastive instance discrimination.
```

## Implemented

- `GlobalAlignmentPredictor`: LayerNorm + MLP auxiliary head.
- `global_alignment_loss`: negative cosine/BYOL-style loss from context global to stop-gradient EMA target global.
- CLI flags:
  - `--global_align_weight`
  - `--global_align_hidden`
  - `--global_align_warmup`
- Checkpoint support:
  - `global_align` state is saved/restored separately from the foundation `model`.
- Status logging:
  - `global_align_loss`
  - `global_align_weight`
- Unit tests for:
  - matching-pair preference
  - finite loss
  - gradient flow to student vector and predictor parameters

## Verification

Static/test checks:

```text
python -m py_compile Flagship/v2_jepa/code/train_brain_jepa.py Flagship/v2_jepa/code/tests/test_brain_jepa.py
python -m unittest discover -s Flagship/v2_jepa/code/tests -p 'test_*.py'
Ran 13 tests
OK
```

GPU smoke:

```text
smoke_a5_align_gpu0
3 steps completed
global_align_loss logged
checkpoint written
```

Full training:

```text
A5 w=0.05: step=20000 loss=3.6782 global_align=0.0671 std=0.13368 rank=197.79 DONE=True ERROR=False
A5 w=0.10: step=20000 loss=3.7749 global_align=0.0854 std=0.19459 rank=164.53 DONE=True ERROR=False
```

## Findings

### 1. High: A5 recovers some downstream global signal, especially at `w=0.10`

| Task | Metric | A2 | A5 `w=0.05` | A5 `w=0.10` | S3D wg0.5 |
|---|---:|---:|---:|---:|---:|
| Task1 infarct | AUROC | 0.6731 | 0.6154 | 0.8077 | 0.7212 |
| Task3 brain age | Pearson r | 0.6720 | 0.4801 | 0.6996 | 0.7924 |
| Task5 polymicrogyria | AUROC | 0.8681 | 0.7847 | 0.8715 | 0.9566 |

A5 `w=0.10` improves Task1 above the S3D reference and improves brain age relative to A2, though it remains below S3D on brain age and Task5.

### 2. High: A5 fails the source/confound gate

| Model | Source-probe acc |
|---|---:|
| A2 mainline | 0.0846 mean over seeds 100/101/102 |
| A4 `w=0.10` | 0.1704 seed100 |
| A5 `w=0.05` | 0.2593 seed100 |
| A5 `w=0.10` | 0.2574 seed100 |
| S3D wg0.5 | 0.3105 mean over seeds 100/101/102 |

The positive-only alignment did not prevent source leakage. It removed contrastive negatives, but it still encouraged global vector consistency in a way that preserved or amplified source/cohort information.

### 3. Medium: A5 identifies a useful but unsafe direction

A4 was a scientific dead end: it degraded downstream and source gates. A5 is different. It improves downstream relative to A2/A4, but source predictability becomes too high.

Consequence: A5 should not be promoted, but its `w=0.10` branch is the best starting point for the next trade-off experiment.

## Final Verdict

A5 is technically stable and scientifically useful, but not a final foundation candidate.

Current recommendation:

```text
Reject A5 as-is.
Use A5 w=0.10 as the base for A6.
A6 should keep the recovered global signal and increase nuisance removal.
```

Most direct A6:

```text
A2 mainline
+ global_align_weight=0.10
+ stronger source adversary: source_adv_weight in {0.10, 0.20}
```
