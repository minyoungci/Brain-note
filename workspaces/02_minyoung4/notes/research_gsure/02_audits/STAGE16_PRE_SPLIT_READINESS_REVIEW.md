# Stage 16 Pre-Split Readiness Review

## Scope

Review whether the G-SURE workspace is ready for the next approved action. This
stage did not create official split files, preprocess data, run GPU, train a
model, or write outputs outside `/home/vlm/minyoung4`.

## Research Goal Reminder

G-SURE is a segmentation-grounding and reliability study. The required first
scientific asset is full-volume out-of-fold segmentation predictions under
leave-one-consortium-out evaluation. Dice improvement alone is not the research
goal.

## Current Prepared State

| area | status | evidence |
|---|---|---|
| data inventory | ready | MRI/mask inventory and mask geometry audits exist |
| primary target | draft-ready | `selected_mask > 0` binary whole-lesion target |
| primary cohort | draft-ready | 1,614 selected subject units |
| split policy | draft-ready | leave-one-consortium-out, subject-level unit |
| split builder | dry-run ready | validates 6,456 split rows without writing |
| official split | not created | `loco_split_manifest.csv` remains absent |
| loader smoke | hardened | shape, affine, orientation, spacing, finite checks |
| pre-split smoke validation | passed on bounded samples | MU 2 rows and UCSD 2 rows loaded |
| tile budget | prepared | subject-level and split-aware modes available |
| GPU preview | contract ready | no GPU command approved |
| baseline training | not ready | waits on official split, post-split smoke, orientation/crop policy, command preview |

## Synchronized Documents

The post-split loader smoke contract already requires:

- T1/T1ce/T2/FLAIR and mask load,
- matching shape,
- matching affine,
- matching orientation,
- matching voxel spacing,
- finite loaded arrays,
- non-empty mask target.

This review aligned the official split approval packet and experiment readiness
checklist with those stricter smoke requirements.

## Remaining Hard Gates

1. Min must explicitly approve official LOCO split creation.
2. Run `build_loco_split_manifest.py --write` only after approval.
3. Inspect official split summary and audit report.
4. Run post-split CPU loader smoke on `loco_split_manifest.csv`.
5. Run split-aware tile budget on official test rows.
6. Lock loader canonical orientation plus crop/pad/sliding-window policy.
7. Prepare GPU preview command only; wait for separate GPU approval.

## Current Blocker

The workspace is prepared for the next approval-gated action, but not for GPU
training. The immediate blocker is official split approval, not code.

## Reviewer-Relevant Risks Still Open

- UCSD differs from the other datasets in shape/orientation.
- UCSD has lower lesion fraction and concentrated timing warnings.
- The primary target is binary whole-lesion, not harmonized subregions.
- Reliability labels are not available until full-volume OOF baseline
  predictions exist.
- A center-crop-only baseline would invalidate the reliability task; inference
  must assemble full-volume predictions.

## Next Recommended Action

If Min accepts the cohort/split policy, request explicit approval using:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```

Without that approval, continue only with safe protocol review or loader design.
