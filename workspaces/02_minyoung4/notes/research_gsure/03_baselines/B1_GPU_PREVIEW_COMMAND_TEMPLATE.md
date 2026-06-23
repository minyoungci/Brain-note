# B1 GPU Preview Command Template

## Scope

This template is for the first approved GPU preview after the official LOCO
split and post-split CPU validation pass.

It is not a command approval. It must not be used before:

1. official LOCO split creation,
2. official split artifact check,
3. post-split loader smoke,
4. split-aware tile budget and tile-grid dry-run.

## Research Purpose

The preview answers only this question:

```text
Can the B1 segmentation loader/model path execute safely enough to produce
future full-volume OOF predictions?
```

It must not be interpreted as:

- segmentation performance evidence,
- Dice model selection,
- reliability evidence,
- G-SURE method evidence,
- permission for full training.

## Required Command Preview

Fill every field before asking Min for GPU approval.

```text
Experiment ID:
Command:
Working directory:
Git status:
Official split manifest:
Held-out dataset:
Split role:
Sample size:
GPU(s):
Expected runtime:
Expected peak memory risk:
Patch shape:
Overlap:
Batch size:
AMP dtype:
Model:
Loss:
Optimizer:
Seed:
Output directory:
Files to be written:
Files that must not be written:
How to stop:
Validation expected:
Stop criteria:
```

## Required Preview Matrix

The first preview must compare exactly:

| candidate | overlap | required result |
|---|---:|---|
| `160x192x160` | `0.50` | forward/backward plus small full-volume assembly |
| `192x224x160` | `0.50` | forward/backward plus small full-volume assembly |

Do not choose the preview candidate using held-out Dice.

## Output Policy

Allowed preview outputs:

- command log,
- memory summary,
- shape/assembly summary,
- failure log,
- recommendation for the later B1 smoke command.

Disallowed preview outputs:

- official OOF prediction manifest,
- reliability labels,
- reliability metrics,
- full training checkpoints,
- publication tables,
- outputs written outside `/home/vlm/minyoung4`.

Preview outputs must use a timestamped directory and must not overwrite prior
artifacts.

## Minimum Stop Criteria

Stop immediately if:

- any output path would overwrite an existing artifact,
- the command would write to `/home/vlm/data/raw/`,
- the command uses held-out masks for tile placement,
- the command reports Dice and uses it to choose patch size,
- full-volume assembled output shape differs from canonical input shape,
- any loader geometry check fails,
- OOM occurs.

## Post-Preview Report Fields

After an approved preview, record:

```text
Command actually run:
Runtime:
GPU:
Peak allocated memory:
Peak reserved memory:
Patch candidate results:
Forward/backward result:
Full-volume assembly result:
Files written:
Failures:
Interpretation:
Next recommended action:
```

## Current Status

No GPU preview command is approved. This file is a template only.
