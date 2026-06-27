# Stage 17 Loader Inference Policy Review

## Scope

Convert the earlier loader feasibility evidence into a pre-GPU loader and
full-volume inference policy draft. This stage did not create official split
files, preprocess data, run GPU, train a model, or write outside
`/home/vlm/minyoung4`.

## Goal Reminder

G-SURE requires full-volume out-of-fold segmentation predictions. The reliability
task is invalid if held-out predictions come from mask-centered crops,
fixed-center crops that miss lesions, or patch outputs that are never assembled
back into full-volume maps.

## Inputs Reviewed

- `STAGE9_LOADER_TRANSFORM_FEASIBILITY.md`
- `STAGE10_SLIDING_WINDOW_COVERAGE.md`
- `STAGE11_TILE_BUDGET_AUDIT.md`
- `STAGE12_GPU_PREVIEW_PREP.md`
- `SEGMENTATION_BASELINE_PROTOCOL.md`
- `GPU_PREVIEW_CONTRACT.md`

## Decision / Action

Added:

```text
research_gsure/01_protocol/LOADER_INFERENCE_POLICY_DRAFT.md
```

The draft policy defines:

- in-memory closest-canonical orientation as the pre-GPU geometry policy,
- strict channel/mask geometry checks,
- train-split-only foreground-aware patch sampling,
- mask-free validation/test sliding-window inference,
- full-volume probability-map assembly before reliability/error labels,
- first GPU preview candidates: `160x192x160@0.50` and
  `192x224x160@0.50`.

## Interpretation

The policy keeps `160x192x160` viable only as a patch/sliding-window candidate.
It explicitly rejects fixed-center inference because the expanded audit found a
UCSD lesion that was not contained by fixed-center crops at `160x192x160` or
`192x224x160`.

## Guardrails

- This is a policy draft, not GPU approval.
- It does not lock the exact augmentation, sampling ratio, blending rule,
  checkpoint path, or prediction output path.
- Official split creation remains approval-gated.

## Next Action

After official split approval:

1. create the official LOCO split,
2. run post-split loader smoke,
3. run split-aware tile budget,
4. implement/review the actual baseline loader against this policy,
5. prepare a GPU preview command for separate approval.
