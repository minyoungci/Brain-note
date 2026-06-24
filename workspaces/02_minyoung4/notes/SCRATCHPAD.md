## 2026-06-23 — B1 scratch segmentation baseline runner

### Task
- Start Autoresearch baseline mode by adding the first executable B1 scratch
  segmentation runner and GPU preview packet.

### Research question
- Can the official LOCO G-SURE cohort support a real scratch 3D segmentation
  baseline path before G-SURE reliability modeling?

### What I inspected
- `research_gsure/03_baselines/SEGMENTATION_BASELINE_PROTOCOL.md`
- `research_gsure/03_baselines/GPU_PREVIEW_CONTRACT.md`
- `research_gsure/03_baselines/B1_GPU_PREVIEW_COMMAND_TEMPLATE.md`
- `research_gsure/01_protocol/LOADER_INFERENCE_POLICY_DRAFT.md`
- `research_gsure/02_audits/scripts/smoke_load_manifest_sample.py`
- `research_gsure/02_audits/outputs/loco_split_manifest.csv`

### Decision / action
- Added a real B1 runner instead of adding more protocol-only documents.
- Kept B1 as scratch/random initialization; no pretrained weights.
- Implemented bounded preview mode that writes only summary JSON, not
  checkpoints or OOF prediction maps.
- Added an Autoresearch ladder and GPU preview approval packet.
- Re-reviewed the runner before GPU approval and fixed preview-step control:
  `steps_per_epoch` now controls actual steps, and patch sampling changes by
  epoch while staying deterministic.

### Result
- `train_b1_segmentation.py` now supports:
  - official LOCO manifest loading,
  - train/test leakage-group validation,
  - RAS-canonical NIfTI loading with geometry checks,
  - train-only foreground-biased patch sampling,
  - scratch 3D U-Net,
  - Dice+BCE loss,
  - bf16 autocast on CUDA,
  - full-volume shape-based sliding-window assembly,
  - CPU synthetic self-test.
- CPU validation passed.
- Actual NIfTI load-one dry-run passed for UCSD held-out fold.
- Additional CPU check confirmed `PatchDataset(..., steps_per_epoch=2)` reports
  exactly 2 steps and supports epoch updates.
- No GPU training or preview was executed.

### Interpretation
- The project has moved from split/readiness work to an executable B1 baseline
  path.
- The next meaningful step is Min-approved GPU preview for two patch candidates.
- This still does not produce segmentation performance, OOF maps, reliability
  labels, or a G-SURE method result.

### Insight tags
- ✅ SUCCESS: B1 scratch baseline code path exists and passes CPU checks.
- ⚠️ RISK: Preview code passing does not prove training quality or final Dice.
- 🧪 NEXT: Run the two-command GPU preview only after Min approval.
- 🔁 DO NOT REPEAT: Do not add more reliability-method code before B1 OOF
  segmentation maps exist.
- 📌 MIN DECISION: GPU preview execution still requires explicit approval.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
  - `research_gsure/03_baselines/B1_AUTORESEARCH_LADDER.md`
  - `research_gsure/03_baselines/B1_GPU_PREVIEW_APPROVAL_PACKET.md`
- Commands:
  - `python -m py_compile research_gsure/03_baselines/scripts/train_b1_segmentation.py`
  - `python research_gsure/03_baselines/scripts/train_b1_segmentation.py --synthetic-self-test --patch-shape 32,32,32`
  - `python research_gsure/03_baselines/scripts/train_b1_segmentation.py --mode dry-run --manifest research_gsure/02_audits/outputs/loco_split_manifest.csv --heldout-dataset UCSD-PTGBM --patch-shape 160,192,160 --overlap 0.50`
  - `python research_gsure/03_baselines/scripts/train_b1_segmentation.py --mode dry-run --manifest research_gsure/02_audits/outputs/loco_split_manifest.csv --heldout-dataset UCSD-PTGBM --patch-shape 160,192,160 --overlap 0.50 --load-one`
  - `python - <<'PY' ... PatchDataset steps_per_epoch/epoch smoke ... PY`
  - `nvidia-smi --query-gpu=index,name,memory.total,memory.used --format=csv,noheader`
- Metrics:
  - Synthetic self-test: PASS
  - UCSD held-out fold train rows: 1436
  - UCSD held-out fold test rows: 178
  - Loaded train case shape: `(240, 240, 155)`, RAS, 1mm
  - Loaded test case shape: `(256, 256, 256)`, RAS, 1mm

### Remaining uncertainty
- GPU memory/runtime for `160x192x160` and `192x224x160` is not measured yet.
- No full training, OOF predictions, or reliability labels exist yet.

### Next recommended action
- If Min approves, execute the two B1 GPU preview commands in
  `research_gsure/03_baselines/B1_GPU_PREVIEW_APPROVAL_PACKET.md`.

## 2026-06-23 — B1 GPU preview on GPU 4

### Task
- Execute the approved bounded B1 GPU preview on fixed GPU 4.

### Research question
- Can the scratch B1 segmentation path run bf16 forward/backward and full-volume
  held-out assembly for both candidate patch sizes?

### What I inspected
- `nvidia-smi --query-gpu=index,name,memory.total,memory.used --format=csv,noheader`
- `research_gsure/03_baselines/B1_GPU_PREVIEW_APPROVAL_PACKET.md`
- `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
- Preview output JSON files.

### Decision / action
- Used `CUDA_VISIBLE_DEVICES=4` as Min requested.
- Ran Candidate A: `160x192x160@0.50`.
- Ran Candidate B: `192x224x160@0.50`.
- Kept the run bounded: one epoch, two train steps, four train rows, one UCSD
  held-out inference row.
- Wrote only `preview_summary.json` files.

### Result
- Candidate A passed:
  - peak allocated: 2940.91 MiB
  - peak reserved: 3934.00 MiB
  - train loss: 0.8685
  - train seconds: 11.48
  - held-out tile count: 18
  - output shape: `256x256x256`
- Candidate B passed:
  - peak allocated: 4083.90 MiB
  - peak reserved: 5474.00 MiB
  - train loss: 0.8701
  - train seconds: 11.15
  - held-out tile count: 12
  - output shape: `256x256x256`
- GPU 4 returned to 0 MiB used after the preview.

### Interpretation
- Both candidate patches are feasible on B200 GPU 4 for the preview path.
- `192x224x160@0.50` provides larger spatial context and fewer UCSD tiles while
  remaining low memory risk in this bounded preview.
- This is not performance evidence; it only proves the data/model/inference path
  can run.

### Insight tags
- ✅ SUCCESS: B1 GPU preview passed for both candidate patch sizes.
- ⚠️ RISK: Dice/learning quality is still unknown.
- 💡 INSIGHT: `192x224x160@0.50` is a reasonable first smoke-training patch on
  B200, with `160x192x160@0.50` as fallback.
- 🧪 NEXT: Prepare a separate B1 smoke training command with checkpoint/log
  policy and explicit stop criteria.
- 🔁 DO NOT REPEAT: Do not interpret preview train loss or random probability
  range as segmentation performance.

### Evidence
- Files:
  - `research_gsure/03_baselines/outputs/20260623_064056_b1_gpu_preview_ucsd_160x192x160/preview_summary.json`
  - `research_gsure/03_baselines/outputs/20260623_064056_b1_gpu_preview_ucsd_192x224x160/preview_summary.json`
  - `research_gsure/03_baselines/B1_GPU_PREVIEW_RESULT_20260623_064056.md`
- Commands:
  - `CUDA_VISIBLE_DEVICES=4 python research_gsure/03_baselines/scripts/train_b1_segmentation.py --mode preview ... --patch-shape 160,192,160 ...`
  - `CUDA_VISIBLE_DEVICES=4 python research_gsure/03_baselines/scripts/train_b1_segmentation.py --mode preview ... --patch-shape 192,224,160 ...`
- Metrics:
  - Candidate A peak allocated/reserved MiB: 2940.91 / 3934.00
  - Candidate B peak allocated/reserved MiB: 4083.90 / 5474.00
  - Candidate A/B output shape: `256x256x256`

### Remaining uncertainty
- No smoke/full training has been run.
- No Dice, OOF prediction, or reliability label exists.
- Checkpoint and validation cadence for B1 smoke training still need a command
  preview.

### Next recommended action
- Prepare and approve the first B1 smoke training run using
  `192x224x160@0.50` on GPU 4.

## 2026-06-23 — B1 smoke training mode preparation

### Task
- Add a bounded smoke training mode after successful B1 GPU preview.

### Research question
- Can B1 move from preview-only execution to a short scratch training run with
  safe checkpoint/log output and train-consortia validation?

### What I inspected
- `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
- `research_gsure/03_baselines/B1_GPU_PREVIEW_RESULT_20260623_064056.md`
- `research_gsure/02_audits/outputs/loco_split_manifest.csv`
- Current GPU state via `nvidia-smi`.

### Decision / action
- Added `--mode smoke` to the B1 runner.
- Implemented deterministic train-consortia train/validation splitting.
- Kept held-out UCSD test rows out of smoke validation and prediction outputs.
- Added safe `training_log.jsonl`, `smoke_summary.json`, and
  `checkpoint_last.pt` writing with overwrite refusal.
- Added smoke result summaries:
  - finite train-loss check,
  - internal validation Dice mean/min/max,
  - validation output-shape mismatch count,
  - explicit `decision.smoke_passed`.
- Added `B1_SMOKE_TRAINING_APPROVAL_PACKET.md`.

### Result
- `py_compile` passed.
- Synthetic self-test passed, including smoke artifact/checkpoint writing in a
  temporary directory.
- Smoke decision helper self-test passed.
- Actual manifest dry-run with `192x224x160@0.50` passed.
- Internal split check for UCSD fold:
  - outer train: 1436
  - fit: 1292
  - internal val: 144
  - held-out test: 178
  - fit/val/test overlaps: 0
- No smoke GPU training was executed yet.

### Interpretation
- B1 now has the minimum infrastructure needed for a real short training smoke
  run.
- Smoke training remains separate from full OOF baseline training and does not
  generate reliability labels.

### Insight tags
- ✅ SUCCESS: Smoke training mode is implemented and CPU-validated.
- ⚠️ RISK: Smoke validation Dice is only a sanity signal, not final performance.
- 🧪 NEXT: If approved, run the smoke command in
  `B1_SMOKE_TRAINING_APPROVAL_PACKET.md` on GPU 4.
- 🔁 DO NOT REPEAT: Do not launch full four-fold OOF training before one smoke
  checkpoint/log/validation run passes.
- 📌 MIN DECISION: Smoke GPU training still requires explicit approval.

### Evidence
- Files:
- `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
- `research_gsure/03_baselines/B1_SMOKE_TRAINING_APPROVAL_PACKET.md`
- `research_gsure/03_baselines/B1_AUTORESEARCH_LADDER.md`
- Commands:
  - `python -m py_compile research_gsure/03_baselines/scripts/train_b1_segmentation.py`
  - `python research_gsure/03_baselines/scripts/train_b1_segmentation.py --synthetic-self-test --patch-shape 32,32,32`
  - `python research_gsure/03_baselines/scripts/train_b1_segmentation.py --mode dry-run --manifest research_gsure/02_audits/outputs/loco_split_manifest.csv --heldout-dataset UCSD-PTGBM --patch-shape 192,224,160 --overlap 0.50 --load-one`
  - `python - <<'PY' ... split_train_val_rows overlap check ... PY`
  - `python - <<'PY' ... summarize_train_log / summarize_validation_rows / smoke_decision check ... PY`
- Metrics:
- synthetic self-test: PASS
- smoke artifact self-test: PASS
- smoke decision self-test: PASS
- UCSD internal fit/val/test overlap: 0

### Remaining uncertainty
- No smoke GPU training has been run.
- No real training Dice trajectory exists yet.
- Full OOF training plan still depends on smoke result.

### Next recommended action
- Approve or reject the bounded B1 smoke training command.

## 2026-06-23 — B1 smoke result validator

### Task
- Add a CPU-only validator for B1 smoke-training artifacts.

### Research question
- After a smoke run, can the project automatically determine whether the run is
  execution-ready for full OOF planning without manually reading JSON logs?

### What I inspected
- `research_gsure/03_baselines/B1_SMOKE_TRAINING_APPROVAL_PACKET.md`
- `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
- Current `research_gsure/03_baselines/outputs/` contents.

### Decision / action
- Added `research_gsure/03_baselines/scripts/validate_b1_smoke_result.py`.
- Validator checks required smoke files, finite train summary, validation shape
  match, finite validation Dice, `decision.smoke_passed`, no forbidden
  prediction-like artifacts, and expected "not written" outputs.
- Added validator command to the smoke approval packet.

### Result
- `py_compile` passed for the validator.
- Validator self-test passed.
- Negative path on a missing smoke directory failed with exit code 1 as expected.
- `train_b1_segmentation.py` still compiles.
- No GPU smoke training was executed.

### Interpretation
- B1 smoke output now has an explicit post-run gate before any full OOF training
  plan.
- This reduces the chance of advancing from an incomplete or contaminated smoke
  run.

### Insight tags
- ✅ SUCCESS: Smoke result validation is automated.
- ⚠️ RISK: Validator checks execution readiness, not final segmentation quality.
- 🧪 NEXT: Run B1 smoke on GPU 4 only after explicit approval, then run the
  validator on its output directory.
- 🔁 DO NOT REPEAT: Do not start full OOF training from a smoke directory that
  has not passed `validate_b1_smoke_result.py`.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/validate_b1_smoke_result.py`
  - `research_gsure/03_baselines/B1_SMOKE_TRAINING_APPROVAL_PACKET.md`
- Commands:
  - `python -m py_compile research_gsure/03_baselines/scripts/validate_b1_smoke_result.py`
  - `python research_gsure/03_baselines/scripts/validate_b1_smoke_result.py --self-test`
  - `python research_gsure/03_baselines/scripts/validate_b1_smoke_result.py --smoke-dir research_gsure/03_baselines/outputs/does_not_exist`
  - `python -m py_compile research_gsure/03_baselines/scripts/train_b1_segmentation.py`
- Metrics:
  - validator self-test: PASS
  - missing-directory negative path: expected failure

### Remaining uncertainty
- No real smoke output exists yet.
- Validator has not been run on a real smoke output directory.

### Next recommended action
- Approve the bounded B1 smoke training command, then run the validator.

## 2026-06-23 — B1 full-fit command planner

### Task
- Prepare the post-smoke B1 full-fit command planning path without executing
  GPU training.

### Research question
- After smoke passes, can B1 generate consistent fold-level fit commands for all
  LOCO folds with row counts, output directories, and a smoke-validation gate?

### What I inspected
- `research_gsure/01_protocol/OOF_PREDICTION_RELIABILITY_CONTRACT.md`
- `research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py`
- `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
- `research_gsure/02_audits/outputs/loco_split_manifest.csv`

### Decision / action
- Added `--mode fit` to `train_b1_segmentation.py`.
- Added `max_train_rows=0`, `max_val_rows=0`, and `max_infer_rows=0` semantics
  for using all selected rows.
- Added `research_gsure/03_baselines/scripts/plan_b1_fit_commands.py`.
- Generated draft fold command plan:
  `research_gsure/03_baselines/B1_FULL_FIT_COMMAND_PLAN_DRAFT.md`.
- Fixed a planner command-formatting bug where shell lines contained stray `+`
  characters.

### Result
- Planner self-test passed.
- B1 runner synthetic self-test still passed.
- Draft plan contains all four LOCO folds:
  - MU-Glioma-Post: train 1411, internal fit 1270, internal val 141, heldout test 203
  - UCSD-PTGBM: train 1436, internal fit 1292, internal val 144, heldout test 178
  - UPENN-GBM: train 1003, internal fit 903, internal val 100, heldout test 611
  - UTSW: train 992, internal fit 893, internal val 99, heldout test 622
- Draft plan explicitly says not to execute until B1 smoke output passes
  `validate_b1_smoke_result.py`.
- No GPU fit or OOF prediction generation was executed.

### Interpretation
- B1 now has a staged path: preview -> smoke -> validator -> fold checkpoint fit.
- At the time of this entry, OOF probability-map writing was still a later,
  separate implementation step. It was implemented in the subsequent B1 predict
  mode entry.

### Insight tags
- ✅ SUCCESS: Full-fit command planning is reproducible and fold-count aware.
- ⚠️ RISK: Fit checkpoints alone are not OOF prediction artifacts.
- 🧪 NEXT: Run smoke first; only after smoke validator passes should full-fit
  commands be considered.
- 🔁 DO NOT REPEAT: Do not skip from preview directly to four long fold fits.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/plan_b1_fit_commands.py`
  - `research_gsure/03_baselines/B1_FULL_FIT_COMMAND_PLAN_DRAFT.md`
  - `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
- Commands:
  - `python -m py_compile research_gsure/03_baselines/scripts/plan_b1_fit_commands.py research_gsure/03_baselines/scripts/train_b1_segmentation.py research_gsure/03_baselines/scripts/validate_b1_smoke_result.py`
  - `python research_gsure/03_baselines/scripts/plan_b1_fit_commands.py --self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_fit_commands.py --split-manifest research_gsure/02_audits/outputs/loco_split_manifest.csv --timestamp 20260623_DRAFT --gpu 4`
  - `python research_gsure/03_baselines/scripts/plan_b1_fit_commands.py --split-manifest research_gsure/02_audits/outputs/loco_split_manifest.csv --timestamp 20260623_DRAFT --gpu 4 --output-md research_gsure/03_baselines/B1_FULL_FIT_COMMAND_PLAN_DRAFT.md`
  - `python research_gsure/03_baselines/scripts/train_b1_segmentation.py --synthetic-self-test --patch-shape 32,32,32`
- Metrics:
  - planner self-test: PASS
  - generated fold commands: 4

### Remaining uncertainty
- B1 smoke has not been run.
- Full-fit commands have not been approved or executed.
- OOF prediction map writing was not implemented at this point; see the later
  B1 predict mode entry.

### Next recommended action
- Execute B1 smoke on GPU 4 only after explicit approval, then validate smoke
  output before considering full-fit commands.

## 2026-06-23 — B1 OOF prediction mode preparation

### Task
- Add checkpoint-based held-out prediction artifact writing for B1.

### Research question
- Once B1 fold checkpoints exist, can the runner write full-volume held-out
  probability maps and an OOF prediction manifest compatible with the G-SURE
  reliability-label contract?

### What I inspected
- `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
- `research_gsure/01_protocol/OOF_PREDICTION_RELIABILITY_CONTRACT.md`
- `research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py`

### Decision / action
- Added `--mode predict` to `train_b1_segmentation.py`.
- Added checkpoint loading with architecture-argument consistency checks.
- Added canonical probability NIfTI writing.
- Added OOF prediction manifest row construction using the contract columns.
- Added output files for prediction config and command log.
- Kept held-out mask access limited to metric/shape validation, not tile
  placement.
- Fixed predict failure order so missing checkpoints fail before creating the
  output directory.

### Result
- `py_compile` passed for the runner and OOF prediction manifest validator.
- B1 synthetic self-test passed and now includes prediction-manifest-row self-test.
- OOF prediction manifest validator synthetic self-test passed.
- Predict mode negative path with a nonexistent checkpoint failed as expected and
  did not create its output directory.
- No real checkpoint inference or probability-map generation was executed.

### Interpretation
- B1 now has the code path needed after fold fit checkpoints exist:
  checkpoint -> held-out full-volume probability maps -> OOF prediction manifest.
- This still depends on the earlier gates: smoke training, smoke validation, and
  approved fold fit checkpoints.

### Insight tags
- ✅ SUCCESS: B1 OOF prediction artifact writing is implemented at code level.
- ⚠️ RISK: It has not been run on real checkpoints yet.
- 🧪 NEXT: Run smoke, validate it, fit fold checkpoints, then run predict mode
  and validate the prediction manifest.
- 🔁 DO NOT REPEAT: Do not generate reliability labels from predictions before
  `validate_oof_prediction_manifest.py` passes.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
  - `research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py`
- Commands:
  - `python -m py_compile research_gsure/03_baselines/scripts/train_b1_segmentation.py research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py`
  - `python research_gsure/03_baselines/scripts/train_b1_segmentation.py --synthetic-self-test --patch-shape 32,32,32`
  - `python research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py --synthetic-self-test`
  - `python research_gsure/03_baselines/scripts/train_b1_segmentation.py --mode predict --manifest research_gsure/02_audits/outputs/loco_split_manifest.csv --heldout-dataset UCSD-PTGBM --checkpoint-path research_gsure/03_baselines/outputs/nonexistent_checkpoint.pt --output-dir research_gsure/03_baselines/outputs/nonexistent_predict_negative`
  - `test ! -e research_gsure/03_baselines/outputs/nonexistent_predict_negative`
- Metrics:
  - synthetic self-test: PASS
  - prediction manifest row self-test: PASS
  - OOF manifest validator synthetic errors: 0
  - negative missing-checkpoint path: expected failure, no output dir created

### Remaining uncertainty
- No B1 smoke checkpoint exists yet.
- No fold fit checkpoint exists yet.
- Predict mode has not been run on real MRI data.

### Next recommended action
- Execute B1 smoke on GPU 4 only after explicit approval.

## 2026-06-23 — B1 held-out prediction command planner

### Task
- Add a CPU-only command planner for B1 held-out prediction after fit
  checkpoints exist.

### Research question
- Once B1 fold checkpoints are trained, can the project generate fold-specific
  held-out prediction commands and matching OOF manifest validation commands
  without manually stitching paths?

### What I inspected
- `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
- `research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py`
- `research_gsure/03_baselines/scripts/plan_b1_fit_commands.py`
- `research_gsure/02_audits/outputs/loco_split_manifest.csv`

### Decision / action
- Added `research_gsure/03_baselines/scripts/plan_b1_predict_commands.py`.
- Added `--heldout-dataset` fold filtering to
  `validate_oof_prediction_manifest.py`, because fold-specific prediction
  manifests should not be forced to contain all four held-out folds at once.
- Generated draft prediction command plan:
  `research_gsure/03_baselines/B1_PREDICT_COMMAND_PLAN_DRAFT.md`.

### Result
- Prediction planner self-test passed.
- OOF prediction manifest validator self-test passed, including fold-filter
  validation.
- Draft plan includes four fold-specific predict commands and four corresponding
  `validate_oof_prediction_manifest.py --heldout-dataset ... --check-files`
  commands.
- Draft plan is blocked because expected fit checkpoints do not exist yet.
- No GPU inference, probability map writing, or reliability label generation was
  executed.

### Interpretation
- The B1 artifact chain is now planned through prediction manifest validation:
  smoke -> fit checkpoints -> held-out probability maps -> OOF manifest
  validator.
- Execution remains gated by the missing smoke run and missing fit checkpoints.

### Insight tags
- ✅ SUCCESS: Fold-level prediction planning and validation commands are now
  reproducible.
- ⚠️ RISK: The planner does not prove prediction runtime; real inference remains
  unrun.
- 🧪 NEXT: Run B1 smoke first, then validate, then consider fit commands.
- 🔁 DO NOT REPEAT: Do not create reliability labels from unvalidated
  prediction manifests.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/plan_b1_predict_commands.py`
  - `research_gsure/03_baselines/B1_PREDICT_COMMAND_PLAN_DRAFT.md`
  - `research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py`
  - `research_gsure/03_baselines/B1_AUTORESEARCH_LADDER.md`
- Commands:
  - `python -m py_compile research_gsure/03_baselines/scripts/plan_b1_predict_commands.py research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py`
  - `python research_gsure/03_baselines/scripts/plan_b1_predict_commands.py --self-test`
  - `python research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py --synthetic-self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_predict_commands.py --split-manifest research_gsure/02_audits/outputs/loco_split_manifest.csv --fit-timestamp 20260623_DRAFT --predict-timestamp 20260623_DRAFT --gpu 4 --output-md research_gsure/03_baselines/B1_PREDICT_COMMAND_PLAN_DRAFT.md`
  - `rg -n "BLOCKED: missing fit checkpoints|--mode predict|validate_oof_prediction_manifest.py|--heldout-dataset" research_gsure/03_baselines/B1_PREDICT_COMMAND_PLAN_DRAFT.md`
- Metrics:
  - prediction planner self-test: PASS
  - OOF validator synthetic validation errors: 0
  - fold-specific predict commands: 4
  - fold-specific manifest validator commands: 4

### Remaining uncertainty
- B1 smoke has not been run.
- Fit checkpoints do not exist.
- Prediction commands have not been executed.

### Next recommended action
- Execute B1 smoke on GPU 4 only after explicit approval.

## 2026-06-23 — B1 architecture option for Autoresearch

### Task
- Add an architecture switch so B1 can compare model structures after the first
  scratch baseline gates pass.

### Research question
- Can B1 run plain `unet3d` and compact `resunet3d` under the same LOCO split,
  loader, loss, checkpoint, prediction, and manifest contract?

### What I inspected
- `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
- `research_gsure/03_baselines/scripts/plan_b1_fit_commands.py`
- `research_gsure/03_baselines/scripts/plan_b1_predict_commands.py`
- Current B1 command plan drafts.

### Decision / action
- Added `--architecture {unet3d,resunet3d}` to the runner.
- Kept default as `unet3d` so existing B1 smoke command remains stable.
- Added compact `ResUNet3D` with residual encoder/decoder blocks.
- Added `build_model(args)` factory and architecture consistency checks when
  loading checkpoints.
- Added `--architecture` to fit/predict command planners and draft command
  plans.
- Extended synthetic self-test to cover `resunet3d` forward/backward.

### Result
- No GPU training was executed.
- `resunet3d` is now available as a future B1 structure variant.
- Existing smoke/fold/predict plans remain `unet3d` unless explicitly changed.

### Interpretation
- Autoresearch can now compare B1.0/B1.2 plain U-Net against a compact ResUNet
  variant without changing data split or artifact contracts.
- ResUNet should not be trained before the `unet3d` smoke gate passes, otherwise
  architecture exploration would outrun data-flow validation.

### Insight tags
- ✅ SUCCESS: First structure-variation hook is implemented.
- ⚠️ RISK: More architecture options do not matter until smoke/full OOF training
  proves the baseline path works.
- 🧪 NEXT: Run B1 smoke for `unet3d` first; use `resunet3d` only as a controlled
  variant afterward.
- 🔁 DO NOT REPEAT: Do not treat architecture changes as novelty before baseline
  and reliability metrics exist.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
  - `research_gsure/03_baselines/scripts/plan_b1_fit_commands.py`
  - `research_gsure/03_baselines/scripts/plan_b1_predict_commands.py`
  - `research_gsure/03_baselines/B1_FULL_FIT_COMMAND_PLAN_DRAFT.md`
  - `research_gsure/03_baselines/B1_PREDICT_COMMAND_PLAN_DRAFT.md`
- Commands:
  - `python -m py_compile research_gsure/03_baselines/scripts/train_b1_segmentation.py research_gsure/03_baselines/scripts/plan_b1_fit_commands.py research_gsure/03_baselines/scripts/plan_b1_predict_commands.py`
  - `python research_gsure/03_baselines/scripts/train_b1_segmentation.py --synthetic-self-test --patch-shape 32,32,32`
  - `python research_gsure/03_baselines/scripts/plan_b1_fit_commands.py --self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_predict_commands.py --self-test`
  - `rg -n -- '--architecture unet3d|architecture:' research_gsure/03_baselines/B1_FULL_FIT_COMMAND_PLAN_DRAFT.md research_gsure/03_baselines/B1_PREDICT_COMMAND_PLAN_DRAFT.md research_gsure/03_baselines/B1_SMOKE_TRAINING_APPROVAL_PACKET.md`
- Metrics:
  - `unet3d` synthetic self-test: PASS
  - `resunet3d` forward/backward self-test: PASS
  - fit planner self-test: PASS
  - predict planner self-test: PASS

### Remaining uncertainty
- ResUNet has not been trained or evaluated.
- No B1 smoke result exists yet.

### Next recommended action
- Execute B1 smoke on GPU 4 for `unet3d` only after explicit approval.

## 2026-06-23 — B1 loss variants for Autoresearch

### Task
- Add controlled loss-function variants to the B1 runner and command planners.

### Research question
- Can B1 compare Dice+BCE against Dice+Focal and Dice+Tversky without changing
  split, loader, architecture contract, checkpoint policy, or prediction
  manifest schema?

### What I inspected
- `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
- `research_gsure/03_baselines/scripts/plan_b1_fit_commands.py`
- `research_gsure/03_baselines/scripts/plan_b1_predict_commands.py`
- `research_gsure/03_baselines/B1_AUTORESEARCH_LADDER.md`

### Decision / action
- Added `--loss {dice_bce,dice_focal,dice_tversky}` to the runner.
- Kept default as `dice_bce` so the approved smoke path stays unchanged.
- Implemented focal and Tversky losses and kept soft Dice as the shared anchor.
- Added loss name and description to training summaries.
- Added `--loss` to fit/predict planners and command-plan drafts.

### Result
- No GPU training was executed.
- `dice_bce`, `dice_focal`, and `dice_tversky` all pass synthetic finite-loss
  checks.
- Fit and predict planners can emit variant commands such as
  `--architecture resunet3d --loss dice_focal`.

### Interpretation
- B1 now supports the first two Autoresearch variation axes:
  architecture and loss.
- These variants should be tried only after the default `unet3d + dice_bce`
  smoke/full OOF path is validated.

### Insight tags
- ✅ SUCCESS: Loss variants are implemented under the same data/artifact path.
- ⚠️ RISK: Loss variation can overfit noisy internal validation if used before
  OOF metrics exist.
- 🧪 NEXT: Run default B1 smoke first, then use loss variants in controlled
  follow-up experiments.
- 🔁 DO NOT REPEAT: Do not tune loss on held-out Dice.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
  - `research_gsure/03_baselines/scripts/plan_b1_fit_commands.py`
  - `research_gsure/03_baselines/scripts/plan_b1_predict_commands.py`
  - `research_gsure/03_baselines/B1_FULL_FIT_COMMAND_PLAN_DRAFT.md`
  - `research_gsure/03_baselines/B1_PREDICT_COMMAND_PLAN_DRAFT.md`
  - `research_gsure/03_baselines/B1_SMOKE_TRAINING_APPROVAL_PACKET.md`
- Commands:
  - `python -m py_compile research_gsure/03_baselines/scripts/train_b1_segmentation.py research_gsure/03_baselines/scripts/plan_b1_fit_commands.py research_gsure/03_baselines/scripts/plan_b1_predict_commands.py`
  - `python research_gsure/03_baselines/scripts/train_b1_segmentation.py --synthetic-self-test --patch-shape 32,32,32`
  - `python research_gsure/03_baselines/scripts/plan_b1_fit_commands.py --self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_predict_commands.py --self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_fit_commands.py --split-manifest research_gsure/02_audits/outputs/loco_split_manifest.csv --timestamp 20260623_DRAFT_FOCAL --gpu 4 --architecture resunet3d --loss dice_focal | rg -n -- '--architecture resunet3d|--loss dice_focal|architecture:|loss:'`
  - `python research_gsure/03_baselines/scripts/plan_b1_predict_commands.py --split-manifest research_gsure/02_audits/outputs/loco_split_manifest.csv --fit-timestamp 20260623_DRAFT_FOCAL --predict-timestamp 20260623_DRAFT_FOCAL --gpu 4 --architecture resunet3d --loss dice_focal | rg -n -- '--architecture resunet3d|--loss dice_focal|architecture:|loss:'`
- Metrics:
  - loss variant self-test: PASS
  - fit planner variant command check: PASS
  - predict planner variant command check: PASS

### Remaining uncertainty
- No loss variant has been trained or evaluated.
- No default B1 smoke result exists yet.

### Next recommended action
- Execute B1 smoke on GPU 4 for default `unet3d + dice_bce` only after explicit
  approval.

## 2026-06-23 — Stage66 official split and post-split validation

### Task
- Create the approved official LOCO split and run post-split CPU validation.

### Research question
- Can the approved subject-level G-SURE cohort be locked into official LOCO
  split artifacts, and do the post-split loader/tile assumptions pass before GPU
  training?

### What I inspected
- `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- `research_gsure/02_audits/scripts/build_loco_split_manifest.py`
- `research_gsure/02_audits/scripts/check_official_split_artifacts.py`
- `research_gsure/02_audits/scripts/run_post_split_validation.py`
- `research_gsure/02_audits/outputs/loco_split_summary.csv`
- `research_gsure/02_audits/outputs/loco_split_audit_report.md`

### Decision / action
- Min approved exact official LOCO split creation.
- Ran pre-split readiness one final time before `--write`.
- Confirmed official split artifacts were absent.
- Ran `build_loco_split_manifest.py --write`.
- Ran official split artifact checker.
- Ran consolidated post-split CPU validation.
- Updated README, ROADMAP, and experiment readiness checklist to reflect
  post-split state.
- Added `STAGE66_OFFICIAL_SPLIT_AND_POST_SPLIT_VALIDATION.md`.

### Result
- Official split builder wrote:
  - `loco_split_manifest.csv`
  - `loco_split_summary.csv`
  - `loco_split_audit_report.md`
- Official split builder reported:
  - Subject rows: 1614
  - Split rows: 6456
  - Fold rows: 4
  - Validation: ok
- Official split checker passed:
  - Subject overlap: 0
  - Duplicate train/test subjects: 0
  - Missing path rows: 0
  - Lesion-burden summary fields: validated
  - Timing-warning summary fields: validated
- Post-split validation runner passed.
- All-consortium bounded loader smoke passed for MU, UCSD, UPENN, and UTSW.
- Official-split tile-grid dry-run reported coverage failures: 0.

### Interpretation
- The official split is now created and validated.
- The project can proceed to first segmentation baseline command preview.
- This is still not model training, OOF prediction generation, reliability label
  generation, G-SURE method training, or performance evidence.

### Insight tags
- ✅ SUCCESS: Official LOCO split was created and passed post-split CPU
  validation.
- ⚠️ RISK: GPU training is still separate; split validation does not prove model
  quality.
- 🧪 NEXT: Prepare first-baseline GPU command preview with expected outputs,
  runtime, checkpoint policy, and stop criteria.
- 🔁 DO NOT REPEAT: Do not rerun split creation with `--force` unless Min gives
  separate explicit overwrite approval.

### Evidence
- Files:
  - `research_gsure/02_audits/outputs/loco_split_manifest.csv`
  - `research_gsure/02_audits/outputs/loco_split_summary.csv`
  - `research_gsure/02_audits/outputs/loco_split_audit_report.md`
  - `research_gsure/02_audits/outputs/20260623_061921_sliding_window_tile_budget_loco_test.csv`
  - `research_gsure/02_audits/outputs/20260623_061921_sliding_window_tile_budget_loco_test_by_dataset.csv`
  - `research_gsure/02_audits/outputs/20260623_061921_sliding_window_tile_budget_loco_test_oof_estimate.csv`
  - `research_gsure/02_audits/outputs/20260623_061921_sliding_window_tile_budget_loco_test_report.md`
  - `research_gsure/02_audits/outputs/20260623_061921_tile_grid_dry_run_loco_test.csv`
  - `research_gsure/02_audits/outputs/20260623_061921_tile_grid_dry_run_loco_test_summary.csv`
  - `research_gsure/02_audits/outputs/20260623_061921_tile_grid_dry_run_loco_test_report.md`
  - `research_gsure/02_audits/STAGE66_OFFICIAL_SPLIT_AND_POST_SPLIT_VALIDATION.md`
- Commands:
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `python research_gsure/02_audits/scripts/check_official_split_artifacts.py --expect-missing`
  - `python research_gsure/02_audits/scripts/build_loco_split_manifest.py --write`
  - `python research_gsure/02_audits/scripts/check_official_split_artifacts.py`
  - `python research_gsure/02_audits/scripts/run_post_split_validation.py --run`
- Metrics:
  - Official split manifest rows: 6456
  - Fold summaries: 4
  - Subject overlap: 0
  - Missing path rows: 0
  - Loader smoke rows per consortium: 8
  - Tile-grid coverage failures: 0

### Remaining uncertainty
- No GPU segmentation baseline has been trained yet.
- No OOF prediction, reliability label, reliability metric, or G-SURE method
  result exists yet.

### Next recommended action
- Prepare first-baseline GPU command preview and request separate GPU approval.

## 2026-06-23 — Stage65 post-split timing summary validation

### Task
- Harden post-split validation so timing-warning summary fields are checked
  against the official split manifest.

### Research question
- After official split creation, can the checker detect a corrupted
  timing-warning summary instead of validating only subject counts and lesion
  burden?

### What I inspected
- `research_gsure/02_audits/scripts/run_post_split_validation.py`
- `research_gsure/02_audits/scripts/check_official_split_artifacts.py`
- `research_gsure/02_audits/scripts/build_loco_split_manifest.py`
- `research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md`
- `research_gsure/02_audits/STAGE26_POST_SPLIT_VALIDATION_RUNNER.md`

### Decision / action
- Added timing-warning summary validation to
  `check_official_split_artifacts.py`.
- Added a timing-warning mismatch negative control to the checker dry-run
  self-test.
- Updated post-approval runbook hard failures to include timing-warning summary
  mismatch.
- Updated Stage26 to state that official split checker validates timing-warning
  summary fields against the split manifest.
- Added `STAGE65_POST_SPLIT_TIMING_SUMMARY_VALIDATION.md`.
- Added preflight document invariants for the new post-split timing summary
  guardrails.
- Updated Stage35 to record Stage 2-65 coverage.

### Result
- `py_compile` passed.
- Official split checker dry-run self-test passed.
- Timing-warning positive path was validated.
- Timing-warning negative control detected a mismatch.
- Document invariant self-test passed.
- Stage audit coverage self-test passed.
- Output evidence coverage self-test passed.
- Full pre-split readiness passed.
- Official split artifacts remain absent.

### Interpretation
- This closes a post-split validation gap introduced by treating timing warnings
  as a required sensitivity/reporting axis.

### Insight tags
- ✅ SUCCESS: Timing-warning split summaries are now checked rather than only
  written.
- ⚠️ RISK: This verifies summary counts, not whether timing warnings are
  clinically harmless.
- 🧪 NEXT: Keep official split gated pending exact Min approval.
- 🔁 DO NOT REPEAT: Do not trust split summary fields that are written but not
  independently validated.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/check_official_split_artifacts.py`
  - `research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md`
  - `research_gsure/02_audits/STAGE26_POST_SPLIT_VALIDATION_RUNNER.md`
  - `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`
  - `research_gsure/02_audits/STAGE65_POST_SPLIT_TIMING_SUMMARY_VALIDATION.md`
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/check_official_split_artifacts.py research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `python research_gsure/02_audits/scripts/check_official_split_artifacts.py --dry-run-self-test`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py --document-invariant-self-test`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py --stage-audit-coverage-self-test`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py --output-evidence-coverage-self-test`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `rg -n "Timing-warning positive path|Timing-warning negative control|timing-warning summary values that do not match the split manifest|timing-warning summary fields against the split manifest|STAGE65_POST_SPLIT_TIMING_SUMMARY_VALIDATION|Stage 2-65" research_gsure/02_audits/scripts/check_official_split_artifacts.py research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md research_gsure/02_audits/STAGE26_POST_SPLIT_VALIDATION_RUNNER.md research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md research_gsure/02_audits/STAGE65_POST_SPLIT_TIMING_SUMMARY_VALIDATION.md research_gsure/02_audits/scripts/check_pre_split_readiness.py SCRATCHPAD.md`
- Metrics:
  - Generated split rows in memory: 6456
  - Generated fold summaries in memory: 4
  - Missing-text negative controls rejected: 46
  - Stage audit notes covered: 66
  - Pre-split output artifacts covered: 39
  - Pre-split readiness: PASS
  - Draft subject cohort rows: 1614

### Remaining uncertainty
- Official split remains uncreated.

### Next recommended action
- Keep official split gated pending exact Min approval.

## 2026-06-23 — Stage64 pre-approval decision brief

### Task
- Add a short pre-approval decision brief for official LOCO split creation.

### Research question
- Can Min review the immediate split decision without confusing it with GPU
  training, prediction generation, reliability labels, or performance claims?

### What I inspected
- `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`
- `research_gsure/README.md`
- `research_gsure/ROADMAP.md`
- `research_gsure/02_audits/scripts/check_pre_split_readiness.py`

### Decision / action
- Added `research_gsure/01_protocol/PRE_APPROVAL_DECISION_BRIEF.md`.
- Added `research_gsure/02_audits/STAGE64_PRE_APPROVAL_DECISION_BRIEF.md`.
- Added the brief and Stage64 to `check_pre_split_readiness.py`
  `REQUIRED_FILES`.
- Added document invariants for:
  - split approval is not training approval,
  - official split approval does not authorize later work,
  - GPU command preparation remains blocked until post-split CPU validation
    passes.
- Updated Stage35 to record Stage 2-64 coverage.

### Result
- `py_compile` passed.
- Direction contamination self-test passed.
- Document invariant self-test passed.
- Stage audit coverage self-test passed.
- Output evidence coverage self-test passed.
- Full pre-split readiness passed.
- Official split artifacts remain absent.

### Interpretation
- This is approval-surface hardening. It does not create a split or evidence of
  model performance.

### Insight tags
- ✅ SUCCESS: The next gate now has a short review brief protected by preflight
  invariants.
- ⚠️ RISK: A brief can drift from the detailed approval packet unless preflight
  protects the core guardrails.
- 🧪 NEXT: Keep official split gated pending exact Min approval.
- 🔁 DO NOT REPEAT: Do not treat split approval as GPU or training approval.

### Evidence
- Files:
  - `research_gsure/01_protocol/PRE_APPROVAL_DECISION_BRIEF.md`
  - `research_gsure/02_audits/STAGE64_PRE_APPROVAL_DECISION_BRIEF.md`
  - `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py --direction-contamination-self-test`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py --document-invariant-self-test`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py --stage-audit-coverage-self-test`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py --output-evidence-coverage-self-test`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `rg -n "PRE_APPROVAL_DECISION_BRIEF|STAGE64_PRE_APPROVAL_DECISION_BRIEF|The immediate decision is only the official split, not training|Official split approval does not authorize|No GPU command may be prepared until this post-split CPU validation passes|Stage 2-64" research_gsure/01_protocol/PRE_APPROVAL_DECISION_BRIEF.md research_gsure/02_audits/STAGE64_PRE_APPROVAL_DECISION_BRIEF.md research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md research_gsure/02_audits/scripts/check_pre_split_readiness.py SCRATCHPAD.md`
- Metrics:
  - Missing-text negative controls rejected: 44
  - Stage audit notes covered: 65
  - Pre-split output artifacts covered: 39
  - Pre-split readiness: PASS
  - Draft subject cohort rows: 1614

### Remaining uncertainty
- Official split remains uncreated.

### Next recommended action
- Keep official split gated pending exact Min approval.

## 2026-06-23 — Stage63 timing sensitivity contract

### Task
- Convert the Stage62 timing-warning recommendation into an explicit
  sensitivity-reporting contract.

### Research question
- If the first official split keeps MU/UCSD timing-warning rows, what minimum
  no-warning and high-risk subgroup analyses are required before final G-SURE
  claims?

### What I inspected
- `research_gsure/01_protocol/RELIABILITY_METRIC_CONTRACT.md`
- `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
- `research_gsure/01_protocol/GSURE_PROTOCOL_DRAFT.md`
- `research_gsure/02_audits/STAGE62_TIMING_WARNING_DECISION_AUDIT.md`
- `research_gsure/02_audits/scripts/check_pre_split_readiness.py`

### Decision / action
- Added `research_gsure/01_protocol/TIMING_WARNING_SENSITIVITY_CONTRACT.md`.
- Required timing groups:
  - no warning,
  - MU missing days from diagnosis,
  - UCSD missing acquisition-to-initial-event offset,
  - UCSD scan more than 1y after initial event.
- Required later sensitivity views:
  - primary keep-all result,
  - no-warning subset,
  - UCSD no-warning subset,
  - UCSD `scan >1y` high-risk subgroup if sample size is sufficient,
  - warning versus no-warning rows within each consortium where sample size is
    sufficient.
- Updated `RELIABILITY_METRIC_CONTRACT.md` and
  `EXPERIMENT_READINESS_CHECKLIST.md`.
- Added document invariants and required-file coverage for the new contract.
- Added `STAGE63_TIMING_SENSITIVITY_CONTRACT.md`.
- Updated Stage35 to record Stage 2-63 coverage.

### Result
- `py_compile` passed.
- Direction contamination self-test passed.
- Document invariant self-test passed.
- Stage audit coverage self-test passed.
- Output evidence coverage self-test passed.
- Full pre-split readiness passed.
- Official split artifacts remain absent.

### Interpretation
- Keeping all 1,614 rows in the primary split is now tied to a mandatory
  no-warning and UCSD high-risk subgroup sensitivity contract.
- This does not prove robustness; it prevents later claims from ignoring the
  timing heterogeneity.

### Insight tags
- ✅ SUCCESS: Timing-warning sensitivity is now a formal reporting contract and
  is protected by preflight invariants.
- ⚠️ RISK: Small warning subgroups may be exploratory only; row counts must be
  reported.
- 🧪 NEXT: Keep official split gated pending exact Min approval.
- 🔁 DO NOT REPEAT: Do not report primary keep-all results without no-warning
  sensitivity once real predictions exist.

### Evidence
- Files:
  - `research_gsure/01_protocol/TIMING_WARNING_SENSITIVITY_CONTRACT.md`
  - `research_gsure/01_protocol/RELIABILITY_METRIC_CONTRACT.md`
  - `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
  - `research_gsure/02_audits/STAGE63_TIMING_SENSITIVITY_CONTRACT.md`
  - `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py --direction-contamination-self-test`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py --document-invariant-self-test`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py --stage-audit-coverage-self-test`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py --output-evidence-coverage-self-test`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `rg -n "primary keep-all results require|Do not claim timing robustness|timing-warning sensitivity contract|TIMING_WARNING_SENSITIVITY_CONTRACT|STAGE63_TIMING_SENSITIVITY_CONTRACT|Stage 2-63" research_gsure/01_protocol/TIMING_WARNING_SENSITIVITY_CONTRACT.md research_gsure/01_protocol/RELIABILITY_METRIC_CONTRACT.md research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md research_gsure/02_audits/STAGE63_TIMING_SENSITIVITY_CONTRACT.md research_gsure/02_audits/scripts/check_pre_split_readiness.py SCRATCHPAD.md`
- Metrics:
  - Missing-text negative controls rejected: 41
  - Stage audit notes covered: 64
  - Pre-split output artifacts covered: 39
  - Pre-split readiness: PASS
  - Draft subject cohort rows: 1614

### Remaining uncertainty
- Official split remains uncreated.
- No segmentation, prediction, reliability-label, or reliability-metric result
  exists yet.

### Next recommended action
- Keep official split gated pending exact Min approval.

## 2026-06-23 — Stage62 timing warning decision audit

### Task
- Quantify MU/UCSD timing warnings before official LOCO split creation.

### Research question
- Should timing-warning rows be excluded before the official split, or retained
  in the primary split with disclosure and mandatory sensitivity analysis?

### What I inspected
- `research_gsure/02_audits/outputs/subject_level_cohort_manifest_draft.csv`
- `research_gsure/02_audits/outputs/loco_split_readiness_by_dataset.csv`
- `research_gsure/02_audits/outputs/loco_split_readiness_by_fold.csv`
- `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`
- `research_gsure/02_audits/scripts/check_pre_split_readiness.py`

### Decision / action
- Calculated timing-warning counts and exclusion-policy scenarios from the
  draft subject-level cohort.
- Added `STAGE62_TIMING_WARNING_DECISION_AUDIT.md`.
- Added approval-packet wording recommending keep-all primary split with
  disclosure and sensitivity analysis, not pre-split exclusion.
- Added a document invariant so the timing-warning recommendation cannot
  disappear silently from the approval packet.
- Updated Stage35 to record Stage 2-62 coverage.

### Result
- Timing warnings are concentrated in MU/UCSD:
  - MU-Glioma-Post: 12 warning rows, 191 no-warning rows.
  - UCSD-PTGBM: 63 warning rows, 115 no-warning rows.
  - UPENN-GBM: 0 warning rows.
  - UTSW: 0 warning rows.
- Excluding all timing warnings would reduce the cohort from 1,614 to 1,539 and
  reduce UCSD from 178 to 115 subjects.
- Excluding only known UCSD scans >1y after initial event would reduce the
  cohort from 1,614 to 1,588 and UCSD from 178 to 152 subjects.
- Warning rows are not obviously trivial lesions; UCSD warning rows have higher
  median mask fraction than UCSD no-warning rows.

### Interpretation
- Strict pre-split exclusion would weaken the UCSD held-out fold and may reduce
  the value of the cross-consortium reliability test.
- Missing timing fields are not equivalent to invalid segmentation labels.
- The most defensible first split is keep-all primary cohort, disclose/stratify
  timing warnings, and require sensitivity analyses before final claims.

### Insight tags
- 💡 INSIGHT: Timing-warning exclusion is not a free quality improvement; it
  materially changes the UCSD held-out fold.
- ⚠️ RISK: Mixed treatment/timing semantics remain a reviewer attack point.
- 🧯 MITIGATION: Require no-warning and UCSD `scan >1y` subgroup sensitivity
  before final claims.
- 🧪 NEXT: Validate preflight with Stage62 included, then keep official split
  gated pending exact Min approval.
- 🔁 DO NOT REPEAT: Do not silently exclude warning rows before the official
  split without documenting fold-level consequences.

### Evidence
- Files:
  - `research_gsure/02_audits/STAGE62_TIMING_WARNING_DECISION_AUDIT.md`
  - `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`
  - `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- Commands:
  - `python - <<'PY' ... timing warning scenario analysis ...`
- Metrics:
  - keep-all cohort: 1,614 subjects.
  - exclude-any-warning cohort: 1,539 subjects.
  - UCSD keep-all / no-warning: 178 / 115.
  - warning rows: 75 total.

### Remaining uncertainty
- Min still needs to approve whether timing warnings are disclosure-only or
  exclusion criteria for the official primary split.
- Official split remains uncreated.
- No segmentation, prediction, reliability-label, or reliability-metric result
  exists yet.

### Next recommended action
- Run CPU-only validation, then keep official split gated pending exact Min
  approval.

## 2026-06-23 — Stage61 approval output evidence sync

### Task
- Continue G-SURE preparation by synchronizing approval-facing documents with
  the output evidence coverage self-test added in Stage 60.

### Research question
- Do the split approval packet, readiness checklist, post-approval runbook, and
  preflight note describe the same output-evidence coverage check that the
  executable pre-split readiness gate runs?

### What I inspected
- `research_gsure/README.md`
- `research_gsure/ROADMAP.md`
- `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`
- `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
- `research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md`
- `research_gsure/02_audits/STAGE24_PRE_SPLIT_PREFLIGHT.md`
- `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`
- `research_gsure/02_audits/scripts/check_pre_split_readiness.py`

### Decision / action
- Added output evidence coverage self-test wording to top-level status,
  approval packet, readiness checklist, runbook, and Stage24.
- Added document invariants so those approval-facing phrases cannot disappear
  silently.
- Added `STAGE61_APPROVAL_OUTPUT_EVIDENCE_SYNC.md`.
- Updated Stage35 to record Stage 2-61 coverage.

### Result
- `py_compile` passed.
- `--document-invariant-self-test` passed.
- `--output-evidence-coverage-self-test` passed.
- `--stage-audit-coverage-self-test` passed.
- Full pre-split readiness passed and includes `[OK] output evidence coverage
  self-test`.
- Official split artifacts remain absent.

### Interpretation
- This keeps the approval surface aligned with the executable pre-split gate
  before official LOCO split creation is requested.

### Insight tags
- ✅ SUCCESS: Approval-facing docs now mention output evidence coverage and are
  protected by document invariants.
- ⚠️ RISK: This is document/gate hygiene only, not segmentation or reliability
  evidence.
- 🧪 NEXT: Keep official split gated pending exact Min approval.
- 🔁 DO NOT REPEAT: Do not add a new preflight self-test without syncing the
  approval packet and runbook.

### Evidence
- Files:
  - `research_gsure/README.md`
  - `research_gsure/ROADMAP.md`
  - `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`
  - `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
  - `research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md`
  - `research_gsure/02_audits/STAGE24_PRE_SPLIT_PREFLIGHT.md`
  - `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`
  - `research_gsure/02_audits/STAGE61_APPROVAL_OUTPUT_EVIDENCE_SYNC.md`
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py --document-invariant-self-test`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py --output-evidence-coverage-self-test`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py --stage-audit-coverage-self-test`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `rg -n "output evidence coverage self-test: all current pre-split output artifacts|output evidence coverage negative controls|\\[OK\\] output evidence coverage self-test|STAGE61_APPROVAL_OUTPUT_EVIDENCE_SYNC|Stage 2-61" research_gsure/README.md research_gsure/ROADMAP.md research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md research_gsure/02_audits/STAGE24_PRE_SPLIT_PREFLIGHT.md research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md research_gsure/02_audits/STAGE61_APPROVAL_OUTPUT_EVIDENCE_SYNC.md research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- Metrics:
  - Document invariants: PASS
  - Missing-text negative controls rejected: 37
  - Pre-split output artifacts covered: 39
  - Stage audit notes covered: 62
  - Pre-split readiness: PASS
  - Draft subject cohort rows: 1614
  - Official split artifact exists exit code: 1

### Remaining uncertainty
- Official split remains uncreated.
- No segmentation, prediction, reliability-label, or reliability-metric result
  exists yet.

### Next recommended action
- Keep official split gated pending exact Min approval.

## 2026-06-23 — G-SURE pre-research stage 1

### Task
- Define staged pre-research evidence requirements and start Step 1.

### Research question
- Can glioma segmentation be reframed as visual grounding reliability rather than Dice-only mask prediction?

### What I inspected
- Root workspace state.
- `data/` top-level cohort layout.
- Existing `research_gsure/` planning documents.

### Decision / action
- Proceed with a path-level mask taxonomy inventory before any image loading, split creation, preprocessing, or GPU training.

### Result
- Stage 1 path-level audit completed.
- Discovered 25,342 NIfTI files and 3,673 candidate segmentation files.
- Dataset-level segmentation file counts:
  - MU-Glioma-Post: 594 `tumorMask` files across 594 units.
  - UCSD-PTGBM: 972 segmentation files across 243 units, with BraTS, total cellular, enhancing cellular, and non-enhancing cellular keys.
  - UPENN-GBM: 758 `UPENN_segm` files across 611 units.
  - UTSW: 1,349 segmentation files across 625 units, including FeTS and manual correction variants.
- One zero-byte NIfTI file was detected: `UCSD-PTGBM-0149_02_total_cellular_tumor_seg.nii.gz`.

### Interpretation
- All four datasets have substantial segmentation-mask coverage by path inventory.
- The mask taxonomy is not yet harmonized. UCSD has multiple biologically distinct mask keys; UTSW has FeTS and manual-correction variants; MU and UPENN masks remain semantically underspecified by filename alone.
- This supports continuing to Stage 2, but does not yet justify defining the segmentation target or launching training.

### Insight tags
- ✅ SUCCESS: Stage 1 produced a complete path-level NIfTI and mask inventory.
- ⚠️ RISK: Filename-based semantic guesses cannot prove anatomical equivalence.
- 🧯 MITIGATION: Stage 2 must read mask values and geometry before locking the task.
- 📌 MIN DECISION: Restarted research around MRI plus segmentation-mask strength, with G-SURE as a candidate direction.
- 🔁 DO NOT REPEAT: Do not train a segmentation model before target taxonomy and geometry are locked.

### Evidence
- Files:
  - `research_gsure/`
  - `data/`
  - `research_gsure/02_audits/outputs/mask_path_inventory.csv`
  - `research_gsure/02_audits/outputs/mask_path_summary_by_dataset.csv`
  - `research_gsure/02_audits/outputs/mask_path_summary_by_key.csv`
  - `research_gsure/02_audits/outputs/mask_path_audit_report.md`
- Commands:
  - `pwd`
  - `git status --short`
  - `git branch --show-current`
  - `find . -maxdepth 3 -type f | sort | head -200`
  - `python -m py_compile research_gsure/02_audits/scripts/build_mask_path_inventory.py`
  - `python research_gsure/02_audits/scripts/build_mask_path_inventory.py --data-root data --out-dir research_gsure/02_audits/outputs`
- Metrics:
  - NIfTI rows: 25,342.
  - Candidate segmentation rows: 3,673.
  - Dataset summary rows: 4.
  - Segmentation-key summary rows: 9.
  - Zero-byte NIfTI rows: 1.
  - Segmentation rows with blank unit/key: 0 / 0.
- Logs:
  - `research_gsure/02_audits/outputs/mask_path_audit_report.md`

### Remaining uncertainty
- Actual mask label values, shape/affine compatibility, and target harmonization remain unverified.

### Next recommended action
- Run Stage 2 mask value and geometry audit on segmentation files and matched structural MRI candidates.

## 2026-06-23 — Stage 2 mask value and geometry audit

### Task
- Verify mask label values, empty masks, structural MRI channel coverage, and image-mask geometry.

### Research question
- Can the four-consortium MRI plus segmentation data support one coherent segmentation target for G-SURE?

### What I inspected
- `research_gsure/02_audits/outputs/mask_path_inventory.csv`
- Segmentation mask NIfTI values.
- Structural MRI NIfTI headers for same-unit geometry comparison.

### Decision / action
- Added a Stage 2 audit script.
- Discovered and fixed a modality classifier bug: `brain_t1c` and `brain_t2f` were initially classified too early as plain T1/T2. Re-ran Stage 1 and Stage 2 after the fix.

### Result
- Segmentation masks audited: 3,673.
- Masks loaded successfully: 3,672.
- Zero-byte/unreadable masks: 1.
- Empty masks: 160.
- Masks matching at least one structural candidate by shape and affine: 3,514.
- Units with segmentation and all four core modalities: 2,073.
- Geometry review cases: 159.

### Interpretation
- Four-channel MRI coverage is viable for all segmentation units after corrected modality parsing.
- The safest first target is likely binary lesion/whole-tumor candidate using `mask > 0`, but source semantics must still be verified.
- UTSW `tumorseg_manual_correction` should not be used directly because 158 files fail geometry matching; `rtumorseg_manual_correction` is the registered alternative for 362 units.
- UCSD component masks contain legitimate-looking empty component cases, but UTSW empty FeTS masks are suspicious and need review.

### Insight tags
- ✅ SUCCESS: Stage 2 confirmed broad mask loadability and 4-channel MRI availability.
- ⚠️ RISK: Multilabel values are not harmonized by evidence alone.
- ⚠️ RISK: UTSW manual correction has registered and unregistered variants; using the wrong one breaks supervision.
- ❌ FAILURE: Initial modality classifier order produced a false all-four-coverage failure; fixed and reran.
- 🧯 MITIGATION: Lock target mapping and source mask precedence before any training.
- 🧪 NEXT: Verify source label semantics and decide official target mapping.

### Evidence
- Files:
  - `research_gsure/01_protocol/PRE_EXPERIMENT_EVIDENCE_MAP.md`
  - `research_gsure/02_audits/scripts/audit_mask_values_geometry.py`
  - `research_gsure/02_audits/outputs/mask_value_geometry_audit.csv`
  - `research_gsure/02_audits/outputs/mask_value_summary_by_key.csv`
  - `research_gsure/02_audits/outputs/structural_coverage_by_unit.csv`
  - `research_gsure/02_audits/STAGE2_FINDINGS.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/audit_mask_values_geometry.py`
  - `python research_gsure/02_audits/scripts/audit_mask_values_geometry.py --limit 20 --progress-every 10`
  - `python research_gsure/02_audits/scripts/audit_mask_values_geometry.py --progress-every 500`
  - `python research_gsure/02_audits/scripts/build_mask_path_inventory.py --data-root data --out-dir research_gsure/02_audits/outputs`
- Metrics:
  - NIfTI rows: 25,342.
  - Segmentation rows: 3,673.
  - Structural coverage unit rows: 2,135.
  - Segmentation key rows: 9.
- Logs:
  - `research_gsure/02_audits/outputs/mask_value_geometry_report.md`

### Remaining uncertainty
- Exact semantic meaning of labels 1/2/3/4/5 by dataset.
- Whether UTSW should use FeTS-only or registered manual corrections where available.
- Whether suspicious empty FeTS masks represent true empty lesions or data defects.
- Which session/timepoint should be selected per subject.

### Next recommended action
- Create target-mapping decision table using source documentation and then draft the official cohort manifest.

## 2026-06-23 — Stage 3 target mapping review

### Task
- Review candidate target-mask mapping policies before official cohort manifest creation.

### Research question
- Can we define a defensible all-consortium segmentation target without overclaiming subregion harmonization?

### What I inspected
- Local metadata:
  - `MU-Glioma-Post_Segmentation_Volumes.xlsx`
  - `UPENN-GBM_data_availability.csv`
  - `UPENN-GBM_clinical_info_v2.1.csv`
  - `radiomic_features_CaPTk.zip`
  - `UTSW_Glioma_Metadata-2-1.tsv`
  - `UCSD_PTGBM-clinical-information_v3_2026-12-Mar.xlsx`
- Existing Stage 1/2 audit outputs.
- External context for UPENN/BraTS label semantics.

### Decision / action
- Added a candidate target mapping draft.
- Added a target mapping policy review script.
- Compared two policies:
  - Policy A: FeTS-only UTSW.
  - Policy B: registered manual correction preferred for UTSW.

### Result
- Both policies include 2,070 / 2,073 segmentation units.
- Both exclude UTSW `BT0926`, `BT1016`, `BT1090` due empty FeTS masks.
- Policy B uses UTSW `rtumorseg_manual_correction` for 362 units and `tumorseg_FeTS` for 263 units.
- UTSW registered manual corrections include label `3` in 116 units and label `5` in 5 units.

### Interpretation
- Binary `selected_mask > 0` is the safest first all-consortium target.
- Subregion harmonization is not yet defensible.
- FeTS-only UTSW is the cleaner primary policy because it avoids unexplained labels `3` and `5` and avoids mixed supervision sources.
- Registered manual correction should be a sensitivity analysis, not the first primary target.

### Insight tags
- ✅ SUCCESS: Target policy review found a feasible candidate target with 2,070 usable units.
- ⚠️ RISK: UTSW registered manual corrections contain source-unverified labels `3` and `5`.
- ⚠️ RISK: UPENN local integer labels appear closer to BraTS-style `1/2/4`; external derivative descriptions may conflict.
- 💡 INSIGHT: Binary target is not just simpler; it is currently the only defensible cross-consortium target.
- 🧪 NEXT: Get Min approval for target policy, then build candidate cohort manifest.
- 🔁 DO NOT REPEAT: Do not train subregion segmentation before integer label semantics are source-verified per dataset.

### Evidence
- Files:
  - `research_gsure/01_protocol/TARGET_MAPPING_DRAFT.md`
  - `research_gsure/02_audits/STAGE3_TARGET_MAPPING_REVIEW.md`
  - `research_gsure/02_audits/scripts/review_target_mapping.py`
  - `research_gsure/02_audits/outputs/target_mapping_policy_review.csv`
  - `research_gsure/02_audits/outputs/target_mapping_policy_summary.csv`
  - `research_gsure/02_audits/outputs/target_mapping_policy_report.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/review_target_mapping.py`
  - `python research_gsure/02_audits/scripts/review_target_mapping.py`
- Metrics:
  - Policy rows: 4,146.
  - Summary rows: 8.
  - Included candidates per policy: 2,070.
- Logs:
  - `research_gsure/02_audits/outputs/target_mapping_policy_report.md`

### Remaining uncertainty
- Whether Min accepts FeTS-only UTSW as primary source.
- Whether empty FeTS masks should be excluded immediately or manually reviewed first.
- Session/timepoint selection for MU and UCSD.

### Next recommended action
- With Min approval, generate a draft candidate cohort manifest under the approved policy without creating splits or preprocessing.

## 2026-06-23 — Stage 4 candidate cohort manifest draft

### Task
- Generate a candidate unit-level cohort manifest under the approved first target policy.

### Research question
- Can we map each valid unit to one selected mask and four geometry-compatible MRI channels?

### What I inspected
- Stage 1 path inventory.
- Stage 2 mask value/geometry audit.
- Stage 3 target policy review.
- Selected MRI path geometry against selected mask.

### Decision / action
- Built `candidate_cohort_manifest_draft.csv` using:
  - target: `selected_mask > 0`
  - policy: `binary_whole_lesion_fets_only`
  - UTSW source: `tumorseg_FeTS`
- Did not create a split.
- Did not preprocess images.

### Result
- Units reviewed: 2,135.
- Include candidates: 2,070.
- Excluded by hard criteria: 65.
- Included subjects: 1,614.
- Included rows with all selected MRI paths matching mask geometry: 2,070.
- Included units with review flags before official subject-level cohort lock: 878.

### Interpretation
- The unit-level manifest is technically coherent.
- The official training cohort is not locked because MU/UCSD have multi-session/timepoint structure.
- The conservative primary experiment should probably use one selected unit per subject; all valid units can be sensitivity analysis.

### Insight tags
- ✅ SUCCESS: Candidate manifest maps 2,070 units to 4 MRI channels plus selected mask with geometry match.
- ⚠️ RISK: 701 included units belong to multiunit subjects; using all units as primary may overweight longitudinal subjects.
- ⚠️ RISK: 837 MU/UCSD included units still need session/timepoint policy.
- 💡 INSIGHT: Unit-level N=2,070, subject-level ceiling N=1,614.
- 🧪 NEXT: Lock subject/unit selection policy before split creation.
- 🔁 DO NOT REPEAT: Do not create LOCO split from unit-level rows before grouping/selection policy is fixed.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/build_candidate_cohort_manifest.py`
  - `research_gsure/02_audits/outputs/candidate_cohort_manifest_draft.csv`
  - `research_gsure/02_audits/outputs/candidate_cohort_summary.csv`
  - `research_gsure/02_audits/outputs/candidate_cohort_manifest_report.md`
  - `research_gsure/02_audits/STAGE4_COHORT_MANIFEST_REVIEW.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/build_candidate_cohort_manifest.py`
  - `python research_gsure/02_audits/scripts/build_candidate_cohort_manifest.py`
- Metrics:
  - Candidate manifest rows: 2,135.
  - Include candidates: 2,070.
  - Excluded rows: 65.
  - Included subjects: 1,614.
- Logs:
  - `research_gsure/02_audits/outputs/candidate_cohort_manifest_report.md`

### Remaining uncertainty
- One-unit-per-subject selection rule.
- Whether MU/UCSD should use earliest, baseline/pre-treatment, or metadata-timed unit.
- Whether all valid units should be used only as sensitivity analysis.

### Next recommended action
- Create and review subject/unit selection policy options. Recommended primary: one unit per subject.

## 2026-06-23 — Stage 5 subject-level cohort draft

### Task
- Build a subject-level primary cohort draft from the unit-level candidate manifest.

### Research question
- Can the first G-SURE cohort avoid repeated-subject leakage and longitudinal overweighting while preserving enough data?

### What I inspected
- Candidate unit-level manifest.
- MU timepoint timing metadata.
- UCSD acquisition-relative treatment/surgery timing metadata.
- UPENN baseline timing metadata.
- UTSW operation status metadata.

### Decision / action
- Added a subject-level manifest builder.
- Applied policy: one included unit per subject, earliest numeric unit/session/timepoint.
- Preserved all secondary valid units for sensitivity/review.
- Added experiment readiness checklist.

### Result
- Candidate units before selection: 2,070.
- Selected primary subject units: 1,614.
- Secondary valid units retained: 456.
- Duplicate primary `dataset::subject_id`: 0.
- Selected rows with all paths present and geometry-matched: 1,614.

### Interpretation
- The primary subject-level cohort draft is technically coherent.
- MU/UCSD timing remains post-treatment/longitudinal and must be disclosed.
- The next blocker is approval to create a LOCO split manifest; split is not created yet.

### Insight tags
- ✅ SUCCESS: Primary cohort draft has one row per subject and no geometry/path gaps.
- ⚠️ RISK: UCSD includes post-treatment scans; 26 selected rows are >1 year after initial event by metadata offset.
- ⚠️ RISK: MU has 12 selected rows missing days-from-diagnosis timing metadata.
- 💡 INSIGHT: Subject-level primary N=1,614 is the clean number for first experiment planning.
- 🧪 NEXT: After Min approval, create LOCO split manifest and split audit.
- 🔁 DO NOT REPEAT: Do not use unit-level N=2,070 as the primary cohort headline.

### Evidence
- Files:
  - `research_gsure/01_protocol/SUBJECT_UNIT_SELECTION_DRAFT.md`
  - `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
  - `research_gsure/02_audits/scripts/build_subject_level_manifest.py`
  - `research_gsure/02_audits/outputs/subject_level_cohort_manifest_draft.csv`
  - `research_gsure/02_audits/outputs/unit_selection_review.csv`
  - `research_gsure/02_audits/outputs/subject_level_cohort_summary.csv`
  - `research_gsure/02_audits/outputs/subject_level_cohort_report.md`
  - `research_gsure/02_audits/STAGE5_SUBJECT_SELECTION_REVIEW.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/build_subject_level_manifest.py`
  - `python research_gsure/02_audits/scripts/build_subject_level_manifest.py`
- Metrics:
  - Subject-level primary rows: 1,614.
  - Unit selection review rows: 2,070.
  - Secondary units: 456.
  - Duplicate primary subjects: 0.
- Logs:
  - `research_gsure/02_audits/outputs/subject_level_cohort_report.md`

### Remaining uncertainty
- Min approval for subject-level primary policy.
- LOCO split manifest and split leakage audit.
- Baseline data loader smoke test.
- Literature novelty check against segmentation reliability/uncertainty work.

### Next recommended action
- Approve subject-level primary cohort policy, then create LOCO split manifest.

## 2026-06-23 — Stage 6 LOCO split readiness audit

### Task
- Audit whether the subject-level cohort draft is ready for LOCO split creation without creating the official split.

### Research question
- Can G-SURE evaluate cross-consortium generalization without subject overlap or secondary-unit leakage?

### What I inspected
- `subject_level_cohort_manifest_draft.csv`
- `unit_selection_review.csv`
- lesion burden fields
- timing warning fields
- scanner strength fields

### Decision / action
- Added LOCO split policy draft.
- Added LOCO readiness audit script.
- Ran readiness audit only; no official split manifest was created.

### Result
- Four LOCO held-out folds are feasible:
  - MU test 203 / train 1,411.
  - UCSD test 178 / train 1,436.
  - UPENN test 611 / train 1,003.
  - UTSW test 622 / train 992.
- Subject overlap count: 0 in all folds.
- Secondary-unit leakage count: 0 in all folds.

### Interpretation
- LOCO split family is feasible for the subject-level primary cohort.
- UCSD has lower median lesion fraction and concentrated timing warnings, so lesion-size and timing-warning stratified reporting are required.
- Official split manifest still requires Min approval.

### Insight tags
- ✅ SUCCESS: LOCO readiness passed hard leakage checks.
- ⚠️ RISK: UCSD has lower median lesion fraction than other datasets.
- ⚠️ RISK: UCSD timing warnings concentrate in the UCSD held-out fold.
- 💡 INSIGHT: Cross-consortium evaluation is feasible, but per-fold interpretation must be cautious.
- 🧪 NEXT: If approved, create official LOCO split manifest and split audit report.

### Evidence
- Files:
  - `research_gsure/01_protocol/LOCO_SPLIT_POLICY_DRAFT.md`
  - `research_gsure/02_audits/scripts/audit_loco_split_readiness.py`
  - `research_gsure/02_audits/outputs/loco_split_readiness_by_fold.csv`
  - `research_gsure/02_audits/outputs/loco_split_readiness_by_dataset.csv`
  - `research_gsure/02_audits/outputs/loco_split_readiness_report.md`
  - `research_gsure/02_audits/STAGE6_LOCO_SPLIT_READINESS_REVIEW.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/audit_loco_split_readiness.py`
  - `python research_gsure/02_audits/scripts/audit_loco_split_readiness.py`
- Metrics:
  - Fold rows: 4.
  - Subject overlap: 0 in all folds.
  - Secondary-unit leakage: 0 in all folds.
- Logs:
  - `research_gsure/02_audits/outputs/loco_split_readiness_report.md`

### Remaining uncertainty
- Min approval to create official split manifest.
- Whether timing warnings remain disclosure-only or become exclusion criteria.
- Loader smoke test and baseline training contract.

### Next recommended action
- Create official LOCO split manifest after approval, then run split leakage audit and loader smoke test.

## 2026-06-23 — Stage 7 split and loader prep

### Task
- Prepare official LOCO split builder and post-split loader smoke tools without creating official split outputs.

### Research question
- Can the next approved step be executed reproducibly and safely toward G-SURE baseline preparation?

### What I inspected
- LOCO readiness review.
- Subject-level cohort manifest.
- Experiment readiness checklist.

### Decision / action
- Added `build_loco_split_manifest.py` with dry-run default and `--write` gate.
- Added `smoke_load_manifest_sample.py` for post-split CPU smoke loading.
- Added loader smoke contract.
- Ran split builder only in dry-run mode.

### Result
- Dry-run expected split rows: 6,456.
- Fold rows: 4.
- Validation: ok.
- Confirmed `loco_split_manifest.csv` was not created.

### Interpretation
- We are ready to create the official LOCO split after Min approval.
- Loader smoke cannot be run yet because official split manifest does not exist.
- No preprocessing, split file, or training job was created.

### Insight tags
- ✅ SUCCESS: Official split builder is implemented with no-write dry-run default.
- ✅ SUCCESS: Loader smoke contract is ready for post-split validation.
- ⚠️ RISK: Running `--write` creates official train/test split artifacts and still requires explicit approval.
- 🧪 NEXT: On approval, run `python research_gsure/02_audits/scripts/build_loco_split_manifest.py --write`, then loader smoke.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/build_loco_split_manifest.py`
  - `research_gsure/02_audits/scripts/smoke_load_manifest_sample.py`
  - `research_gsure/01_protocol/POST_SPLIT_LOADER_SMOKE_CONTRACT.md`
  - `research_gsure/02_audits/STAGE7_SPLIT_AND_LOADER_PREP.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/build_loco_split_manifest.py research_gsure/02_audits/scripts/smoke_load_manifest_sample.py`
  - `python research_gsure/02_audits/scripts/build_loco_split_manifest.py`
  - `test -f research_gsure/02_audits/outputs/loco_split_manifest.csv; echo split_exists=$?`
- Metrics:
  - Dry-run split rows: 6,456.
  - Fold rows: 4.
  - `split_exists=1`, meaning no official split manifest file exists.
- Logs:
  - Dry-run command output.

### Remaining uncertainty
- Min approval for official split `--write`.
- Post-split loader smoke result.
- Baseline training contract and GPU approval.

### Next recommended action
- Ask Min to approve official split creation, then run split write and loader smoke.

## 2026-06-23 — Stage 8 baseline readiness prep

### Task
- Continue G-SURE preparation by tightening the first segmentation baseline
  protocol without creating an official split or running GPU training.

### Research question
- Can the first segmentation baseline be specified so its out-of-fold
  predictions later support grounded reliability/error-localization analysis?

### What I inspected
- `research_gsure/README.md`
- `research_gsure/ROADMAP.md`
- `research_gsure/03_baselines/BASELINE_CONTRACT.md`
- `research_gsure/01_protocol/POST_SPLIT_LOADER_SMOKE_CONTRACT.md`
- `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
- `research_gsure/02_audits/scripts/build_loco_split_manifest.py`
- `research_gsure/02_audits/scripts/smoke_load_manifest_sample.py`
- `research_gsure/02_audits/outputs/subject_level_cohort_manifest_draft.csv`
- `research_gsure/02_audits/outputs/loco_split_readiness_by_fold.csv`

### Decision / action
- Kept official split creation blocked pending Min approval.
- Added a detailed first-baseline protocol.
- Updated status docs so Stage 5 is not treated as active before OOF baseline
  predictions exist.

### Result
- Subject-level draft remains 1,614 subjects:
  - MU-Glioma-Post: 203
  - UCSD-PTGBM: 178
  - UPENN-GBM: 611
  - UTSW: 622
- Dry-run LOCO split still validates 6,456 fold rows and writes nothing.
- Official `loco_split_manifest.csv` still does not exist.
- Shape/orientation risk is explicit:
  - UCSD: `256x256x256 / ILA`
  - MU/UPENN/UTSW: `240x240x155 / LPS`
  - all selected masks: `1x1x1` spacing
- Environment availability only:
  - nibabel 5.4.2
  - torch 2.10.0+cu128, cuda_available=True
  - monai 1.5.2

### Interpretation
- The next scientific requirement is not method design. It is a leakage-safe
  plain segmentation baseline that produces out-of-fold prediction/error maps.
- The first baseline must document orientation and crop/pad/resize policy before
  GPU training.
- UCSD is the most important held-out shift-risk case because its geometry and
  lesion fraction differ from the other consortia.

### Insight tags
- ✅ SUCCESS: First-baseline protocol is now explicit enough to review before GPU.
- ⚠️ RISK: UCSD geometry/orientation shift can confound both Dice and reliability.
- ⚠️ RISK: Reliability labels generated from in-sample predictions would invalidate G-SURE.
- 🧯 MITIGATION: Require official LOCO split plus CPU loader smoke before any GPU command.
- 🧪 NEXT: With Min approval, create official LOCO split and run loader smoke.
- 🔁 DO NOT REPEAT: Do not start G-SURE/reliability-head training before OOF baseline predictions exist.

### Evidence
- Files:
  - `research_gsure/03_baselines/SEGMENTATION_BASELINE_PROTOCOL.md`
  - `research_gsure/02_audits/STAGE8_BASELINE_READINESS_PREP.md`
  - `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
  - `research_gsure/README.md`
  - `research_gsure/ROADMAP.md`
- Commands:
  - `pwd`
  - `git status --short`
  - `git branch --show-current`
  - `python research_gsure/02_audits/scripts/build_loco_split_manifest.py`
  - package import check for `nibabel`, `torch`, `monai`
- Metrics:
  - subject-level rows: 1,614
  - dry-run split rows: 6,456
  - dry-run fold rows: 4
  - official split manifest: absent

### Remaining uncertainty
- Min has not approved official cohort/split write.
- Loader smoke has not run because official split manifest is absent.
- Crop/pad/resize/orientation standardization policy is not yet implemented.
- First GPU command is not approved.

### Next recommended action
- If Min approves the cohort/split gate, run:
  `python research_gsure/02_audits/scripts/build_loco_split_manifest.py --write`
  and then run the documented CPU loader smoke test.

## 2026-06-23 — Stage 9 loader transform feasibility sample

### Task
- Audit whether a first baseline loader can plausibly standardize orientation
  and crop/pad sampled subject-level MRI/mask rows without cutting lesion bboxes.

### Research question
- Before official split/GPU, do sampled rows support a common orientation and
  candidate input shape for the first segmentation baseline?

### What I inspected
- `research_gsure/03_baselines/SEGMENTATION_BASELINE_PROTOCOL.md`
- `research_gsure/02_audits/STAGE8_BASELINE_READINESS_PREP.md`
- `research_gsure/02_audits/outputs/subject_level_cohort_manifest_draft.csv`

### Decision / action
- Added `audit_loader_transform_feasibility.py`.
- Ran a CPU-only read-only sample audit with 5 lesion-fraction quantile samples
  per dataset.
- Did not create split files, preprocessed arrays, cached tensors, or GPU jobs.

### Result
- Manifest rows: 1,614.
- Sampled subject rows: 20.
- Detailed candidate rows: 80.
- Errors: 0.
- Canonical orientation check:
  - MU/UPENN/UTSW: `240x240x155`, `RAS` after canonical orientation.
  - UCSD: `256x256x256`, `RAS` after canonical orientation.
- `128x160x128` failed one sampled MU large-lesion case by bbox extent:
  - `MU-Glioma-Post::PatientID_0047`, bbox extent `134x164x84`.
- `128x160x128` failed 7 / 20 sampled rows under fixed-center crop containment.
- `160x192x160`, `192x224x160`, and `224x224x160` contained all sampled lesion
  bboxes under both extent and fixed-center checks.

### Interpretation
- The first loader should canonicalize orientation before batching.
- `128x160x128` is not a defensible first baseline input candidate.
- `160x192x160` is the smallest sampled-safe candidate, but it is not locked
  until split-aware loader smoke and GPU memory preview are done.
- GT-mask-centered crops cannot be used at test time; patch-based inference must
  use sliding-window or another full-volume coverage path.

### Insight tags
- ✅ SUCCESS: Sampled MRI/mask rows canonicalized to matching `RAS` shapes.
- ⚠️ RISK: Small/fixed crops can crop lesions; this would silently corrupt the segmentation target.
- 🧯 MITIGATION: Reject `128x160x128` for the first baseline; require split-aware transform smoke.
- 🧪 NEXT: After official split approval, run loader smoke and candidate-shape transform check.
- 🔁 DO NOT REPEAT: Do not treat a 20-subject feasibility audit as full-cohort proof.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/audit_loader_transform_feasibility.py`
  - `research_gsure/02_audits/outputs/loader_transform_feasibility_sample.csv`
  - `research_gsure/02_audits/outputs/loader_transform_feasibility_summary.csv`
  - `research_gsure/02_audits/outputs/loader_transform_feasibility_report.md`
  - `research_gsure/02_audits/STAGE9_LOADER_TRANSFORM_FEASIBILITY.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/audit_loader_transform_feasibility.py`
  - `python research_gsure/02_audits/scripts/audit_loader_transform_feasibility.py --max-per-dataset 5`
- Metrics:
  - sample rows: 20
  - candidate rows: 80
  - errors: 0

### Remaining uncertainty
- Full-cohort bbox containment has not been checked.
- Split-aware loader smoke has not run because official split does not exist.
- GPU memory for `160x192x160` has not been previewed.

### Next recommended action
- With Min approval, create official split and run post-split loader smoke;
  then run a split-aware transform check using `160x192x160` as the first
  candidate, not as a locked final choice.

## 2026-06-23 — Stage 9 expanded quantile loader audit

### Task
- Strengthen the loader transform feasibility check from 20 sampled subjects to
  80 lesion-fraction quantile sampled subjects without creating splits or
  running GPU.

### Research question
- Does the previous `160x192x160` candidate remain safe when the sample is
  expanded, and is fixed-center crop a valid first-baseline strategy?

### What I inspected
- `research_gsure/02_audits/scripts/audit_loader_transform_feasibility.py`
- `research_gsure/02_audits/outputs/loader_transform_feasibility_quantile20.csv`
- `research_gsure/02_audits/outputs/loader_transform_feasibility_quantile20_summary.csv`
- `research_gsure/02_audits/outputs/loader_transform_feasibility_quantile20_report.md`

### Decision / action
- Added `--all-rows` and `--output-prefix` support to the transform audit script.
- Ran `--max-per-dataset 20 --output-prefix loader_transform_feasibility_quantile20`.

### Result
- Manifest rows: 1,614.
- Sampled subject rows: 80.
- Detailed candidate rows: 320.
- Errors: 0.
- `128x160x128`: bbox extent 79/80, fixed-center 54/80.
- `160x192x160`: bbox extent 80/80, fixed-center 79/80.
- `192x224x160`: bbox extent 80/80, fixed-center 79/80.
- `224x224x160`: bbox extent 80/80, fixed-center 80/80.
- The fixed-center failure for `160x192x160` was
  `UCSD-PTGBM::UCSD-PTGBM-0127`, bbox `126x50x79` to `232x184x153`.

### Interpretation
- `160x192x160` should not be presented as fixed-center safe.
- If we use `160x192x160`, it must be a patch/sliding-window candidate with
  full-volume inference coverage.
- `224x224x160` is the smallest tested candidate that passed fixed-center
  containment in the expanded sample, but GPU memory may be much higher.
- This result makes a simple center-crop baseline weaker scientifically; a
  full-coverage inference path is the safer baseline design.

### Insight tags
- ✅ SUCCESS: Expanded audit found no load/canonicalization errors.
- ⚠️ RISK: Center-crop baselines can silently miss off-center tumors, especially UCSD.
- 💡 INSIGHT: `160x192x160` is a patch-size candidate, not a fixed input lock.
- 🧯 MITIGATION: Require sliding-window/full-volume inference before treating segmentation predictions as reliability-label sources.
- 🧪 NEXT: After split approval, implement split-aware loader smoke plus full-coverage inference design review.
- 🔁 DO NOT REPEAT: Do not train a center-crop-only 3D U-Net and interpret poor UCSD results as model failure.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/audit_loader_transform_feasibility.py`
  - `research_gsure/02_audits/outputs/loader_transform_feasibility_quantile20.csv`
  - `research_gsure/02_audits/outputs/loader_transform_feasibility_quantile20_summary.csv`
  - `research_gsure/02_audits/outputs/loader_transform_feasibility_quantile20_report.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/audit_loader_transform_feasibility.py`
  - `python research_gsure/02_audits/scripts/audit_loader_transform_feasibility.py --max-per-dataset 20 --output-prefix loader_transform_feasibility_quantile20`
- Metrics:
  - sampled subjects: 80
  - candidate rows: 320
  - errors: 0

### Remaining uncertainty
- Full-cohort containment remains unverified.
- GPU memory/runtime for `224x224x160` versus sliding-window `160x192x160` is unknown.
- Official split and loader smoke remain pending Min approval.

### Next recommended action
- Do not lock input shape yet. First create official split after approval, then
  run post-split loader smoke and compare full-coverage inference designs.

## 2026-06-23 — Stage 10 sliding-window coverage audit

### Task
- Check whether candidate patch sizes can provide full-volume sliding-window
  coverage using the existing 80-subject quantile bbox CSV.

### Research question
- Can `160x192x160` remain a plausible first-baseline patch size if inference is
  full-volume sliding-window rather than center crop?

### What I inspected
- `research_gsure/02_audits/outputs/loader_transform_feasibility_quantile20.csv`
- `research_gsure/02_audits/outputs/loader_transform_feasibility_quantile20_summary.csv`

### Decision / action
- Added `audit_sliding_window_coverage.py`.
- Ran a CSV-only audit over candidate patch sizes `160x192x160`,
  `192x224x160`, and `224x224x160` with overlaps 0.25 and 0.50.

### Result
- Input bbox rows: 320.
- Unique subjects: 80.
- Detail rows: 480.
- Full-volume coverage failures: 0.
- For `160x192x160` with 50% overlap:
  - full-volume coverage: 80 / 80
  - bbox union coverage: 80 / 80
  - single-window bbox containment: 75 / 80
  - tile counts: 4 for MU/UPENN/UTSW, 18 for UCSD
- For `192x224x160` and `224x224x160` with 50% overlap:
  - single-window bbox containment: 80 / 80
  - UCSD tile count: 12

### Interpretation
- `160x192x160` is viable only as a patch/sliding-window full-volume inference
  candidate. It is not a center-crop baseline.
- Some lesions are split across tiles at `160x192x160`; reliability labels must
  come from assembled full-volume predictions, not patch outputs alone.
- Larger patches improve single-tile lesion context but have higher memory risk.

### Insight tags
- ✅ SUCCESS: CSV-only sliding-window audit found no full-volume coverage failures.
- ⚠️ RISK: Patch-only predictions would create biased reliability labels when lesions span tiles.
- 💡 INSIGHT: UCSD requires more tiles because of `256x256x256` geometry.
- 🧯 MITIGATION: Require assembled full-volume OOF prediction maps before reliability/error labels.
- 🧪 NEXT: After official split approval, run split-aware loader/inference dry-run and GPU memory preview.
- 🔁 DO NOT REPEAT: Do not evaluate or supervise reliability from unassembled patch outputs.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/audit_sliding_window_coverage.py`
  - `research_gsure/02_audits/outputs/sliding_window_coverage_quantile20.csv`
  - `research_gsure/02_audits/outputs/sliding_window_coverage_quantile20_summary.csv`
  - `research_gsure/02_audits/outputs/sliding_window_coverage_quantile20_report.md`
  - `research_gsure/02_audits/STAGE10_SLIDING_WINDOW_COVERAGE.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/audit_sliding_window_coverage.py`
  - `python research_gsure/02_audits/scripts/audit_sliding_window_coverage.py`
- Metrics:
  - unique subjects: 80
  - detail rows: 480
  - full-volume coverage failures: 0

### Remaining uncertainty
- Full-cohort coverage has not been audited.
- GPU memory/runtime remains unknown.
- Official split and post-split loader smoke remain pending Min approval.

### Next recommended action
- Keep official split/GPU gated. Next safe step is a split-aware loader dry-run
  after split approval; before approval, only further design/review work is
  appropriate.

## 2026-06-23 — Stage 11 full draft tile budget

### Task
- Estimate full-cohort draft sliding-window tile budget for candidate patch
  sizes before any official split or GPU preview.

### Research question
- Which patch candidates should be compared in the first GPU memory/runtime
  preview for full-volume OOF segmentation prediction generation?

### What I inspected
- `research_gsure/02_audits/outputs/subject_level_cohort_manifest_draft.csv`
- `research_gsure/02_audits/outputs/sliding_window_coverage_quantile20_summary.csv`

### Decision / action
- Added `audit_sliding_window_tile_budget.py`.
- Ran CSV-only tile budget audit on all 1,614 subject-level draft rows.

### Result
- Manifest rows: 1,614.
- Detail rows: 9,684.
- Dataset summary rows: 24.
- OOF estimate rows: 6.
- OOF total tile-voxel budget relative to `160x192x160@0.50`:
  - `160x192x160@0.25`: 0.801x
  - `160x192x160@0.50`: 1.000x
  - `192x224x160@0.25`: 1.122x
  - `192x224x160@0.50`: 1.233x
  - `224x224x160@0.25`: 1.308x
  - `224x224x160@0.50`: 1.438x
- UCSD tile count at 50% overlap:
  - `160x192x160`: 18 tiles/subject, 3,204 total UCSD tiles.
  - `192x224x160`: 12 tiles/subject, 2,136 total UCSD tiles.
  - `224x224x160`: 12 tiles/subject, 2,136 total UCSD tiles.

### Interpretation
- `160x192x160@0.50` remains the memory-conservative full-coverage candidate.
- `192x224x160@0.50` is the stronger context candidate and reduces UCSD tile
  count, but costs 1.233x tile-voxels and more patch memory.
- `224x224x160@0.50` is not a first preview candidate because it has the same
  UCSD tile count as `192x224x160@0.50` but higher tile-voxel budget.

### Insight tags
- ✅ SUCCESS: Full draft cohort tile-budget audit completed without touching split/GPU.
- ⚠️ RISK: Tile count alone can mislead; patch voxel count changes compute and memory.
- 💡 INSIGHT: The first GPU preview should compare `160x192x160@0.50` and `192x224x160@0.50`.
- 🧯 MITIGATION: Require memory/runtime preview before locking patch size.
- 🧪 NEXT: After official split approval, run split-aware tile budget and loader smoke.
- 🔁 DO NOT REPEAT: Do not pick `224x224x160` just because fixed-center containment looked safe.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/audit_sliding_window_tile_budget.py`
  - `research_gsure/02_audits/outputs/sliding_window_tile_budget_subject_level.csv`
  - `research_gsure/02_audits/outputs/sliding_window_tile_budget_subject_level_by_dataset.csv`
  - `research_gsure/02_audits/outputs/sliding_window_tile_budget_subject_level_oof_estimate.csv`
  - `research_gsure/02_audits/outputs/sliding_window_tile_budget_subject_level_report.md`
  - `research_gsure/02_audits/STAGE11_TILE_BUDGET_AUDIT.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/audit_sliding_window_tile_budget.py`
  - `python research_gsure/02_audits/scripts/audit_sliding_window_tile_budget.py`
- Metrics:
  - subject-level draft rows: 1,614
  - OOF candidate rows: 6

### Remaining uncertainty
- Official split and post-split loader smoke remain pending.
- Tile budget is not GPU memory/runtime proof.
- Patch size is not locked.

### Next recommended action
- Keep the official split/GPU gate. When approved, create the split, run loader
  smoke, then preview GPU memory/runtime for `160x192x160@0.50` and
  `192x224x160@0.50`.

## 2026-06-23 — Stage 12 GPU preview contract prep

### Task
- Prepare the GPU preview contract for the first B1 segmentation baseline
  without running GPU or creating official split files.

### Research question
- What exactly must the first GPU preview measure before we can safely choose a
  patch size for full-volume OOF segmentation prediction generation?

### What I inspected
- `research_gsure/03_baselines/SEGMENTATION_BASELINE_PROTOCOL.md`
- `research_gsure/02_audits/STAGE11_TILE_BUDGET_AUDIT.md`
- `research_gsure/02_audits/outputs/sliding_window_tile_budget_subject_level_oof_estimate.csv`

### Decision / action
- Added `estimate_patch_memory_proxy.py`.
- Generated CPU-only patch tensor memory proxy.
- Added `GPU_PREVIEW_CONTRACT.md`.
- Documented Stage 12 GPU preview preparation.

### Result
- Patch tensor proxy, batch size 1:
  - `160x192x160`: 65.62 MiB minimum train tensor proxy.
  - `192x224x160`: 91.88 MiB, 1.400x relative.
  - `224x224x160`: 107.19 MiB, 1.633x relative.
- Combined with Stage 11 tile-voxel budget:
  - first preview candidates remain `160x192x160@0.50` and
    `192x224x160@0.50`.
  - `224x224x160` remains deferred.

### Interpretation
- `160x192x160@0.50` is the memory-conservative feasibility candidate.
- `192x224x160@0.50` is the context candidate with higher memory risk.
- GPU preview must measure memory/runtime/shape/full-volume assembly only; Dice
  should not be used to choose the patch size at this stage.

### Insight tags
- ✅ SUCCESS: GPU preview contract is explicit before any GPU command.
- ⚠️ RISK: Raw tensor proxy understates true 3D U-Net memory because activations dominate.
- 💡 INSIGHT: Patch-size selection should first be a feasibility decision, not a Dice decision.
- 🧯 MITIGATION: Require peak memory, full-volume assembly, and output-shape checks.
- 🧪 NEXT: After official split approval, run split write, loader smoke, split-aware tile budget, then GPU command preview.
- 🔁 DO NOT REPEAT: Do not launch training just to discover patch memory feasibility.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/estimate_patch_memory_proxy.py`
  - `research_gsure/02_audits/outputs/patch_memory_proxy.csv`
  - `research_gsure/02_audits/outputs/patch_memory_proxy_report.md`
  - `research_gsure/03_baselines/GPU_PREVIEW_CONTRACT.md`
  - `research_gsure/02_audits/STAGE12_GPU_PREVIEW_PREP.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/estimate_patch_memory_proxy.py`
  - `python research_gsure/02_audits/scripts/estimate_patch_memory_proxy.py`
- Metrics:
  - proxy rows: 6

### Remaining uncertainty
- Official split still absent.
- GPU memory and runtime not measured.
- Patch size not locked.

### Next recommended action
- Wait for official split approval before any GPU-related command preview.

## 2026-06-23 — Official split approval packet

### Task
- Prepare an explicit approval packet and post-approval runbook for creating the
  official G-SURE LOCO split.

### Research question
- Is the subject-level cohort and LOCO split policy documented clearly enough
  for Min to approve or reject official split creation without ambiguity?

### What I inspected
- `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
- `research_gsure/02_audits/STAGE7_SPLIT_AND_LOADER_PREP.md`
- `research_gsure/02_audits/outputs/loco_split_readiness_report.md`
- `research_gsure/01_protocol/POST_SPLIT_LOADER_SMOKE_CONTRACT.md`
- `research_gsure/01_protocol/LOCO_SPLIT_POLICY_DRAFT.md`

### Decision / action
- Added an official split approval packet.
- Added a post-approval split runbook.
- Did not run `--write`.

### Result
- Approval decision is now explicit:
  - primary cohort: `subject_level_cohort_manifest_draft.csv`
  - selection policy: `one_unit_per_subject_earliest_numeric_order`
  - target: binary `selected_mask > 0`
  - split: LOCO
  - unit: `dataset::subject_id`
- Official split creation remains blocked until Min explicitly approves.

### Interpretation
- The next irreversible-ish research action is not GPU; it is official split
  creation.
- The approval packet separates approval to write split artifacts from approval
  to train, preprocess, or generate reliability labels.

### Insight tags
- ✅ SUCCESS: Split approval wording and exact `--write` outputs are documented.
- ⚠️ RISK: Timing warnings and UCSD geometry shift remain accepted-disclosure risks unless Min changes exclusion policy.
- 🧯 MITIGATION: Post-approval loader smoke and split audit are mandatory before GPU.
- 🧪 NEXT: If Min approves, run split write, inspect split summary, run loader smoke.
- 🔁 DO NOT REPEAT: Do not treat planning documents as approval for `--write`.

### Evidence
- Files:
  - `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`
  - `research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md`
  - `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
  - `research_gsure/02_audits/STAGE7_SPLIT_AND_LOADER_PREP.md`
- Commands:
  - `pwd`
  - `git status --short`
  - `git branch --show-current`
- Metrics:
  - subject-level cohort rows: 1,614
  - dry-run split rows expected: 6,456

### Remaining uncertainty
- Min has not approved official split creation.
- Official split and post-split loader smoke remain unrun.

### Next recommended action
- Ask Min for explicit official split approval using the wording in the approval
  packet, or continue only with safe pre-approval design/review work.

## 2026-06-23 — Split builder overwrite guard

### Task
- Strengthen the official LOCO split builder so approved split artifacts cannot
  be silently overwritten.

### Research question
- Can the official split creation step preserve reproducibility by failing if
  official split artifacts already exist?

### What I inspected
- `research_gsure/02_audits/scripts/build_loco_split_manifest.py`
- `research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md`
- `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`

### Decision / action
- Added `--force` to the split builder.
- Default `--write` now refuses to overwrite existing official split outputs.
- `--force` requires separate explicit overwrite approval.

### Result
- Dry-run behavior remains unchanged.
- Official split file remains absent.

### Interpretation
- This prevents accidental drift of the official split artifact after approval.
- It also makes re-running the approval runbook safer: existing split artifacts
  will cause a hard stop rather than silent replacement.

### Insight tags
- ✅ SUCCESS: Split builder now has overwrite protection.
- ⚠️ RISK: `--force` can still overwrite if misused.
- 🧯 MITIGATION: Runbook states `--force` requires separate explicit overwrite approval.
- 🧪 NEXT: If Min approves official split creation, run `--write` without `--force`.
- 🔁 DO NOT REPEAT: Do not overwrite official split artifacts to “refresh” them without recording a new decision.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/build_loco_split_manifest.py`
  - `research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md`
  - `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`
  - `research_gsure/02_audits/STAGE13_SPLIT_BUILDER_OVERWRITE_GUARD.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/build_loco_split_manifest.py`
  - `python research_gsure/02_audits/scripts/build_loco_split_manifest.py`
  - helper-level `existing_outputs(...)` check
  - official split manifest existence check
  - `find research_gsure -type d -name __pycache__ -print`
  - `git status --short`
  - dry-run: `Subject rows: 1614`, `Split rows to write: 6456`, `Validation: ok`
  - official split manifest: absent

### Remaining uncertainty
- Min has not approved official split creation.
- Full overwrite refusal path was not exercised with official split files,
  because creating official split files remains gated.

### Next recommended action
- Keep official split write gated. If Min approves, run `--write` without
  `--force`.

## 2026-06-23 — Split-aware tile budget prep

### Task
- Prepare tile-budget computation for future official `loco_split_manifest.csv`
  without creating the official split.

### Research question
- Once official split artifacts exist, can we compute the held-out test tile
  budget directly from the split manifest before GPU preview?

### What I inspected
- `research_gsure/02_audits/scripts/audit_sliding_window_tile_budget.py`
- `research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md`
- `research_gsure/02_audits/STAGE11_TILE_BUDGET_AUDIT.md`

### Decision / action
- Added `--split-manifest` and `--split-role` to the tile-budget script.
- Updated the post-approval runbook with the exact split-aware command.
- Did not create official split artifacts.

### Result
- Subject-mode regression still produces:
  - analysis rows: 1,614
  - detail rows: 9,684
  - dataset summary rows: 24
  - OOF estimate rows: 6
- In-memory split-row logic check preserved split metadata and expected tile
  counts `[4, 18]` for `240x240x155` and `256x256x256`.
- Official split manifest remains absent.

### Interpretation
- After split approval, Step 4 no longer needs script adaptation; it has a
  defined command.
- The remaining blocker is still Min approval to create the official split.

### Insight tags
- ✅ SUCCESS: Tile budget script is ready for future split-manifest input.
- ⚠️ RISK: Full split-mode CLI cannot run until official split exists.
- 🧯 MITIGATION: Validate subject mode and in-memory split row logic now; run CLI split mode immediately after split creation.
- 🧪 NEXT: On approval, write official split, smoke-load, then run split-aware tile budget.
- 🔁 DO NOT REPEAT: Do not use subject-level draft tile budget as the official post-split report once `loco_split_manifest.csv` exists.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/audit_sliding_window_tile_budget.py`
  - `research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md`
  - `research_gsure/02_audits/STAGE11_TILE_BUDGET_AUDIT.md`
  - `research_gsure/02_audits/STAGE14_SPLIT_AWARE_TILE_BUDGET_PREP.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/audit_sliding_window_tile_budget.py`
  - `python research_gsure/02_audits/scripts/audit_sliding_window_tile_budget.py`
  - in-memory split-row function check
  - official split manifest existence check

### Remaining uncertainty
- Official split has not been created, so split-manifest CLI mode is prepared
  but not run against real official rows.

### Next recommended action
- Keep waiting for explicit official split approval, or continue only with safe
  pre-approval review/design work.

## 2026-06-23 — Loader smoke hardening

### Task
- Strengthen the CPU loader smoke test so it catches geometry and finite-value
  failures before any GPU work.

### Research question
- Can the loader smoke detect shape/affine/orientation/spacing mismatches that
  would invalidate full-volume OOF segmentation predictions?

### What I inspected
- `research_gsure/02_audits/scripts/smoke_load_manifest_sample.py`
- `research_gsure/01_protocol/POST_SPLIT_LOADER_SMOKE_CONTRACT.md`

### Decision / action
- Added affine, orientation, zoom, and finite-value checks.
- Added `--dataset` filter for bounded pre-split development smoke.
- Did not create official split files.

### Result
- Compile passed.
- MU subject-level smoke loaded 2 rows successfully.
- UCSD subject-level smoke loaded 2 rows successfully.
- Sampled UCSD rows confirmed `256x256x256`, `ILA`, `1x1x1` geometry for all
  MRI channels and mask.

### Interpretation
- The post-split smoke will now catch more failure modes than shape mismatch
  alone.
- Pre-split smoke is useful development validation but does not replace the
  official post-split smoke.

### Insight tags
- ✅ SUCCESS: Loader smoke now checks shape, affine, orientation, spacing, finite values, and non-empty target.
- ⚠️ RISK: Smoke samples are bounded and cannot prove full cohort correctness.
- 🧯 MITIGATION: Required post-split smoke remains mandatory before GPU preview.
- 🧪 NEXT: After official split approval, run smoke on UCSD held-out test rows from `loco_split_manifest.csv`.
- 🔁 DO NOT REPEAT: Do not rely on shape-only loader validation for medical MRI segmentation.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/smoke_load_manifest_sample.py`
  - `research_gsure/01_protocol/POST_SPLIT_LOADER_SMOKE_CONTRACT.md`
  - `research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md`
  - `research_gsure/02_audits/STAGE15_LOADER_SMOKE_HARDENING.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/smoke_load_manifest_sample.py`
  - `python research_gsure/02_audits/scripts/smoke_load_manifest_sample.py --manifest research_gsure/02_audits/outputs/subject_level_cohort_manifest_draft.csv --max-rows 2`
  - `python research_gsure/02_audits/scripts/smoke_load_manifest_sample.py --manifest research_gsure/02_audits/outputs/subject_level_cohort_manifest_draft.csv --dataset UCSD-PTGBM --max-rows 2`

### Remaining uncertainty
- Official split has not been created, so post-split smoke remains unrun.

### Next recommended action
- Keep official split write gated; after approval, run the required post-split
  loader smoke before any tile budget or GPU preview.

## 2026-06-23 — Pre-split readiness review

### Task
- Check whether the G-SURE workspace is ready for the next approved action
  toward the final research goal.

### Research question
- Are the cohort, split, loader smoke, tile-budget, and GPU-preview preparation
  artifacts aligned well enough to proceed once Min approves the official split?

### What I inspected
- `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
- `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`
- `research_gsure/01_protocol/POST_SPLIT_LOADER_SMOKE_CONTRACT.md`
- `research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md`
- `research_gsure/03_baselines/GPU_PREVIEW_CONTRACT.md`
- `research_gsure/03_baselines/SEGMENTATION_BASELINE_PROTOCOL.md`
- `research_gsure/04_method/GSURE_METHOD_SKETCH.md`
- `research_gsure/02_audits/outputs/`

### Decision / action
- Aligned the official split approval packet and experiment readiness checklist
  with the stricter Stage 15 loader smoke requirements.
- Added a pre-split readiness review note.
- Did not create official split files, run GPU, train models, or preprocess data.

### Result
- Official split manifest is still absent.
- The workspace is prepared for the next approval-gated action, but not for GPU
  training.

### Interpretation
- The immediate blocker is Min approval for official LOCO split creation.
- After approval, the runbook sequence is split write -> split inspection ->
  post-split loader smoke -> split-aware tile budget -> GPU command preview.

### Insight tags
- ✅ SUCCESS: Loader smoke, split runbook, and approval packet now describe the same geometry/finite-value checks.
- ⚠️ RISK: GPU training is still blocked by official split absence and unlocked canonical loader policy.
- 🧪 NEXT: Request explicit official LOCO split approval if Min accepts the subject-level cohort policy.
- 🔁 DO NOT REPEAT: Do not jump from draft subject manifest directly to GPU training.
- 📌 MIN DECISION: Official LOCO split creation still requires explicit approval wording.

### Evidence
- Files:
  - `research_gsure/02_audits/STAGE16_PRE_SPLIT_READINESS_REVIEW.md`
  - `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`
  - `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
- Commands:
  - `find research_gsure -maxdepth 3 -type f | sort`
  - `find research_gsure/02_audits/outputs -maxdepth 1 -type f | sort`
  - official split manifest existence check

### Remaining uncertainty
- Official split and post-split smoke are not run because approval has not been
  given.
- Canonical orientation/crop/pad/sliding-window loader implementation remains a
  separate pre-GPU design gate.

### Next recommended action
- If the cohort/split policy is accepted, Min should explicitly approve official
  LOCO split creation; otherwise continue with loader implementation design only.

## 2026-06-23 — Loader and full-volume inference policy draft

### Task
- Turn the loader feasibility and sliding-window audits into a concrete
  pre-GPU loader/inference policy draft.

### Research question
- What loader and inference constraints are necessary so that later OOF
  segmentation predictions can be used as valid G-SURE reliability evidence?

### What I inspected
- `research_gsure/02_audits/STAGE9_LOADER_TRANSFORM_FEASIBILITY.md`
- `research_gsure/02_audits/STAGE10_SLIDING_WINDOW_COVERAGE.md`
- `research_gsure/02_audits/STAGE11_TILE_BUDGET_AUDIT.md`
- `research_gsure/02_audits/STAGE12_GPU_PREVIEW_PREP.md`
- `research_gsure/03_baselines/SEGMENTATION_BASELINE_PROTOCOL.md`
- `research_gsure/03_baselines/GPU_PREVIEW_CONTRACT.md`

### Decision / action
- Added `research_gsure/01_protocol/LOADER_INFERENCE_POLICY_DRAFT.md`.
- Added `research_gsure/02_audits/STAGE17_LOADER_INFERENCE_POLICY_REVIEW.md`.
- Updated readiness and baseline protocol docs to reference the policy draft.
- Did not create official split files, run GPU, train models, or preprocess data.

### Result
- The draft policy requires in-memory closest-canonical orientation, strict
  geometry checks, train-split-only foreground-aware sampling, and mask-free
  validation/test full-volume sliding-window assembly.
- `160x192x160` remains allowed only as a patch/sliding-window candidate, not as
  fixed-center inference.

### Interpretation
- This directly protects the final G-SURE objective: reliability/error labels
  must come from assembled full-volume OOF predictions, not crop artifacts.

### Insight tags
- ✅ SUCCESS: Loader policy now explicitly forbids held-out mask-centered crops and center-crop-only inference.
- ⚠️ RISK: Exact blending, augmentation, normalization, and sampling ratios remain implementation decisions.
- 🧪 NEXT: After official split approval, implement/review the actual baseline loader against this policy.
- 🔁 DO NOT REPEAT: Do not use patch-only outputs as reliability labels.

### Evidence
- Files:
  - `research_gsure/01_protocol/LOADER_INFERENCE_POLICY_DRAFT.md`
  - `research_gsure/02_audits/STAGE17_LOADER_INFERENCE_POLICY_REVIEW.md`
  - `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
  - `research_gsure/03_baselines/SEGMENTATION_BASELINE_PROTOCOL.md`
- Commands:
  - `sed` review of Stage 9-12 audit documents

### Remaining uncertainty
- Official split has not been created.
- The actual training loader has not been implemented or reviewed.

### Next recommended action
- Keep official split gated; after approval, run split creation and post-split
  smoke before any loader implementation is used for GPU preview.

## 2026-06-23 — Tile grid dry-run

### Task
- Verify that the first GPU-preview patch candidates can cover every draft
  subject volume using shape-based sliding-window tile placement.

### Research question
- Do `160x192x160@0.50` and `192x224x160@0.50` produce coverage holes over the
  full 1,614-subject draft cohort when tile placement ignores masks?

### What I inspected
- `research_gsure/02_audits/scripts/audit_sliding_window_tile_budget.py`
- `research_gsure/02_audits/scripts/audit_sliding_window_coverage.py`
- existing tile budget outputs and reports

### Decision / action
- Added `research_gsure/02_audits/scripts/audit_tile_grid_dry_run.py`.
- Ran it on the draft subject-level manifest for the two first-preview
  candidates.
- Added Stage 18 documentation and connected the official post-split runbook to
  the same dry-run.

### Result
- Input rows: 1,614
- Detail rows: 3,228
- Coverage failures: 0
- UCSD tile count remains the driver:
  - `160x192x160@0.50`: 18 tiles per UCSD subject.
  - `192x224x160@0.50`: 12 tiles per UCSD subject.

### Interpretation
- Both candidates remain viable for GPU preview from a shape-coverage
  standpoint.
- This is not accuracy, runtime, memory, or blending-quality evidence.

### Insight tags
- ✅ SUCCESS: Shape-based full-volume tile placement has 0 coverage failures over the draft subject cohort.
- ⚠️ RISK: Official split-aware dry-run still must be rerun after split creation.
- 🧪 NEXT: After official split approval, rerun tile-grid dry-run with `--split-manifest ... --split-role test`.
- 🔁 DO NOT REPEAT: Do not treat draft-subject coverage as a replacement for official split validation.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/audit_tile_grid_dry_run.py`
  - `research_gsure/02_audits/outputs/tile_grid_dry_run_subject_level.csv`
  - `research_gsure/02_audits/outputs/tile_grid_dry_run_subject_level_summary.csv`
  - `research_gsure/02_audits/outputs/tile_grid_dry_run_subject_level_report.md`
  - `research_gsure/02_audits/STAGE18_TILE_GRID_DRY_RUN.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/audit_tile_grid_dry_run.py`
  - `python research_gsure/02_audits/scripts/audit_tile_grid_dry_run.py --candidate-shapes 160x192x160,192x224x160 --overlaps 0.50 --fail-on-coverage-hole`

### Remaining uncertainty
- Official split is still absent.
- GPU memory, runtime, blending, and actual model inference are untested.

### Next recommended action
- Keep official split gated. After approval, run split creation, post-split
  smoke, split-aware tile budget, and split-aware tile-grid dry-run before GPU
  preview.

## 2026-06-23 — OOF prediction and reliability label contract

### Task
- Define the artifact and provenance contract for future OOF segmentation
  predictions and reliability/error labels.

### Research question
- What must a prediction artifact prove before it can be used as G-SURE
  reliability supervision or evaluation evidence?

### What I inspected
- `research_gsure/03_baselines/BASELINE_CONTRACT.md`
- `research_gsure/03_baselines/SEGMENTATION_BASELINE_PROTOCOL.md`
- `research_gsure/04_method/GSURE_METHOD_SKETCH.md`
- `research_gsure/05_reports/REPORT_TEMPLATE.md`
- `rg` search for OOF/reliability/prediction references

### Decision / action
- Added `research_gsure/01_protocol/OOF_PREDICTION_RELIABILITY_CONTRACT.md`.
- Added `research_gsure/02_audits/STAGE19_OOF_PREDICTION_CONTRACT.md`.
- Linked the contract from readiness, baseline, method, and report docs.
- Did not create official split files, run GPU, generate predictions, or create
  reliability labels.

### Result
- Future prediction artifacts now have required manifest columns and hard
  invariants.
- Reliability/error labels are allowed only from full-volume, held-out/OOF,
  provenance-recorded, shape-validated predictions.

### Interpretation
- This prevents the next major failure mode: producing predictions that look
  useful but cannot defensibly generate reliability labels.

### Insight tags
- ✅ SUCCESS: OOF prediction provenance requirements are now explicit.
- ⚠️ RISK: Probability-map file format, threshold policy, boundary radius, and artifact-level map validation remain unresolved at this stage; artifact-level NIfTI validation is later added in Stage 21.
- 🧪 NEXT: Require a manifest validator before generating reliability labels.
- 🔁 DO NOT REPEAT: Do not generate reliability labels from in-sample, patch-only, or provenance-missing predictions.

### Evidence
- Files:
  - `research_gsure/01_protocol/OOF_PREDICTION_RELIABILITY_CONTRACT.md`
  - `research_gsure/02_audits/STAGE19_OOF_PREDICTION_CONTRACT.md`
  - `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
  - `research_gsure/03_baselines/BASELINE_CONTRACT.md`
  - `research_gsure/03_baselines/SEGMENTATION_BASELINE_PROTOCOL.md`
  - `research_gsure/04_method/GSURE_METHOD_SKETCH.md`
  - `research_gsure/05_reports/REPORT_TEMPLATE.md`
- Commands:
  - `rg -n "OOF|out-of-fold|reliability|error label|probability|prediction|in-sample|full-volume" research_gsure`

### Remaining uncertainty
- No actual OOF predictions exist yet.
- Official split is still absent.
- Prediction map format and validation script are not implemented yet.

### Next recommended action
- Keep official split gated. After split approval and GPU preview, require any
  prediction-writing code to emit the OOF prediction manifest before reliability
  labels can be generated.

## 2026-06-23 — OOF prediction manifest validator

### Task
- Add a metadata-only validator for future OOF prediction manifests.

### Research question
- Can we enforce the prediction provenance contract before reliability/error
  labels are generated?

### What I inspected
- `research_gsure/01_protocol/OOF_PREDICTION_RELIABILITY_CONTRACT.md`
- Stage 19 contract requirements

### Decision / action
- Added `research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py`.
- Added `research_gsure/02_audits/STAGE20_OOF_PREDICTION_VALIDATOR.md`.
- Updated the OOF prediction contract and readiness checklist to require the
  validator before reliability label generation.

### Result
- `py_compile` passed.
- Synthetic self-test passed with 1 row and 0 validation errors.
- Schema print smoke returned the required prediction manifest columns.

### Interpretation
- The future prediction-writing stage now has an enforceable metadata gate.
- This still does not inspect probability map values or NIfTI geometry.

### Insight tags
- ✅ SUCCESS: OOF prediction manifest schema/provenance checks are executable.
- ⚠️ RISK: Artifact-level probability map validation remains unimplemented until the file format is locked.
- 🧪 NEXT: After prediction-writing code exists, run validator with `--split-manifest` and `--check-files`.
- 🔁 DO NOT REPEAT: Do not generate reliability labels before the OOF prediction manifest validator passes.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py`
  - `research_gsure/02_audits/STAGE20_OOF_PREDICTION_VALIDATOR.md`
  - `research_gsure/01_protocol/OOF_PREDICTION_RELIABILITY_CONTRACT.md`
  - `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py`
  - `python research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py --synthetic-self-test`
  - `python research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py --print-schema`

### Remaining uncertainty
- No real prediction manifest exists yet.
- Official split is still absent.
- Probability map file format is not locked.

### Next recommended action
- Continue pre-GPU preparation only, or request explicit approval for official
  LOCO split creation if the cohort/split policy is accepted.

## 2026-06-23 — Prediction artifact validator

### Task
- Add an artifact-level validator for future OOF prediction NIfTI files.

### Research question
- Can we verify that a probability map referenced by the OOF manifest is finite,
  in `[0,1]`, and in the same canonical geometry as the target mask?

### What I inspected
- `research_gsure/01_protocol/OOF_PREDICTION_RELIABILITY_CONTRACT.md`
- `research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py`
- `research_gsure/02_audits/STAGE20_OOF_PREDICTION_VALIDATOR.md`

### Decision / action
- Added `research_gsure/02_audits/scripts/validate_prediction_artifacts.py`.
- Added `research_gsure/02_audits/STAGE21_PREDICTION_ARTIFACT_VALIDATOR.md`.
- Updated the OOF contract, readiness checklist, baseline protocol, and report
  template to require artifact-level validation before reliability labels.

### Result
- `py_compile` passed.
- Synthetic NIfTI self-test passed with 1 row and 0 validation errors.
- Official split remains absent.
- No real prediction artifacts were generated.

### Interpretation
- We now have two gates for future OOF predictions:
  - metadata/provenance manifest validation,
  - probability-map artifact value/geometry validation.

### Insight tags
- ✅ SUCCESS: Probability map value-range and geometry checks are executable for NIfTI artifacts.
- ⚠️ RISK: Real prediction file format, threshold policy, and boundary-label morphology are still not fully locked.
- 🧪 NEXT: After prediction-writing code exists, run metadata validator first, then artifact validator.
- 🔁 DO NOT REPEAT: Do not create reliability labels from prediction files that have only metadata validation.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/validate_prediction_artifacts.py`
  - `research_gsure/02_audits/STAGE21_PREDICTION_ARTIFACT_VALIDATOR.md`
  - `research_gsure/01_protocol/OOF_PREDICTION_RELIABILITY_CONTRACT.md`
  - `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
  - `research_gsure/03_baselines/SEGMENTATION_BASELINE_PROTOCOL.md`
  - `research_gsure/05_reports/REPORT_TEMPLATE.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/validate_prediction_artifacts.py`
  - `python research_gsure/02_audits/scripts/validate_prediction_artifacts.py --synthetic-self-test`

### Remaining uncertainty
- No real OOF prediction manifest exists yet.
- Official split is still absent.
- Threshold and boundary-label settings are still draft decisions.

### Next recommended action
- Continue pre-GPU preparation only, or move to official LOCO split creation if
  Min explicitly approves the split.

## 2026-06-23 — Reliability label policy

### Task
- Define the first reliability/error label policy before any OOF labels exist.

### Research question
- What threshold, error maps, and boundary policy should govern the first
  G-SURE reliability labels without post-hoc tuning?

### What I inspected
- `research_gsure/01_protocol/OOF_PREDICTION_RELIABILITY_CONTRACT.md`
- `research_gsure/01_protocol/GSURE_PROTOCOL_DRAFT.md`
- `research_gsure/04_method/GSURE_METHOD_SKETCH.md`
- `research_gsure/05_reports/REPORT_TEMPLATE.md`
- `rg` search for FN/FP/ERR/threshold/boundary references

### Decision / action
- Added `research_gsure/01_protocol/RELIABILITY_LABEL_POLICY_DRAFT.md`.
- Added `research_gsure/02_audits/STAGE22_RELIABILITY_LABEL_POLICY.md`.
- Updated readiness, OOF contract, method sketch, and report template.
- Did not generate predictions or reliability labels.

### Result
- First label policy uses:
  - `threshold_source = fixed_0.5`
  - `threshold_value = 0.5`
  - `FN`, `FP`, `ERR`, `SOFT_ERROR`
  - `ERR` as first binary reliability target
  - boundary labels deferred with `boundary_radius = 0`

### Interpretation
- The policy blocks held-out threshold tuning and avoids arbitrary boundary-band
  choices as the first reliability target.

### Insight tags
- ✅ SUCCESS: First reliability-label semantics are now explicit before prediction generation.
- ⚠️ RISK: Label generator and label manifest validator are still unimplemented.
- 🧪 NEXT: After real OOF predictions exist and validators pass, implement label generation against this policy.
- 🔁 DO NOT REPEAT: Do not tune threshold or boundary radius after inspecting held-out error maps.

### Evidence
- Files:
  - `research_gsure/01_protocol/RELIABILITY_LABEL_POLICY_DRAFT.md`
  - `research_gsure/02_audits/STAGE22_RELIABILITY_LABEL_POLICY.md`
  - `research_gsure/01_protocol/OOF_PREDICTION_RELIABILITY_CONTRACT.md`
  - `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
  - `research_gsure/04_method/GSURE_METHOD_SKETCH.md`
  - `research_gsure/05_reports/REPORT_TEMPLATE.md`
- Commands:
  - `rg -n "FN|FP|ERR|soft_error|boundary|threshold|label generation|reliability label|morphology|connectivity" ...`

### Remaining uncertainty
- No real OOF predictions exist.
- Official split is still absent.
- Label generator and label manifest validator remain future work.

### Next recommended action
- Continue with pre-GPU preparation, or request explicit approval for official
  LOCO split creation if the cohort/split policy is accepted.

## 2026-06-23 — Reliability label generator and validator

### Task
- Add CPU-only scripts to generate and validate first-pass reliability/error
  labels under the fixed-threshold policy.

### Research question
- Can FN/FP/ERR/SOFT_ERROR labels be generated reproducibly from OOF probability
  maps and then validated against the declared policy?

### What I inspected
- `research_gsure/01_protocol/RELIABILITY_LABEL_POLICY_DRAFT.md`
- `research_gsure/02_audits/scripts/validate_prediction_artifacts.py`
- `research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py`
- `research_gsure/02_audits/STAGE22_RELIABILITY_LABEL_POLICY.md`

### Decision / action
- Added `research_gsure/02_audits/scripts/generate_reliability_labels.py`.
- Added `research_gsure/02_audits/scripts/validate_reliability_label_manifest.py`.
- Added `research_gsure/02_audits/STAGE23_RELIABILITY_LABEL_GENERATOR.md`.
- Updated reliability policy, OOF contract, readiness checklist, and report
  template.
- Did not run on real data.

### Result
- `py_compile` passed.
- Synthetic label generation passed with 1 row and 0 errors.
- Synthetic label validation passed with 1 row and 0 errors.
- Official split remains absent.

### Interpretation
- Future label generation now has an executable path and a separate validator.
- Real labels remain blocked until official split and OOF prediction artifacts
  exist and pass validation.

### Insight tags
- ✅ SUCCESS: Fixed-threshold FN/FP/ERR/SOFT_ERROR generation is executable on synthetic NIfTI data.
- ⚠️ RISK: Real output directory policy and real prediction artifacts are not available yet.
- 🧪 NEXT: After validated OOF predictions exist, run generator then validator with approved output paths.
- 🔁 DO NOT REPEAT: Do not run label generation on real predictions before metadata and artifact validators pass.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/generate_reliability_labels.py`
  - `research_gsure/02_audits/scripts/validate_reliability_label_manifest.py`
  - `research_gsure/02_audits/STAGE23_RELIABILITY_LABEL_GENERATOR.md`
  - `research_gsure/01_protocol/RELIABILITY_LABEL_POLICY_DRAFT.md`
  - `research_gsure/01_protocol/OOF_PREDICTION_RELIABILITY_CONTRACT.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/generate_reliability_labels.py research_gsure/02_audits/scripts/validate_reliability_label_manifest.py`
  - `python research_gsure/02_audits/scripts/generate_reliability_labels.py --synthetic-self-test`
  - `python research_gsure/02_audits/scripts/validate_reliability_label_manifest.py --synthetic-self-test`

### Remaining uncertainty
- No real OOF prediction manifest exists.
- Official split is still absent.
- Real label output directory policy is not approved.

### Next recommended action
- Continue pre-GPU preparation, or request explicit official LOCO split approval
  if Min accepts the current cohort/split policy.

## 2026-06-23 — Pre-split readiness preflight

### Task
- Add a single CPU-only preflight for current G-SURE pre-official-split
  readiness.

### Research question
- Can the workspace prove it is internally consistent and still safely
  pre-split before requesting or executing official LOCO split creation?

### What I inspected
- `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
- `research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md`
- `research_gsure/02_audits/outputs/`
- current audit scripts and validator scripts

### Decision / action
- Added `research_gsure/02_audits/scripts/check_pre_split_readiness.py`.
- Added `research_gsure/02_audits/STAGE24_PRE_SPLIT_PREFLIGHT.md`.
- Linked the preflight from the readiness checklist and post-approval runbook.

### Result
- `py_compile` passed.
- Preflight passed.
- Official split artifacts remain absent.

### Interpretation
- The workspace is coherent for the next approval-gated action.
- The next gate is explicit official LOCO split approval, not GPU.

### Insight tags
- ✅ SUCCESS: Pre-split readiness is now executable as one command.
- ⚠️ RISK: PASS does not prove segmentation performance, GPU feasibility, or novelty.
- 🧪 NEXT: If Min approves, run official split creation only after this preflight passes.
- 🔁 DO NOT REPEAT: Do not manually jump to split/GPU without rerunning the gate sequence.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `research_gsure/02_audits/STAGE24_PRE_SPLIT_PREFLIGHT.md`
  - `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
  - `research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`

### Remaining uncertainty
- Official split is still absent.
- No GPU preview, training, OOF prediction, or real reliability labels exist.

### Next recommended action
- Request explicit official LOCO split approval if the subject-level cohort and
  LOCO policy are accepted.

## 2026-06-23 — Official split artifact checker

### Task
- Add a CPU-only checker for official LOCO split artifacts.

### Research question
- Can we mechanically verify that official split artifacts are absent before
  approval and structurally valid after approved creation?

### What I inspected
- `research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md`
- `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- `research_gsure/02_audits/scripts/build_loco_split_manifest.py`

### Decision / action
- Added `research_gsure/02_audits/scripts/check_official_split_artifacts.py`.
- Added `research_gsure/02_audits/STAGE25_OFFICIAL_SPLIT_ARTIFACT_CHECKER.md`.
- Linked the checker from pre-split preflight, post-approval runbook, and
  readiness checklist.

### Result
- `py_compile` passed.
- Pre-approval `--expect-missing` check passed.
- Official split artifacts remain absent.

### Interpretation
- The next approval-gated split action now has a before/after checker:
  - before approval: official split artifacts must be absent,
  - after approval/write: official split artifacts must pass structural checks.

### Insight tags
- ✅ SUCCESS: Official split absence/validity check is now executable.
- ⚠️ RISK: Post-approval default checker cannot run until the official split exists.
- 🧪 NEXT: After explicit approval, run preflight, write split, then run default split artifact checker.
- 🔁 DO NOT REPEAT: Do not proceed from split write to loader smoke without the artifact checker passing.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/check_official_split_artifacts.py`
  - `research_gsure/02_audits/STAGE25_OFFICIAL_SPLIT_ARTIFACT_CHECKER.md`
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md`
  - `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/check_official_split_artifacts.py`
  - `python research_gsure/02_audits/scripts/check_official_split_artifacts.py --expect-missing`

### Remaining uncertainty
- Official split has not been created.
- Default post-approval checker remains unrun.

### Next recommended action
- Keep official split gated until Min explicitly approves creation.

## 2026-06-23 — Post-split validation runner

### Task
- Prepare a consolidated validation runner for the state after official LOCO
  split creation.

### Research question
- Can split artifacts, loader smoke, and full-volume tile-grid assumptions be
  checked in one reproducible CPU-only sequence before any GPU work?

### What I inspected
- `research_gsure/02_audits/scripts/check_official_split_artifacts.py`
- `research_gsure/02_audits/scripts/smoke_load_manifest_sample.py`
- `research_gsure/02_audits/scripts/audit_sliding_window_tile_budget.py`
- `research_gsure/02_audits/scripts/audit_tile_grid_dry_run.py`
- `research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md`
- `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`

### Decision / action
- Added `research_gsure/02_audits/scripts/run_post_split_validation.py`.
- Default mode is preview-only.
- `--run` refuses to proceed if official split artifacts are absent.
- Tile-audit outputs use timestamped prefixes to avoid overwriting old audits.
- Linked runner preview into pre-split readiness.

### Result
- `py_compile` passed.
- Runner preview passed and reported that the official split manifest is absent.
- Runner `--run` refused execution because the official split manifest is absent.
- Pre-split readiness passed with the new runner preview included.

### Interpretation
- This prepares the official split-to-GPU gate without creating the split,
  running GPU, or generating predictions.

### Insight tags
- ✅ SUCCESS: Post-split validation is now represented as one explicit gate.
- ⚠️ RISK: The runner cannot validate the official split until Min approves
  split creation and the artifacts exist.
- 🧪 NEXT: Validate runner preview and rerun pre-split readiness.
- 🔁 DO NOT REPEAT: Do not manually skip from split creation to GPU preview.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/run_post_split_validation.py`
  - `research_gsure/02_audits/STAGE26_POST_SPLIT_VALIDATION_RUNNER.md`
  - `research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md`
  - `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/run_post_split_validation.py research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `python research_gsure/02_audits/scripts/run_post_split_validation.py --preview`
  - `python research_gsure/02_audits/scripts/check_official_split_artifacts.py --expect-missing`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `python research_gsure/02_audits/scripts/run_post_split_validation.py --run`

### Remaining uncertainty
- Official LOCO split is still absent.
- No baseline segmentation, OOF prediction, or reliability label artifacts exist.

### Next recommended action
- Run CPU-only validation for the new runner and readiness gate.

## 2026-06-23 — Pre-approval state audit

### Task
- Re-check whether current G-SURE documents still match the active research
  objective before official LOCO split approval.

### Research question
- Are the current protocol, roadmap, approval packet, and evidence map
  internally consistent with the segmentation reliability/grounding direction?

### What I inspected
- `research_gsure/README.md`
- `research_gsure/ROADMAP.md`
- `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`
- `research_gsure/01_protocol/GSURE_PROTOCOL_DRAFT.md`
- `research_gsure/01_protocol/PRE_EXPERIMENT_EVIDENCE_MAP.md`
- `research_gsure/02_audits/README.md`
- `research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md`
- `SCRATCHPAD.md`

### Decision / action
- Kept the active objective as G-SURE segmentation reliability/grounding.
- Updated stale current-status text in the pre-experiment evidence map.
- Updated the official split approval packet to require the consolidated
  post-split validation runner after split creation.
- Updated roadmap and README entry points so the immediate gate is consistent.
- Added `research_gsure/02_audits/STAGE27_PRE_APPROVAL_STATE_AUDIT.md`.

### Result
- Official split absent check passed.
- Post-split validation runner preview passed.
- Pre-split readiness passed.
- `git diff --check` passed.

### Interpretation
- The workspace remains pre-split and pre-GPU.
- The next gate remains explicit official LOCO split approval, not model
  training.

### Insight tags
- ✅ SUCCESS: Main documents now point to the same next validation chain.
- ⚠️ RISK: Literature novelty is still not verified in this session.
- ⚠️ RISK: No segmentation baseline performance exists yet.
- 🧪 NEXT: Rerun CPU-only readiness and absent-split checks.
- 🔁 DO NOT REPEAT: Do not treat stale planning status as current evidence.

### Evidence
- Files:
  - `research_gsure/01_protocol/PRE_EXPERIMENT_EVIDENCE_MAP.md`
  - `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`
  - `research_gsure/README.md`
  - `research_gsure/ROADMAP.md`
  - `research_gsure/02_audits/README.md`
  - `research_gsure/02_audits/STAGE27_PRE_APPROVAL_STATE_AUDIT.md`
- Commands:
  - `python research_gsure/02_audits/scripts/check_official_split_artifacts.py --expect-missing`
  - `python research_gsure/02_audits/scripts/run_post_split_validation.py --preview`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `git diff --check`

### Remaining uncertainty
- Official LOCO split is still absent.
- No GPU preview, baseline training, OOF predictions, or reliability labels
  exist.

### Next recommended action
- Run CPU-only validation and then decide whether to request official split
  approval.

## 2026-06-23 — G-SURE literature scout

### Task
- Run a first-pass literature scout for G-SURE novelty risk.

### Research question
- Is G-SURE distinguishable from existing glioma segmentation uncertainty,
  segmentation quality-control, and error-map prediction work?

### What I inspected
- Web literature search for brain tumor segmentation uncertainty, segmentation
  quality prediction, segmentation QC, and medical segmentation error
  localization.
- `research_gsure/01_protocol/GSURE_PROTOCOL_DRAFT.md`
- `research_gsure/03_baselines/BASELINE_CONTRACT.md`
- `research_gsure/03_baselines/SEGMENTATION_BASELINE_PROTOCOL.md`
- `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
- `research_gsure/01_protocol/PRE_EXPERIMENT_EVIDENCE_MAP.md`

### Decision / action
- Added `research_gsure/00_context/20260623_gsure_literature_scout.md`.
- Strengthened required baselines with DeVries-style segmentation quality
  prediction and QCResUNet-style subject-level QC plus voxel-level error-map
  prediction.
- Updated protocol/checklist language so G-SURE is not framed as first
  uncertainty map or first segmentation QC method.

### Result
- Initial literature scout found direct novelty threats:
  - brain tumor segmentation uncertainty is established,
  - segmentation quality prediction is established,
  - brain tumor segmentation QC with voxel-level error-map prediction exists.

### Interpretation
- G-SURE should not be claimed as a generic uncertainty/QC method.
- The viable claim is narrower: LOCO multi-consortium full-volume OOF error
  localization and reliability grounding, compared against strong
  uncertainty/QC baselines.

### Insight tags
- ✅ SUCCESS: Literature scout prevented an overbroad novelty claim.
- ⚠️ RISK: QCResUNet-style work is a direct prior-work threat.
- ⚠️ RISK: Full literature review is still incomplete.
- 💡 INSIGHT: G-SURE lives or dies on cross-consortium full-volume OOF
  reliability/error localization, not Dice or basic uncertainty.
- 🧪 NEXT: Before method lock, read QCResUNet and QU-BraTS/BraTS uncertainty
  metrics in detail.
- 🔁 DO NOT REPEAT: Do not claim first uncertainty map, first QC model, or first
  brain tumor segmentation error-map predictor.

### Evidence
- Files:
  - `research_gsure/00_context/20260623_gsure_literature_scout.md`
  - `research_gsure/01_protocol/GSURE_PROTOCOL_DRAFT.md`
  - `research_gsure/03_baselines/BASELINE_CONTRACT.md`
  - `research_gsure/03_baselines/SEGMENTATION_BASELINE_PROTOCOL.md`
  - `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
  - `research_gsure/01_protocol/PRE_EXPERIMENT_EVIDENCE_MAP.md`
- Commands:
  - web search/open for prior work sources
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `rg -n "QCResUNet|DeVries|Jungo|QU-BraTS|uncertainty/QC|20260623_gsure_literature_scout|novelty/literature" ...`
  - `git diff --check`

### Remaining uncertainty
- This is not a full systematic review.
- Exact QCResUNet inputs, labels, datasets, and metrics still need detailed
  extraction.
- 2024-2026 medical segmentation reliability/foundation-segmentation papers
  still need targeted review.

### Next recommended action
- Keep official split gated, but carry the stronger QC baseline requirements
  into the first baseline planning.

## 2026-06-23 — Prior work to baseline contract

### Task
- Convert the initial G-SURE literature scout into implementable baseline
  requirements.

### Research question
- Which uncertainty/QC baselines must G-SURE beat before any method contribution
  is defensible?

### What I inspected
- QCResUNet MICCAI 2023 page and arXiv/PubMed records.
- BraTS 2020 Task 3 uncertainty evaluation.
- QU-BraTS article/abstract and MIDL uncertainty metric page.
- DeVries and Taylor arXiv page.
- Current protocol and baseline docs.

### Decision / action
- Added `research_gsure/00_context/20260623_gsure_prior_work_matrix.md`.
- Added `research_gsure/03_baselines/UNCERTAINTY_QC_BASELINE_REQUIREMENTS.md`.
- Linked both from literature scout, protocol, baseline contract, and readiness
  checklist.
- Locked the key leakage rule for QC baselines: train-row QC/error labels must
  come from inner-OOF predictions or another approved train-only protocol.

### Result
- G-SURE baseline family now includes:
  - probability-derived entropy/confidence,
  - TTA uncertainty,
  - ensemble/repeated-seed disagreement,
  - DeVries-style subject-level quality predictor,
  - QCResUNet-style subject-level QC plus voxel error-map predictor,
  - reliability head without grounding constraint,
  - G-SURE only after a baseline gap remains.

### Interpretation
- The project is now more conservative and reviewer-resistant.
- The cost is higher: a real QC comparison likely requires inner-OOF
  predictions, not just outer-fold predictions.

### Insight tags
- ✅ SUCCESS: Prior work has been translated into explicit baseline obligations.
- ⚠️ RISK: QC baseline implementation is more expensive than the first B1
  segmentation baseline.
- ⚠️ RISK: If QCResUNet-style baseline solves error localization, G-SURE method
  work should not proceed.
- 💡 INSIGHT: The next experimental design problem is nested/inner-OOF
  prediction generation for second-stage QC labels.
- 🧪 NEXT: After official split approval and B1 prediction planning, design the
  inner-OOF prediction schedule needed for QC baselines.
- 🔁 DO NOT REPEAT: Do not compare G-SURE only against TTA/ensemble while
  ignoring segmentation QC prior work.

### Evidence
- Files:
  - `research_gsure/00_context/20260623_gsure_prior_work_matrix.md`
  - `research_gsure/03_baselines/UNCERTAINTY_QC_BASELINE_REQUIREMENTS.md`
  - `research_gsure/02_audits/STAGE28_PRIOR_WORK_TO_BASELINE_CONTRACT.md`
  - `research_gsure/00_context/20260623_gsure_literature_scout.md`
  - `research_gsure/03_baselines/BASELINE_CONTRACT.md`
  - `research_gsure/01_protocol/GSURE_PROTOCOL_DRAFT.md`
  - `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
- Commands:
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `rg -n "UNCERTAINTY_QC_BASELINE_REQUIREMENTS|prior_work_matrix|QCResUNet|DeVries|QU-BraTS|inner-OOF|BraTS 2020" research_gsure SCRATCHPAD.md`
  - `git diff --check`

### Remaining uncertainty
- Full 2024-2026 related-work review is not complete.
- Exact computational budget for inner-OOF QC-label generation is unknown.
- Official split is still absent.

### Next recommended action
- Validate the updated documentation and keep official split/GPU gated.

## 2026-06-23 — Inner-OOF QC label schedule

### Task
- Define the leakage-safe schedule for QC baseline training labels.

### Research question
- How can DeVries-style and QCResUNet-style baselines be trained without using
  outer held-out consortium labels or in-sample segmentation errors?

### What I inspected
- `research_gsure/03_baselines/UNCERTAINTY_QC_BASELINE_REQUIREMENTS.md`
- `research_gsure/01_protocol/OOF_PREDICTION_RELIABILITY_CONTRACT.md`
- `research_gsure/03_baselines/SEGMENTATION_BASELINE_PROTOCOL.md`
- `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
- `research_gsure/02_audits/outputs/subject_level_cohort_manifest_draft.csv`
- `research_gsure/02_audits/outputs/loco_split_readiness_by_fold.csv`

### Decision / action
- Added `research_gsure/01_protocol/INNER_OOF_QC_LABEL_SCHEDULE_DRAFT.md`.
- Added `research_gsure/02_audits/STAGE29_INNER_OOF_QC_LABEL_SCHEDULE.md`.
- Linked the schedule from QC baseline requirements, OOF prediction contract,
  readiness checklist, and roadmap.

### Result
- Primary schedule: for each outer LOCO fold, generate QC training labels from
  inner leave-one-consortium-out predictions over the outer train consortia.
- One B1 config/seed would require 4 outer B1 fits plus 12 inner B1 fits before
  Q1/Q2/Q3 training.
- Current outer OOF validator is explicitly marked insufficient for real
  inner-OOF QC label generation.

### Interpretation
- The project now has a leakage-safe route for QC baselines, but the compute
  burden is substantial.
- G-SURE method work should not begin until this schedule is either implemented
  or explicitly replaced by an approved weaker fallback.

### Insight tags
- ✅ SUCCESS: A major QC-label leakage path is now documented before code exists.
- ⚠️ RISK: Inner-OOF requires 12 additional segmentation fits per B1 config/seed.
- ⚠️ RISK: Two inner folds have only 381 training subjects; this may produce weak
  inner segmenters and noisy QC labels.
- 💡 INSIGHT: The future validator must distinguish outer OOF predictions from
  inner-OOF QC-label-source predictions.
- 🧪 NEXT: After official split and B1 viability, design the inner-OOF validator
  before generating real QC labels.
- 🔁 DO NOT REPEAT: Do not train QC baselines from in-sample B1 errors.

### Evidence
- Files:
  - `research_gsure/01_protocol/INNER_OOF_QC_LABEL_SCHEDULE_DRAFT.md`
  - `research_gsure/02_audits/STAGE29_INNER_OOF_QC_LABEL_SCHEDULE.md`
  - `research_gsure/03_baselines/UNCERTAINTY_QC_BASELINE_REQUIREMENTS.md`
  - `research_gsure/01_protocol/OOF_PREDICTION_RELIABILITY_CONTRACT.md`
  - `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
  - `research_gsure/ROADMAP.md`
- Commands:
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `rg -n "INNER_OOF_QC_LABEL_SCHEDULE|inner-OOF|outer_heldout_dataset|inner_heldout_dataset|inner_train_datasets|16|12 inner" research_gsure SCRATCHPAD.md`
  - `git diff --check`

### Remaining uncertainty
- Official split is absent.
- No B1 predictions exist.
- No inner-OOF validator exists.
- No compute budget has been approved.

### Next recommended action
- Validate the documentation links and keep split/GPU gated.

## 2026-06-23 — Inner-OOF manifest validator

### Task
- Add a metadata-only validator for future inner-OOF prediction manifests.

### Research question
- Can obvious QC-label leakage cases be blocked before inner-OOF predictions are
  used to train DeVries/QCResUNet-style baselines?

### What I inspected
- `research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py`
- `research_gsure/01_protocol/INNER_OOF_QC_LABEL_SCHEDULE_DRAFT.md`
- `research_gsure/01_protocol/OOF_PREDICTION_RELIABILITY_CONTRACT.md`
- `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`

### Decision / action
- Added `research_gsure/02_audits/scripts/validate_inner_oof_prediction_manifest.py`.
- Added `research_gsure/02_audits/STAGE30_INNER_OOF_VALIDATOR.md`.
- Linked the validator from the inner-OOF schedule, OOF contract, readiness
  checklist, and pre-split readiness preflight.

### Result
- `py_compile` passed.
- Inner-OOF validator synthetic self-test passed.
- Invalid synthetic row triggered expected leakage/provenance errors.
- Pre-split readiness passed with the new validator included.
- `git diff --check` passed.

### Interpretation
- The validator enforces `outer_role=train`, `inner_role=test`,
  `dataset == inner_heldout_dataset`, `dataset != outer_heldout_dataset`, and
  strict `inner_train_datasets` exclusion.
- It is synthetic-only for now because no official split or inner-OOF
  predictions exist.

### Insight tags
- ✅ SUCCESS: Inner-OOF QC-label provenance now has an executable schema guard.
- ⚠️ RISK: Artifact-level probability-map validation is still separate.
- ⚠️ RISK: The validator does not reduce the 12-inner-fit compute burden.
- 🧪 NEXT: Run py_compile, synthetic self-test, and pre-split readiness.
- 🔁 DO NOT REPEAT: Do not use the outer OOF validator alone for inner-OOF QC
  label sources.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/validate_inner_oof_prediction_manifest.py`
  - `research_gsure/02_audits/STAGE30_INNER_OOF_VALIDATOR.md`
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `research_gsure/01_protocol/INNER_OOF_QC_LABEL_SCHEDULE_DRAFT.md`
  - `research_gsure/01_protocol/OOF_PREDICTION_RELIABILITY_CONTRACT.md`
  - `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/validate_inner_oof_prediction_manifest.py research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `python research_gsure/02_audits/scripts/validate_inner_oof_prediction_manifest.py --synthetic-self-test`
  - `python research_gsure/02_audits/scripts/validate_inner_oof_prediction_manifest.py --print-schema`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `rg -n "validate_inner_oof_prediction_manifest|inner-OOF prediction validator|outer_role == train|inner_role == test|inner_train_datasets" research_gsure SCRATCHPAD.md`
  - `git diff --check`

### Remaining uncertainty
- No official split exists.
- No real prediction manifest exists.
- No inner-OOF artifact validator extension has been run on real outputs.

### Next recommended action
- Validate the new script and keep split/GPU gated.

## 2026-06-23 — Reliability metric contract

### Task
- Define the metric contract for G-SURE reliability/error-localization results.

### Research question
- What metrics must a method satisfy before we can say it improves visual
  grounding or reliability beyond Dice-only segmentation?

### What I inspected
- `research_gsure/01_protocol/GSURE_PROTOCOL_DRAFT.md`
- `research_gsure/03_baselines/BASELINE_CONTRACT.md`
- `research_gsure/03_baselines/UNCERTAINTY_QC_BASELINE_REQUIREMENTS.md`
- `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
- `research_gsure/05_reports/REPORT_TEMPLATE.md`

### Decision / action
- Added `research_gsure/01_protocol/RELIABILITY_METRIC_CONTRACT.md`.
- Added `research_gsure/02_audits/STAGE31_RELIABILITY_METRIC_CONTRACT.md`.
- Linked the metric contract from protocol, baseline, QC baseline, readiness,
  and report-template docs.
- Updated report template to separate ERR, FP, FN, top-k capture, calibration,
  and QU-BraTS-style filtering.

### Result
- Pre-split readiness passed.
- Metric contract links and required metric names were found by `rg`.
- `git diff --check` passed.

### Interpretation
- A future G-SURE result cannot rely on Dice, aggregate ERR AUROC, or visual
  examples alone.
- FP/FN separation, top-k review budget, reliability calibration, and
  consortium-stratified reporting are now mandatory.

### Insight tags
- ✅ SUCCESS: Metric success criteria are stricter and less gameable.
- ⚠️ RISK: These metrics require validated full-volume OOF predictions and
  reliability labels, which do not exist yet.
- 💡 INSIGHT: A method that only highlights boundaries should fail FP/FN
  separated metrics even if aggregate ERR looks acceptable.
- 🧪 NEXT: Run pre-split readiness and doc-link validation.
- 🔁 DO NOT REPEAT: Do not claim reliability improvement from pooled ERR-only
  metrics or qualitative maps.

### Evidence
- Files:
  - `research_gsure/01_protocol/RELIABILITY_METRIC_CONTRACT.md`
  - `research_gsure/02_audits/STAGE31_RELIABILITY_METRIC_CONTRACT.md`
  - `research_gsure/01_protocol/GSURE_PROTOCOL_DRAFT.md`
  - `research_gsure/03_baselines/BASELINE_CONTRACT.md`
  - `research_gsure/03_baselines/UNCERTAINTY_QC_BASELINE_REQUIREMENTS.md`
  - `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
  - `research_gsure/05_reports/REPORT_TEMPLATE.md`
- Commands:
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `rg -n "RELIABILITY_METRIC_CONTRACT|top-k|QU-BraTS|FP AUPRC|FN AUPRC|calibration|filtered-TP|filtered-TN" research_gsure SCRATCHPAD.md`
  - `git diff --check`

### Remaining uncertainty
- No official split exists.
- No real predictions, reliability labels, or metric implementations exist.

### Next recommended action
- Validate documentation consistency and keep split/GPU gated.

## 2026-06-23 — Reliability metric harness

### Task
- Add an executable metric harness for G-SURE reliability/error-localization
  reporting.

### Research question
- Can future OOF segmentation predictions be evaluated for error localization,
  calibration, and segmentation failure detection without relying on qualitative
  maps or aggregate Dice alone?

### What I inspected
- `research_gsure/02_audits/scripts/generate_reliability_labels.py`
- `research_gsure/02_audits/scripts/validate_reliability_label_manifest.py`
- `research_gsure/02_audits/scripts/validate_prediction_artifacts.py`
- `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- `research_gsure/01_protocol/RELIABILITY_METRIC_CONTRACT.md`
- `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
- `research_gsure/05_reports/REPORT_TEMPLATE.md`

### Decision / action
- Added `compute_reliability_metrics.py`.
- Connected its synthetic self-test to pre-split readiness.
- Linked the metric implementation from the metric contract, checklist, report
  template, and a Stage 32 audit note.

### Result
- `py_compile` passed.
- Metric harness synthetic self-test passed.
- Pre-split readiness passed with the metric self-test included.
- Link/keyword check found the metric harness and required metric terms.
- `git diff --check` passed.

### Interpretation
- The evaluation path is now structurally complete through:
  OOF prediction manifest -> artifact validation -> reliability labels ->
  label validation -> reliability metric computation.
- Real metrics remain blocked until official split, OOF predictions, and
  reliability labels exist.

### Insight tags
- ✅ SUCCESS: The research goal is now less likely to collapse into Dice-only
  segmentation.
- ⚠️ RISK: `soft_error_map_path` is oracle diagnostic only and must not be
  treated as a model reliability map.
- ⚠️ RISK: Voxel-level pooled metrics require sampling to avoid memory-heavy
  full-cohort concatenation.
- 🧪 NEXT: Run py_compile, synthetic metric self-test, pre-split readiness, and
  diff checks.
- 🔁 DO NOT REPEAT: Do not report pooled ERR-only metrics without FP/FN,
  top-k, calibration, and consortium-stratified summaries.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/compute_reliability_metrics.py`
  - `research_gsure/02_audits/STAGE32_RELIABILITY_METRIC_HARNESS.md`
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `research_gsure/01_protocol/RELIABILITY_METRIC_CONTRACT.md`
  - `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
  - `research_gsure/05_reports/REPORT_TEMPLATE.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/compute_reliability_metrics.py research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `python research_gsure/02_audits/scripts/compute_reliability_metrics.py --synthetic-self-test`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `rg -n "compute_reliability_metrics|reliability metric harness|ERR AUROC|top-k|QU-BraTS|soft_error_map_path" research_gsure SCRATCHPAD.md`
  - `git diff --check`
- Metrics:
  - Synthetic metric rows: 1
  - Pre-split readiness: PASS
- Logs:
  - Official split artifacts remain absent.

### Remaining uncertainty
- No official split exists.
- No real OOF predictions exist.
- No real reliability labels or metric outputs exist.

### Next recommended action
- Validate the harness and keep official split/GPU gated.

## 2026-06-23 — Pre-split gate re-audit

### Task
- Re-audit the current G-SURE state immediately before the official LOCO split
  approval gate.

### Research question
- Are we genuinely ready to create the official subject-level LOCO split, and
  have we avoided accidentally crossing the split/GPU/prediction gates?

### What I inspected
- `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`
- `research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md`
- `research_gsure/02_audits/scripts/build_loco_split_manifest.py`
- `research_gsure/02_audits/scripts/check_official_split_artifacts.py`
- Current `research_gsure` file tree

### Decision / action
- Ran the consolidated pre-split readiness preflight.
- Confirmed official split artifacts are absent.
- Ran the split builder in dry-run mode only.
- Previewed the post-split validation sequence only.
- Added `research_gsure/02_audits/STAGE33_PRE_SPLIT_GATE_AUDIT.md`.

### Result
- Pre-split readiness: PASS.
- Official split artifact absent check: PASS.
- Split builder dry-run: 1,614 subject rows, 6,456 split rows, 4 folds,
  validation ok.
- Post-split validation preview: no split creation, no GPU, no official writes.

### Interpretation
- The workspace is ready to request the official LOCO split approval.
- It is not yet ready for GPU training, real OOF prediction generation,
  reliability labels, metric reporting, or method claims.

### Insight tags
- ✅ SUCCESS: The next gate is explicit and narrow: official LOCO split creation.
- ⚠️ RISK: Running `--write` without Min's exact approval would violate the
  research guardrails.
- ⚠️ RISK: GPU remains a separate later gate even after the split exists.
- 🧪 NEXT: If Min approves with the exact wording, run split creation and then
  the post-split validation runner.
- 🔁 DO NOT REPEAT: Do not jump from pre-split PASS directly to training.

### Evidence
- Files:
  - `research_gsure/02_audits/STAGE33_PRE_SPLIT_GATE_AUDIT.md`
  - `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`
  - `research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md`
- Commands:
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `python research_gsure/02_audits/scripts/check_official_split_artifacts.py --expect-missing`
  - `python research_gsure/02_audits/scripts/build_loco_split_manifest.py`
  - `python research_gsure/02_audits/scripts/run_post_split_validation.py --preview`
- Metrics:
  - Draft subject cohort rows: 1,614
  - Dry-run split rows: 6,456
  - LOCO folds: 4
- Logs:
  - Official split artifacts remain absent.

### Remaining uncertainty
- Official split has not been created.
- Post-split loader smoke has not run because the official split manifest is
  absent.
- No real OOF predictions, reliability labels, metric outputs, or GPU results
  exist.

### Next recommended action
- Ask Min for exact official split approval wording before running `--write`.

## 2026-06-23 — Direction contamination check

### Task
- Check whether stale research directions or previous failed experiment
  language are contaminating the active G-SURE workspace.

### Research question
- Is the current workspace still aligned with segmentation reliability and
  visual grounding, rather than older IDH/VLM/exp-style directions?

### What I inspected
- Root files: `AGENTS.md`, `CLAUDE.md`, `SCRATCHPAD.md`
- `research_gsure/README.md`
- `research_gsure/ROADMAP.md`
- Targeted keyword search for stale terms:
  `IDH`, `CTEC`, `exp02`, `Res3D`, `age-only`, `brain-age`, `VLM`, `MLLM`,
  `JEPA`, `PET`

### Decision / action
- Did not edit or delete `CLAUDE.md`; it is an untracked generic research
  posture note and should not be treated as project evidence.
- Updated `research_gsure/README.md` and `research_gsure/ROADMAP.md` so the
  current stage reflects the official split gate, synthetic-ready reliability
  label/metric tooling, and absence of real outputs.

### Result
- No active `research_gsure` documents contained stale IDH/CTEC/exp02/Res3D
  direction terms.
- Hits for `VLM`, `MLLM`, `JEPA`, and `PET` were in `AGENTS.md` guardrails,
  not in the G-SURE research plan.
- Hits for `image-only` and clinical metadata were expected G-SURE baseline
  policy text, not stale VLM/IDH direction.

### Interpretation
- Current research state is aligned with G-SURE.
- The next gate remains official LOCO split approval; not GPU or method work.

### Insight tags
- ✅ SUCCESS: No stale IDH/VLM experiment direction was found in active
  `research_gsure` planning docs.
- ⚠️ RISK: Root `CLAUDE.md` exists but is not the authoritative project
  evidence; use `AGENTS.md`, `SCRATCHPAD.md`, and `research_gsure/` artifacts.
- 🧪 NEXT: Re-run readiness and diff checks after the README/ROADMAP update.
- 🔁 DO NOT REPEAT: Do not use old external notes as evidence for G-SURE unless
  revalidated in this workspace.

### Evidence
- Files:
  - `research_gsure/README.md`
  - `research_gsure/ROADMAP.md`
  - `SCRATCHPAD.md`
- Commands:
  - `rg -n "IDH|CTEC|exp02|Res3D|age-only|brain-age|VLM|MLLM|JEPA|PET" research_gsure SCRATCHPAD.md CLAUDE.md AGENTS.md`
- Metrics:
  - Active stale direction hits in `research_gsure`: 0 for IDH/CTEC/exp02/Res3D
- Logs:
  - Official split remains absent.

### Remaining uncertainty
- `CLAUDE.md` is untracked and generic; it was not modified.
- Official split and real experiments remain uncreated.

### Next recommended action
- Validate the updated docs and keep the split gate explicit.

## 2026-06-23 — B1 GPU preview command template

### Task
- Prepare the first B1 GPU preview approval template without running GPU or
  creating official split artifacts.

### Research question
- After official split validation, can the first GPU request be constrained to a
  feasibility preview rather than accidentally becoming an unreviewed training
  or performance experiment?

### What I inspected
- `research_gsure/03_baselines/SEGMENTATION_BASELINE_PROTOCOL.md`
- `research_gsure/03_baselines/GPU_PREVIEW_CONTRACT.md`
- `research_gsure/03_baselines/BASELINE_CONTRACT.md`
- `research_gsure/01_protocol/OOF_PREDICTION_RELIABILITY_CONTRACT.md`
- `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`

### Decision / action
- Added `research_gsure/03_baselines/B1_GPU_PREVIEW_COMMAND_TEMPLATE.md`.
- Linked the template from the GPU preview contract, B1 segmentation baseline
  protocol, baseline contract, and readiness checklist.

### Result
- Pre-split readiness passed.
- Template link/keyword search found the new command template in baseline
  protocol, GPU preview contract, baseline contract, readiness checklist, and
  scratchpad.
- `git diff --check` passed.
- Official split manifest remains absent.

### Interpretation
- The first GPU action remains a future approval-gated feasibility preview.
- The template explicitly separates allowed preview outputs from disallowed OOF
  predictions, reliability labels, metrics, full checkpoints, and publication
  tables.

### Insight tags
- ✅ SUCCESS: The next GPU request now has a constrained packet format.
- ⚠️ RISK: Filling this template still requires official split and post-split
  CPU validation first.
- ⚠️ RISK: A preview that selects patch size by held-out Dice would invalidate
  the intended gate.
- 🧪 NEXT: Run readiness and doc-link validation.
- 🔁 DO NOT REPEAT: Do not let the GPU preview become a training result.

### Evidence
- Files:
  - `research_gsure/03_baselines/B1_GPU_PREVIEW_COMMAND_TEMPLATE.md`
  - `research_gsure/03_baselines/GPU_PREVIEW_CONTRACT.md`
  - `research_gsure/03_baselines/SEGMENTATION_BASELINE_PROTOCOL.md`
  - `research_gsure/03_baselines/BASELINE_CONTRACT.md`
  - `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
- Commands:
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `rg -n "B1_GPU_PREVIEW_COMMAND_TEMPLATE|B1 GPU preview|disallowed outputs|Do not choose the preview candidate using held-out Dice|No GPU preview command is approved" research_gsure SCRATCHPAD.md`
  - `git diff --check`
  - `test -e research_gsure/02_audits/outputs/loco_split_manifest.csv; echo $?`
- Metrics:
  - Pre-split readiness: PASS
  - Official split manifest existence check: absent
- Logs:
  - No GPU command was executed.

### Remaining uncertainty
- Official split has not been created.
- No post-split loader smoke has run.
- No GPU command has been previewed or approved.

### Next recommended action
- Validate the template links and keep the official split gate first.

## 2026-06-23 — Split lesion-burden audit hardening

### Task
- Strengthen official split audit evidence before split creation.

### Research question
- Will the future official LOCO split artifact prove fold-level lesion burden
  distribution, not only subject counts and leakage isolation?

### What I inspected
- `research_gsure/02_audits/scripts/build_loco_split_manifest.py`
- `research_gsure/02_audits/scripts/check_official_split_artifacts.py`
- `research_gsure/02_audits/outputs/subject_level_cohort_manifest_draft.csv`
- `research_gsure/02_audits/STAGE25_OFFICIAL_SPLIT_ARTIFACT_CHECKER.md`
- `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`

### Decision / action
- Added train/test lesion-burden min/median/max fields to the future official
  split summary.
- Updated the official split artifact checker to recompute those fields from the
  manifest and reject mismatches.
- Updated docs/checklist to record that lesion-burden summary validation is part
  of the split gate.

### Result
- `py_compile` passed.
- Split builder dry-run passed without writing official split artifacts.
- Official split absent check passed.
- Pre-split readiness passed.
- In-memory summary check confirmed new lesion-burden fields are populated.
- In-memory official split checker validation passed with recomputed
  lesion-burden summary values.
- `git diff --check` passed.

### Interpretation
- This closes a real evidence gap: the readiness checklist required
  lesion-volume distribution by fold, but the official split checker previously
  verified only counts, leakage, duplicates, and missing paths.

### Insight tags
- ✅ SUCCESS: Future split artifacts will carry lesion-burden distribution
  evidence.
- ⚠️ RISK: Lesion burden imbalance may still exist; this only makes it visible
  and checkable.
- 🧪 NEXT: Run py_compile, split dry-run, absent split check, pre-split
  readiness, and diff checks.
- 🔁 DO NOT REPEAT: Do not treat subject counts alone as proof of a balanced or
  interpretable split.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/build_loco_split_manifest.py`
  - `research_gsure/02_audits/scripts/check_official_split_artifacts.py`
  - `research_gsure/02_audits/STAGE25_OFFICIAL_SPLIT_ARTIFACT_CHECKER.md`
  - `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/build_loco_split_manifest.py research_gsure/02_audits/scripts/check_official_split_artifacts.py`
  - `python research_gsure/02_audits/scripts/build_loco_split_manifest.py`
  - `python research_gsure/02_audits/scripts/check_official_split_artifacts.py --expect-missing`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - in-memory split summary field check
  - in-memory official split checker validation
  - `rg -n "lesion-burden|lesion burden|mask_nonzero_fraction_median|Lesion Burden Distribution|Split lesion-burden audit" research_gsure SCRATCHPAD.md`
  - `git diff --check`
- Metrics:
  - Dry-run subject rows: 1,614
  - Dry-run split rows: 6,456
  - Dry-run fold rows: 4
  - Test/train median mask fraction by heldout:
    - MU-Glioma-Post: 0.0076631944 / 0.0073662634
    - UCSD-PTGBM: 0.0037783086 / 0.00816929885
    - UPENN-GBM: 0.008578069 / 0.0063692876
    - UTSW: 0.00783551745 / 0.00706810035
- Logs:
  - Official split artifacts remain absent.

### Remaining uncertainty
- Official split has not been created.
- Lesion-burden summary validation has not yet run on real official split
  artifacts.

### Next recommended action
- Validate the dry-run and keep official split creation gated.

## 2026-06-23 — Split checker dry-run self-test

### Task
- Promote the manual in-memory split checker validation into a reproducible
  preflight self-test.

### Research question
- Does the official split checker actually validate lesion-burden summary
  fields, and can it detect a corrupted lesion-burden summary before official
  split creation?

### What I inspected
- `research_gsure/02_audits/scripts/check_official_split_artifacts.py`
- `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- `research_gsure/02_audits/scripts/build_loco_split_manifest.py`
- `research_gsure/02_audits/STAGE25_OFFICIAL_SPLIT_ARTIFACT_CHECKER.md`

### Decision / action
- Added `--dry-run-self-test` to
  `check_official_split_artifacts.py`.
- The self-test builds split rows and summaries in memory from the draft subject
  manifest, validates the positive path, then corrupts
  `test_mask_nonzero_fraction_median` as a negative control.
- Added the self-test to `check_pre_split_readiness.py`.

### Result
- `py_compile` passed.
- `check_official_split_artifacts.py --dry-run-self-test` passed.
- The dry-run self-test generated 6,456 split rows and 4 fold summaries in
  memory.
- The lesion-burden positive path validated.
- The negative control detected the corrupted
  `test_mask_nonzero_fraction_median` value.
- `check_pre_split_readiness.py` passed with the new self-test included.
- Official split artifacts remain absent.
- `git diff --check` passed.

### Interpretation
- The lesion-burden summary check is now part of the standard pre-split
  readiness path, not just a one-off manual validation.

### Insight tags
- ✅ SUCCESS: Future changes to split checker lesion-burden validation should be
  caught before official split creation.
- ⚠️ RISK: This still does not create or validate real official split files; it
  validates checker logic against in-memory generated rows.
- 🧪 NEXT: Run py_compile, dry-run self-test, pre-split readiness, and diff
  checks.
- 🔁 DO NOT REPEAT: Do not rely on undocumented manual in-memory checks for
  split validation.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/check_official_split_artifacts.py`
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `research_gsure/02_audits/STAGE25_OFFICIAL_SPLIT_ARTIFACT_CHECKER.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/check_official_split_artifacts.py research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `python research_gsure/02_audits/scripts/check_official_split_artifacts.py --dry-run-self-test`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `python research_gsure/02_audits/scripts/check_official_split_artifacts.py --expect-missing`
  - `rg -n "dry-run self-test|Lesion-burden negative control|official split checker dry-run self-test|test_mask_nonzero_fraction_median|Split checker dry-run self-test" research_gsure SCRATCHPAD.md`
  - `git diff --check`
- Metrics:
  - In-memory split rows: 6,456
  - In-memory fold summaries: 4
  - Official split artifacts written: 0
- Logs:
  - Pre-split readiness: PASS

### Remaining uncertainty
- Official split remains uncreated.
- Post-approval checker default mode still needs to run after approved split
  creation.

### Next recommended action
- Validate the new self-test and keep official split creation gated.

## 2026-06-23 — Approval packet refresh after lesion-burden self-test

### Task
- Refresh the official split approval materials to reflect the current
  lesion-burden split audit and checker dry-run self-test.

### Research question
- Does the official split approval packet show the evidence Min needs before
  approving the subject-level LOCO split?

### What I inspected
- `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`
- `research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md`
- Current split-builder summary fields generated in memory

### Decision / action
- Added fold-level median lesion fraction test/train values to the approval
  packet.
- Added the split checker `--dry-run-self-test` to the approval packet and
  post-approval runbook.
- Added lesion-burden summary validation to the post-approval validation
  requirements and stop rules.
- Added `research_gsure/02_audits/STAGE34_APPROVAL_PACKET_REFRESH.md`.

### Result
- Pre-split readiness passed.
- Link/keyword search found the dry-run self-test, lesion-burden summary
  validation, numeric UCSD lesion-burden risk, and Stage 34 note.
- `git diff --check` passed.
- Official split manifest remains absent.

### Interpretation
- The approval gate now presents more than subject counts. It exposes the UCSD
  lesion-burden difference before the split is approved.

### Insight tags
- ✅ SUCCESS: Approval packet now reflects current split audit logic.
- ⚠️ RISK: Numeric lesion-burden imbalance is disclosure/stratification
  evidence, not a fix for the imbalance.
- 🧪 NEXT: Run pre-split readiness, link search, and diff checks.
- 🔁 DO NOT REPEAT: Do not ask for split approval using stale evidence after
  audit logic changes.

### Evidence
- Files:
  - `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`
  - `research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md`
  - `research_gsure/02_audits/STAGE34_APPROVAL_PACKET_REFRESH.md`
- Commands:
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `rg -n "dry-run-self-test|median lesion fraction|lesion-burden summary|0\\.0037783086|STAGE34|Approval packet refresh" research_gsure SCRATCHPAD.md`
  - `git diff --check`
  - `test -e research_gsure/02_audits/outputs/loco_split_manifest.csv; echo $?`
- Metrics:
  - median lesion fraction test/train:
    - MU-Glioma-Post: 0.0076631944 / 0.0073662634
    - UCSD-PTGBM: 0.0037783086 / 0.00816929885
    - UPENN-GBM: 0.008578069 / 0.0063692876
    - UTSW: 0.00783551745 / 0.00706810035
- Logs:
  - Pre-split readiness: PASS
  - Official split artifact check remains absent.

### Remaining uncertainty
- Official split remains uncreated.
- Post-approval validation has not run because official split artifacts are
  absent.

### Next recommended action
- Validate the refreshed approval packet and keep split creation gated.

## 2026-06-23 — Preflight required-files hardening

### Task
- Strengthen pre-split readiness so it monitors all current core G-SURE
  protocol, baseline, reliability, QC, and approval-gate documents.

### Research question
- Could a critical pre-GPU contract document disappear without the preflight
  catching it?

### What I inspected
- `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- `research_gsure/01_protocol/`
- `research_gsure/03_baselines/`
- `research_gsure/02_audits/STAGE24_PRE_SPLIT_PREFLIGHT.md`

### Decision / action
- Added core `README.md` and `ROADMAP.md` to required files.
- Added missing protocol documents including split, target, subject-unit,
  post-split loader smoke, reliability metric, inner-OOF, and pre-experiment
  evidence docs.
- Added missing baseline/QC documents including `BASELINE_CONTRACT.md`,
  `B1_GPU_PREVIEW_COMMAND_TEMPLATE.md`, and
  `UNCERTAINTY_QC_BASELINE_REQUIREMENTS.md`.
- Updated `STAGE24_PRE_SPLIT_PREFLIGHT.md`.
- Added `STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`.

### Result
- `py_compile` passed.
- Pre-split readiness passed with the expanded required-file list.
- Link/keyword search found newly monitored B1 GPU preview, reliability metric,
  uncertainty/QC, and inner-OOF files.
- `git diff --check` passed.

### Interpretation
- The preflight now better reflects the actual research-preparation state,
  rather than only the earlier subset of documents.

### Insight tags
- ✅ SUCCESS: Critical pre-GPU documents are now harder to lose silently.
- ⚠️ RISK: File existence does not prove content correctness; separate
  validators and audits still matter.
- 🧪 NEXT: Run py_compile, pre-split readiness, link search, and diff checks.
- 🔁 DO NOT REPEAT: Do not rely on an outdated preflight after adding new gate
  documents.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `research_gsure/02_audits/STAGE24_PRE_SPLIT_PREFLIGHT.md`
  - `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `rg -n "B1_GPU_PREVIEW_COMMAND_TEMPLATE|UNCERTAINTY_QC_BASELINE_REQUIREMENTS|RELIABILITY_METRIC_CONTRACT|STAGE35|required-file|inner-OOF" research_gsure/02_audits/scripts/check_pre_split_readiness.py research_gsure/02_audits/STAGE24_PRE_SPLIT_PREFLIGHT.md research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md SCRATCHPAD.md`
  - `git diff --check`
- Metrics:
  - Pre-split readiness: PASS
- Logs:
  - Official split artifacts remain absent.

### Remaining uncertainty
- Official split remains uncreated.
- File existence checks do not validate every document's semantic content.

### Next recommended action
- Validate preflight and keep official split creation gated.

## 2026-06-23 — Stage49 runner overwrite forwarding aligned

### Task
- Align the consolidated post-split validation runner with the overwrite-safety
  behavior added to the underlying tile-audit scripts.

### Research question
- If the runner is explicitly invoked with `--allow-overwrite` after separate
  overwrite approval, will the child tile-budget and tile-grid audit commands
  receive that same overwrite intent?

### What I inspected
- `research_gsure/02_audits/scripts/run_post_split_validation.py`
- `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- `research_gsure/02_audits/STAGE26_POST_SPLIT_VALIDATION_RUNNER.md`
- `research_gsure/02_audits/STAGE38_POST_SPLIT_RUNNER_SELF_TEST.md`
- `research_gsure/02_audits/STAGE48_TILE_AUDIT_OVERWRITE_SAFETY.md`
- `research_gsure/02_audits/STAGE49_RUNNER_OVERWRITE_FLAG_FORWARDING.md`

### Decision / action
- Forwarded the runner-level `--allow-overwrite` flag to both tile-audit child
  scripts.
- Added a runner dry-run self-test check that default commands do not include
  `--allow-overwrite`, while explicit runner overwrite mode forwards it to both
  tile-audit steps.
- Added Stage49 to the preflight required-file list and recorded the behavior
  in the relevant Stage notes.

### Result
- `py_compile` passed.
- Runner dry-run self-test passed and printed
  `Allow-overwrite forwarding: verified`.
- Runner preview stayed non-executing and reported official split manifest
  absent.
- Pre-split readiness passed with Stage49 included.
- Evidence grep found Stage49 and overwrite-forwarding markers.
- `git diff --check` passed.
- Official split manifest remains absent.
- Validation-generated `__pycache__` was removed.

### Interpretation
- This is command-sequence hygiene for the future post-split validation gate.
  It is not overwrite approval, not official split creation, not GPU work, and
  not segmentation performance evidence.

### Insight tags
- ⚠️ RISK: Runner-level overwrite approval and child-script overwrite behavior
  can drift unless tested together.
- ✅ SUCCESS: The runner and child tile-audit overwrite behavior are now tested
  together.
- 🧪 NEXT: Keep official split creation gated on Min's exact approval phrase.
- 🔁 DO NOT REPEAT: Do not let wrapper flags imply behavior that child scripts
  do not actually receive.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/run_post_split_validation.py`
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `research_gsure/02_audits/STAGE49_RUNNER_OVERWRITE_FLAG_FORWARDING.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/run_post_split_validation.py research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `python research_gsure/02_audits/scripts/run_post_split_validation.py --dry-run-self-test`
  - `python research_gsure/02_audits/scripts/run_post_split_validation.py --preview`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `rg -n "Allow-overwrite forwarding: verified|STAGE49_RUNNER_OVERWRITE_FLAG_FORWARDING|allow-overwrite.*forward|Stage 30-49" research_gsure SCRATCHPAD.md`
  - `git diff --check`
  - `test -e research_gsure/02_audits/outputs/loco_split_manifest.csv; echo official_split_manifest_exists_exit=$?`
  - `find research_gsure -type d -name __pycache__ -print`
- Metrics:
  - Pre-split readiness: PASS
  - Draft subject cohort rows: 1614
  - Official split manifest existence exit: 1
- Logs:
  - Official split artifacts remain absent.

### Remaining uncertainty
- Official split remains uncreated.
- This validates gate behavior only, not segmentation performance or GPU
  feasibility.

### Next recommended action
- Keep official split creation gated on Min's exact approval phrase.

## 2026-06-23 — Approval scope mismatch fixed in readiness checklist

### Task
- Re-check whether the current G-SURE pre-split documents agree on the next
  approval gate.

### Research question
- Does the readiness checklist request the same approval scope as the official
  split approval packet?

### What I inspected
- `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`
- `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
- `research_gsure/ROADMAP.md`
- `research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md`

### Decision / action
- Found that the checklist's `Next Gate` mixed the official primary split
  approval with the later all-unit/sensitivity cohort path.
- Updated the checklist so the immediate official split approval matches the
  approval packet exactly:
  - primary cohort = `subject_level_cohort_manifest_draft.csv`
  - selection policy = `one_unit_per_subject_earliest_numeric_order`
  - target = `binary selected_mask > 0`
  - split policy = `Leave-One-Consortium-Out`
  - unit of split = `dataset::subject_id`
- Explicitly kept the all-unit/sensitivity cohort as a later analysis path, not
  part of the first official primary split approval.

### Result
- Pre-split readiness passed after the edit.
- Approval-scope grep found the aligned primary split fields in both the
  checklist and official approval packet.
- `git diff --check` passed.
- Official split manifest remains absent.

### Interpretation
- This reduces approval ambiguity before creating official split artifacts. It
  does not create the split, run GPU, or provide segmentation evidence.

### Insight tags
- ✅ SUCCESS: The immediate split approval scope is now consistent across the
  checklist and approval packet.
- ⚠️ RISK: The all-unit/sensitivity analysis still needs a separate future
  protocol before it is used.
- 🧪 NEXT: Keep the official primary split gated on Min's exact approval phrase.
- 🔁 DO NOT REPEAT: Do not bundle primary split creation and later sensitivity
  analysis under one ambiguous approval gate.

### Evidence
- Files:
  - `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
  - `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`
- Commands:
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `rg -n "Create the official primary LOCO split manifest|sensitivity cohort remains|primary cohort = subject_level_cohort_manifest_draft|target = binary selected_mask > 0|unit of split = dataset::subject_id" research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`
  - `git diff --check`
  - `test -e research_gsure/02_audits/outputs/loco_split_manifest.csv; echo official_split_manifest_exists_exit=$?`
- Metrics:
  - Pre-split readiness: PASS
  - Draft subject cohort rows: 1614
  - Official split manifest existence exit: 1

### Remaining uncertainty
- Official split remains uncreated.
- No model training or segmentation performance has been tested in this step.

### Next recommended action
- Await exact approval for official primary LOCO split creation, then run the
  post-approval split runbook.

## 2026-06-23 — Targeted 2024-2026 literature risk update

### Task
- Continue preparing the G-SURE research direction by reducing novelty and
  baseline-risk ambiguity before official split creation.

### Research question
- Do recent segmentation QC, uncertainty, and foundation-segmentation papers
  require additional baselines or a narrower G-SURE claim?

### What I inspected
- `research_gsure/00_context/20260623_gsure_literature_scout.md`
- `research_gsure/00_context/20260623_gsure_prior_work_matrix.md`
- `research_gsure/01_protocol/PRE_EXPERIMENT_EVIDENCE_MAP.md`
- `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
- `research_gsure/03_baselines/BASELINE_CONTRACT.md`
- `research_gsure/03_baselines/UNCERTAINTY_QC_BASELINE_REQUIREMENTS.md`
- Targeted web sources for 2024-2026 segmentation QC / uncertainty work.

### Decision / action
- Updated the literature scout and prior-work matrix with targeted 2024-2026
  risks:
  - QCResUNet is now a direct journal-level prior for brain-tumor segmentation
    QC with subject-level quality and voxel-level error maps.
  - MICCAI 2025 image-specific segmentation QC weakens any fixed global
    Dice-threshold-only failure framing.
  - U-MedSAM and prompt-triggered SAM uncertainty make foundation-segmentation
    uncertainty an unsafe novelty claim by itself.
  - A 2026 visual-foundation-model aleatoric uncertainty preprint makes
    sample-difficulty/noisy-label/adaptive-weighting claims insufficient alone.
- Added lesion-size, predicted-volume, and image-difficulty proxy baselines to
  the required baseline order before G-SURE method work.
- Clarified that GT lesion size is oracle diagnostic only; deployable QC
  baselines may use predicted volume and image-derived features.

### Result
- Pre-split readiness passed after the document updates.
- Grep evidence found targeted-update and proxy-baseline markers across context,
  protocol, and baseline documents.
- `git diff --check` passed.
- Official split manifest remains absent.

### Interpretation
- G-SURE is still a plausible direction, but the defensible claim must be
  narrower than "segmentation uncertainty" or "medical foundation segmentation
  reliability." The method can only be justified after it beats uncertainty,
  QCResUNet-style, and simple difficulty/volume proxy controls under LOCO.

### Insight tags
- ✅ SUCCESS: Recent prior work now directly strengthens the baseline contract.
- ⚠️ RISK: Full systematic related-work review is still incomplete.
- 💡 INSIGHT: The strongest reviewer attack is now not only QCResUNet; it is
  also that image difficulty, lesion size, or predicted volume may explain the
  reliability signal without G-SURE.
- 🧪 NEXT: Keep official split gated; after split validation, first compute
  simple proxy controls from B1 predictions before method work.
- 🔁 DO NOT REPEAT: Do not frame G-SURE as first uncertainty map, first QC, or
  foundation-model reliability without beating the obvious baselines.

### Evidence
- Files:
  - `research_gsure/00_context/20260623_gsure_literature_scout.md`
  - `research_gsure/00_context/20260623_gsure_prior_work_matrix.md`
  - `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
  - `research_gsure/01_protocol/PRE_EXPERIMENT_EVIDENCE_MAP.md`
  - `research_gsure/03_baselines/BASELINE_CONTRACT.md`
  - `research_gsure/03_baselines/UNCERTAINTY_QC_BASELINE_REQUIREMENTS.md`
- Commands:
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `rg -n "TARGETED 2024-2026|2024-2026 UPDATE|image-specific segmentation QC|image-difficulty|predicted-volume|predicted volume|difficulty proxy|foundation-model data uncertainty|QCResUNet.*2025" research_gsure/00_context research_gsure/01_protocol research_gsure/03_baselines`
  - `git diff --check`
  - `test -e research_gsure/02_audits/outputs/loco_split_manifest.csv; echo official_split_manifest_exists_exit=$?`
- Metrics:
  - Pre-split readiness: PASS
  - Draft subject cohort rows: 1614
  - Official split manifest existence exit: 1
- Sources:
  - https://pubmed.ncbi.nlm.nih.gov/40945175/
  - https://arxiv.org/html/2412.07156v2
  - https://papers.miccai.org/miccai-2025/0232-Paper4042.html
  - https://arxiv.org/html/2408.08881v2
  - https://openaccess.thecvf.com/content/ICCV2025W/CVAMD/papers/Zhang_Enhancing_the_Reliability_of_Auto-Prompting_SAM_for_Medical_Image_Segmentation_ICCVW_2025_paper.pdf
  - https://arxiv.org/html/2604.10963v1

### Remaining uncertainty
- This is a targeted update, not a systematic review.
- No model training or real segmentation/reliability result exists yet.

### Next recommended action
- Keep official LOCO split creation gated on exact approval; after approval,
  run the post-split validation runner before any GPU preview.

## 2026-06-23 — Stage50 context evidence added to preflight coverage

### Task
- Continue G-SURE preparation by ensuring the research premise and
  novelty/baseline context files are protected by the pre-split readiness gate.

### Research question
- Can the workspace lose the data premise, literature scout, or prior-work
  matrix while `check_pre_split_readiness.py` still passes?

### What I inspected
- `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- `research_gsure/00_context/DATA_PREMISE.md`
- `research_gsure/00_context/20260623_gsure_literature_scout.md`
- `research_gsure/00_context/20260623_gsure_prior_work_matrix.md`
- `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`

### Decision / action
- Found that the three `00_context` evidence files were missing from the
  preflight required-file list.
- Added them to `REQUIRED_FILES`.
- Added `STAGE50_CONTEXT_EVIDENCE_PREFLIGHT_COVERAGE.md`.
- Updated Stage35 so it records context evidence and Stage 30-50 audit-note
  coverage.

### Result
- `py_compile` passed.
- Pre-split readiness passed after the coverage update.
- Grep evidence confirmed the context files and Stage50 note are now required.
- Official split artifacts remain absent.

### Interpretation
- The gate now protects the files that explain why G-SURE is the current
  direction and why uncertainty/QC/proxy baselines are mandatory. This is gate
  integrity only, not segmentation performance evidence.

### Insight tags
- ✅ SUCCESS: Research premise and prior-work defense files are now monitored by
  preflight.
- ⚠️ RISK: Required-file coverage checks existence, not full semantic quality.
- 🧪 NEXT: Keep official split gated; after approval, run post-split validation
  before any GPU preview.
- 🔁 DO NOT REPEAT: Do not let the novelty/baseline defense live outside the
  readiness gate.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`
  - `research_gsure/02_audits/STAGE50_CONTEXT_EVIDENCE_PREFLIGHT_COVERAGE.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `rg -n "00_context/DATA_PREMISE|20260623_gsure_literature_scout|20260623_gsure_prior_work_matrix|STAGE50_CONTEXT_EVIDENCE_PREFLIGHT_COVERAGE|Stage 30-50" research_gsure/02_audits/scripts/check_pre_split_readiness.py research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md research_gsure/02_audits/STAGE50_CONTEXT_EVIDENCE_PREFLIGHT_COVERAGE.md`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- Metrics:
  - Pre-split readiness: PASS
  - Draft subject cohort rows: 1614

### Remaining uncertainty
- Official split remains uncreated.
- No segmentation baseline or reliability result exists yet.

### Next recommended action
- Await exact approval for official primary LOCO split creation.

## 2026-06-23 — Stage60 output evidence coverage self-test added

### Task
- Continue G-SURE preparation by adding a negative-control self-test for
  pre-split output artifact required-file coverage.

### Research question
- Can preflight prove that it rejects an existing audit output artifact that is
  missing from `REQUIRED_FILES`?

### What I inspected
- `research_gsure/02_audits/outputs/*`
- `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`
- `research_gsure/02_audits/STAGE59_PRE_SPLIT_OUTPUT_EVIDENCE_COVERAGE.md`

### Decision / action
- Added `--output-evidence-coverage-self-test` to
  `check_pre_split_readiness.py`.
- Split pre-split output coverage into:
  - current output path discovery excluding forbidden official split artifacts,
  - pure coverage validation,
  - negative-control self-test.
- The self-test removes one output artifact from an in-memory required-file list
  and verifies that the missing output is rejected.
- Full preflight now runs this self-test as part of command checks.
- Added `STAGE60_OUTPUT_EVIDENCE_COVERAGE_SELF_TEST.md`.
- Updated Stage35 to record Stage 2-60 and output evidence coverage self-test.

### Result
- `py_compile` passed.
- `--output-evidence-coverage-self-test` passed.
- Pre-split output artifacts covered: 39.
- Removed-output negative control was rejected.
- Output coverage check reported `missing_output_files=0`.
- `--stage-audit-coverage-self-test` passed.
- `--document-invariant-self-test` passed.
- Full pre-split readiness passed and includes `[OK] output evidence coverage
  self-test`.
- Official split artifacts remain absent.

### Interpretation
- Output evidence coverage now has its own failure-mode test. This reduces the
  chance that future edits silently drop audit artifacts from the readiness
  gate.

### Insight tags
- ✅ SUCCESS: Pre-split output evidence coverage is now negative-control tested.
- ⚠️ RISK: This still checks existence, not full semantic correctness of every
  output artifact.
- 🧪 NEXT: Keep official split gated; after exact approval, run the
  post-approval split runbook.
- 🔁 DO NOT REPEAT: Do not add output coverage checks without a failure-mode
  self-test.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`
  - `research_gsure/02_audits/STAGE60_OUTPUT_EVIDENCE_COVERAGE_SELF_TEST.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py --output-evidence-coverage-self-test`
  - `rg -n "Output evidence coverage self-test|--output-evidence-coverage-self-test|Removed-output negative control|STAGE60_OUTPUT_EVIDENCE_COVERAGE_SELF_TEST|Stage 2-60" research_gsure/02_audits/scripts/check_pre_split_readiness.py research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md research_gsure/02_audits/STAGE60_OUTPUT_EVIDENCE_COVERAGE_SELF_TEST.md`
  - `python - <<'PY' ... output coverage ...`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py --stage-audit-coverage-self-test`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py --document-invariant-self-test`
  - `python - <<'PY' ... Stage coverage ...`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- Metrics:
  - Pre-split output artifacts covered: 39
  - Missing output required-file entries: 0
  - Stage audit notes covered: 61
  - Missing Stage required-file entries: 0
  - Pre-split readiness: PASS
  - Draft subject cohort rows: 1614

### Remaining uncertainty
- Official split remains uncreated.
- No segmentation, prediction, or reliability performance evidence exists yet.

### Next recommended action
- Await exact approval for official primary LOCO split creation.

## 2026-06-23 — Stage59 pre-split output evidence coverage

### Task
- Continue G-SURE preparation by checking whether current pre-split audit output
  artifacts are protected by the readiness required-file gate.

### Research question
- Can a mask/path/geometry/cohort/tile audit output disappear while
  `check_pre_split_readiness.py` still passes?

### What I inspected
- `research_gsure/02_audits/outputs/*`
- `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`

### Decision / action
- Found that only 4 of 39 current output artifacts were included in
  `REQUIRED_FILES`.
- Added current pre-split evidence outputs to `REQUIRED_FILES`, including:
  - mask path inventory and summaries,
  - mask value/geometry audit outputs,
  - target mapping policy review outputs,
  - candidate and subject-level cohort outputs,
  - unit selection review,
  - LOCO readiness outputs,
  - loader transform feasibility outputs,
  - sliding-window coverage outputs,
  - tile-budget and tile-grid dry-run outputs,
  - patch memory proxy outputs.
- Kept official split outputs forbidden and out of `REQUIRED_FILES`.
- Added `STAGE59_PRE_SPLIT_OUTPUT_EVIDENCE_COVERAGE.md`.
- Updated Stage35 to record pre-split output artifact coverage.

### Result
- `py_compile` passed.
- Output coverage check reported:
  - `total_output_files=39`
  - `missing_output_files=0`
- Stage coverage check reported:
  - `total_stage_files=60`
  - `missing_stage_files=0`
- `--document-invariant-self-test` passed.
- `--stage-audit-coverage-self-test` passed.
- Full pre-split readiness passed.
- Official split artifacts remain absent.

### Interpretation
- The current pre-split evidence trail now protects both Stage documents and the
  output artifacts those documents summarize. This reduces the risk that
  approval proceeds from prose without the underlying audit evidence.

### Insight tags
- ✅ SUCCESS: Current pre-split output evidence artifacts are now covered by
  preflight.
- ⚠️ RISK: Required-file coverage checks existence, not semantic correctness of
  every output file.
- 🧪 NEXT: Keep official split gated; after exact approval, run the
  post-approval split runbook.
- 🔁 DO NOT REPEAT: Do not protect audit prose while leaving the underlying
  evidence artifacts unguarded.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`
  - `research_gsure/02_audits/STAGE59_PRE_SPLIT_OUTPUT_EVIDENCE_COVERAGE.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `python - <<'PY' ... output coverage ...`
  - `python - <<'PY' ... Stage coverage ...`
  - `rg -n "candidate_cohort_manifest_draft|mask_path_inventory|mask_value_geometry_audit|sliding_window_tile_budget_subject_level|STAGE59_PRE_SPLIT_OUTPUT_EVIDENCE_COVERAGE|pre-split audit output artifacts" research_gsure/02_audits/scripts/check_pre_split_readiness.py research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md research_gsure/02_audits/STAGE59_PRE_SPLIT_OUTPUT_EVIDENCE_COVERAGE.md`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py --document-invariant-self-test`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py --stage-audit-coverage-self-test`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- Metrics:
  - Output files: 39
  - Missing output required-file entries: 0
  - Stage files: 60
  - Missing Stage required-file entries: 0
  - Pre-split readiness: PASS
  - Draft subject cohort rows: 1614

### Remaining uncertainty
- Official split remains uncreated.
- No segmentation, prediction, or reliability performance evidence exists yet.

### Next recommended action
- Await exact approval for official primary LOCO split creation.

## 2026-06-23 — Stage58 post-approval runbook preflight scope synced

### Task
- Continue G-SURE preparation by synchronizing the post-approval split runbook
  with the current strengthened pre-split readiness output.

### Research question
- Does the runbook tell the operator what strengthened preflight evidence should
  be visible before acting on official split approval?

### What I inspected
- `research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md`
- `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`
- `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`

### Decision / action
- Updated the runbook Step 0 to require visible preflight output markers:
  - `[OK] document invariant self-test`
  - `[OK] Stage audit coverage self-test`
  - `Pre-split readiness: PASS`
  - `Official split artifacts: absent`
- Added a document invariant protecting the runbook's strengthened preflight
  output marker.
- Added `STAGE58_POST_APPROVAL_RUNBOOK_PREFLIGHT_SCOPE.md`.
- Updated Stage35 to record Stage 2-58 coverage.

### Result
- `py_compile` passed.
- `--document-invariant-self-test` passed.
- Missing-text negative controls rejected: 32.
- `--stage-audit-coverage-self-test` passed.
- Stage audit notes covered: 59.
- Stage coverage check reported `missing_stage_files=0`.
- Full pre-split readiness passed.
- Official split artifacts remain absent.

### Interpretation
- The operational runbook now tells the operator what strengthened preflight
  evidence should be visible before split creation. This reduces the risk of
  acting on approval with stale gate assumptions.

### Insight tags
- ✅ SUCCESS: Post-approval runbook now reflects current preflight output.
- ⚠️ RISK: This is operational documentation, not performance evidence.
- 🧪 NEXT: Keep official split gated; after exact approval, run the runbook.
- 🔁 DO NOT REPEAT: Do not let runbooks lag behind gate-hardening work.

### Evidence
- Files:
  - `research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md`
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`
  - `research_gsure/02_audits/STAGE58_POST_APPROVAL_RUNBOOK_PREFLIGHT_SCOPE.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py --document-invariant-self-test`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py --stage-audit-coverage-self-test`
  - `rg -n "\\[OK\\] document invariant self-test|\\[OK\\] Stage audit coverage self-test|STAGE58_POST_APPROVAL_RUNBOOK_PREFLIGHT_SCOPE|Stage 2-58" research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md research_gsure/02_audits/scripts/check_pre_split_readiness.py research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md research_gsure/02_audits/STAGE58_POST_APPROVAL_RUNBOOK_PREFLIGHT_SCOPE.md`
  - `python - <<'PY' ...`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- Metrics:
  - Document invariant negative controls rejected: 32
  - Stage audit notes covered: 59
  - Missing Stage required-file entries: 0
  - Pre-split readiness: PASS
  - Draft subject cohort rows: 1614

### Remaining uncertainty
- Official split remains uncreated.
- No segmentation, prediction, or reliability performance evidence exists yet.

### Next recommended action
- Await exact approval for official primary LOCO split creation.

## 2026-06-23 — Stage57 top-level status synchronized

### Task
- Continue G-SURE preparation by synchronizing README and roadmap summaries with
  the current strengthened pre-split readiness gate.

### Research question
- Do the top-level documents communicate the same current gate state that
  `check_pre_split_readiness.py` actually enforces?

### What I inspected
- `research_gsure/README.md`
- `research_gsure/ROADMAP.md`
- `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`

### Decision / action
- Updated README current status to say pre-split readiness currently passes and
  lists active-direction, subject-manifest, document-invariant, Stage audit
  coverage, official split absence, dry-run, and validator self-test coverage.
- Updated ROADMAP Stage 5 minimum evidence with lesion-size, predicted-volume,
  and image-difficulty proxy baselines.
- Updated ROADMAP current stage to include the strengthened negative-control
  self-test scope.
- Added document invariants protecting these README/ROADMAP status phrases.
- Added `STAGE57_TOP_LEVEL_STATUS_SYNC.md`.
- Updated Stage35 to record Stage 2-57 coverage.

### Result
- First document-invariant self-test failed because the ROADMAP wording split
  `Stage audit coverage negative-control self-tests` across a line break.
- Added a stable explicit sentence to ROADMAP.
- `py_compile` passed.
- `--document-invariant-self-test` passed after the ROADMAP wording fix.
- Missing-text negative controls rejected: 31.
- `--stage-audit-coverage-self-test` passed.
- Stage audit notes covered: 58.
- Stage coverage check reported `missing_stage_files=0`.
- Full pre-split readiness passed.
- Official split artifacts remain absent.

### Interpretation
- Top-level research status now matches the actual preflight gate. The failure
  caught by the document-invariant self-test confirms that the guardrail is doing
  useful work, not just passing trivially.

### Insight tags
- ✅ SUCCESS: README/ROADMAP now reflect the current gate and proxy-baseline
  requirements.
- ✅ SUCCESS: Document invariant self-test caught and helped fix an exact-marker
  mismatch.
- ⚠️ RISK: Top-level summaries still summarize; detailed protocol files remain
  authoritative for exact execution.
- 🧪 NEXT: Keep official split gated; after exact approval, run the
  post-approval split runbook.
- 🔁 DO NOT REPEAT: Do not let top-level status lag behind gate-hardening work.

### Evidence
- Files:
  - `research_gsure/README.md`
  - `research_gsure/ROADMAP.md`
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`
  - `research_gsure/02_audits/STAGE57_TOP_LEVEL_STATUS_SYNC.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py --document-invariant-self-test`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py --stage-audit-coverage-self-test`
  - `rg -n "pre-split readiness gate currently passes|lesion-size, predicted-volume, and image-difficulty proxy baselines|Stage audit coverage negative-control self-tests|STAGE57_TOP_LEVEL_STATUS_SYNC|Stage 2-57" research_gsure/README.md research_gsure/ROADMAP.md research_gsure/02_audits/scripts/check_pre_split_readiness.py research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md research_gsure/02_audits/STAGE57_TOP_LEVEL_STATUS_SYNC.md`
  - `python - <<'PY' ...`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- Metrics:
  - Document invariant negative controls rejected: 31
  - Stage audit notes covered: 58
  - Missing Stage required-file entries: 0
  - Pre-split readiness: PASS
  - Draft subject cohort rows: 1614

### Remaining uncertainty
- Official split remains uncreated.
- No segmentation, prediction, or reliability performance evidence exists yet.

### Next recommended action
- Await exact approval for official primary LOCO split creation.

## 2026-06-23 — Stage56 approval docs synced with Stage coverage evidence

### Task
- Continue G-SURE preparation by synchronizing approval-facing documents with
  the Stage audit coverage self-test.

### Research question
- Does the official split approval packet describe the same Stage audit coverage
  evidence that `check_pre_split_readiness.py` actually runs?

### What I inspected
- `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`
- `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
- `research_gsure/02_audits/STAGE24_PRE_SPLIT_PREFLIGHT.md`
- `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`
- `research_gsure/02_audits/scripts/check_pre_split_readiness.py`

### Decision / action
- Added Stage audit coverage self-test evidence to the official split approval
  packet.
- Updated the readiness checklist preflight row to include Stage audit coverage
  negative controls.
- Updated Stage24 so it records that missing Stage required-file entries are
  rejected.
- Added document invariants protecting those approval/checklist phrases.
- Added `STAGE56_APPROVAL_STAGE_COVERAGE_EVIDENCE_SYNC.md`.
- Updated Stage35 to record Stage 2-56 coverage.

### Result
- `py_compile` passed.
- `--document-invariant-self-test` passed.
- Missing-text negative controls rejected: 28.
- `--stage-audit-coverage-self-test` passed.
- Stage audit notes covered: 57.
- Full pre-split readiness passed.
- Official split artifacts remain absent.

### Interpretation
- The approval packet now reflects the current preflight scope, including Stage
  audit coverage evidence. This keeps Min's split-approval evidence aligned with
  what the gate actually verifies.

### Insight tags
- ✅ SUCCESS: Approval-facing docs now include Stage audit coverage
  negative-control evidence.
- ⚠️ RISK: This is still gate integrity, not model performance or novelty
  evidence.
- 🧪 NEXT: Keep official split gated; after exact approval, run the
  post-approval split runbook.
- 🔁 DO NOT REPEAT: Do not strengthen preflight without syncing the approval
  packet.

### Evidence
- Files:
  - `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`
  - `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
  - `research_gsure/02_audits/STAGE24_PRE_SPLIT_PREFLIGHT.md`
  - `research_gsure/02_audits/STAGE56_APPROVAL_STAGE_COVERAGE_EVIDENCE_SYNC.md`
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py --document-invariant-self-test`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py --stage-audit-coverage-self-test`
  - `rg -n "Stage audit coverage self-test: all current Stage audit notes are covered|Stage audit coverage negative controls|missing Stage required-file entries|STAGE56_APPROVAL_STAGE_COVERAGE_EVIDENCE_SYNC|Stage 2-56" research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md research_gsure/02_audits/STAGE24_PRE_SPLIT_PREFLIGHT.md research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md research_gsure/02_audits/STAGE56_APPROVAL_STAGE_COVERAGE_EVIDENCE_SYNC.md research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- Metrics:
  - Document invariant negative controls rejected: 28
  - Stage audit notes covered: 57
  - Pre-split readiness: PASS
  - Draft subject cohort rows: 1614

### Remaining uncertainty
- Official split remains uncreated.
- No segmentation, prediction, or reliability performance evidence exists yet.

### Next recommended action
- Await exact approval for official primary LOCO split creation.

## 2026-06-23 — Stage55 Stage audit coverage self-test added

### Task
- Continue G-SURE preparation by adding a negative-control self-test for Stage
  audit required-file coverage.

### Research question
- Can preflight prove that it rejects a Stage audit note that exists on disk but
  is missing from `REQUIRED_FILES`?

### What I inspected
- `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`
- `research_gsure/02_audits/STAGE54_STAGE_AUDIT_TRAIL_COVERAGE.md`
- `research_gsure/02_audits/STAGE*.md`

### Decision / action
- Added `--stage-audit-coverage-self-test` to
  `check_pre_split_readiness.py`.
- Split Stage audit coverage into:
  - current Stage path discovery,
  - pure coverage validation,
  - negative-control self-test.
- The self-test removes one Stage entry from an in-memory required-file list and
  verifies that the missing Stage is rejected.
- Full preflight now runs this self-test as part of command checks.
- Added `STAGE55_STAGE_AUDIT_COVERAGE_SELF_TEST.md`.
- Updated Stage35 to record Stage 2-55 coverage and the self-test.

### Result
- `py_compile` passed.
- `--stage-audit-coverage-self-test` passed.
- Stage audit notes covered: 56.
- Removed-stage negative control was rejected.
- Stage coverage check reported `missing_stage_files=0`.
- Full pre-split readiness passed and includes `[OK] Stage audit coverage
  self-test`.
- Official split artifacts remain absent.

### Interpretation
- The audit-trail coverage check now has its own failure-mode test. This reduces
  the chance that future edits silently drop Stage evidence from the preflight
  gate.

### Insight tags
- ✅ SUCCESS: Stage audit coverage is now negative-control tested.
- ⚠️ RISK: This still checks file coverage, not the semantic quality of each
  Stage note.
- 🧪 NEXT: Keep official split gated; after exact approval, run the
  post-approval split runbook.
- 🔁 DO NOT REPEAT: Do not add dynamic coverage checks without a self-test.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`
  - `research_gsure/02_audits/STAGE55_STAGE_AUDIT_COVERAGE_SELF_TEST.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py --stage-audit-coverage-self-test`
  - `rg -n "Stage audit coverage self-test|--stage-audit-coverage-self-test|Removed-stage negative control|STAGE55_STAGE_AUDIT_COVERAGE_SELF_TEST|Stage 2-55" research_gsure/02_audits/scripts/check_pre_split_readiness.py research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md research_gsure/02_audits/STAGE55_STAGE_AUDIT_COVERAGE_SELF_TEST.md`
  - `python - <<'PY' ...`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- Metrics:
  - Stage files: 56
  - Missing Stage required-file entries: 0
  - Pre-split readiness: PASS
  - Draft subject cohort rows: 1614

### Remaining uncertainty
- Official split remains uncreated.
- No segmentation, prediction, or reliability performance evidence exists yet.

### Next recommended action
- Await exact approval for official primary LOCO split creation.

## 2026-06-23 — Stage54 full Stage audit-trail coverage

### Task
- Continue G-SURE preparation by checking whether all Stage audit notes are
  protected by the pre-split readiness required-file gate.

### Research question
- Can a `STAGE*.md` audit note disappear from `REQUIRED_FILES` while
  `check_pre_split_readiness.py` still passes?

### What I inspected
- `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- `research_gsure/02_audits/STAGE*.md`
- `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`

### Decision / action
- Found that 27 of 54 existing Stage files were outside required-file coverage.
- Added the missing Stage notes to `REQUIRED_FILES`, including Stage 2-22 and
  Stage 26-29.
- Added `check_stage_audit_coverage()` so preflight scans existing `STAGE*.md`
  files and fails if any are not listed in `REQUIRED_FILES`.
- Added `STAGE54_STAGE_AUDIT_TRAIL_COVERAGE.md`.
- Updated Stage35 to record Stage 2-54 audit-note coverage.

### Result
- `py_compile` passed.
- Stage coverage check reported:
  - `total_stage_files=55`
  - `missing_stage_files=0`
- Full pre-split readiness passed.
- Official split artifacts remain absent.

### Interpretation
- The audit trail is now protected as a whole, not only for recent gate-hardening
  notes. This improves reproducibility and decision traceability before official
  split creation.

### Insight tags
- ✅ SUCCESS: All current Stage audit notes are now covered by preflight.
- ⚠️ RISK: Required-file coverage checks existence, not full semantic quality of
  every Stage note.
- 🧪 NEXT: Keep official split gated; after exact approval, run the
  post-approval split runbook.
- 🔁 DO NOT REPEAT: Do not let early audit evidence fall outside readiness gate
  coverage.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`
  - `research_gsure/02_audits/STAGE54_STAGE_AUDIT_TRAIL_COVERAGE.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `python - <<'PY' ...`
  - `rg -n "check_stage_audit_coverage|STAGE54_STAGE_AUDIT_TRAIL_COVERAGE|Stage 2-54|missing_stage_files=0" research_gsure/02_audits/scripts/check_pre_split_readiness.py research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md research_gsure/02_audits/STAGE54_STAGE_AUDIT_TRAIL_COVERAGE.md`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- Metrics:
  - Stage files: 55
  - Missing Stage required-file entries: 0
  - Pre-split readiness: PASS
  - Draft subject cohort rows: 1614

### Remaining uncertainty
- Official split remains uncreated.
- No segmentation, prediction, or reliability performance evidence exists yet.

### Next recommended action
- Await exact approval for official primary LOCO split creation.

## 2026-06-23 — Stage53 approval preflight evidence synchronized

### Task
- Keep the approval-facing G-SURE documents synchronized with the current
  pre-split readiness command checks.

### Research question
- Does the official split approval packet describe the same preflight evidence
  that `check_pre_split_readiness.py` actually runs?

### What I inspected
- `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`
- `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
- `research_gsure/02_audits/STAGE24_PRE_SPLIT_PREFLIGHT.md`
- `research_gsure/02_audits/scripts/check_pre_split_readiness.py`

### Decision / action
- Added document-invariant self-test evidence to the official split approval
  packet.
- Updated the readiness checklist preflight row to include document-invariant
  negative controls.
- Updated Stage24 so it says selected document invariants are negative-control
  tested, including G-SURE novelty/baseline guardrails.
- Added document invariants that protect those approval/checklist descriptions.
- Added `STAGE53_APPROVAL_PREFLIGHT_EVIDENCE_SYNC.md`.

### Result
- `py_compile` passed.
- `--document-invariant-self-test` passed.
- Missing-text negative controls rejected: 27.
- Full pre-split readiness passed and includes `[OK] document invariant
  self-test`.
- Official split artifacts remain absent.

### Interpretation
- The approval packet now reflects the actual gate. This matters because Min's
  split approval should be based on current evidence, not an outdated preflight
  description.

### Insight tags
- ✅ SUCCESS: Approval-facing documentation now includes document-invariant
  negative-control evidence.
- ⚠️ RISK: This is still pre-split gate integrity, not model performance.
- 🧪 NEXT: Keep official split gated; after exact approval, run the
  post-approval split runbook.
- 🔁 DO NOT REPEAT: Do not strengthen preflight code without synchronizing the
  approval packet.

### Evidence
- Files:
  - `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`
  - `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
  - `research_gsure/02_audits/STAGE24_PRE_SPLIT_PREFLIGHT.md`
  - `research_gsure/02_audits/STAGE53_APPROVAL_PREFLIGHT_EVIDENCE_SYNC.md`
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py --document-invariant-self-test`
  - `rg -n "document invariant self-test: current gate/novelty/baseline invariant phrases|document-invariant negative controls|negative-control tested|STAGE53_APPROVAL_PREFLIGHT_EVIDENCE_SYNC|Stage 30-53" research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md research_gsure/02_audits/STAGE24_PRE_SPLIT_PREFLIGHT.md research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md research_gsure/02_audits/STAGE53_APPROVAL_PREFLIGHT_EVIDENCE_SYNC.md research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- Metrics:
  - Document invariant negative controls rejected: 27
  - Pre-split readiness: PASS
  - Draft subject cohort rows: 1614

### Remaining uncertainty
- Official split remains uncreated.
- No segmentation, prediction, or reliability performance evidence exists yet.

### Next recommended action
- Await exact approval for official primary LOCO split creation.

## 2026-06-23 — Stage52 document invariant self-test added

### Task
- Continue G-SURE preparation by adding a negative-control self-test for selected
  document invariants.

### Research question
- Can preflight prove that it rejects missing gate, novelty, and baseline
  guardrail phrases rather than only checking current files once?

### What I inspected
- `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`
- `research_gsure/02_audits/STAGE36_PREFLIGHT_DOCUMENT_INVARIANTS.md`
- `research_gsure/02_audits/STAGE51_CONTEXT_SEMANTIC_INVARIANTS.md`

### Decision / action
- Added `--document-invariant-self-test` to
  `check_pre_split_readiness.py`.
- Split document invariant checking into:
  - current-file text loading,
  - pure text invariant validation,
  - negative-control self-test.
- The self-test now:
  - checks current documents satisfy all selected invariants,
  - rejects a missing required invariant document,
  - removes each required invariant phrase in-memory and verifies rejection.
- Full preflight now runs this self-test as part of command checks.
- Added `STAGE52_DOCUMENT_INVARIANT_SELF_TEST.md`.

### Result
- `py_compile` passed.
- `--document-invariant-self-test` passed.
- Missing-document negative control was rejected.
- Missing-text negative controls rejected: 26.
- Full pre-split readiness passed and includes `[OK] document invariant
  self-test`.

### Interpretation
- The readiness gate now tests that selected semantic guardrails are enforceable,
  not just present in the current files. This protects the G-SURE framing before
  official split creation.

### Insight tags
- ✅ SUCCESS: Document invariant enforcement now has negative-control coverage.
- ⚠️ RISK: The invariants are selected high-risk phrases, not a complete
  semantic validator for every document.
- 🧪 NEXT: Keep official split gated; after approval, run post-split validation
  before any GPU preview.
- 🔁 DO NOT REPEAT: Do not add guardrail checks without a failure-mode self-test.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`
  - `research_gsure/02_audits/STAGE36_PREFLIGHT_DOCUMENT_INVARIANTS.md`
  - `research_gsure/02_audits/STAGE52_DOCUMENT_INVARIANT_SELF_TEST.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py --document-invariant-self-test`
  - `rg -n "document invariant self-test|--document-invariant-self-test|Missing-text negative controls rejected|STAGE52_DOCUMENT_INVARIANT_SELF_TEST|Stage 30-52" research_gsure/02_audits/scripts/check_pre_split_readiness.py research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md research_gsure/02_audits/STAGE36_PREFLIGHT_DOCUMENT_INVARIANTS.md research_gsure/02_audits/STAGE52_DOCUMENT_INVARIANT_SELF_TEST.md`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- Metrics:
  - Document invariant negative controls rejected: 26
  - Pre-split readiness: PASS
  - Draft subject cohort rows: 1614

### Remaining uncertainty
- Official split remains uncreated.
- No segmentation, prediction, or reliability performance evidence exists yet.

### Next recommended action
- Await exact approval for official primary LOCO split creation.

## 2026-06-23 — Stage51 context semantic invariants added

### Task
- Continue G-SURE preparation by making selected novelty/baseline guardrails
  part of the pre-split readiness document-invariant checks.

### Research question
- Can the literature/baseline defense language disappear while required files
  still exist and preflight still passes?

### What I inspected
- `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- `research_gsure/00_context/20260623_gsure_literature_scout.md`
- `research_gsure/00_context/20260623_gsure_prior_work_matrix.md`
- `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
- `research_gsure/03_baselines/BASELINE_CONTRACT.md`
- `research_gsure/03_baselines/UNCERTAINTY_QC_BASELINE_REQUIREMENTS.md`
- `research_gsure/02_audits/STAGE36_PREFLIGHT_DOCUMENT_INVARIANTS.md`

### Decision / action
- Added document invariants for:
  - targeted 2024-2026 literature update status remaining non-exhaustive,
  - unsupported "first/novel/SOTA/robust/clinically useful" claims remaining
    blocked,
  - QCResUNet remaining documented as a 2025 journal-level novelty threat,
  - lesion-size, predicted-volume, and image-difficulty proxy baselines
    remaining required,
  - ground-truth lesion size remaining oracle diagnostic only,
  - B0 proxy controls remaining before G-SURE method comparison.
- Added `STAGE51_CONTEXT_SEMANTIC_INVARIANTS.md`.
- Updated Stage35 and Stage36 notes.

### Result
- `py_compile` passed.
- Grep evidence found all new invariant markers.
- Pre-split readiness passed.
- Official split artifacts remain absent.

### Interpretation
- The readiness gate now protects both file presence and selected core research
  framing semantics. This reduces the chance of drifting back to a weak
  uncertainty/QC/foundation-model claim.

### Insight tags
- ✅ SUCCESS: Novelty and baseline guardrails are now semantic preflight
  invariants.
- ⚠️ RISK: These invariants are selected guardrails, not a full formal proof of
  related-work quality.
- 🧪 NEXT: Keep official split gated; after approval, run post-split validation
  before any GPU preview.
- 🔁 DO NOT REPEAT: Do not let a passing preflight protect only files while the
  actual research claim silently changes.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`
  - `research_gsure/02_audits/STAGE36_PREFLIGHT_DOCUMENT_INVARIANTS.md`
  - `research_gsure/02_audits/STAGE51_CONTEXT_SEMANTIC_INVARIANTS.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `rg -n "TARGETED 2024-2026|QCResUNet has a 2025 Medical Image Analysis|Lesion-size, predicted-volume, and image-difficulty proxy baselines|oracle diagnostic only|Compute B0 predicted-volume|STAGE51_CONTEXT_SEMANTIC_INVARIANTS|Stage 30-51" research_gsure/02_audits/scripts/check_pre_split_readiness.py research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md research_gsure/02_audits/STAGE36_PREFLIGHT_DOCUMENT_INVARIANTS.md research_gsure/02_audits/STAGE51_CONTEXT_SEMANTIC_INVARIANTS.md research_gsure/00_context research_gsure/01_protocol research_gsure/03_baselines`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- Metrics:
  - Pre-split readiness: PASS
  - Draft subject cohort rows: 1614

### Remaining uncertainty
- Official split remains uncreated.
- No segmentation, prediction, or reliability performance evidence exists yet.

### Next recommended action
- Await exact approval for official primary LOCO split creation.

## 2026-06-23 — Post-split runner dry-run self-test

### Task
- Add a CPU-only self-test so the post-split validation runner cannot silently
  regress from all-consortium loader smoke to a single held-out fold.

### Research question
- Can the pre-split gate catch a broken validation sequence before official
  split approval, GPU preview, or prediction generation?

### What I inspected
- `research_gsure/02_audits/scripts/run_post_split_validation.py`
- `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- `research_gsure/02_audits/STAGE26_POST_SPLIT_VALIDATION_RUNNER.md`
- `research_gsure/02_audits/STAGE37_ALL_CONSORTIUM_LOADER_SMOKE.md`
- `research_gsure/02_audits/STAGE24_PRE_SPLIT_PREFLIGHT.md`
- `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`

### Decision / action
- Added `--dry-run-self-test` to `run_post_split_validation.py`.
- The self-test checks default 4-consortium smoke expansion, single-fold smoke,
  unknown held-out dataset rejection, and absent official split refusal.
- Added the self-test to `check_pre_split_readiness.py` command checks.
- Added `STAGE38_POST_SPLIT_RUNNER_SELF_TEST.md`.
- Updated Stage 24, Stage 26, Stage 35, and Stage 37 docs.

### Result
- `py_compile` passed.
- Runner dry-run self-test passed:
  - default loader smoke steps: 4
  - single-fold loader smoke steps: 1
  - unknown held-out dataset: rejected
  - absent official split manifest: refused
- Runner preview still shows four held-out consortium smoke steps.
- Pre-split readiness passed with the new self-test included.

### Interpretation
- The post-split validation gate is now checked for the exact all-consortium
  smoke behavior we need before GPU work.
- This is gate integrity only; it is not segmentation performance evidence.

### Insight tags
- ✅ SUCCESS: Preflight now tests all-consortium runner behavior directly.
- ⚠️ RISK: Official split remains absent, so real loader smoke has not run.
- 🧪 NEXT: Run link search, diff checks, and official-split-absent check.
- 🔁 DO NOT REPEAT: Do not rely on preview text alone when a runner invariant can
  be tested mechanically.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/run_post_split_validation.py`
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `research_gsure/02_audits/STAGE38_POST_SPLIT_RUNNER_SELF_TEST.md`
  - `research_gsure/02_audits/STAGE26_POST_SPLIT_VALIDATION_RUNNER.md`
  - `research_gsure/02_audits/STAGE37_ALL_CONSORTIUM_LOADER_SMOKE.md`
  - `research_gsure/02_audits/STAGE24_PRE_SPLIT_PREFLIGHT.md`
  - `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/run_post_split_validation.py research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `python research_gsure/02_audits/scripts/run_post_split_validation.py --dry-run-self-test`
  - `python research_gsure/02_audits/scripts/run_post_split_validation.py --preview`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- Metrics:
  - Runner dry-run self-test: PASS
  - Pre-split readiness: PASS
  - Official split artifacts written: 0
- Logs:
  - Official split manifest remains absent.

### Remaining uncertainty
- Official split remains uncreated.
- Real loader smoke across all folds can only run after official split approval
  and split creation.

### Next recommended action
- Keep the next gate explicit: official LOCO split approval, then post-split
  validation runner `--run`.

## 2026-06-23 — Approval decision invariants

### Task
- Add preflight invariants for the official split approval packet's decision
  tuple.

### Research question
- Could the approval packet still exist and contain the exact approval sentence,
  while silently changing the cohort, target, split policy, split unit, or
  authorization boundaries?

### What I inspected
- `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`
- `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- `research_gsure/02_audits/STAGE36_PREFLIGHT_DOCUMENT_INVARIANTS.md`
- `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`

### Decision / action
- Added approval-packet document invariants to `check_pre_split_readiness.py`.
- The checked decision tuple is:
  - `primary cohort = subject_level_cohort_manifest_draft.csv`
  - `selection policy = one_unit_per_subject_earliest_numeric_order`
  - `target = binary selected_mask > 0`
  - `split policy = Leave-One-Consortium-Out`
  - `unit of split = dataset::subject_id`
- Added invariants that split approval does not authorize GPU training or
  reliability label generation.
- Added `STAGE39_APPROVAL_DECISION_INVARIANTS.md`.
- Updated Stage 35 and Stage 36 notes.

### Result
- `py_compile` passed.
- Invariant search found the approval decision tuple in both the approval packet
  and preflight checker.
- Pre-split readiness passed with Stage 39 included in required files and
  document invariants.
- `git diff --check` passed.

### Interpretation
- This protects the exact split decision under review before crossing the
  official split gate.

### Insight tags
- ✅ SUCCESS: Approval-packet decision tuple is now machine-checked by preflight.
- ⚠️ RISK: Required-file existence alone does not protect the meaning of an
  approval packet.
- 🧪 NEXT: Confirm official split artifacts are absent and keep split creation
  approval-gated.
- 🔁 DO NOT REPEAT: Do not request approval from a packet whose decision tuple is
  not machine-checked.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `research_gsure/02_audits/STAGE39_APPROVAL_DECISION_INVARIANTS.md`
  - `research_gsure/02_audits/STAGE36_PREFLIGHT_DOCUMENT_INVARIANTS.md`
  - `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `rg -n "primary cohort = subject_level_cohort_manifest_draft.csv|selection policy = one_unit_per_subject_earliest_numeric_order|target = binary selected_mask > 0|split policy = Leave-One-Consortium-Out|unit of split = dataset::subject_id|Approval does not authorize:|- GPU training,|- reliability label generation,|STAGE39_APPROVAL_DECISION_INVARIANTS" research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md research_gsure/02_audits/scripts/check_pre_split_readiness.py research_gsure/02_audits/STAGE39_APPROVAL_DECISION_INVARIANTS.md SCRATCHPAD.md`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `git diff --check`
- Metrics:
  - Pre-split readiness: PASS
  - Approval decision invariant search: found
- Logs:
  - Official split manifest remains absent as of the preceding check.

### Remaining uncertainty
- Official split remains uncreated.
- String invariants guard the approval tuple but are not a full semantic proof of
  every sentence in the packet.

### Next recommended action
- Validate the new approval decision invariants before any split approval
  request.

## 2026-06-23 — Subject manifest semantic preflight

### Task
- Strengthen pre-split readiness so the subject-level cohort manifest must match
  the reviewed G-SURE target and unit-selection policy.

### Research question
- Could the manifest keep correct row counts and paths while drifting in target
  policy, selected-unit policy, dataset-specific mask source, or subject-level
  uniqueness?

### What I inspected
- `research_gsure/02_audits/outputs/subject_level_cohort_manifest_draft.csv`
- `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- `research_gsure/01_protocol/SUBJECT_UNIT_SELECTION_DRAFT.md`
- `research_gsure/01_protocol/TARGET_MAPPING_DRAFT.md`

### Decision / action
- Confirmed current manifest values:
  - rows: 1,614
  - unique `dataset::subject_id`: 1,614
  - duplicate leakage groups: 0
  - `policy = binary_whole_lesion_fets_only`: 1,614 rows
  - `target_definition = selected_mask > 0`: 1,614 rows
  - `selection_policy = one_unit_per_subject_earliest_numeric_order`: 1,614 rows
  - `is_primary_subject_unit = 1`: 1,614 rows
  - `selection_rank = 1`: 1,614 rows
  - `include_candidate = 1`: 1,614 rows
  - `all_modalities_shape_affine_match_mask = 1`: 1,614 rows
  - nonpositive selected masks: 0 rows
- Added semantic subject-manifest checks to `check_pre_split_readiness.py`.
- Added `STAGE40_SUBJECT_MANIFEST_SEMANTIC_PREFLIGHT.md`.
- Updated Stage 24 and Stage 35 notes.

### Result
- `py_compile` passed.
- Link/keyword search found Stage 40, expected target/selection constants, mask
  key checks, and geometry-match semantic checks.
- `git diff --check` passed.
- Pre-split readiness passed with the strengthened subject-manifest semantic
  checks.

### Interpretation
- The official split gate now checks not only manifest size/path existence, but
  also whether the manifest still encodes the intended G-SURE cohort and target.

### Insight tags
- ✅ SUCCESS: Preflight now checks manifest semantics, not only row counts and
  paths.
- ⚠️ RISK: A correct row count is not enough; the CSV semantics can drift.
- 🧪 NEXT: Confirm official split artifacts are absent and keep split creation
  approval-gated.
- 🔁 DO NOT REPEAT: Do not create a split from a manifest whose target and unit
  policy are not checked.

### Evidence
- Files:
  - `research_gsure/02_audits/outputs/subject_level_cohort_manifest_draft.csv`
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `research_gsure/02_audits/STAGE40_SUBJECT_MANIFEST_SEMANTIC_PREFLIGHT.md`
  - `research_gsure/02_audits/STAGE24_PRE_SPLIT_PREFLIGHT.md`
  - `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `rg -n "STAGE40_SUBJECT_MANIFEST_SEMANTIC_PREFLIGHT|EXPECTED_TARGET_POLICY|EXPECTED_SELECTION_POLICY|EXPECTED_MASK_KEYS|all_modalities_shape_affine_match_mask|binary_whole_lesion_fets_only|selected_mask > 0|one_unit_per_subject_earliest_numeric_order" research_gsure/02_audits/scripts/check_pre_split_readiness.py research_gsure/02_audits/STAGE40_SUBJECT_MANIFEST_SEMANTIC_PREFLIGHT.md research_gsure/02_audits/STAGE24_PRE_SPLIT_PREFLIGHT.md SCRATCHPAD.md`
  - `git diff --check`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- Metrics:
  - Pre-split readiness: PASS
  - Subject rows checked: 1,614
  - Duplicate `dataset::subject_id` groups observed: 0
  - Nonpositive selected masks observed: 0
- Logs:
  - Official split manifest remains absent as of the preceding check.

### Remaining uncertainty
- Official split remains uncreated.
- These are metadata/CSV semantic checks; they do not replace post-split loader
  smoke or image-level validation.

### Next recommended action
- Validate the strengthened preflight before any split approval request.

## 2026-06-23 — Subject manifest semantic negative controls

### Task
- Add an in-memory negative-control self-test for subject manifest semantic
  validation.

### Research question
- Does the preflight fail if the subject manifest drifts in target definition,
  unit-selection policy, dataset-specific mask key, mask burden, geometry flag,
  path presence, or subject-level uniqueness?

### What I inspected
- `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- `research_gsure/02_audits/STAGE40_SUBJECT_MANIFEST_SEMANTIC_PREFLIGHT.md`

### Decision / action
- Refactored subject manifest semantic validation into reusable row-level logic.
- Added `--subject-manifest-self-test` to `check_pre_split_readiness.py`.
- Connected the self-test to normal preflight command checks.
- Added `STAGE41_SUBJECT_MANIFEST_SEMANTIC_SELF_TEST.md`.
- Updated Stage 24, Stage 35, and Stage 40 notes.

### Result
- `py_compile` passed.
- Subject manifest semantic self-test passed:
  - baseline manifest validation: PASS
  - negative controls rejected: 8
- Full pre-split readiness passed with the new self-test included.

### Interpretation
- A passing preflight should now mean both:
  - the current subject manifest matches the reviewed G-SURE task,
  - plausible in-memory semantic corruptions are rejected.

### Insight tags
- ✅ SUCCESS: Subject manifest semantic validator now has targeted negative
  controls.
- ⚠️ RISK: A validator that only passes current data but has no negative control
  can be falsely reassuring.
- 🧪 NEXT: Run link search, diff check, and official split absent check.
- 🔁 DO NOT REPEAT: Do not trust a preflight extension until it has at least one
  targeted negative-control self-test.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `research_gsure/02_audits/STAGE41_SUBJECT_MANIFEST_SEMANTIC_SELF_TEST.md`
  - `research_gsure/02_audits/STAGE24_PRE_SPLIT_PREFLIGHT.md`
  - `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`
  - `research_gsure/02_audits/STAGE40_SUBJECT_MANIFEST_SEMANTIC_PREFLIGHT.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py --subject-manifest-self-test`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- Metrics:
  - Subject manifest semantic self-test: PASS
  - Negative controls rejected: 8
  - Pre-split readiness: PASS
- Logs:
  - Official split manifest remains absent as of the preceding check.

### Remaining uncertainty
- Official split remains uncreated.
- This is still metadata/CSV validation; image-level loader smoke remains a
  post-split requirement.

### Next recommended action
- Validate the subject manifest semantic self-test before any split approval
  request.

## 2026-06-23 — Approval packet preflight evidence refresh

### Task
- Refresh the official split approval packet so it exposes the current CPU-only
  preflight evidence chain.

### Research question
- Could the approval packet lock the right split decision but omit newer gate
  evidence, such as subject-manifest negative controls and post-split runner
  self-tests?

### What I inspected
- `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`
- `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- `research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md`
- `research_gsure/03_baselines/B1_GPU_PREVIEW_COMMAND_TEMPLATE.md`

### Decision / action
- Updated the approval packet to list the current pre-split readiness command.
- Added explicit packet bullets for:
  - subject manifest semantic self-test with 8 rejected negative controls,
  - official split builder dry-run,
  - official split artifacts absent check,
  - official split checker dry-run self-test,
  - post-split validation runner preview,
  - post-split validation runner dry-run self-test,
  - OOF/inner-OOF/prediction/reliability synthetic self-tests.
- Added two approval-packet evidence phrases to `DOCUMENT_INVARIANTS`.
- Added `STAGE42_APPROVAL_PACKET_PREFLIGHT_EVIDENCE.md`.

### Result
- `py_compile` passed.
- Invariant search found the refreshed approval-packet preflight evidence.
- `git diff --check` passed.
- Full pre-split readiness passed with the new approval-packet invariants.

### Interpretation
- The packet Min reviews before official split approval now states the current
  gate evidence more completely.

### Insight tags
- ✅ SUCCESS: The approval packet now reports the current preflight evidence
  chain and preflight guards that wording.
- ⚠️ RISK: A correct decision tuple is not enough if the approval packet hides
  the actual readiness evidence chain.
- 🧪 NEXT: Confirm official split artifacts are absent and keep split creation
  approval-gated.
- 🔁 DO NOT REPEAT: Do not request split approval from a packet that omits newer
  preflight gates.

### Evidence
- Files:
  - `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `research_gsure/02_audits/STAGE42_APPROVAL_PACKET_PREFLIGHT_EVIDENCE.md`
  - `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `rg -n 'subject manifest semantic self-test: baseline validation and 8 negative|post-split validation runner dry-run self-test passes|STAGE42_APPROVAL_PACKET_PREFLIGHT_EVIDENCE|preflight evidence includes|official split builder dry-run' research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md research_gsure/02_audits/scripts/check_pre_split_readiness.py research_gsure/02_audits/STAGE42_APPROVAL_PACKET_PREFLIGHT_EVIDENCE.md SCRATCHPAD.md`
  - `git diff --check`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- Metrics:
  - Pre-split readiness: PASS
  - Approval-packet evidence invariant search: found
- Logs:
  - Official split manifest remains absent as of the preceding check.

### Remaining uncertainty
- Official split remains uncreated.
- The packet summarizes readiness evidence; it is still not approval and not
  performance evidence.

### Next recommended action
- Validate the refreshed approval packet before any split approval request.

## 2026-06-23 — Direction contamination guard

### Task
- Add a preflight guard against stale IDH/VLM/exp-style direction contamination
  in active G-SURE planning documents.

### Research question
- Could older classification/VLM direction language re-enter active G-SURE
  protocol, baseline, approval, or method files without the pre-split gate
  noticing?

### What I inspected
- `research_gsure/README.md`
- `research_gsure/ROADMAP.md`
- `research_gsure/01_protocol/`
- `research_gsure/03_baselines/`
- `research_gsure/04_method/`
- `research_gsure/02_audits/scripts/check_pre_split_readiness.py`

### Decision / action
- Added active-direction stale term checks to `check_pre_split_readiness.py`.
- Added `--direction-contamination-self-test`.
- Connected the self-test to normal preflight command checks.
- Added `STAGE43_DIRECTION_CONTAMINATION_GUARD.md`.
- Updated Stage 24 and Stage 35 notes.

### Result
- Initial direction-contamination self-test failed because naive substring
  matching treated `image-only` as containing stale `age-only`.
- Immediate cause: simple `term in text` matching.
- Deeper cause: stale-direction guard needs token-boundary matching to avoid
  rejecting valid segmentation-baseline language.
- Fixed by using token-boundary regex matching.
- `py_compile` passed after the fix.
- Direction contamination self-test passed:
  - baseline active direction documents: clean
  - injected stale direction term: rejected
- Full pre-split readiness passed with the new guard included.

### Interpretation
- The guard protects current G-SURE direction documents only. Historical audit
  logs and `SCRATCHPAD.md` remain allowed to mention rejected directions as
  research memory.

### Insight tags
- ✅ SUCCESS: Active G-SURE direction documents are now checked for stale
  IDH/VLM/exp-style contamination with a targeted negative control.
- ❌ FAILURE: First implementation overmatched `age-only` inside valid
  `image-only` baseline text.
- 🧯 MITIGATION: Switched stale-term detection to token-boundary regex matching.
- ⚠️ RISK: Previous research directions can contaminate current gate documents
  even when the split mechanics are correct.
- 🧪 NEXT: Run link search, diff check, and official split absent check.
- 🔁 DO NOT REPEAT: Do not rely on manual search alone to keep the active
  research direction clean.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `research_gsure/02_audits/STAGE43_DIRECTION_CONTAMINATION_GUARD.md`
  - `research_gsure/02_audits/STAGE24_PRE_SPLIT_PREFLIGHT.md`
  - `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py --direction-contamination-self-test`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- Metrics:
  - Direction contamination self-test: PASS after token-boundary fix
  - Pre-split readiness: PASS
- Logs:
  - Official split manifest remains absent as of the preceding check.

### Remaining uncertainty
- Official split remains uncreated.
- This guard covers selected active direction documents only; historical logs may
  still mention prior rejected directions.

### Next recommended action
- Validate the direction contamination guard before any split approval request.

## 2026-06-23 — Direction guard case-insensitive hardening

### Task
- Strengthen the direction contamination guard so lowercase and mixed-case stale
  terms are detected.

### Research question
- Could stale terms like `idh` or `Brain-Age` enter active G-SURE documents
  without being caught because the guard only matched exact capitalization?

### What I inspected
- `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- `research_gsure/02_audits/STAGE43_DIRECTION_CONTAMINATION_GUARD.md`

### Decision / action
- Added `re.IGNORECASE` to stale-term regex matching.
- Expanded the direction contamination self-test to inject:
  - uppercase `IDH`,
  - lowercase `idh`,
  - mixed-case `Brain-Age`.
- Added `STAGE44_DIRECTION_GUARD_CASE_INSENSITIVE.md`.
- Updated Stage 35 and Stage 43 notes.

### Result
- First validation failed because case-insensitive `VLM` matched the legitimate
  workspace path `/home/vlm/minyoung4`.
- Immediate cause: `VLM` was made case-insensitive along with all other terms.
- Deeper cause: stale-direction terms can overlap with project infrastructure
  paths, so term-specific exceptions are needed.
- Mitigation: `VLM` is now exact-case while other stale terms remain
  case-insensitive.
- `py_compile` passed after the fix.
- Direction contamination self-test passed:
  - baseline active direction documents: clean
  - injected stale direction terms rejected: 3
- Full pre-split readiness passed.

### Interpretation
- The direction guard should now reject stale-direction terms regardless of
  capitalization while still avoiding the previous `image-only` false positive.

### Insight tags
- ✅ SUCCESS: Lowercase/mixed-case stale terms are now rejected without treating
  `/home/vlm` as stale VLM direction.
- ❌ FAILURE: First case-insensitive implementation overmatched the workspace
  path.
- 🧯 MITIGATION: Keep `VLM` exact-case; keep the rest case-insensitive.
- ⚠️ RISK: Case-sensitive guards can miss common lowercase stale terminology.
- 🧪 NEXT: Run link search, diff check, and official split absent check.
- 🔁 DO NOT REPEAT: Do not rely on exact-case matching for research-direction
  contamination.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `research_gsure/02_audits/STAGE43_DIRECTION_CONTAMINATION_GUARD.md`
  - `research_gsure/02_audits/STAGE44_DIRECTION_GUARD_CASE_INSENSITIVE.md`
  - `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py --direction-contamination-self-test`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- Metrics:
  - Direction contamination self-test: PASS after `VLM` exact-case exception
  - Injected stale terms rejected: 3
  - Pre-split readiness: PASS
- Logs:
  - Official split manifest remains absent as of the preceding check.

### Remaining uncertainty
- Official split remains uncreated.
- The guard is limited to selected active direction documents.

### Next recommended action
- Validate the case-insensitive direction guard before any split approval
  request.

## 2026-06-23 — Approval packet direction guard evidence

### Task
- Synchronize the official split approval packet with the latest direction
  contamination guard evidence.

### Research question
- Could the approval packet list older preflight evidence while omitting the
  active-direction contamination self-test that now guards G-SURE alignment?

### What I inspected
- `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`
- `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- `research_gsure/02_audits/STAGE42_APPROVAL_PACKET_PREFLIGHT_EVIDENCE.md`
- `research_gsure/02_audits/STAGE44_DIRECTION_GUARD_CASE_INSENSITIVE.md`

### Decision / action
- Added direction contamination self-test evidence to the official split
  approval packet.
- Added a document invariant in `check_pre_split_readiness.py` so the phrase
  cannot silently disappear.
- Updated Stage 42 and Stage 35 notes.
- Added `STAGE45_APPROVAL_PACKET_DIRECTION_GUARD_EVIDENCE.md`.

### Result
- `py_compile` passed.
- Invariant search found the new direction-contamination evidence phrase in the
  approval packet and preflight checker.
- `git diff --check` passed.
- Full pre-split readiness passed with Stage 45 and the new approval-packet
  invariant included.

### Interpretation
- The packet Min reviews before official split approval should now reflect the
  current full preflight evidence chain, including active-direction hygiene.

### Insight tags
- ✅ SUCCESS: Official split approval packet now reflects the direction
  contamination guard evidence.
- ⚠️ RISK: Approval-context documents can lag behind newly added gates.
- 🧪 NEXT: Confirm official split artifacts are absent and keep split creation
  approval-gated.
- 🔁 DO NOT REPEAT: Do not leave approval packet evidence stale after adding a
  new preflight gate.

### Evidence
- Files:
  - `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `research_gsure/02_audits/STAGE45_APPROVAL_PACKET_DIRECTION_GUARD_EVIDENCE.md`
  - `research_gsure/02_audits/STAGE42_APPROVAL_PACKET_PREFLIGHT_EVIDENCE.md`
  - `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `rg -n 'direction contamination self-test: active G-SURE direction documents are clean|STAGE45_APPROVAL_PACKET_DIRECTION_GUARD_EVIDENCE|approval packet reports active-direction contamination guard evidence|3 injected stale-direction terms' research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md research_gsure/02_audits/scripts/check_pre_split_readiness.py research_gsure/02_audits/STAGE45_APPROVAL_PACKET_DIRECTION_GUARD_EVIDENCE.md research_gsure/02_audits/STAGE42_APPROVAL_PACKET_PREFLIGHT_EVIDENCE.md SCRATCHPAD.md`
  - `git diff --check`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- Metrics:
  - Pre-split readiness: PASS
  - Approval-packet direction guard evidence invariant search: found
- Logs:
  - Official split manifest remains absent as of the preceding check.

### Remaining uncertainty
- Official split remains uncreated.
- The packet summarizes readiness evidence; it is still not approval or
  performance evidence.

### Next recommended action
- Validate approval packet/preflight synchronization before any split approval
  request.

## 2026-06-23 — Readiness checklist preflight scope sync

### Task
- Align the experiment readiness checklist with the current strengthened
  pre-split readiness scope.

### Research question
- Could the checklist understate current preflight coverage after direction
  contamination and subject-manifest semantic checks were added?

### What I inspected
- `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
- `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`

### Decision / action
- Updated the checklist `pre-split preflight` row to mention:
  - active-direction contamination,
  - subject-manifest semantics/negative controls,
  - official split absence,
  - dry-runs,
  - validator self-tests.
- Added a document invariant so the checklist phrase cannot silently regress.
- Added `STAGE46_READINESS_CHECKLIST_PREFLIGHT_SCOPE.md`.
- During patch review, found `STAGE45_APPROVAL_PACKET_DIRECTION_GUARD_EVIDENCE.md`
  was not yet in `REQUIRED_FILES` despite Stage35 saying Stage 30-46 were
  covered.
- Added both Stage 45 and Stage 46 notes to `REQUIRED_FILES`.

### Result
- `py_compile` passed.
- Coverage search found:
  - checklist preflight scope phrase,
  - Stage45 and Stage46 in `REQUIRED_FILES`,
  - Stage35 Stage 30-46 coverage wording,
  - the new checklist document invariant.
- `git diff --check` passed.
- Full pre-split readiness passed.

### Interpretation
- This keeps the top-level readiness checklist and preflight required-file list
  aligned with the actual current gate.

### Insight tags
- ✅ SUCCESS: Checklist preflight scope and Stage45/46 required-file coverage are
  now aligned with the current gate.
- ⚠️ RISK: Audit notes can be created but not actually monitored by preflight.
- 🧪 NEXT: Confirm official split artifacts are absent and keep split creation
  approval-gated.
- 🔁 DO NOT REPEAT: Do not update Stage35 coverage wording without verifying
  every named stage is in `REQUIRED_FILES`.

### Evidence
- Files:
  - `research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md`
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `research_gsure/02_audits/STAGE46_READINESS_CHECKLIST_PREFLIGHT_SCOPE.md`
  - `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `rg -n 'checks active-direction contamination, subject-manifest semantics/negative controls|STAGE45_APPROVAL_PACKET_DIRECTION_GUARD_EVIDENCE|STAGE46_READINESS_CHECKLIST_PREFLIGHT_SCOPE|Stage 30-46|readiness checklist reports the current strengthened preflight scope' research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md research_gsure/02_audits/scripts/check_pre_split_readiness.py research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md research_gsure/02_audits/STAGE46_READINESS_CHECKLIST_PREFLIGHT_SCOPE.md SCRATCHPAD.md`
  - `git diff --check`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- Metrics:
  - Pre-split readiness: PASS
  - Stage45/46 required-file coverage search: found
- Logs:
  - Official split manifest remains absent as of the preceding check.

### Remaining uncertainty
- Official split remains uncreated.
- Checklist alignment is documentation/gate hygiene, not performance evidence.

### Next recommended action
- Validate checklist/preflight scope synchronization before any split approval
  request.

## 2026-06-23 — Split builder write-safety hardening

### Task
- Ensure the official LOCO split builder refuses to write artifacts when split
  validation errors are present.

### Research question
- Could `build_loco_split_manifest.py --write` create official split outputs
  even after detecting validation errors?

### What I inspected
- `research_gsure/02_audits/scripts/build_loco_split_manifest.py`
- `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`
- `research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md`

### Decision / action
- Found that the builder printed validation errors but still entered the
  `--write` block before returning a nonzero status.
- Added `write_official_outputs(...)` with validation-error write refusal before
  any split CSV/report write.
- Added `--write-safety-self-test`.
- Connected the self-test to pre-split readiness command checks.
- Updated the approval packet, post-approval runbook, Stage 24, and Stage 35.
- Added `STAGE47_SPLIT_BUILDER_WRITE_SAFETY.md`.

### Result
- `py_compile` passed.
- Split builder write-safety self-test passed.
- The self-test detected corrupted split validation errors and refused the
  invalid write.
- Full pre-split readiness passed with write-safety self-test included.
- Link search found the write-safety command, Stage47 note, approval-packet
  evidence, and preflight command hook.
- `git diff --check` passed.

### Interpretation
- This closes a real gate-safety issue: invalid split artifacts should not be
  materialized even if `--write` is accidentally used on a broken manifest.

### Insight tags
- ✅ SUCCESS: Split builder now refuses validation-error writes before creating
  split CSV/report artifacts.
- ⚠️ RISK: A nonzero exit code is not enough if invalid artifacts are written
  before returning.
- 🧪 NEXT: Confirm official split artifacts are absent and keep split creation
  approval-gated.
- 🔁 DO NOT REPEAT: Do not rely on downstream artifact checkers to rescue an
  invalid split write.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/build_loco_split_manifest.py`
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `research_gsure/02_audits/STAGE47_SPLIT_BUILDER_WRITE_SAFETY.md`
  - `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`
  - `research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md`
  - `research_gsure/02_audits/STAGE24_PRE_SPLIT_PREFLIGHT.md`
  - `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/build_loco_split_manifest.py research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `python research_gsure/02_audits/scripts/build_loco_split_manifest.py --write-safety-self-test`
  - `rg -n 'write-safety-self-test|Split builder write-safety self-test|Refusing to write official split outputs because validation failed|STAGE47_SPLIT_BUILDER_WRITE_SAFETY|official split builder write-safety self-test' research_gsure SCRATCHPAD.md`
  - `git diff --check`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- Metrics:
  - Split builder write-safety self-test: PASS
  - Invalid write attempt: refused
  - Official artifacts written by self-test: 0
  - Pre-split readiness: PASS
- Logs:
  - Official split manifest remains absent as of the preceding check.

### Remaining uncertainty
- Official split remains uncreated.
- This does not replace the post-approval official split artifact checker.

### Next recommended action
- Validate split builder write safety before any official split approval request.

## 2026-06-23 — Tile audit overwrite safety

### Task
- Prevent manual sliding-window tile budget and tile-grid dry-run outputs from
  silently overwriting previous gate evidence.

### Research question
- Could post-approval manual tile-audit commands reuse fixed output prefixes and
  overwrite existing evidence before GPU preview?

### What I inspected
- `research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md`
- `research_gsure/02_audits/scripts/run_post_split_validation.py`
- `research_gsure/02_audits/scripts/audit_sliding_window_tile_budget.py`
- `research_gsure/02_audits/scripts/audit_tile_grid_dry_run.py`

### Decision / action
- Confirmed the consolidated post-split runner already uses timestamped prefixes
  and refuses collisions.
- Found the manual fallback tile-audit scripts used plain `open("w")` and could
  overwrite existing outputs.
- Added default collision refusal plus `--allow-overwrite` to both tile-audit
  scripts.
- Added `--overwrite-safety-self-test` to both scripts.
- Connected both overwrite-safety self-tests to pre-split readiness command
  checks.
- Updated the post-approval runbook to prefer the consolidated runner and use
  UTC timestamped prefixes for manual fallback commands.
- Added `STAGE48_TILE_AUDIT_OVERWRITE_SAFETY.md`.

### Result
- `py_compile` passed.
- Sliding-window tile budget overwrite-safety self-test passed.
- Tile-grid dry-run overwrite-safety self-test passed.
- Full pre-split readiness passed with both overwrite-safety self-tests included.
- Link search found script flags, Stage48, runbook timestamped prefixes,
  approval-packet evidence, and preflight command hooks.

### Interpretation
- This protects post-split gate evidence from accidental overwrite before GPU
  preview.

### Insight tags
- ✅ SUCCESS: Manual tile-audit scripts now refuse output collisions by default.
- ⚠️ RISK: Fallback/debug commands can bypass runner-level safety if scripts
  themselves allow overwrites.
- 🧪 NEXT: Run diff check, official split absent check, and temporary directory
  cleanup check.
- 🔁 DO NOT REPEAT: Do not rely only on a wrapper runner for output safety when
  scripts are also documented for manual use.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/audit_sliding_window_tile_budget.py`
  - `research_gsure/02_audits/scripts/audit_tile_grid_dry_run.py`
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `research_gsure/02_audits/STAGE48_TILE_AUDIT_OVERWRITE_SAFETY.md`
  - `research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md`
  - `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`
  - `research_gsure/02_audits/STAGE24_PRE_SPLIT_PREFLIGHT.md`
  - `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/audit_sliding_window_tile_budget.py research_gsure/02_audits/scripts/audit_tile_grid_dry_run.py research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `python research_gsure/02_audits/scripts/audit_sliding_window_tile_budget.py --overwrite-safety-self-test`
  - `python research_gsure/02_audits/scripts/audit_tile_grid_dry_run.py --overwrite-safety-self-test`
  - `rg -n 'overwrite-safety-self-test|STAGE48_TILE_AUDIT_OVERWRITE_SAFETY|tile-audit overwrite-safety self-tests|Sliding-window tile budget overwrite-safety self-test|Tile-grid dry-run overwrite-safety self-test|allow-overwrite|RUN_TAG=\\$\\(date' research_gsure SCRATCHPAD.md`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- Metrics:
  - Sliding-window overwrite-safety self-test: PASS
  - Tile-grid overwrite-safety self-test: PASS
  - Pre-split readiness: PASS
- Logs:
  - Official split manifest remains absent as of the preceding check.

### Remaining uncertainty
- Official split remains uncreated.
- `--allow-overwrite` still exists for explicit override, so it must remain
  separately approval-gated.

### Next recommended action
- Validate tile-audit overwrite safety before any split approval request.

## 2026-06-23 — All-consortium post-split loader smoke

### Task
- Strengthen post-split validation so bounded loader smoke covers every held-out
  consortium by default.

### Research question
- Could the post-split gate miss loader or geometry failures in non-UCSD folds
  if it smokes only one held-out consortium?

### What I inspected
- `research_gsure/02_audits/scripts/run_post_split_validation.py`
- `research_gsure/01_protocol/POST_SPLIT_LOADER_SMOKE_CONTRACT.md`
- `research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md`
- `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`

### Decision / action
- Changed `run_post_split_validation.py` default `--heldout-dataset` to `all`.
- Added all-consortium expansion for:
  - `MU-Glioma-Post`
  - `UCSD-PTGBM`
  - `UPENN-GBM`
  - `UTSW`
- Updated the loader smoke contract, approval packet, post-approval runbook, and
  Stage 26 note.
- Added `STAGE37_ALL_CONSORTIUM_LOADER_SMOKE.md`.
- Added Stage 37 to preflight required files.

### Result
- `py_compile` passed.
- `run_post_split_validation.py --preview` showed four bounded loader smoke
  steps, one for each held-out consortium.
- `check_pre_split_readiness.py` passed with Stage 37 included in required
  files.
- Link/keyword search found the all-consortium smoke references.
- `git diff --check` passed.
- Official split manifest remains absent.

### Interpretation
- After official split creation, the default post-split gate will smoke all
  held-out consortia before any GPU preview can be prepared.

### Insight tags
- ✅ SUCCESS: The post-split loader gate is now less UCSD-only.
- ⚠️ RISK: This is still bounded smoke, not full data loading or training.
- 🧪 NEXT: Run py_compile, runner preview, pre-split readiness, link search, and
  diff checks.
- 🔁 DO NOT REPEAT: Do not proceed to GPU after smoking only one held-out fold.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/run_post_split_validation.py`
  - `research_gsure/01_protocol/POST_SPLIT_LOADER_SMOKE_CONTRACT.md`
  - `research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md`
  - `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`
  - `research_gsure/02_audits/STAGE37_ALL_CONSORTIUM_LOADER_SMOKE.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/run_post_split_validation.py research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `python research_gsure/02_audits/scripts/run_post_split_validation.py --preview`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `rg -n "all-consortium|all held-out|heldout-dataset.*all|STAGE37|post-split loader smoke \\(|MU-Glioma-Post.*UCSD-PTGBM.*UPENN-GBM.*UTSW" research_gsure SCRATCHPAD.md`
  - `git diff --check`
- Metrics:
  - Previewed loader smoke steps: 4
  - Official split artifacts written: 0
- Logs:
  - Preview showed smoke steps for MU-Glioma-Post, UCSD-PTGBM, UPENN-GBM, and UTSW.

### Remaining uncertainty
- Official split remains uncreated, so all-fold smoke has not actually run.

### Next recommended action
- Validate preview and keep official split creation gated.

## 2026-06-23 — Preflight document invariants

### Task
- Add semantic document invariant checks to the pre-split readiness preflight.

### Research question
- Could a critical gate phrase disappear from a required document while the file
  still exists and the preflight passes?

### What I inspected
- `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- `research_gsure/README.md`
- `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`
- `research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md`
- `research_gsure/02_audits/STAGE24_PRE_SPLIT_PREFLIGHT.md`
- `research_gsure/03_baselines/B1_GPU_PREVIEW_COMMAND_TEMPLATE.md`
- `research_gsure/01_protocol/RELIABILITY_METRIC_CONTRACT.md`

### Decision / action
- Added selected document invariant checks to `check_pre_split_readiness.py`.
- Added `STAGE36_PREFLIGHT_DOCUMENT_INVARIANTS.md`.
- Updated `STAGE24_PRE_SPLIT_PREFLIGHT.md`.

### Result
- `py_compile` passed.
- First preflight run failed because two invariant strings were too brittle
  around line breaks/backticks, not because the guardrail meaning was absent.
- Adjusted those invariants to stable substrings.
- Pre-split readiness passed after adjustment.
- Invariant link/keyword search found the guarded phrases.
- `git diff --check` passed.
- Official split manifest remains absent.

### Interpretation
- Preflight now checks a small set of gate-changing phrases, not only file
  existence.

### Insight tags
- ✅ SUCCESS: Exact split approval wording and no-GPU/no-force/oracle warnings
  are now guarded by preflight.
- ⚠️ RISK: This is not a full semantic review of every document.
- 🧪 NEXT: Run py_compile, pre-split readiness, invariant link search, and diff
  checks.
- 🔁 DO NOT REPEAT: Do not assume a required document is safe because the file
  exists.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `research_gsure/02_audits/STAGE24_PRE_SPLIT_PREFLIGHT.md`
  - `research_gsure/02_audits/STAGE36_PREFLIGHT_DOCUMENT_INVARIANTS.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `rg -n "DOCUMENT_INVARIANTS|document invariant|No GPU preview command is approved|oracle diagnostic upper-bound|PASS is not approval for GPU work|STAGE36" research_gsure SCRATCHPAD.md`
  - `git diff --check`
  - `test -e research_gsure/02_audits/outputs/loco_split_manifest.csv; echo $?`
- Metrics:
  - Pre-split readiness: PASS after invariant string adjustment
- Logs:
  - Official split artifacts remain absent.

### Remaining uncertainty
- Official split remains uncreated.
- Document invariant checks cover only selected high-risk gate phrases.

### Next recommended action
- Validate the invariants and keep official split creation gated.

## 2026-06-23 — Latest Stage audit notes added to preflight

### Task
- Ensure recent Stage 30-36 audit notes are monitored by the pre-split
  readiness required-file list.

### Research question
- Could the current gate-hardening audit trail disappear without preflight
  noticing?

### What I inspected
- `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
- `research_gsure/02_audits/STAGE30_INNER_OOF_VALIDATOR.md`
- `research_gsure/02_audits/STAGE31_RELIABILITY_METRIC_CONTRACT.md`
- `research_gsure/02_audits/STAGE32_RELIABILITY_METRIC_HARNESS.md`
- `research_gsure/02_audits/STAGE33_PRE_SPLIT_GATE_AUDIT.md`
- `research_gsure/02_audits/STAGE34_APPROVAL_PACKET_REFRESH.md`
- `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`
- `research_gsure/02_audits/STAGE36_PREFLIGHT_DOCUMENT_INVARIANTS.md`

### Decision / action
- Added Stage 30-36 audit notes to `REQUIRED_FILES` in
  `check_pre_split_readiness.py`.
- Updated `STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md` to record the broader
  required-file coverage.

### Result
- `py_compile` passed.
- Pre-split readiness passed with Stage 30-36 notes included in required files.
- `rg` coverage check found the Stage 30-36 required-file entries.
- `git diff --check` passed.

### Interpretation
- The preflight now watches the current gate-hardening audit trail, not only the
  older split/loader artifacts.

### Insight tags
- ✅ SUCCESS: Recent audit notes are now part of readiness integrity.
- ⚠️ RISK: This still verifies existence, not full semantic correctness.
- 🧪 NEXT: Run py_compile, pre-split readiness, rg coverage, and diff checks.
- 🔁 DO NOT REPEAT: Do not let the audit trail drift outside preflight coverage.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `python research_gsure/02_audits/scripts/check_pre_split_readiness.py`
  - `rg -n "STAGE30_INNER_OOF_VALIDATOR|STAGE31_RELIABILITY_METRIC_CONTRACT|STAGE32_RELIABILITY_METRIC_HARNESS|STAGE33_PRE_SPLIT_GATE_AUDIT|STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING|STAGE36_PREFLIGHT_DOCUMENT_INVARIANTS|Stage 30-36" research_gsure/02_audits/scripts/check_pre_split_readiness.py research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md SCRATCHPAD.md`
  - `git diff --check`
- Metrics:
  - Pre-split readiness: PASS
- Logs:
  - Official split artifacts remain absent.

### Remaining uncertainty
- Official split remains uncreated.
- Stage notes prove decisions and validation history, not model performance.

### Next recommended action
- Validate preflight and keep official split creation gated.

## 2026-06-23 — B1 GPU4 smoke gate revalidated before training

### Task
- Re-check the current B1 segmentation baseline state before any GPU smoke
  training.

### Research question
- Is the scratch B1 segmentation pipeline still executable and ready for a
  bounded GPU4 smoke run under the official LOCO split?

### What I inspected
- `research_gsure/03_baselines/B1_SMOKE_TRAINING_APPROVAL_PACKET.md`
- `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
- `research_gsure/03_baselines/scripts/plan_b1_fit_commands.py`
- `research_gsure/03_baselines/scripts/plan_b1_predict_commands.py`
- `research_gsure/03_baselines/scripts/validate_b1_smoke_result.py`
- `research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py`
- `research_gsure/02_audits/outputs/loco_split_manifest.csv`

### Decision / action
- Kept GPU binding fixed to physical GPU 4 via `CUDA_VISIBLE_DEVICES=4`.
- Ran only CPU/read-only validators and a real-data dry-run.
- Did not launch GPU training because the smoke packet still requires explicit
  Min approval.

### Result
- `py_compile` passed for the B1 runner, fit/predict planners, smoke validator,
  and OOF validator.
- B1 runner synthetic self-test passed, including scratch forward/backward,
  ResUNet path, loss variants, smoke artifact self-test, and prediction manifest
  row self-test.
- Fit planner self-test passed.
- Predict planner self-test passed.
- Smoke validator self-test passed.
- OOF validator synthetic self-test passed.
- Real-data dry-run passed for `heldout_dataset=UCSD-PTGBM`:
  - train rows: 1436
  - test rows: 178
  - loaded train sample orientation/zooms: RAS, 1.0mm isotropic
  - loaded test sample orientation/zooms: RAS, 1.0mm isotropic
- Smoke output directory
  `research_gsure/03_baselines/outputs/20260623_064541_b1_smoke_ucsd_192x224x160`
  does not exist yet, so the planned run would not overwrite existing smoke
  artifacts.

### Interpretation
- The current blocker is not code readiness. The blocker is explicit approval
  to launch the bounded GPU4 smoke training job.
- The smoke run remains an execution-readiness experiment, not evidence of final
  segmentation performance.

### Insight tags
- ✅ SUCCESS: CPU validators and real-data dry-run passed immediately before the
  planned GPU4 smoke gate.
- ⚠️ RISK: No real training Dice, checkpoint, OOF maps, or reliability labels
  exist yet.
- 🧪 NEXT: After explicit approval, run the GPU4 smoke command from
  `B1_SMOKE_TRAINING_APPROVAL_PACKET.md`, then validate with
  `validate_b1_smoke_result.py`.
- 🔁 DO NOT REPEAT: Do not start architecture/loss variants before the default
  `unet3d + dice_bce` smoke path produces validated artifacts.

### Evidence
- Files:
  - `research_gsure/03_baselines/B1_SMOKE_TRAINING_APPROVAL_PACKET.md`
  - `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
  - `research_gsure/03_baselines/scripts/validate_b1_smoke_result.py`
- Commands:
  - `pwd`
  - `git status --short`
  - `git branch --show-current`
  - `nvidia-smi`
  - `python -m py_compile research_gsure/03_baselines/scripts/train_b1_segmentation.py research_gsure/03_baselines/scripts/plan_b1_fit_commands.py research_gsure/03_baselines/scripts/plan_b1_predict_commands.py research_gsure/03_baselines/scripts/validate_b1_smoke_result.py research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py`
  - `python research_gsure/03_baselines/scripts/plan_b1_fit_commands.py --self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_predict_commands.py --self-test`
  - `python research_gsure/03_baselines/scripts/validate_b1_smoke_result.py --self-test`
  - `python research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py --synthetic-self-test`
  - `python research_gsure/03_baselines/scripts/train_b1_segmentation.py --synthetic-self-test --patch-shape 32,32,32`
  - `python research_gsure/03_baselines/scripts/train_b1_segmentation.py --mode dry-run --manifest research_gsure/02_audits/outputs/loco_split_manifest.csv --heldout-dataset UCSD-PTGBM --patch-shape 192,224,160 --overlap 0.50 --device cpu --amp-dtype none --load-one`
- Metrics:
  - GPU 4 at inspection: 0 MiB used.
  - UCSD held-out split dry-run: train=1436, test=178.
- Logs:
  - Dry-run loaded train sample
    `UCSD-PTGBM::train::MU-Glioma-Post::PatientID_0003::PatientID_0003::Timepoint_1`
    with shape `(240, 240, 155)`.
  - Dry-run loaded test sample
    `UCSD-PTGBM::test::UCSD-PTGBM::UCSD-PTGBM-0001::UCSD-PTGBM-0001_01`
    with shape `(256, 256, 256)`.

### Remaining uncertainty
- GPU smoke has not been run.
- Final B1 performance, OOF reliability labels, and method comparisons remain
  unmeasured.

### Next recommended action
- Approve and run the bounded GPU4 smoke training command, then validate the
  smoke output before planning full LOCO fits.

## 2026-06-23 — B1 Autoresearch status checker

### Task
- Add a CPU-only gate checker for the B1 Autoresearch baseline ladder.

### Research question
- Can the current B1 state be classified reproducibly instead of relying on
  memory of which preview, smoke, fit, or prediction artifacts exist?

### What I inspected
- `research_gsure/03_baselines/scripts/plan_b1_fit_commands.py`
- `research_gsure/03_baselines/scripts/plan_b1_predict_commands.py`
- `research_gsure/03_baselines/scripts/validate_b1_smoke_result.py`
- `research_gsure/03_baselines/B1_AUTORESEARCH_LADDER.md`
- `research_gsure/03_baselines/B1_SMOKE_TRAINING_APPROVAL_PACKET.md`
- Preview summaries under `research_gsure/03_baselines/outputs/`
- `research_gsure/02_audits/outputs/loco_split_manifest.csv`

### Decision / action
- Added `check_b1_autoresearch_status.py`.
- The checker is CPU-only and does not train, infer, write probability maps, or
  approve GPU execution.
- It checks official split availability, preview summary validity, smoke output
  status via `validate_b1_smoke_result.py`, expected fit checkpoint presence,
  and expected prediction manifest presence.
- Updated `B1_AUTORESEARCH_LADDER.md` to reference the checker.

### Result
- `py_compile` passed.
- Checker self-test passed.
- Current worktree status check reports:
  - split valid: yes
  - preview valid: 2/2
  - smoke exists: no
  - fit checkpoints: 0/4
  - prediction manifests: 0/4
  - decision stage: `ready_for_smoke_approval`

### Interpretation
- The next valid scientific/engineering action is still the bounded GPU4 B1
  smoke run after explicit approval.
- Full LOCO fit, held-out prediction, loss variants, architecture variants, and
  reliability labels remain blocked until smoke passes.

### Insight tags
- ✅ SUCCESS: B1 Autoresearch now has a machine-checkable gate status.
- ⚠️ RISK: The checker verifies artifact existence/validity, not segmentation
  performance.
- 🧪 NEXT: Run GPU4 smoke after explicit approval; then rerun this checker and
  the smoke validator.
- 🔁 DO NOT REPEAT: Do not decide the next baseline stage from conversation
  memory alone.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`
  - `research_gsure/03_baselines/B1_AUTORESEARCH_LADDER.md`
- Commands:
  - `python -m py_compile research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`
  - `python research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py --self-test`
  - `python research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`
- Metrics:
  - Checker decision: `ready_for_smoke_approval`
  - Official split rows: 6456
  - Heldout folds: 4
  - Valid preview summaries: 2
  - Smoke artifacts: absent

### Remaining uncertainty
- No real smoke checkpoint, full fit checkpoint, OOF prediction map, or
  reliability label exists yet.

### Next recommended action
- Approve and run the bounded GPU4 B1 smoke command.

## 2026-06-23 — Latest B1A chain pointer

### Task
- Keep the tail of SCRATCHPAD aligned with the latest B1A Autoresearch state.

### Research question
- Same as current B1 baseline: staged scratch segmentation baseline execution
  before any variant search.

### What I inspected
- Latest next-action output.
- B1A-specific smoke/full-fit/predict/evaluation command plans.

### Decision / action
- The detailed B1A-specific downstream chain record exists earlier in this
  scratchpad under `2026-06-23 — B1A-specific downstream command chain`.
- This pointer records the current authoritative files at the end of the log.

### Result
- Current status remains `ready_for_smoke_approval`.
- Latest action packet:
  `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_081116.md`
- Latest B1A smoke plan:
  `research_gsure/03_baselines/B1_SMOKE_COMMAND_PLAN_20260623_080846_b1a_unet3d_dice_bce_bc16_d4_smoke.md`
- Latest B1A full-fit plan:
  `research_gsure/03_baselines/B1_FULL_FIT_COMMAND_PLAN_20260623_080846_b1a_unet3d_dice_bce_bc16_d4_fit.md`
- Latest B1A prediction plan:
  `research_gsure/03_baselines/B1_PREDICT_COMMAND_PLAN_20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict.md`
- Latest B1A evaluation plan:
  `research_gsure/03_baselines/B1_EVALUATION_COMMAND_PLAN_20260623_080846_b1a_unet3d_dice_bce_bc16_d4_eval.md`

### Interpretation
- The B1A execution chain is traceable but not executed.

### Insight tags
- ✅ SUCCESS: Tail pointer now identifies the latest B1A plan chain.
- ⚠️ RISK: No real segmentation metrics exist.
- 🧪 NEXT: Approve or defer B1A-specific bounded GPU4 smoke.
- 🔁 DO NOT REPEAT: Do not use generic DRAFT plans when B1A-specific plans exist.

### Evidence
- Commands:
  - `python research_gsure/03_baselines/scripts/plan_b1_next_action.py`
  - planner self-tests for fit, predict, evaluation, next-action, and status.
  - `git diff --check`

### Remaining uncertainty
- No smoke/full-fit/prediction/evaluation result exists yet.

### Next recommended action
- Approve B1A-specific bounded GPU4 smoke execution, or explicitly defer GPU.

## 2026-06-23 — Current GPU4-fixed B1 gate

### Task
- Record the current GPU4-fixed execution gate at the end of the scratchpad.

### Research question
- Can B1 segmentation baseline execution proceed under a single fixed GPU
  binding without accidental non-GPU4 execution?

### What I inspected
- GPU inventory, B1 planners, training runtime guard, smoke/fit validators,
  plan-chain validation, and next-action controller.

### Decision / action
- Keep `CUDA_VISIBLE_DEVICES=4` as the only allowed CUDA binding for B1 smoke,
  fit, and prediction.
- Do not launch GPU training in this step.

### Result
- GPU 4 is present as an NVIDIA B200.
- Smoke, fit, and prediction planners reject non-4 `--gpu` values.
- `train_b1_segmentation.py` refuses CUDA execution unless
  `CUDA_VISIBLE_DEVICES=4`.
- Smoke and fit validators require runtime summaries to report GPU4 binding.
- Current status remains `ready_for_smoke_approval`.
- Latest plan-chain validation:
  `research_gsure/03_baselines/B1_PLAN_CHAIN_VALIDATION_20260623_084634.md`.
- Latest smoke preflight:
  `research_gsure/03_baselines/B1A_SMOKE_PREFLIGHT_20260623_085000_gpu4_fixed.md`.
- Latest next-action packet:
  `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_085000.md`.

### Interpretation
- The execution path is GPU4-fixed and internally consistent. No segmentation
  performance result exists because smoke/full-fit/prediction/evaluation have
  not been run.

### Insight tags
- ✅ SUCCESS: GPU4 binding is enforced by command planners and runtime
  artifact validators.
- ✅ SUCCESS: Fresh smoke preflight is `READY_FOR_MIN_APPROVAL`.
- ⚠️ RISK: GPU 4 currently has active utilization, so smoke runtime may be
  noisy even if memory is sufficient.
- 🧪 NEXT: Run bounded B1A GPU4 smoke only after explicit approval.
- 🔁 DO NOT REPEAT: Do not proceed to full LOCO fit until smoke output passes
  `validate_b1_smoke_result.py`.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
  - `research_gsure/03_baselines/scripts/plan_b1_smoke_command.py`
  - `research_gsure/03_baselines/scripts/plan_b1_fit_commands.py`
  - `research_gsure/03_baselines/scripts/plan_b1_predict_commands.py`
  - `research_gsure/03_baselines/scripts/validate_b1_smoke_result.py`
  - `research_gsure/03_baselines/scripts/validate_b1_fit_results.py`
- Commands:
  - `nvidia-smi --query-gpu=index,name,memory.used,memory.total,utilization.gpu --format=csv,noheader`
  - `python -m py_compile ...`
  - `python research_gsure/03_baselines/scripts/validate_b1_smoke_result.py --self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_fit_commands.py --self-test`
  - `python research_gsure/03_baselines/scripts/validate_b1_fit_results.py --self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_predict_commands.py --self-test`
  - `python research_gsure/03_baselines/scripts/preflight_b1a_smoke.py --output-md research_gsure/03_baselines/B1A_SMOKE_PREFLIGHT_20260623_085000_gpu4_fixed.md --output-json research_gsure/03_baselines/B1A_SMOKE_PREFLIGHT_20260623_085000_gpu4_fixed.json`
  - non-GPU4 planner guard checks with `--gpu 0`

### Remaining uncertainty
- No smoke artifact, full-fit checkpoint, prediction manifest, or Dice metric
  exists yet.

### Next recommended action
- Use the existing bounded smoke plan on GPU 4, then validate its artifact
  before any full-fit command.

## 2026-06-23 — Min decision: fix GPU execution to GPU4

### Task
- Record Min's instruction to keep GPU execution fixed to GPU 4.

### Research question
- Can the B1 segmentation baseline be executed without ambiguity about which
  physical GPU is used?

### What I inspected
- Current workspace state, GPU inventory, B1 status checker, latest smoke
  preflight, and `train_b1_segmentation.py` GPU guard.

### Decision / action
- Treat GPU 4 as the fixed device for B1 smoke, fit, and prediction.
- Preserve the existing `CUDA_VISIBLE_DEVICES=4` guard.
- Do not run GPU training until the exact bounded smoke command is explicitly
  approved.

### Result
- `train_b1_segmentation.py` requires `CUDA_VISIBLE_DEVICES=4` before CUDA
  execution.
- Latest smoke preflight is ready for approval and its command uses
  `CUDA_VISIBLE_DEVICES=4`.
- Current B1 stage remains `ready_for_smoke_approval`.

### Interpretation
- GPU selection is no longer an open design choice. The next executable step is
  the bounded B1A smoke run on GPU 4, followed by strict smoke validation.

### Insight tags
- 📌 MIN DECISION: Use GPU 4 as the fixed GPU.
- ✅ SUCCESS: GPU4 binding is already enforced in the training path.
- ⚠️ RISK: `nvidia-smi` showed GPU 4 at high utilization during this check.
- 🧪 NEXT: Execute only the bounded B1A smoke command on GPU 4 after exact
  command approval.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
  - `research_gsure/03_baselines/B1A_SMOKE_PREFLIGHT_20260623_085000_gpu4_fixed.md`
- Commands:
  - `pwd`
  - `git status --short`
  - `git branch --show-current`
  - `nvidia-smi`
  - `python research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`
  - `sed -n '1,120p' research_gsure/03_baselines/B1A_SMOKE_PREFLIGHT_20260623_085000_gpu4_fixed.md`
  - `sed -n '650,685p' research_gsure/03_baselines/scripts/train_b1_segmentation.py`

### Remaining uncertainty
- No smoke output or segmentation metric exists yet.

### Next recommended action
- Approve the exact B1A smoke command before launching GPU training.

## 2026-06-23 — Post-prediction transition guard

### Task
- Add a CPU-only guard for the transition from held-out prediction manifests
  to segmentation metric evaluation.

### Research question
- After all B1A held-out prediction manifests exist, can Autoresearch evaluate
  segmentation performance only when manifest schema, split membership, file
  paths, and NIfTI artifacts are all valid?

### What I inspected
- `plan_b1_evaluation_commands.py`
- `validate_oof_prediction_manifest.py`
- `validate_prediction_artifacts.py`
- `check_b1_autoresearch_status.py`

### Decision / action
- Added `research_gsure/03_baselines/scripts/plan_b1_post_prediction_transition.py`.
- The script validates every held-out prediction manifest against the official
  split with file checks, validates NIfTI probability/target artifacts, checks
  for `b1_oof_prediction_manifests_present`, and generates CPU evaluation
  commands only when those gates pass.

### Result
- `py_compile` passed.
- `plan_b1_post_prediction_transition.py --self-test` passed.
- `plan_b1_evaluation_commands.py --self-test` passed.
- Running the transition script against the current real workspace is correctly
  `BLOCKED` because no prediction manifests exist yet.

### Interpretation
- The pipeline now has an explicit safe handoff after held-out prediction:
  prediction manifests -> manifest/schema/split/file validation -> NIfTI
  artifact validation -> CPU metric evaluation plan. This prevents treating
  manifest presence alone as evidence.

### Insight tags
- ✅ SUCCESS: Post-prediction transition guard is implemented and tested.
- ⚠️ RISK: The real workspace still has no smoke, full-fit, prediction, or
  metric artifact.
- 🧪 NEXT: After prediction manifests are generated, run
  `plan_b1_post_prediction_transition.py` before metric evaluation.
- 🔁 DO NOT REPEAT: Do not compute or compare Dice from unvalidated prediction
  manifests.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/plan_b1_post_prediction_transition.py`
  - `research_gsure/03_baselines/B1_AUTORESEARCH_LADDER.md`
- Commands:
  - `python -m py_compile research_gsure/03_baselines/scripts/plan_b1_post_prediction_transition.py research_gsure/03_baselines/scripts/plan_b1_evaluation_commands.py research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py research_gsure/02_audits/scripts/validate_prediction_artifacts.py`
  - `python research_gsure/03_baselines/scripts/plan_b1_post_prediction_transition.py --self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_evaluation_commands.py --self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_post_prediction_transition.py`

### Remaining uncertainty
- No actual prediction manifest or Dice metric exists yet.

### Next recommended action
- Run the bounded B1A smoke on GPU4 after explicit approval, then proceed
  through post-smoke, post-fit, and post-prediction guards in order.

## 2026-06-23 — Post-fit transition guard

### Task
- Add a CPU-only guard for the transition from validated full-fit checkpoints
  to held-out prediction approval.

### Research question
- After all four B1A LOCO full-fit runs finish, can Autoresearch advance to
  held-out prediction only when every fit artifact passes strict validation?

### What I inspected
- `plan_b1_predict_commands.py`
- `validate_b1_fit_results.py`
- `check_b1_autoresearch_status.py`
- Existing prediction approval plan and B1 ladder.

### Decision / action
- Added `research_gsure/03_baselines/scripts/plan_b1_post_fit_transition.py`.
- Updated `plan_b1_predict_commands.py` to accept `--output-root` instead of
  hard-coding the output root.
- The new transition guard validates fit artifacts, checks for
  `fit_checkpoints_present_ready_for_prediction_approval`, and generates a
  prediction approval packet only when the fit gate is truly passed.

### Result
- `py_compile` passed.
- `plan_b1_post_fit_transition.py --self-test` passed.
- `plan_b1_predict_commands.py --self-test` passed.
- Running the transition script against the current real workspace is correctly
  `BLOCKED` because no full-fit artifacts exist yet.

### Interpretation
- The pipeline now has an explicit safe handoff after full-fit:
  full-fit artifacts -> strict fit validator -> status stage check ->
  prediction plan generation. This prevents stale or partial checkpoints from
  opening held-out prediction.

### Insight tags
- ✅ SUCCESS: Post-fit transition guard is implemented and tested.
- ⚠️ RISK: The real workspace still has no smoke or full-fit artifact.
- 🧪 NEXT: After smoke and full-fit complete, run
  `plan_b1_post_fit_transition.py` before any prediction job.
- 🔁 DO NOT REPEAT: Do not run held-out prediction from incomplete or
  unvalidated fit directories.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/plan_b1_post_fit_transition.py`
  - `research_gsure/03_baselines/scripts/plan_b1_predict_commands.py`
  - `research_gsure/03_baselines/B1_AUTORESEARCH_LADDER.md`
- Commands:
  - `python -m py_compile research_gsure/03_baselines/scripts/plan_b1_post_fit_transition.py research_gsure/03_baselines/scripts/plan_b1_predict_commands.py`
  - `python research_gsure/03_baselines/scripts/plan_b1_post_fit_transition.py --self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_predict_commands.py --self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_post_fit_transition.py`

### Remaining uncertainty
- No actual full-fit checkpoint, prediction manifest, or Dice metric exists
  yet.

### Next recommended action
- Run the bounded B1A smoke on GPU4 after explicit approval, then use the
  post-smoke and post-fit transition guards in order.

## 2026-06-23 — Post-smoke transition guard

### Task
- Add a CPU-only guard for the transition from validated smoke output to
  full-fit approval planning.

### Research question
- After the B1A smoke run finishes, can Autoresearch advance to full LOCO fit
  without manually reassembling paths or trusting a stale blocked plan?

### What I inspected
- `check_b1_autoresearch_status.py`
- `plan_b1_next_action.py`
- `plan_b1_fit_commands.py`
- `validate_b1_smoke_result.py`

### Decision / action
- Added `research_gsure/03_baselines/scripts/plan_b1_post_smoke_transition.py`.
- The script validates the smoke directory, checks that the status stage has
  advanced to `smoke_passed_ready_for_full_fit_approval`, and generates a
  full-fit approval packet only when the smoke gate is actually passed.
- It remains CPU-only and does not launch training.

### Result
- `py_compile` passed.
- Positive self-test passed: valid smoke produces a full-fit plan with four
  GPU4 commands.
- Negative self-test passed: wrong smoke GPU runtime is blocked.
- Running the transition script against the current real workspace is correctly
  `BLOCKED` because no smoke output exists yet.

### Interpretation
- The pipeline now has a stricter handoff after smoke: smoke result -> smoke
  validator -> status stage check -> full-fit plan generation. This reduces
  risk of accidentally approving full LOCO fit from a stale plan.

### Insight tags
- ✅ SUCCESS: Post-smoke transition guard is implemented and tested.
- ⚠️ RISK: The real workspace still has no smoke artifact.
- 🧪 NEXT: Execute B1A bounded smoke on GPU4 after explicit approval, then run
  `plan_b1_post_smoke_transition.py`.
- 🔁 DO NOT REPEAT: Do not manually edit a full-fit plan to bypass the smoke
  gate.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/plan_b1_post_smoke_transition.py`
  - `research_gsure/03_baselines/B1_AUTORESEARCH_LADDER.md`
- Commands:
  - `python -m py_compile research_gsure/03_baselines/scripts/plan_b1_post_smoke_transition.py`
  - `python research_gsure/03_baselines/scripts/plan_b1_post_smoke_transition.py --self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_post_smoke_transition.py`
  - `python research_gsure/03_baselines/scripts/plan_b1_fit_commands.py --self-test`
  - `python research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py --self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_next_action.py --self-test`

### Remaining uncertainty
- No actual smoke output, full-fit checkpoint, prediction manifest, or Dice
  metric exists yet.

### Next recommended action
- Run bounded B1A smoke on GPU4 after explicit approval, validate smoke output,
  then use `plan_b1_post_smoke_transition.py` to generate the full-fit approval
  packet.

## 2026-06-23 — Latest executable B1A smoke gate

### Task
- Keep the latest executable B1A smoke gate visible at the end of the research
  log.

### Research question
- What is the next evidence-producing action for the segmentation baseline?

### What I inspected
- B1 status checker, plan-chain validation, and fresh GPU4 smoke preflight.

### Decision / action
- Generated a fresh CPU-only preflight and next-action packet.
- Did not launch GPU training.

### Result
- Current stage: `ready_for_smoke_approval`.
- Fresh preflight status: `READY_FOR_MIN_APPROVAL`.
- Fresh preflight:
  `research_gsure/03_baselines/B1A_SMOKE_PREFLIGHT_20260623_085000_gpu4_fixed.md`.
- Fresh next-action packet:
  `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_085000.md`.
- No smoke output, fit checkpoint, prediction manifest, or Dice metric exists
  yet.

### Interpretation
- The next real experiment is the bounded B1A smoke run on GPU 4, followed by
  `validate_b1_smoke_result.py`.

### Insight tags
- ✅ SUCCESS: The smoke gate is ready for explicit approval.
- ⚠️ RISK: GPU 4 showed high utilization during preflight, so runtime is not a
  reliable benchmark.
- 🧪 NEXT: Execute the preflight command only if Min approves GPU work.
- 🔁 DO NOT REPEAT: Do not proceed to full-fit or variants before smoke
  validation passes.

### Evidence
- Files:
  - `research_gsure/03_baselines/B1A_SMOKE_PREFLIGHT_20260623_085000_gpu4_fixed.md`
  - `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_085000.md`
- Commands:
  - `python research_gsure/03_baselines/scripts/preflight_b1a_smoke.py --output-md research_gsure/03_baselines/B1A_SMOKE_PREFLIGHT_20260623_085000_gpu4_fixed.md --output-json research_gsure/03_baselines/B1A_SMOKE_PREFLIGHT_20260623_085000_gpu4_fixed.json`
  - `python research_gsure/03_baselines/scripts/plan_b1_next_action.py --timestamp 20260623_085000 ...`
  - `python research_gsure/03_baselines/scripts/validate_b1_plan_chain.py`

### Remaining uncertainty
- No actual segmentation performance result exists.

### Next recommended action
- Run the bounded smoke command from the fresh preflight after explicit GPU
  approval.

## 2026-06-23 — Fresh B1A GPU4 smoke preflight

### Task
- Refresh the executable B1A smoke gate after fixing GPU4 execution.

### Research question
- Is the first scratch segmentation smoke command currently ready to run on
  physical GPU 4 without output-path collision or plan-chain inconsistency?

### What I inspected
- `pwd`, `git status --short`, `git branch --show-current`
- `nvidia-smi` GPU inventory
- B1 Autoresearch status checker
- B1A smoke preflight
- B1A plan-chain validation

### Decision / action
- Generated a fresh CPU-only smoke preflight.
- Did not launch GPU training.

### Result
- Current stage: `ready_for_smoke_approval`.
- Split: valid.
- GPU preview: valid.
- Smoke artifact: absent.
- Full-fit checkpoints: `0/4`.
- Prediction manifests: `0/4`.
- Evaluation metrics: absent.
- Fresh preflight status: `READY_FOR_MIN_APPROVAL`.
- Fresh preflight file:
  `research_gsure/03_baselines/B1A_SMOKE_PREFLIGHT_20260623_085000_gpu4_fixed.md`.
- Fresh next-action packet:
  `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_085000.md`.

### Interpretation
- The next evidence-producing step is still the bounded B1A smoke run on GPU 4.
- GPU 4 is available as an NVIDIA B200, but utilization was high during
  preflight, so runtime should not be interpreted as a performance benchmark.

### Insight tags
- ✅ SUCCESS: Preflight passed and confirms the smoke command binds
  `CUDA_VISIBLE_DEVICES=4`.
- ⚠️ RISK: GPU4 utilization was high during preflight.
- 🧪 NEXT: Execute the bounded B1A smoke only after explicit approval, then run
  `validate_b1_smoke_result.py`.
- 🔁 DO NOT REPEAT: Do not start full LOCO fit before the smoke validator exits
  with code 0.

### Evidence
- Files:
  - `research_gsure/03_baselines/B1A_SMOKE_PREFLIGHT_20260623_085000_gpu4_fixed.md`
  - `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_085000.md`
  - `research_gsure/03_baselines/B1_SMOKE_COMMAND_PLAN_20260623_080846_b1a_unet3d_dice_bce_bc16_d4_smoke.md`
- Commands:
  - `python research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`
  - `python research_gsure/03_baselines/scripts/preflight_b1a_smoke.py --self-test`
  - `python research_gsure/03_baselines/scripts/preflight_b1a_smoke.py --output-md research_gsure/03_baselines/B1A_SMOKE_PREFLIGHT_20260623_085000_gpu4_fixed.md --output-json research_gsure/03_baselines/B1A_SMOKE_PREFLIGHT_20260623_085000_gpu4_fixed.json`
  - `python research_gsure/03_baselines/scripts/validate_b1_plan_chain.py`
  - `python research_gsure/03_baselines/scripts/plan_b1_next_action.py --timestamp 20260623_085000 ...`
- Metrics:
  - Plan-chain validation: PASS.
  - Preflight status: READY_FOR_MIN_APPROVAL.

### Remaining uncertainty
- No segmentation Dice or failure metric exists yet.

### Next recommended action
- Run the bounded smoke command from the preflight packet if approved.

## 2026-06-23 — GPU4 fixed execution guard for B1

### Task
- Fix B1 GPU execution to physical GPU 4 and verify the command/validator
  chain cannot silently use another GPU.

### Research question
- Can the first scratch segmentation baseline be executed under one
  reproducible GPU binding before smoke/full-fit training begins?

### What I inspected
- `nvidia-smi` GPU inventory.
- B1 smoke/full-fit/prediction planners.
- B1 training runtime guard.
- Smoke and fit artifact validators.
- B1 plan-chain and next-action controllers.

### Decision / action
- Keep GPU execution fixed to `CUDA_VISIBLE_DEVICES=4`.
- Do not launch training in this step.
- Strengthen prediction planning so fit artifacts are validated against the
  requested architecture/loss/capacity/seed before held-out inference planning.

### Result
- GPU 4 is present as an NVIDIA B200.
- Smoke, fit, and prediction planners reject non-4 GPU values.
- `train_b1_segmentation.py` requires `CUDA_VISIBLE_DEVICES=4` for CUDA use.
- Smoke and fit validators require runtime summaries to report GPU4 binding.
- Latest CPU-only plan-chain validation:
  `research_gsure/03_baselines/B1_PLAN_CHAIN_VALIDATION_20260623_084634.md`.
- Latest CPU-only next-action packet:
  `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_085000.md`.

### Interpretation
- GPU4 binding is enforced at command-generation and artifact-validation
  boundaries. No performance result exists yet because smoke/full-fit/predict
  execution has not been run.

### Insight tags
- ✅ SUCCESS: GPU4 fixed guard verified for smoke/fit/predict planners.
- ✅ SUCCESS: Smoke and fit validators self-test passed after variant-aware
  expected-config generalization.
- ⚠️ RISK: GPU 4 currently has active memory/utilization, so smoke timing may
  be noisy even though memory headroom appears sufficient.
- 🧪 NEXT: Run bounded GPU4 B1A smoke only after explicit approval.
- 🔁 DO NOT REPEAT: Do not execute fit or prediction before the bounded smoke
  artifact passes `validate_b1_smoke_result.py`.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
  - `research_gsure/03_baselines/scripts/plan_b1_smoke_command.py`
  - `research_gsure/03_baselines/scripts/plan_b1_fit_commands.py`
  - `research_gsure/03_baselines/scripts/plan_b1_predict_commands.py`
  - `research_gsure/03_baselines/scripts/validate_b1_smoke_result.py`
  - `research_gsure/03_baselines/scripts/validate_b1_fit_results.py`
  - `research_gsure/03_baselines/B1_AUTORESEARCH_LADDER.md`
- Commands:
  - `nvidia-smi --query-gpu=index,name,memory.used,memory.total,utilization.gpu --format=csv,noheader`
  - `python -m py_compile research_gsure/03_baselines/scripts/plan_b1_predict_commands.py research_gsure/03_baselines/scripts/validate_b1_smoke_result.py research_gsure/03_baselines/scripts/plan_b1_fit_commands.py research_gsure/03_baselines/scripts/validate_b1_fit_results.py`
  - `python research_gsure/03_baselines/scripts/validate_b1_smoke_result.py --self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_fit_commands.py --self-test`
  - `python research_gsure/03_baselines/scripts/validate_b1_fit_results.py --self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_predict_commands.py --self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_smoke_command.py --gpu 0 --timestamp gpu_guard_test --output-md /tmp/should_not_write.md`
  - `python research_gsure/03_baselines/scripts/plan_b1_fit_commands.py --gpu 0 --timestamp gpu_guard_test`
  - `python research_gsure/03_baselines/scripts/plan_b1_predict_commands.py --gpu 0 --fit-timestamp x --predict-timestamp y`
- Metrics:
  - Self-tests: PASS.
  - Non-GPU4 planner attempts: rejected as expected.

### Remaining uncertainty
- No new segmentation metric exists.
- No smoke artifact exists yet.

### Next recommended action
- If GPU smoke is approved, run the existing bounded B1A smoke command with
  `CUDA_VISIBLE_DEVICES=4`, then validate the smoke artifact before any
  full-fit command.

## 2026-06-23 — Fix B1 GPU execution to physical GPU4

### Task
- Lock B1/B1A GPU execution to physical GPU 4 before any training run.

### Research question
- Can the scratch 3D U-Net segmentation baseline be launched with an unambiguous,
  reproducible GPU binding?

### What I inspected
- Current git/workspace state.
- `nvidia-smi` GPU inventory.
- B1 smoke/full-fit/predict plans.
- `train_b1_segmentation.py` device-selection path.
- `preflight_b1a_smoke.py` preflight output.

### Decision / action
- Added a runtime guard in `train_b1_segmentation.py`: any CUDA execution now
  requires `CUDA_VISIBLE_DEVICES=4`.
- Generated a timestamped GPU4 smoke preflight artifact.
- Updated the next-action controller so the latest smoke preflight artifact is
  reported alongside the smoke plan.
- Did not launch GPU training.

### Result
- GPU4 is the only accepted CUDA binding for B1 execution.
- Missing or non-4 `CUDA_VISIBLE_DEVICES` fails before training starts.
- Current B1A state remains `ready_for_smoke_approval`; no smoke/full-fit/
  prediction/evaluation result exists yet.

### Interpretation
- The execution path is now safer: plan files, preflight, and runtime code all
  agree on physical GPU4.
- GPU4 had active utilization during preflight, so launch timing still needs to
  be checked immediately before execution.

### Insight tags
- ✅ SUCCESS: `CUDA_VISIBLE_DEVICES=4` guard passed; missing env guard failed as
  expected.
- ⚠️ RISK: GPU4 was busy during preflight, so runtime could still queue/slow
  down if launched while occupied.
- 🧪 NEXT: If Min approves, run only the bounded B1A smoke command, then validate
  with `validate_b1_smoke_result.py`.
- 🔁 DO NOT REPEAT: Do not run B1 training with `--device cuda` unless the command
  visibly includes `CUDA_VISIBLE_DEVICES=4`.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
  - `research_gsure/03_baselines/scripts/plan_b1_next_action.py`
  - `research_gsure/03_baselines/B1A_SMOKE_PREFLIGHT_20260623_082000_gpu4_fixed.md`
  - `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_082038.md`
- Commands:
  - `pwd`
  - `git status --short`
  - `git branch --show-current`
  - `nvidia-smi --query-gpu=index,name,memory.total,memory.used,utilization.gpu --format=csv`
  - `python -m py_compile research_gsure/03_baselines/scripts/train_b1_segmentation.py research_gsure/03_baselines/scripts/preflight_b1a_smoke.py research_gsure/03_baselines/scripts/validate_b1_plan_chain.py`
  - `python research_gsure/03_baselines/scripts/train_b1_segmentation.py --synthetic-self-test`
  - `env -u CUDA_VISIBLE_DEVICES python -c "... t.choose_device('cuda')"`
  - `CUDA_VISIBLE_DEVICES=4 python -c "... print(t.choose_device('cuda'))"`
  - `python research_gsure/03_baselines/scripts/preflight_b1a_smoke.py --output-md research_gsure/03_baselines/B1A_SMOKE_PREFLIGHT_20260623_082000_gpu4_fixed.md --output-json research_gsure/03_baselines/B1A_SMOKE_PREFLIGHT_20260623_082000_gpu4_fixed.json`
  - `python research_gsure/03_baselines/scripts/plan_b1_next_action.py --output-md research_gsure/03_baselines/B1_NEXT_ACTION_20260623_082038.md --output-json research_gsure/03_baselines/B1_NEXT_ACTION_20260623_082038.json`
- Metrics:
  - `preflight_b1a_smoke.py --self-test`: PASS
  - `validate_b1_plan_chain.py`: PASS
  - `train_b1_segmentation.py --synthetic-self-test`: PASS

### Remaining uncertainty
- No real GPU smoke training has been executed yet.
- Smoke/full-fit/prediction/evaluation artifacts are still absent.

### Next recommended action
- Recheck `nvidia-smi`, then run the bounded GPU4 B1A smoke command only if Min
  explicitly approves the launch.

## 2026-06-23 — Harden B1A smoke validation before launch

### Task
- Strengthen the CPU-only post-smoke validation path before running any GPU
  training.

### Research question
- After the bounded B1A smoke run finishes, can the artifact validator prove it
  used the intended scratch segmentation baseline configuration and GPU4 binding?

### What I inspected
- `validate_b1_smoke_result.py`
- `check_b1_autoresearch_status.py`
- `train_b1_segmentation.py`
- Current B1A smoke/preflight/plan-chain/next-action artifacts.

### Decision / action
- Added runtime environment metadata to train/preview/predict summaries,
  including `cuda_visible_devices` and required fixed GPU id.
- Hardened `validate_b1_smoke_result.py` so a passing smoke must match the B1A
  config exactly: UCSD heldout, `192,224,160`, `unet3d`, `dice_bce`,
  base channels 16, depth 4, 3 epochs, 16 steps/epoch, `cuda`, `bf16`,
  scratch initialization, and `CUDA_VISIBLE_DEVICES=4`.
- Regenerated timestamped preflight, plan-chain validation, and next-action
  artifacts.
- Did not launch GPU training.

### Result
- Current state remains `ready_for_smoke_approval`.
- Split and preview are valid.
- Smoke is pending.
- Fit checkpoints, prediction manifests, and segmentation metrics are absent.

### Interpretation
- The next smoke run is now better constrained: a different architecture, loss,
  fold, device, dtype, or GPU binding should fail post-run validation instead of
  silently advancing the Autoresearch ladder.

### Insight tags
- ✅ SUCCESS: Smoke validator self-test passes under the stricter B1A contract.
- ✅ SUCCESS: B1A plan-chain validation remains PASS.
- ⚠️ RISK: GPU4 still showed high utilization during preflight; launch timing
  must be checked immediately before execution.
- 🧪 NEXT: Await explicit Min approval for the bounded GPU4 B1A smoke command.
- 🔁 DO NOT REPEAT: Do not accept smoke artifacts from a different fold/config as
  evidence for B1A readiness.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
  - `research_gsure/03_baselines/scripts/validate_b1_smoke_result.py`
  - `research_gsure/03_baselines/B1A_SMOKE_PREFLIGHT_20260623_082338_gpu4_fixed.md`
  - `research_gsure/03_baselines/B1_PLAN_CHAIN_VALIDATION_20260623_082338.md`
  - `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_082338.md`
- Commands:
  - `python -m py_compile research_gsure/03_baselines/scripts/train_b1_segmentation.py research_gsure/03_baselines/scripts/validate_b1_smoke_result.py research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`
  - `python research_gsure/03_baselines/scripts/validate_b1_smoke_result.py --self-test`
  - `python research_gsure/03_baselines/scripts/train_b1_segmentation.py --synthetic-self-test`
  - `python research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`
  - `python research_gsure/03_baselines/scripts/preflight_b1a_smoke.py --output-md research_gsure/03_baselines/B1A_SMOKE_PREFLIGHT_20260623_082338_gpu4_fixed.md --output-json research_gsure/03_baselines/B1A_SMOKE_PREFLIGHT_20260623_082338_gpu4_fixed.json`
  - `python research_gsure/03_baselines/scripts/validate_b1_plan_chain.py --output-md research_gsure/03_baselines/B1_PLAN_CHAIN_VALIDATION_20260623_082338.md --output-json research_gsure/03_baselines/B1_PLAN_CHAIN_VALIDATION_20260623_082338.json`
  - `python research_gsure/03_baselines/scripts/plan_b1_next_action.py --output-md research_gsure/03_baselines/B1_NEXT_ACTION_20260623_082338.md --output-json research_gsure/03_baselines/B1_NEXT_ACTION_20260623_082338.json`
- Metrics:
  - `validate_b1_smoke_result.py --self-test`: PASS
  - `train_b1_segmentation.py --synthetic-self-test`: PASS
  - `check_b1_autoresearch_status.py`: `ready_for_smoke_approval`
  - Plan-chain validation: PASS

### Remaining uncertainty
- No real smoke/full-fit/predict/evaluate result exists yet.
- The next GPU smoke may be slow if GPU4 remains occupied.

### Next recommended action
- Re-run pre-launch checks, then execute the bounded GPU4 B1A smoke only after
  explicit approval.

## 2026-06-23 — Add strict B1A full-fit validation gate

### Task
- Add a CPU-only validator for B1A full-fit artifacts before prediction or
  variant promotion.

### Research question
- Can the Autoresearch ladder prevent invalid full-fit checkpoints from being
  used for held-out prediction and later architecture/loss comparisons?

### What I inspected
- B1A full-fit command plan.
- `plan_b1_fit_commands.py`
- `plan_b1_predict_commands.py`
- `check_b1_autoresearch_status.py`
- `validate_b1_plan_chain.py`
- Current status output.

### Decision / action
- Added `validate_b1_fit_results.py`.
- Wired status checking so fit artifacts are counted separately as existing vs
  strictly valid.
- Updated predict planning so prediction is blocked on missing or invalid fit
  artifacts, not mere checkpoint/summary existence.
- Updated the authoritative B1A fit/predict command plans to mention the
  full-fit validator.
- Regenerated plan-chain validation and next-action packets.
- Did not launch GPU training.

### Result
- Current state remains `ready_for_smoke_approval`.
- Smoke is still pending.
- Fit checkpoints: 0/4.
- Fit summaries: 0/4.
- Valid fits: 0/4.
- Prediction manifests: 0/4.

### Interpretation
- The B1A pipeline now has stricter gates for the eventual Autoresearch loop:
  smoke must validate, then all four full fits must validate, then prediction can
  run, then evaluation/ranking can happen.

### Insight tags
- ✅ SUCCESS: Full-fit validator self-test passes.
- ✅ SUCCESS: Status checker now reports valid/invalid fit counts.
- ✅ SUCCESS: Prediction planner blocks on `validate_b1_fit_results.py` failure.
- ⚠️ RISK: No actual B1A smoke/full-fit/evaluation result exists yet.
- 🧪 NEXT: Await explicit approval for bounded GPU4 B1A smoke.
- 🔁 DO NOT REPEAT: Do not feed checkpoint files into held-out prediction before
  full-fit validation passes.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/validate_b1_fit_results.py`
  - `research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`
  - `research_gsure/03_baselines/scripts/plan_b1_fit_commands.py`
  - `research_gsure/03_baselines/scripts/plan_b1_predict_commands.py`
  - `research_gsure/03_baselines/scripts/plan_b1_next_action.py`
  - `research_gsure/03_baselines/scripts/validate_b1_plan_chain.py`
  - `research_gsure/03_baselines/B1_FULL_FIT_COMMAND_PLAN_20260623_080846_b1a_unet3d_dice_bce_bc16_d4_fit.md`
  - `research_gsure/03_baselines/B1_PREDICT_COMMAND_PLAN_20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict.md`
  - `research_gsure/03_baselines/B1_PLAN_CHAIN_VALIDATION_20260623_082914.md`
  - `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_082914.md`
- Commands:
  - `python -m py_compile research_gsure/03_baselines/scripts/validate_b1_fit_results.py research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py research_gsure/03_baselines/scripts/plan_b1_fit_commands.py research_gsure/03_baselines/scripts/plan_b1_predict_commands.py research_gsure/03_baselines/scripts/plan_b1_next_action.py research_gsure/03_baselines/scripts/validate_b1_plan_chain.py`
  - `python research_gsure/03_baselines/scripts/validate_b1_fit_results.py --self-test`
  - `python research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py --self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_fit_commands.py --self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_predict_commands.py --self-test`
  - `python research_gsure/03_baselines/scripts/validate_b1_plan_chain.py`
  - `python research_gsure/03_baselines/scripts/plan_b1_next_action.py`
- Metrics:
  - `validate_b1_fit_results.py --self-test`: PASS
  - `check_b1_autoresearch_status.py --self-test`: PASS
  - `plan_b1_fit_commands.py --self-test`: PASS
  - `plan_b1_predict_commands.py --self-test`: PASS
  - Plan-chain validation: PASS
  - Current status: `ready_for_smoke_approval`

### Remaining uncertainty
- Whether the actual B1A model trains stably is still unknown until bounded GPU4
  smoke runs.

### Next recommended action
- Re-run pre-launch checks and execute only the bounded GPU4 B1A smoke command
  after explicit approval.

## 2026-06-23 — Require strict smoke validation before full fit planning

### Task
- Strengthen the smoke-to-full-fit handoff in the B1 Autoresearch planner.

### Research question
- Can the full-fit planner be prevented from advancing on a weak or malformed
  smoke summary that merely sets `decision.smoke_passed=true`?

### What I inspected
- `plan_b1_fit_commands.py`
- `validate_b1_smoke_result.py`
- Current B1A plan-chain and next-action outputs.

### Decision / action
- Changed `plan_b1_fit_commands.py` so `--smoke-summary` is validated through
  `validate_smoke_dir(smoke_summary.parent)`.
- Added self-test coverage for two cases:
  - fake summary with `decision.smoke_passed=true` is blocked;
  - strict B1A smoke artifact shape is passed.
- Updated the B1 ladder pointer and latest next-action/plan-chain artifacts.
- Did not run GPU training.

### Result
- Current state remains `ready_for_smoke_approval`.
- Full-fit planning is still blocked because no smoke output exists.
- Once a smoke output exists, full-fit planning now requires the strict smoke
  validator, including B1A config, GPU4 runtime, finite losses, validation Dice,
  and absence of prediction-like artifacts.

### Interpretation
- This removes a real weak link in the Autoresearch chain: a manually edited or
  incomplete smoke summary can no longer unlock full LOCO training.

### Insight tags
- ✅ SUCCESS: `plan_b1_fit_commands.py --self-test` now checks invalid and valid
  smoke gate behavior.
- ✅ SUCCESS: B1A plan-chain validation remains PASS.
- ⚠️ RISK: Actual smoke/full-fit/prediction/evaluation results still do not
  exist.
- 🧪 NEXT: Await explicit approval for bounded GPU4 B1A smoke.
- 🔁 DO NOT REPEAT: Do not use `decision.smoke_passed` alone as an execution
  gate.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/plan_b1_fit_commands.py`
  - `research_gsure/03_baselines/B1_AUTORESEARCH_LADDER.md`
  - `research_gsure/03_baselines/B1_PLAN_CHAIN_VALIDATION_20260623_084117.md`
  - `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_084117.md`
- Commands:
  - `python -m py_compile research_gsure/03_baselines/scripts/plan_b1_fit_commands.py research_gsure/03_baselines/scripts/validate_b1_smoke_result.py`
  - `python research_gsure/03_baselines/scripts/plan_b1_fit_commands.py --self-test`
  - `python research_gsure/03_baselines/scripts/validate_b1_smoke_result.py --self-test`
  - `python research_gsure/03_baselines/scripts/validate_b1_plan_chain.py`
  - `python research_gsure/03_baselines/scripts/plan_b1_next_action.py`
  - `python research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`
- Metrics:
  - `plan_b1_fit_commands.py --self-test`: PASS
  - `validate_b1_smoke_result.py --self-test`: PASS
  - Plan-chain validation: PASS
  - Current state: `ready_for_smoke_approval`

### Remaining uncertainty
- Whether the actual B1A smoke run trains stably remains unknown until approved
  GPU execution.

### Next recommended action
- Re-run pre-launch checks and execute only the bounded GPU4 B1A smoke command
  after explicit approval.

## 2026-06-23 — Extend B1 status machine through evaluation validation

### Task
- Extend the B1 Autoresearch status/next-action controller past prediction
  manifests into validated metric evaluation and leaderboard readiness.

### Research question
- Can the B1 controller track the full smoke→fit→predict→evaluate→rank handoff
  instead of stopping once OOF prediction manifests exist?

### What I inspected
- `check_b1_autoresearch_status.py`
- `plan_b1_next_action.py`
- Existing B1A plan-chain and output directories.

### Decision / action
- Added evaluation artifact status to `check_b1_autoresearch_status.py`.
- Added a new `b1_evaluation_valid_ready_for_leaderboard` stage for validated
  OOF metric outputs.
- Added `blocked_evaluation_invalid` for malformed or incomplete metric outputs.
- Updated `plan_b1_next_action.py` to show evaluation state/validity and point
  to ranking/promotion once validated metrics exist.
- Regenerated latest next-action and plan-chain validation artifacts.
- Did not run GPU training, prediction, or real metric evaluation.

### Result
- Current state remains `ready_for_smoke_approval`.
- Evaluation state is now reported as `pending`.
- Latest next-action packet includes evaluation state and summary path.

### Interpretation
- The controller now covers the full Autoresearch handoff chain needed for
  baseline-to-variant iteration. This still does not produce performance
  evidence; it makes later evidence harder to misroute.

### Insight tags
- ✅ SUCCESS: Status checker self-test passes with the extended state model.
- ✅ SUCCESS: Next-action packet now reports evaluation state and validity.
- ⚠️ RISK: No real smoke/full-fit/predict/evaluate result exists yet.
- 🧪 NEXT: Await explicit approval for bounded GPU4 B1A smoke.
- 🔁 DO NOT REPEAT: Do not treat OOF prediction manifests as the endpoint; they
  must be evaluated and validated before ranking.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`
  - `research_gsure/03_baselines/scripts/plan_b1_next_action.py`
  - `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_083816.md`
  - `research_gsure/03_baselines/B1_PLAN_CHAIN_VALIDATION_20260623_083816.md`
- Commands:
  - `python -m py_compile research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py research_gsure/03_baselines/scripts/plan_b1_next_action.py`
  - `python research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py --self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_next_action.py --self-test`
  - `python research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`
  - `python research_gsure/03_baselines/scripts/plan_b1_next_action.py`
  - `python research_gsure/03_baselines/scripts/validate_b1_plan_chain.py --output-md research_gsure/03_baselines/B1_PLAN_CHAIN_VALIDATION_20260623_083816.md --output-json research_gsure/03_baselines/B1_PLAN_CHAIN_VALIDATION_20260623_083816.json`
  - `python research_gsure/03_baselines/scripts/plan_b1_next_action.py --output-md research_gsure/03_baselines/B1_NEXT_ACTION_20260623_083816.md --output-json research_gsure/03_baselines/B1_NEXT_ACTION_20260623_083816.json`
- Metrics:
  - `check_b1_autoresearch_status.py --self-test`: PASS
  - `plan_b1_next_action.py --self-test`: PASS
  - Current state: `ready_for_smoke_approval`
  - Evaluation state: `pending`

### Remaining uncertainty
- Actual B1A segmentation performance remains unknown until the GPU smoke,
  full-fit, prediction, and evaluation gates run.

### Next recommended action
- Re-run pre-launch checks and execute only the bounded GPU4 B1A smoke command
  after explicit approval.

## 2026-06-23 — Add strict B1 evaluation validation before ranking

### Task
- Add a CPU-only validation gate between segmentation metric evaluation and
  variant leaderboard/promotion.

### Research question
- Can the Autoresearch loop prevent incomplete or malformed OOF metric summaries
  from being ranked as candidate segmentation baselines?

### What I inspected
- `evaluate_b1_segmentation_predictions.py`
- `rank_b1_segmentation_variants.py`
- `decide_b1_variant_promotion.py`
- `plan_b1_evaluation_commands.py`
- Current B1A evaluation command plan and plan-chain validator.

### Decision / action
- Added `validate_b1_evaluation_results.py`.
- Updated evaluation command planning so metric computation is followed by
  strict summary validation before ranking.
- Updated ranker so summary JSON files must pass evaluation validation to be
  eligible for selection.
- Updated promotion decision so old leaderboards without declared strict
  evaluation validation are not evaluable.
- Updated the authoritative B1A evaluation plan and ladder pointers.
- Did not run GPU training, prediction, or real metric evaluation.

### Result
- Evaluation validator self-test passes.
- Ranker self-test passes with strict synthetic evaluation artifacts.
- Promotion decision self-test passes with validation-aware leaderboard rows.
- Plan-chain validation remains PASS.
- Current execution state remains `ready_for_smoke_approval`.

### Interpretation
- The Autoresearch ladder now has gates for smoke, full fit, prediction,
  evaluation, ranking, and promotion. This still does not produce performance
  results, but it reduces the chance that a bad or incomplete artifact is treated
  as scientific evidence later.

### Insight tags
- ✅ SUCCESS: Evaluation summary validation is now mandatory before leaderboard
  eligibility.
- ✅ SUCCESS: Promotion decisions reject leaderboards that do not declare strict
  evaluation validation.
- ⚠️ RISK: No real B1A smoke/full-fit/predict/evaluate result exists yet.
- 🧪 NEXT: Await explicit approval for bounded GPU4 B1A smoke.
- 🔁 DO NOT REPEAT: Do not rank variants from summary JSON alone without
  validating official LOCO row coverage and selection-guard consistency.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/validate_b1_evaluation_results.py`
  - `research_gsure/03_baselines/scripts/rank_b1_segmentation_variants.py`
  - `research_gsure/03_baselines/scripts/decide_b1_variant_promotion.py`
  - `research_gsure/03_baselines/scripts/plan_b1_evaluation_commands.py`
  - `research_gsure/03_baselines/scripts/validate_b1_plan_chain.py`
  - `research_gsure/03_baselines/B1_EVALUATION_COMMAND_PLAN_20260623_080846_b1a_unet3d_dice_bce_bc16_d4_eval.md`
  - `research_gsure/03_baselines/B1_PLAN_CHAIN_VALIDATION_20260623_083509.md`
  - `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_083509.md`
- Commands:
  - `python -m py_compile research_gsure/03_baselines/scripts/validate_b1_evaluation_results.py research_gsure/03_baselines/scripts/rank_b1_segmentation_variants.py research_gsure/03_baselines/scripts/decide_b1_variant_promotion.py research_gsure/03_baselines/scripts/plan_b1_evaluation_commands.py research_gsure/03_baselines/scripts/validate_b1_plan_chain.py`
  - `python research_gsure/03_baselines/scripts/validate_b1_evaluation_results.py --self-test`
  - `python research_gsure/03_baselines/scripts/rank_b1_segmentation_variants.py --synthetic-self-test`
  - `python research_gsure/03_baselines/scripts/decide_b1_variant_promotion.py --self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_evaluation_commands.py --self-test`
  - `python research_gsure/03_baselines/scripts/validate_b1_plan_chain.py`
  - `python research_gsure/03_baselines/scripts/plan_b1_next_action.py`
- Metrics:
  - `validate_b1_evaluation_results.py --self-test`: PASS
  - `rank_b1_segmentation_variants.py --synthetic-self-test`: PASS
  - `decide_b1_variant_promotion.py --self-test`: PASS
  - `plan_b1_evaluation_commands.py --self-test`: PASS
  - Plan-chain validation: PASS

### Remaining uncertainty
- Actual B1A segmentation performance remains unknown.

### Next recommended action
- Re-run pre-launch checks and execute only the bounded GPU4 B1A smoke command
  after explicit approval.

## 2026-06-23 — B1A plan-chain validator

### Task
- Add a CPU-only validator for the B1A smoke/full-fit/predict/evaluation plan
  chain.

### Research question
- Does not change the segmentation baseline question. This verifies that the
  staged B1A command plans are internally consistent before any GPU execution.

### What I inspected
- B1A smoke command plan.
- B1A full-fit command plan.
- B1A prediction command plan.
- B1A evaluation command plan.
- Current next-action packet.

### Decision / action
- Added `validate_b1_plan_chain.py`.
- Generated:
  - `research_gsure/03_baselines/B1_PLAN_CHAIN_VALIDATION_20260623_081453.md`
  - `research_gsure/03_baselines/B1_PLAN_CHAIN_VALIDATION_20260623_081453.json`
- Updated `plan_b1_next_action.py` so next-action packets include the latest
  plan-chain validation report.
- Generated:
  - `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_081513.md`
  - `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_081513.json`
- Updated `B1_AUTORESEARCH_LADDER.md`.
- Did not run GPU training, prediction, evaluation, or metric reporting.

### Result
- B1A plan-chain validation status: `PASS`.
- Planned output dirs checked: 10.
- Existing planned output dirs: 0.
- No validation errors or warnings.

### Interpretation
- The B1A staged plan chain is internally consistent.
- This does not mean any training or segmentation result exists.

### Insight tags
- ✅ SUCCESS: B1A plan chain has a reusable validation report.
- ⚠️ RISK: The next evidence-producing action is still GPU approval-gated.
- 🧪 NEXT: Approve or defer B1A-specific bounded GPU4 smoke.
- 🔁 DO NOT REPEAT: Do not manually stitch plan files without running the
  plan-chain validator.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/validate_b1_plan_chain.py`
  - `research_gsure/03_baselines/B1_PLAN_CHAIN_VALIDATION_20260623_081453.md`
  - `research_gsure/03_baselines/B1_PLAN_CHAIN_VALIDATION_20260623_081453.json`
  - `research_gsure/03_baselines/scripts/plan_b1_next_action.py`
  - `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_081513.md`
  - `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_081513.json`
  - `research_gsure/03_baselines/B1_AUTORESEARCH_LADDER.md`
- Commands:
  - `python -m py_compile research_gsure/03_baselines/scripts/validate_b1_plan_chain.py`
  - `python research_gsure/03_baselines/scripts/validate_b1_plan_chain.py --self-test`
  - `python research_gsure/03_baselines/scripts/validate_b1_plan_chain.py`
  - `python research_gsure/03_baselines/scripts/validate_b1_plan_chain.py --output-md research_gsure/03_baselines/B1_PLAN_CHAIN_VALIDATION_20260623_081453.md --output-json research_gsure/03_baselines/B1_PLAN_CHAIN_VALIDATION_20260623_081453.json`
  - `python research_gsure/03_baselines/scripts/plan_b1_next_action.py --self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_next_action.py --timestamp 20260623_081513 --output-md research_gsure/03_baselines/B1_NEXT_ACTION_20260623_081513.md --output-json research_gsure/03_baselines/B1_NEXT_ACTION_20260623_081513.json`
- Metrics:
  - Plan-chain validation: PASS
  - planned output dirs: 10
  - existing planned output dirs: 0

### Remaining uncertainty
- No smoke/full-fit/prediction/evaluation artifact exists yet.

### Next recommended action
- Approve B1A-specific bounded GPU4 smoke execution, or explicitly defer GPU.

## 2026-06-23 — B1A-specific downstream command chain

### Task
- Generate B1A-specific full-fit, prediction, and evaluation command plans
  aligned to the latest B1A smoke plan.

### Research question
- Does not change the research question. This ensures that the first scratch
  segmentation baseline can move from smoke to LOCO fit, prediction, and OOF
  evaluation without generic/draft path confusion.

### What I inspected
- Existing smoke, full-fit, prediction, evaluation, and next-action plan files.
- Current status checker output.
- Current next-action output.

### Decision / action
- Generated B1A-specific downstream plans:
  - `research_gsure/03_baselines/B1_FULL_FIT_COMMAND_PLAN_20260623_080846_b1a_unet3d_dice_bce_bc16_d4_fit.md`
  - `research_gsure/03_baselines/B1_PREDICT_COMMAND_PLAN_20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict.md`
  - `research_gsure/03_baselines/B1_EVALUATION_COMMAND_PLAN_20260623_080846_b1a_unet3d_dice_bce_bc16_d4_eval.md`
- Updated `plan_b1_next_action.py` to prefer timestamped plans over `DRAFT`
  fallback files.
- Generated updated next-action packet:
  - `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_081116.md`
  - `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_081116.json`
- Updated `B1_AUTORESEARCH_LADDER.md` to point to the latest next-action
  packet.
- Did not run GPU training, prediction, evaluation, or metric reporting.

### Result
- Latest next-action now points to:
  - B1A smoke plan:
    `B1_SMOKE_COMMAND_PLAN_20260623_080846_b1a_unet3d_dice_bce_bc16_d4_smoke.md`
  - B1A full-fit plan:
    `B1_FULL_FIT_COMMAND_PLAN_20260623_080846_b1a_unet3d_dice_bce_bc16_d4_fit.md`
  - B1A prediction plan:
    `B1_PREDICT_COMMAND_PLAN_20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict.md`
  - B1A evaluation plan:
    `B1_EVALUATION_COMMAND_PLAN_20260623_080846_b1a_unet3d_dice_bce_bc16_d4_eval.md`
- Full-fit plan is correctly blocked until smoke summary exists.
- Prediction plan is correctly blocked until all fit checkpoints/summaries
  exist.
- Evaluation plan is correctly blocked until all prediction manifests exist.

### Interpretation
- The full B1A command chain is now traceable and ready for staged approval.
- This still gives no real segmentation result; it only fixes execution
  planning.

### Insight tags
- ✅ SUCCESS: B1A smoke -> fit -> predict -> evaluate plan chain is aligned.
- ⚠️ RISK: GPU execution remains approval-gated.
- 🧪 NEXT: Run B1A-specific GPU4 smoke if approved, then validate smoke before
  using the B1A full-fit plan.
- 🔁 DO NOT REPEAT: Do not use generic DRAFT downstream plans for the B1A run
  unless intentionally reverting to draft planning.

### Evidence
- Files:
  - `research_gsure/03_baselines/B1_FULL_FIT_COMMAND_PLAN_20260623_080846_b1a_unet3d_dice_bce_bc16_d4_fit.md`
  - `research_gsure/03_baselines/B1_PREDICT_COMMAND_PLAN_20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict.md`
  - `research_gsure/03_baselines/B1_EVALUATION_COMMAND_PLAN_20260623_080846_b1a_unet3d_dice_bce_bc16_d4_eval.md`
  - `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_081116.md`
  - `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_081116.json`
  - `research_gsure/03_baselines/scripts/plan_b1_next_action.py`
  - `research_gsure/03_baselines/B1_AUTORESEARCH_LADDER.md`
- Commands:
  - `python research_gsure/03_baselines/scripts/plan_b1_fit_commands.py --timestamp 20260623_080846_b1a_unet3d_dice_bce_bc16_d4_fit ...`
  - `python research_gsure/03_baselines/scripts/plan_b1_predict_commands.py --fit-timestamp 20260623_080846_b1a_unet3d_dice_bce_bc16_d4_fit --predict-timestamp 20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict ...`
  - `python research_gsure/03_baselines/scripts/plan_b1_evaluation_commands.py --predict-timestamp 20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict --metrics-timestamp 20260623_080846_b1a_unet3d_dice_bce_bc16_d4_eval ...`
  - `python research_gsure/03_baselines/scripts/plan_b1_next_action.py --timestamp 20260623_081116 --output-md research_gsure/03_baselines/B1_NEXT_ACTION_20260623_081116.md --output-json research_gsure/03_baselines/B1_NEXT_ACTION_20260623_081116.json`
  - Python output-dir absence check for B1A smoke/fit/predict/eval outputs.
  - `python -m py_compile research_gsure/03_baselines/scripts/plan_b1_fit_commands.py research_gsure/03_baselines/scripts/plan_b1_predict_commands.py research_gsure/03_baselines/scripts/plan_b1_evaluation_commands.py research_gsure/03_baselines/scripts/plan_b1_next_action.py`
  - planner self-tests for fit, predict, evaluation, and next-action.
  - `git diff --check`
- Metrics:
  - Planned output dirs checked: 10
  - Existing planned output dirs: 0
  - Status stage: `ready_for_smoke_approval`

### Remaining uncertainty
- No real smoke, full-fit, prediction, evaluation, or leaderboard result exists
  yet.

### Next recommended action
- Approve B1A-specific bounded GPU4 smoke execution, or explicitly defer GPU.

## 2026-06-23 — B1 next-action controller

### Task
- Add a CPU-only controller that summarizes the current B1 Autoresearch state
  and emits the single next valid action.

### Research question
- Can B1 Autoresearch progress from baseline smoke to full LOCO training,
  prediction, evaluation, and later variants without losing the current gate
  state across sessions?

### What I inspected
- Current worktree, branch, and B1 baseline artifact list.
- `check_b1_autoresearch_status.py`
- `plan_b1_smoke_command.py`
- Latest smoke command plan.
- Current status checker JSON.

### Decision / action
- Added `plan_b1_next_action.py`.
- Generated:
  - `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_080444.md`
  - `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_080444.json`
- Linked the next-action controller from `B1_AUTORESEARCH_LADDER.md`.
- Did not run GPU training, inference, prediction generation, or metric
  evaluation.

### Result
- Current next-action packet reports:
  - status stage: `ready_for_smoke_approval`
  - action type: `request_gpu_approval`
  - plan file: `B1_SMOKE_COMMAND_PLAN_20260623_075613.md`
  - checkpoints: `0/4`
  - fit summaries: `0/4`
  - prediction manifests: `0/4`

### Interpretation
- The workspace now has one preferred entry point for the next B1 action.
- The controller confirms that the only valid next evidence-producing action is
  bounded GPU4 smoke, not later variants.

### Insight tags
- ✅ SUCCESS: Current B1 state can now be summarized by a reproducible
  next-action packet.
- ⚠️ RISK: The packet still requires explicit Min approval before GPU work.
- 🧪 NEXT: If approved, run the exact GPU4 smoke command from
  `B1_SMOKE_COMMAND_PLAN_20260623_075613.md`.
- 🔁 DO NOT REPEAT: Do not infer the next action from memory; inspect the latest
  next-action packet or rerun the controller.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/plan_b1_next_action.py`
  - `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_080444.md`
  - `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_080444.json`
  - `research_gsure/03_baselines/B1_AUTORESEARCH_LADDER.md`
- Commands:
  - `python -m py_compile research_gsure/03_baselines/scripts/plan_b1_next_action.py research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`
  - `python research_gsure/03_baselines/scripts/plan_b1_next_action.py --self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_next_action.py`
  - `python research_gsure/03_baselines/scripts/plan_b1_next_action.py --timestamp 20260623_080444 --output-md research_gsure/03_baselines/B1_NEXT_ACTION_20260623_080444.md --output-json research_gsure/03_baselines/B1_NEXT_ACTION_20260623_080444.json`
  - `python -m json.tool research_gsure/03_baselines/B1_NEXT_ACTION_20260623_080444.json`
  - `rg -n -- 'ready_for_smoke_approval|request_gpu_approval|B1_SMOKE_COMMAND_PLAN_20260623_075613|B1_VARIANT_LADDER_PLAN_20260623_080158' research_gsure/03_baselines/B1_NEXT_ACTION_20260623_080444.md research_gsure/03_baselines/B1_NEXT_ACTION_20260623_080444.json`
  - `git diff --check`
- Metrics:
  - Next-action self-test: PASS
  - Current status stage: `ready_for_smoke_approval`

### Remaining uncertainty
- No real smoke output, full-fit checkpoint, prediction manifest, or
  segmentation metric exists yet.

### Next recommended action
- Approve bounded GPU4 B1A smoke execution, or explicitly defer GPU and keep
  hardening CPU-only orchestration.

## 2026-06-23 — B1 variant promotion decision layer

### Task
- Add a CPU-only decision layer for promoting or rejecting B1 segmentation
  variants after real leaderboard metrics exist.

### Research question
- When loss/architecture/capacity variants are evaluated, can we decide whether
  a candidate is genuinely better than B1A using worst-consortium performance
  rather than pooled mean Dice?

### What I inspected
- `rank_b1_segmentation_variants.py`
- `plan_b1_variant_ladder.py`
- `B1_AUTORESEARCH_LADDER.md`
- Current next-action artifacts.

### Decision / action
- Added `decide_b1_variant_promotion.py`.
- Added `B1_VARIANT_PROMOTION_DECISION_PLAN.md`.
- Linked the promotion decision layer from `B1_AUTORESEARCH_LADDER.md`.
- Updated `plan_b1_next_action.py` so next-action packets include the promotion
  decision plan.
- Generated updated next-action packet:
  - `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_080732.md`
  - `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_080732.json`
- Did not run GPU training, inference, evaluation, or metric reporting.

### Result
- Promotion rule is explicit:
  - candidate must be eligible,
  - must include four consortium rows,
  - must improve worst-consortium mean Dice over B1A by at least `0.01`,
  - must not increase overall `Dice <= 0.8` failure rate by more than `0.02`.
- Current next-action is unchanged:
  - `ready_for_smoke_approval`
  - `request_gpu_approval`
  - plan file `B1_SMOKE_COMMAND_PLAN_20260623_075613.md`.

### Interpretation
- Autoresearch now has a guarded path not only to run variants, but to reject or
  promote them after metrics exist.
- This still does not provide any real segmentation result.

### Insight tags
- ✅ SUCCESS: Variant promotion is now tied to worst-consortium improvement and
  failure-rate guard.
- ⚠️ RISK: The decision tool is blocked until real leaderboard JSON exists.
- 🧪 NEXT: Run bounded GPU4 B1A smoke if approved; promotion logic is for later.
- 🔁 DO NOT REPEAT: Do not promote a variant based on pooled mean Dice alone.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/decide_b1_variant_promotion.py`
  - `research_gsure/03_baselines/B1_VARIANT_PROMOTION_DECISION_PLAN.md`
  - `research_gsure/03_baselines/scripts/plan_b1_next_action.py`
  - `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_080732.md`
  - `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_080732.json`
  - `research_gsure/03_baselines/B1_AUTORESEARCH_LADDER.md`
- Commands:
  - `python -m py_compile research_gsure/03_baselines/scripts/decide_b1_variant_promotion.py research_gsure/03_baselines/scripts/rank_b1_segmentation_variants.py`
  - `python research_gsure/03_baselines/scripts/decide_b1_variant_promotion.py --self-test`
  - `python research_gsure/03_baselines/scripts/decide_b1_variant_promotion.py`
  - `python -m py_compile research_gsure/03_baselines/scripts/plan_b1_next_action.py research_gsure/03_baselines/scripts/decide_b1_variant_promotion.py`
  - `python research_gsure/03_baselines/scripts/plan_b1_next_action.py --self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_next_action.py --timestamp 20260623_080732 --output-md research_gsure/03_baselines/B1_NEXT_ACTION_20260623_080732.md --output-json research_gsure/03_baselines/B1_NEXT_ACTION_20260623_080732.json`
  - `python -m json.tool research_gsure/03_baselines/B1_NEXT_ACTION_20260623_080732.json`
  - `rg -n -- 'decide_b1_variant_promotion|B1_VARIANT_PROMOTION_DECISION_PLAN|worst-consortium Dice|pooled mean Dice' research_gsure/03_baselines/B1_AUTORESEARCH_LADDER.md research_gsure/03_baselines/B1_VARIANT_PROMOTION_DECISION_PLAN.md research_gsure/03_baselines/scripts/plan_b1_next_action.py`
- Metrics:
  - Promotion decision self-test: PASS
  - Next-action self-test: PASS
  - Current status stage: `ready_for_smoke_approval`

### Remaining uncertainty
- No real B1A smoke/full-fit/OOF/evaluation/leaderboard results exist yet.

### Next recommended action
- Approve bounded GPU4 B1A smoke execution, or keep CPU-only planning but do
  not claim baseline performance.

## 2026-06-23 — Align latest smoke plan with B1A variant identity

### Task
- Regenerate the next smoke command plan with the primary B1A variant name in
  the run timestamp.

### Research question
- Does not change the research question. This improves experiment traceability
  for the first scratch segmentation baseline before actual GPU smoke.

### What I inspected
- Current smoke command plans.
- Current B1 variant ladder plan.
- Current next-action output.
- Current B1 status checker output.

### Decision / action
- Generated:
  `research_gsure/03_baselines/B1_SMOKE_COMMAND_PLAN_20260623_080846_b1a_unet3d_dice_bce_bc16_d4_smoke.md`.
- Generated updated next-action packet:
  - `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_080901.md`
  - `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_080901.json`
- Did not run GPU training.

### Result
- Latest next-action now points to the B1A-specific smoke plan.
- Planned output dir is absent:
  `research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_smoke_b1_smoke_UCSD-PTGBM_192x224x160`.
- Status remains `ready_for_smoke_approval`.

### Interpretation
- The next actual smoke run will be easier to trace back to
  `b1a_unet3d_dice_bce_bc16_d4`.
- This still provides no real segmentation performance evidence.

### Insight tags
- ✅ SUCCESS: Latest smoke plan and next-action packet now align with B1A.
- ⚠️ RISK: GPU execution is still approval-gated.
- 🧪 NEXT: If approved, run the B1A-specific GPU4 smoke command.
- 🔁 DO NOT REPEAT: Do not run the older generic smoke plan unless explicitly
  choosing to ignore variant-traceability.

### Evidence
- Files:
  - `research_gsure/03_baselines/B1_SMOKE_COMMAND_PLAN_20260623_080846_b1a_unet3d_dice_bce_bc16_d4_smoke.md`
  - `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_080901.md`
  - `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_080901.json`
- Commands:
  - `python research_gsure/03_baselines/scripts/plan_b1_smoke_command.py --timestamp 20260623_080846_b1a_unet3d_dice_bce_bc16_d4_smoke --architecture unet3d --loss dice_bce --base-channels 16 --depth 4 --gpu 4 --output-md research_gsure/03_baselines/B1_SMOKE_COMMAND_PLAN_20260623_080846_b1a_unet3d_dice_bce_bc16_d4_smoke.md`
  - `test ! -e research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_smoke_b1_smoke_UCSD-PTGBM_192x224x160`
  - `python research_gsure/03_baselines/scripts/plan_b1_next_action.py --timestamp 20260623_080901 --output-md research_gsure/03_baselines/B1_NEXT_ACTION_20260623_080901.md --output-json research_gsure/03_baselines/B1_NEXT_ACTION_20260623_080901.json`
  - `bash -n` on the B1A-specific smoke command.
  - `python -m py_compile research_gsure/03_baselines/scripts/plan_b1_smoke_command.py research_gsure/03_baselines/scripts/plan_b1_next_action.py research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`
  - `python research_gsure/03_baselines/scripts/plan_b1_smoke_command.py --self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_next_action.py --self-test`
  - `python research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py --self-test`
- Metrics:
  - planner self-tests: PASS
  - shell syntax: PASS
  - current status stage: `ready_for_smoke_approval`

### Remaining uncertainty
- No smoke output, full-fit checkpoint, OOF prediction, or segmentation metric
  exists yet.

### Next recommended action
- Approve bounded GPU4 B1A smoke execution, or explicitly defer GPU execution.

## 2026-06-23 — B1 GPU4 smoke command planner

### Task
- Add a CPU-only planner for the bounded B1 GPU4 smoke command.

### Research question
- Does not change the G-SURE research question. This supports the first
  scratch segmentation baseline by making the smoke-launch gate reproducible,
  GPU4-fixed, and overwrite-safe.

### What I inspected
- Current worktree, branch, and B1 baseline file layout.
- `nvidia-smi` GPU memory/utilization summary.
- Existing B1 smoke approval packet.
- Existing B1 fit/predict command planners.
- GPU preview summary for `192x224x160@0.50`.
- Current B1 Autoresearch status checker output.

### Decision / action
- Added `plan_b1_smoke_command.py`.
- The planner is CPU-only and does not train, infer, write predictions, or
  generate reliability labels.
- It enforces physical GPU 4 only.
- It checks preview summary, official split, and output-dir nonexistence before
  marking the plan `READY_FOR_MIN_APPROVAL`.
- It writes timestamped command-plan markdown without overwriting existing
  files.
- Updated `check_b1_autoresearch_status.py` so default status checks discover
  the latest matching smoke directory instead of relying on one stale fixed
  timestamp.
- Generated latest plan:
  `research_gsure/03_baselines/B1_SMOKE_COMMAND_PLAN_20260623_075613.md`.
- Did not launch GPU training.

### Result
- Latest plan gate:
  - overall: `READY_FOR_MIN_APPROVAL`
  - preview: `PASSED`
  - split: `PASSED`
  - output: `PASSED`
- Planned output dir is absent:
  `research_gsure/03_baselines/outputs/20260623_075613_b1_smoke_UCSD-PTGBM_192x224x160`.
- Current Autoresearch checker remains `ready_for_smoke_approval`.

### Interpretation
- The next GPU4 smoke command is now cleaner than the static approval packet:
  it has a fresh timestamp, checks overwrite risk, and includes post-run
  validation.
- This is still not segmentation performance evidence.

### Insight tags
- ✅ SUCCESS: B1 smoke launch planning is now script-generated and GPU4-only.
- ⚠️ RISK: GPU 4 availability must still be checked immediately before launch.
- 🧪 NEXT: If Min approves, run the smoke command from
  `B1_SMOKE_COMMAND_PLAN_20260623_075613.md`.
- 🔁 DO NOT REPEAT: Do not use stale static smoke timestamps when launching.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/plan_b1_smoke_command.py`
  - `research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`
  - `research_gsure/03_baselines/B1_SMOKE_COMMAND_PLAN_20260623_075613.md`
- Commands:
  - `pwd`
  - `git status --short`
  - `git branch --show-current`
  - `python -m py_compile research_gsure/03_baselines/scripts/plan_b1_smoke_command.py`
  - `python research_gsure/03_baselines/scripts/plan_b1_smoke_command.py --self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_smoke_command.py --gpu 0`
  - `python research_gsure/03_baselines/scripts/plan_b1_smoke_command.py --timestamp 20260623_080500`
  - `python research_gsure/03_baselines/scripts/plan_b1_smoke_command.py --timestamp 20260623_075613 --output-md research_gsure/03_baselines/B1_SMOKE_COMMAND_PLAN_20260623_075613.md`
  - `python research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py --self-test`
  - `test ! -e research_gsure/03_baselines/outputs/20260623_075613_b1_smoke_UCSD-PTGBM_192x224x160`
  - `python research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`
  - `git diff --check`
- Metrics:
  - Planner self-test: PASS
  - GPU override negative test: PASS (`--gpu 0` exits nonzero)
  - Current status stage: `ready_for_smoke_approval`

### Remaining uncertainty
- No smoke training has run yet.
- No full-fit checkpoints, prediction manifests, or segmentation metrics exist.

### Next recommended action
- Approve the bounded GPU4 smoke command, or explicitly defer GPU execution and
  continue CPU-only protocol hardening.

## 2026-06-23 — B1 variant ladder planner and capacity-aware model IDs

### Task
- Prepare Autoresearch planning for B1 baseline variants after the first scratch
  segmentation baseline.

### Research question
- Can scratch 3D segmentation performance be improved through controlled loss,
  architecture, and capacity variants while preserving LOCO generalization and
  worst-consortium selection guards?

### What I inspected
- `B1_AUTORESEARCH_LADDER.md`
- `rank_b1_segmentation_variants.py`
- `plan_b1_evaluation_commands.py`
- `B1_VARIANT_LEADERBOARD_PLAN_DRAFT.md`
- `train_b1_segmentation.py` architecture/loss/capacity knobs.

### Decision / action
- Added `plan_b1_variant_ladder.py`.
- Generated:
  `research_gsure/03_baselines/B1_VARIANT_LADDER_PLAN_20260623_080158.md`.
- Fixed default B1 `model_id` to include `base_channels` and `depth`, not only
  architecture/loss/seed.
- Fixed prediction planner default model prefix to include `base_channels` and
  `depth`.
- Updated checker/validator synthetic fixtures for the new capacity-aware model
  ID format.
- Linked the variant ladder planner from `B1_AUTORESEARCH_LADDER.md`.
- Did not run GPU training, inference, or metric evaluation.

### Result
- Variant registry now includes:
  - `b1a_unet3d_dice_bce_bc16_d4`
  - `b1b_unet3d_dice_focal_bc16_d4`
  - `b1c_unet3d_dice_tversky_bc16_d4`
  - `b1d_resunet3d_dice_bce_bc16_d4`
  - `b1e_resunet3d_dice_focal_bc16_d4`
  - `b1f_unet3d_dice_bce_bc24_d4`
- Current status remains:
  - B1A = next after explicit GPU4 smoke approval.
  - All later variants = blocked until primary baseline OOF metrics exist.

### Interpretation
- Autoresearch now has a reproducible post-baseline search path instead of an
  ad hoc hyperparameter sweep.
- The plan explicitly prevents selecting by pooled mean Dice alone.

### Insight tags
- ✅ SUCCESS: Variant identities are now capacity-aware and less likely to
  collide across experiments.
- ✅ SUCCESS: Loss, architecture, and capacity variants have a staged plan.
- ⚠️ RISK: No real B1A OOF metrics exist yet; later variants must not run first.
- 🔁 DO NOT REPEAT: Do not launch multiple variants before B1A has full LOCO
  segmentation metrics.
- 🧪 NEXT: Run bounded GPU4 smoke if Min approves; then full LOCO B1A before
  any B1B/B1C/B1D variant.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/plan_b1_variant_ladder.py`
  - `research_gsure/03_baselines/B1_VARIANT_LADDER_PLAN_20260623_080158.md`
  - `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
  - `research_gsure/03_baselines/scripts/plan_b1_predict_commands.py`
  - `research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`
  - `research_gsure/03_baselines/scripts/validate_b1_smoke_result.py`
  - `research_gsure/03_baselines/B1_AUTORESEARCH_LADDER.md`
- Commands:
  - `python -m py_compile research_gsure/03_baselines/scripts/plan_b1_variant_ladder.py research_gsure/03_baselines/scripts/train_b1_segmentation.py research_gsure/03_baselines/scripts/plan_b1_predict_commands.py`
  - `python research_gsure/03_baselines/scripts/plan_b1_variant_ladder.py --self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_variant_ladder.py --gpu 0`
  - `python research_gsure/03_baselines/scripts/plan_b1_variant_ladder.py --timestamp 20260623_081500`
  - `python research_gsure/03_baselines/scripts/plan_b1_variant_ladder.py --timestamp 20260623_080158 --output-md research_gsure/03_baselines/B1_VARIANT_LADDER_PLAN_20260623_080158.md`
  - `python research_gsure/03_baselines/scripts/plan_b1_predict_commands.py --fit-timestamp T --predict-timestamp P --architecture unet3d --loss dice_bce --base-channels 24 --depth 4`
  - `python research_gsure/03_baselines/scripts/train_b1_segmentation.py --synthetic-self-test --patch-shape 32,32,32`
- Metrics:
  - Variant planner self-test: PASS
  - GPU override negative test: PASS
  - Ranker synthetic self-test: PASS
  - Train synthetic self-test: PASS
  - Capacity-aware model prefix observed:
    `b1_unet3d_dice_bce_bc24_d4_seed_20260623`

### Remaining uncertainty
- No real smoke, full-fit, OOF prediction, or segmentation metrics exist yet.
- Whether the primary B1A baseline is strong enough is unknown until full LOCO
  evaluation.

### Next recommended action
- Run the bounded GPU4 B1A smoke only after explicit approval.

## 2026-06-23 — Fix future B1 GPU commands to GPU 4

### Task
- Ensure future B1 baseline GPU command plans use physical GPU 4 only.

### Research question
- Does not change the G-SURE research question; this is an execution-control
  decision for the B1 segmentation baseline gate.

### What I inspected
- Current worktree and branch.
- Current `nvidia-smi`.
- B1 smoke approval packet.
- B1 full-fit and prediction command planners.
- Existing GPU preview approval packet.

### Decision / action
- Kept `CUDA_VISIBLE_DEVICES=4` as the fixed GPU binding for B1 smoke,
  full-fit, and prediction commands.
- Confirmed `plan_b1_fit_commands.py` and `plan_b1_predict_commands.py`
  default to `--gpu 4`.
- Added planner guards so `--gpu` values other than `4` fail instead of
  silently generating non-GPU4 commands.
- Corrected the old GPU preview approval packet so it no longer recommends or
  previews GPU 0.
- Did not run GPU training.

### Result
- Future B1 command plans are aligned to GPU 4.
- Current status checker still reports `ready_for_smoke_approval`.

### Interpretation
- GPU selection is now consistent, but this is not training approval and does
  not produce segmentation metrics.

### Insight tags
- ✅ SUCCESS: B1 GPU command planning is fixed to GPU 4.
- ⚠️ RISK: Current `nvidia-smi` shows GPU 4 already has another process using
  memory; run state must be checked immediately before launch.
- 🔁 DO NOT REPEAT: Do not switch to GPU 0 from stale preview-packet text.
- 🧪 NEXT: Present the bounded GPU4 smoke command preview and wait for explicit
  launch approval.

### Evidence
- Files:
  - `research_gsure/03_baselines/B1_GPU_PREVIEW_APPROVAL_PACKET.md`
  - `research_gsure/03_baselines/B1_SMOKE_TRAINING_APPROVAL_PACKET.md`
  - `research_gsure/03_baselines/scripts/plan_b1_fit_commands.py`
  - `research_gsure/03_baselines/scripts/plan_b1_predict_commands.py`
- Commands:
  - `pwd`
  - `git status --short`
  - `git branch --show-current`
  - `nvidia-smi`
  - `rg -n "CUDA_VISIBLE_DEVICES|gpu|GPU|device cuda|--device cuda" research_gsure/03_baselines SCRATCHPAD.md`
  - `python research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`
  - `python -m py_compile research_gsure/03_baselines/scripts/train_b1_segmentation.py research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py research_gsure/03_baselines/scripts/plan_b1_fit_commands.py research_gsure/03_baselines/scripts/plan_b1_predict_commands.py research_gsure/03_baselines/scripts/validate_b1_smoke_result.py`
  - `python research_gsure/03_baselines/scripts/train_b1_segmentation.py --synthetic-self-test --patch-shape 32,32,32`
  - `python research_gsure/03_baselines/scripts/plan_b1_fit_commands.py --self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_predict_commands.py --self-test`
  - `python research_gsure/03_baselines/scripts/validate_b1_smoke_result.py --self-test`
- Metrics:
  - Status stage: `ready_for_smoke_approval`
- Logs:
  - GPU 4 at inspection had one active Python process using 28568 MiB.

### Remaining uncertainty
- Whether GPU 4 remains available at the exact launch time.
- Whether Min approves the bounded smoke training command.

### Next recommended action
- If Min approves, run the bounded GPU4 smoke training command and then validate
  the smoke output.

## 2026-06-23 — Reject smoke checkpoints for OOF prediction

### Task
- Prevent held-out OOF prediction from accidentally using a smoke checkpoint.

### Research question
- Does predict-time checkpoint loading enforce that the checkpoint came from
  full-fit mode rather than smoke mode?

### What I inspected
- `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
- `research_gsure/03_baselines/scripts/plan_b1_predict_commands.py`
- `research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`
- `research_gsure/03_baselines/B1_SMOKE_TRAINING_APPROVAL_PACKET.md`
- `research_gsure/03_baselines/B1_PREDICT_COMMAND_PLAN_DRAFT.md`

### Decision / action
- Added checkpoint mode eligibility check in `load_checkpoint_into_model(...)`:
  - if checkpoint args contain `mode`, it must be `fit`.
- Strengthened B1 runner synthetic self-test:
  - creates a valid synthetic `mode=fit` checkpoint and loads it;
  - creates a synthetic `mode=smoke` checkpoint and confirms prediction loading
    rejects it.

### Result
- `py_compile` passed.
- B1 runner synthetic self-test passed and now reports
  `smoke_checkpoint_rejection_self_test: PASS`.
- Predict planner self-test passed.
- Smoke validator self-test passed.
- OOF manifest validator synthetic self-test passed.
- Segmentation evaluator synthetic self-test passed.
- Variant ranker synthetic self-test passed.
- Current Autoresearch status remains `ready_for_smoke_approval`.

### Interpretation
- OOF prediction cannot accidentally use a smoke checkpoint when checkpoint
  provenance is present.
- This protects baseline validity and leaderboard integrity without changing
  training, inference, split policy, or metrics.

### Insight tags
- ✅ SUCCESS: Smoke checkpoints are now rejected for prediction loading.
- ⚠️ RISK: Real checkpoint mode validation is still unrun because no real
  full-fit checkpoint exists.
- 🧪 NEXT: GPU4 smoke remains the next real training gate after explicit
  approval.
- 🔁 DO NOT REPEAT: Do not generate OOF prediction maps from smoke checkpoints.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
- Commands:
  - `python -m py_compile research_gsure/03_baselines/scripts/train_b1_segmentation.py`
  - `python research_gsure/03_baselines/scripts/train_b1_segmentation.py --synthetic-self-test --patch-shape 32,32,32`
  - `python research_gsure/03_baselines/scripts/plan_b1_predict_commands.py --self-test`
  - `python research_gsure/03_baselines/scripts/validate_b1_smoke_result.py --self-test`
  - `python research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py --synthetic-self-test`
  - `python research_gsure/03_baselines/scripts/evaluate_b1_segmentation_predictions.py --synthetic-self-test`
  - `python research_gsure/03_baselines/scripts/rank_b1_segmentation_variants.py --synthetic-self-test`
  - `python research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`
- Metrics:
  - `smoke_checkpoint_rejection_self_test`: PASS
  - Current checker stage: `ready_for_smoke_approval`
  - Fit checkpoints: 0/4
  - Fit summaries: 0/4

### Remaining uncertainty
- No real smoke checkpoint, full-fit checkpoint, OOF probability map,
  segmentation metric, or variant leaderboard exists yet.

### Next recommended action
- Approve and run the bounded GPU4 B1 smoke command.

## 2026-06-23 — Checkpoint provenance mismatch guard

### Task
- Strengthen checkpoint loading so prediction manifests cannot silently claim a
  different variant identity than the checkpoint actually used.

### Research question
- Can predict-time commands with mismatched `loss`, `seed`, or `experiment_id`
  be rejected before they write misleading OOF prediction manifests?

### What I inspected
- `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
- `research_gsure/03_baselines/scripts/plan_b1_predict_commands.py`
- `research_gsure/03_baselines/scripts/evaluate_b1_segmentation_predictions.py`
- `research_gsure/03_baselines/scripts/rank_b1_segmentation_variants.py`

### Decision / action
- Added `resolved_model_id(args)` and used it consistently for summaries and
  prediction manifests/configs.
- Extended `load_checkpoint_into_model(...)` checks:
  - architectural compatibility remains required;
  - `loss`, `seed`, and `experiment_id` must also match checkpoint args when
    present.
- Strengthened B1 runner synthetic self-test with negative checks:
  - loss mismatch must be rejected;
  - seed mismatch must be rejected.

### Result
- `py_compile` passed.
- B1 runner synthetic self-test passed and now reports
  `checkpoint_provenance_mismatch_self_test: PASS`.
- Predict planner self-test passed.
- Smoke validator self-test passed.
- OOF manifest validator synthetic self-test passed.
- Segmentation evaluator synthetic self-test passed.
- Variant ranker synthetic self-test passed.
- Current Autoresearch status remains `ready_for_smoke_approval`.

### Interpretation
- Prediction can no longer quietly relabel a checkpoint as a different
  loss/seed/experiment variant.
- This protects leaderboard validity without changing training, inference,
  split policy, or metrics.

### Insight tags
- ✅ SUCCESS: Checkpoint-to-prediction provenance mismatch is now explicitly
  guarded.
- ⚠️ RISK: Real checkpoint loading is still untested because no real full-fit
  checkpoint exists.
- 🧪 NEXT: GPU4 smoke remains the next real training gate after explicit
  approval.
- 🔁 DO NOT REPEAT: Do not write prediction manifests from checkpoints whose
  training config does not match the predict command identity.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
- Commands:
  - `python -m py_compile research_gsure/03_baselines/scripts/train_b1_segmentation.py`
  - `python research_gsure/03_baselines/scripts/train_b1_segmentation.py --synthetic-self-test --patch-shape 32,32,32`
  - `python research_gsure/03_baselines/scripts/plan_b1_predict_commands.py --self-test`
  - `python research_gsure/03_baselines/scripts/validate_b1_smoke_result.py --self-test`
  - `python research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py --synthetic-self-test`
  - `python research_gsure/03_baselines/scripts/evaluate_b1_segmentation_predictions.py --synthetic-self-test`
  - `python research_gsure/03_baselines/scripts/rank_b1_segmentation_variants.py --synthetic-self-test`
  - `python research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`
- Metrics:
  - `checkpoint_provenance_mismatch_self_test`: PASS
  - Current checker stage: `ready_for_smoke_approval`
  - Fit checkpoints: 0/4
  - Fit summaries: 0/4

### Remaining uncertainty
- No real smoke checkpoint, full-fit checkpoint, OOF probability map,
  segmentation metric, or variant leaderboard exists yet.

### Next recommended action
- Approve and run the bounded GPU4 B1 smoke command.

## 2026-06-23 — Separate smoke and full-fit summary artifacts

### Task
- Separate smoke and full-fit summary artifact naming before any real smoke or
  full LOCO fit is run.

### Research question
- Can full-fit checkpoints be distinguished from smoke artifacts and carry a
  paired fit summary before held-out prediction commands are allowed?

### What I inspected
- `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
- `research_gsure/03_baselines/scripts/plan_b1_predict_commands.py`
- `research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`
- `research_gsure/03_baselines/scripts/validate_b1_smoke_result.py`
- `research_gsure/03_baselines/B1_PREDICT_COMMAND_PLAN_DRAFT.md`
- `research_gsure/03_baselines/B1_AUTORESEARCH_LADDER.md`

### Decision / action
- Kept smoke output contract unchanged:
  - smoke mode writes `smoke_summary.json`.
- Changed full-fit output naming:
  - fit mode writes `fit_summary.json`.
- Updated predict command planner to require both:
  - `checkpoint_last.pt`
  - `fit_summary.json`
- Updated Autoresearch status checker to count both checkpoint and fit summary
  artifacts.
- Updated the prediction command plan draft and B1 ladder documentation.

### Result
- `py_compile` passed.
- B1 runner synthetic self-test passed.
- Smoke validator self-test passed.
- Fit planner self-test passed.
- Predict planner self-test passed.
- Status checker self-test passed.
- Current status remains `ready_for_smoke_approval`.
- Current fit artifacts remain absent:
  - checkpoints: 0/4
  - fit summaries: 0/4

### Interpretation
- Full-fit outputs are now less likely to be confused with smoke outputs.
- Held-out prediction commands are now gated on fit provenance, not checkpoint
  presence alone.
- This does not change model training, inference, metrics, or split logic.

### Insight tags
- ✅ SUCCESS: Smoke and full-fit artifacts are now separated by filename and
  downstream gate logic.
- ⚠️ RISK: No real fit artifacts exist yet, so this is pre-execution hardening.
- 🧪 NEXT: GPU4 smoke remains the next real training gate after explicit
  approval.
- 🔁 DO NOT REPEAT: Do not run held-out prediction from a checkpoint directory
  that lacks its paired `fit_summary.json`.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
  - `research_gsure/03_baselines/scripts/plan_b1_predict_commands.py`
  - `research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`
  - `research_gsure/03_baselines/B1_PREDICT_COMMAND_PLAN_DRAFT.md`
  - `research_gsure/03_baselines/B1_AUTORESEARCH_LADDER.md`
- Commands:
  - `python -m py_compile research_gsure/03_baselines/scripts/train_b1_segmentation.py research_gsure/03_baselines/scripts/plan_b1_predict_commands.py research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py research_gsure/03_baselines/scripts/validate_b1_smoke_result.py`
  - `python research_gsure/03_baselines/scripts/train_b1_segmentation.py --synthetic-self-test --patch-shape 32,32,32`
  - `python research_gsure/03_baselines/scripts/validate_b1_smoke_result.py --self-test`
  - `python research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py --self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_fit_commands.py --self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_predict_commands.py --self-test`
  - `python research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`
- Metrics:
  - Current checker stage: `ready_for_smoke_approval`
  - Fit checkpoints: 0/4
  - Fit summaries: 0/4

### Remaining uncertainty
- No real smoke checkpoint, full-fit checkpoint, OOF probability map,
  segmentation metric, or variant leaderboard exists yet.

### Next recommended action
- Approve and run the bounded GPU4 B1 smoke command.

## 2026-06-23 — B1 smoke/fit summary model-id provenance

### Task
- Ensure B1 preview/smoke/fit/predict summaries carry resolved model identity
  for later Autoresearch variant tracking.

### Research question
- Can smoke and full-fit checkpoints be linked unambiguously to the same
  architecture/loss/seed identity that appears later in prediction manifests and
  leaderboards?

### What I inspected
- `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
- `research_gsure/03_baselines/scripts/validate_b1_smoke_result.py`
- `research_gsure/03_baselines/scripts/plan_b1_predict_commands.py`
- `research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`

### Decision / action
- Added resolved `model_id` to preview and smoke/fit summaries.
- Added `resolved_model_id` to `prediction_config.json`.
- Strengthened smoke validator to require `model_id`.
- Kept the model definition, loss, split, training loop, inference, and metric
  calculations unchanged.

### Result
- `py_compile` passed.
- Smoke validator self-test passed with required `model_id`.
- B1 runner synthetic self-test passed.
- Predict planner self-test passed.
- OOF manifest validator synthetic self-test passed.
- Segmentation evaluator synthetic self-test passed.
- Variant ranker synthetic self-test passed.
- Current Autoresearch status remains `ready_for_smoke_approval`.

### Interpretation
- The baseline chain now preserves model identity at preview/smoke/fit/predict
  stages, which is needed before comparing architecture/loss variants.
- This still does not create real smoke or segmentation performance evidence.

### Insight tags
- ✅ SUCCESS: Summary/config provenance now includes resolved model identity.
- ⚠️ RISK: Real artifact validation is still pending because no smoke/full-fit
  outputs exist.
- 🧪 NEXT: GPU4 smoke remains the next real training gate after explicit
  approval.
- 🔁 DO NOT REPEAT: Do not rank variants unless their summaries and manifests
  carry distinct model identities.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
  - `research_gsure/03_baselines/scripts/validate_b1_smoke_result.py`
- Commands:
  - `python -m py_compile research_gsure/03_baselines/scripts/train_b1_segmentation.py research_gsure/03_baselines/scripts/validate_b1_smoke_result.py research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py research_gsure/03_baselines/scripts/plan_b1_predict_commands.py`
  - `python research_gsure/03_baselines/scripts/validate_b1_smoke_result.py --self-test`
  - `python research_gsure/03_baselines/scripts/train_b1_segmentation.py --synthetic-self-test --patch-shape 32,32,32`
  - `python research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py --self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_predict_commands.py --self-test`
  - `python research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py --synthetic-self-test`
  - `python research_gsure/03_baselines/scripts/evaluate_b1_segmentation_predictions.py --synthetic-self-test`
  - `python research_gsure/03_baselines/scripts/rank_b1_segmentation_variants.py --synthetic-self-test`
  - `python research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`
  - `git diff --check`
- Metrics:
  - Current checker stage: `ready_for_smoke_approval`
  - Preview valid: 2/2
  - Fit checkpoints: 0/4

### Remaining uncertainty
- No real smoke checkpoint, full-fit checkpoint, OOF probability map,
  segmentation metric, or variant leaderboard exists yet.

### Next recommended action
- Approve and run the bounded GPU4 B1 smoke command.

## 2026-06-23 — B1 variant model-id provenance fix

### Task
- Audit B1 prediction provenance for architecture/loss variant comparisons.

### Research question
- Will OOF prediction manifests and downstream summaries preserve enough
  model identity to distinguish `unet3d`, `resunet3d`, and loss variants during
  Autoresearch ranking?

### What I inspected
- `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
- `research_gsure/03_baselines/scripts/plan_b1_predict_commands.py`
- `research_gsure/03_baselines/B1_PREDICT_COMMAND_PLAN_DRAFT.md`
- `research_gsure/03_baselines/scripts/evaluate_b1_segmentation_predictions.py`
- `research_gsure/03_baselines/scripts/rank_b1_segmentation_variants.py`

### Decision / action
- Found a provenance weakness:
  - fallback `model_id` and predict planner default model prefix were tied to
    `b1_unet3d_seed_20260623`;
  - that would be ambiguous or misleading for `resunet3d`, `dice_focal`, or
    `dice_tversky` variants.
- Added `default_model_id(args)` in the B1 runner:
  - `b1_<architecture>_<loss>_seed_<seed>`.
- Updated predict planner to derive the same model prefix unless explicitly
  overridden.
- Updated `B1_PREDICT_COMMAND_PLAN_DRAFT.md` so the default plan now uses
  `b1_unet3d_dice_bce_seed_20260623_*`.

### Result
- `py_compile` passed.
- B1 runner synthetic self-test passed.
- Predict planner self-test passed.
- OOF manifest validator synthetic self-test passed.
- Segmentation evaluator synthetic self-test passed.
- Variant ranker synthetic self-test passed.
- Current Autoresearch status remains `ready_for_smoke_approval`.

### Interpretation
- Future variant outputs will carry architecture/loss identity in `model_id`,
  reducing the risk of mixing variants in evaluation and leaderboard summaries.
- This does not change the model, loss, training data, split, inference, or
  metric calculations.

### Insight tags
- ✅ SUCCESS: Variant provenance now includes architecture and loss by default.
- ⚠️ RISK: Users can still override `--model-id` manually; reviewers will need
  the command/config logs alongside leaderboard tables.
- 🧪 NEXT: GPU4 smoke remains the next real training gate after explicit
  approval.
- 🔁 DO NOT REPEAT: Do not compare variants whose prediction manifests use
  ambiguous or reused `model_id` values.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
  - `research_gsure/03_baselines/scripts/plan_b1_predict_commands.py`
  - `research_gsure/03_baselines/B1_PREDICT_COMMAND_PLAN_DRAFT.md`
- Commands:
  - `python -m py_compile research_gsure/03_baselines/scripts/train_b1_segmentation.py research_gsure/03_baselines/scripts/plan_b1_predict_commands.py research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py`
  - `python research_gsure/03_baselines/scripts/train_b1_segmentation.py --synthetic-self-test --patch-shape 32,32,32`
  - `python research_gsure/03_baselines/scripts/plan_b1_predict_commands.py --self-test`
  - `python research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py --synthetic-self-test`
  - `python research_gsure/03_baselines/scripts/evaluate_b1_segmentation_predictions.py --synthetic-self-test`
  - `python research_gsure/03_baselines/scripts/rank_b1_segmentation_variants.py --synthetic-self-test`
  - `python research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`
  - `git diff --check`
- Metrics:
  - Runner synthetic self-test: PASS
  - Current checker stage: `ready_for_smoke_approval`
  - Preview valid: 2/2
  - Fit checkpoints: 0/4

### Remaining uncertainty
- No real smoke checkpoint, full-fit checkpoint, OOF prediction map,
  segmentation metric, or variant leaderboard exists yet.

### Next recommended action
- Approve and run the bounded GPU4 B1 smoke command.

## 2026-06-23 — Canonical target comparison fix for B1 post-prediction metrics

### Task
- Audit the B1 train/predict/evaluate path for blockers that would appear only
  after smoke/full-fit prediction artifacts are generated.

### Research question
- Will RAS-canonical probability maps written by `predict_run` validate and
  evaluate correctly against the target masks referenced in the official split
  manifest?

### What I inspected
- `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
- `research_gsure/02_audits/scripts/validate_prediction_artifacts.py`
- `research_gsure/03_baselines/scripts/evaluate_b1_segmentation_predictions.py`
- `research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py`
- `research_gsure/03_baselines/scripts/plan_b1_evaluation_commands.py`
- `research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`

### Decision / action
- Found a post-prediction blocker:
  - `predict_run` saves probability maps in `prediction_space=RAS_canonical`.
  - `target_source_path` points to the original mask file.
  - The artifact validator and segmentation evaluator were loading target masks
    without canonicalization, which could falsely fail affine/orientation checks
    for source masks stored as LPS or another orientation.
- Patched both post-prediction consumers to load NIfTI files with
  `nib.as_closest_canonical(...)`.
- Strengthened synthetic self-tests to cover LPS original target masks compared
  against canonical prediction maps.

### Result
- `py_compile` passed.
- Artifact validator synthetic self-test passed with 0 errors.
- Segmentation evaluator synthetic self-test passed with Dice `0.875000`.
- OOF metadata validator synthetic self-test still passed.
- Evaluation command planner self-test still passed.
- Current Autoresearch status remains `ready_for_smoke_approval`.

### Interpretation
- This prevents a likely false failure after OOF prediction generation.
- The patch does not change training, inference, split membership, or threshold
  policy; it aligns validation/evaluation with the declared canonical prediction
  space.

### Insight tags
- ✅ SUCCESS: Post-prediction validation now matches the runner's RAS-canonical
  output convention.
- ⚠️ RISK: Real OOF artifact validation is still unrun because no prediction
  manifests exist.
- 🧪 NEXT: GPU4 smoke remains the next real training gate after explicit
  approval.
- 🔁 DO NOT REPEAT: Do not compare canonical prediction maps to raw-orientation
  targets without canonicalizing the target side.

### Evidence
- Files:
  - `research_gsure/02_audits/scripts/validate_prediction_artifacts.py`
  - `research_gsure/03_baselines/scripts/evaluate_b1_segmentation_predictions.py`
- Commands:
  - `python -m py_compile research_gsure/02_audits/scripts/validate_prediction_artifacts.py research_gsure/03_baselines/scripts/evaluate_b1_segmentation_predictions.py research_gsure/03_baselines/scripts/rank_b1_segmentation_variants.py research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`
  - `python research_gsure/02_audits/scripts/validate_prediction_artifacts.py --synthetic-self-test`
  - `python research_gsure/03_baselines/scripts/evaluate_b1_segmentation_predictions.py --synthetic-self-test`
  - `python research_gsure/03_baselines/scripts/rank_b1_segmentation_variants.py --synthetic-self-test`
  - `python research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py --synthetic-self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_evaluation_commands.py --self-test`
  - `python research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`
  - `git diff --check`
- Metrics:
  - Artifact synthetic validation errors: 0
  - Segmentation evaluator synthetic Dice: 0.875000
  - Current checker stage: `ready_for_smoke_approval`

### Remaining uncertainty
- No real smoke checkpoint, full-fit checkpoint, OOF probability map, or real
  segmentation metric exists yet.

### Next recommended action
- Approve and run the bounded GPU4 B1 smoke command.

## 2026-06-23 — B1 variant leaderboard guard

### Task
- Add a CPU-only leaderboard/ranker for comparing B1 segmentation variants after
  OOF evaluation summaries exist.

### Research question
- Can model/loss/augmentation variants be selected by a reproducible rule that
  protects worst-consortium performance, instead of chasing pooled mean Dice?

### What I inspected
- `research_gsure/03_baselines/scripts/evaluate_b1_segmentation_predictions.py`
- `research_gsure/03_baselines/B1_AUTORESEARCH_LADDER.md`
- Existing B1 planner and status artifacts.

### Decision / action
- Added `rank_b1_segmentation_variants.py`.
- Added `B1_VARIANT_LEADERBOARD_PLAN_DRAFT.md`.
- Updated `B1_AUTORESEARCH_LADDER.md` with the variant selection guard.
- Ranking rule:
  1. eligible variants first,
  2. higher worst-consortium mean Dice,
  3. higher overall mean Dice,
  4. lower overall `Dice <= 0.8` failure rate.

### Result
- `py_compile` passed.
- Synthetic ranker self-test passed.
- Current Autoresearch state remains `ready_for_smoke_approval`:
  - preview valid: 2/2
  - fit checkpoints: 0/4

### Interpretation
- The baseline ladder now has a fair variant-selection mechanism ready for when
  real OOF segmentation summaries exist.
- This still does not create or imply real segmentation performance.

### Insight tags
- ✅ SUCCESS: Variant selection is guarded against pooled-only improvement.
- ⚠️ RISK: The ranker depends on complete, validated four-consortium summary
  JSONs. Partial comparisons must be marked exploratory.
- 🧪 NEXT: GPU4 smoke remains the next real training gate after explicit
  approval.
- 🔁 DO NOT REPEAT: Do not choose a structure/loss variant from a single fold or
  from a pooled metric that hides worst-consortium collapse.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/rank_b1_segmentation_variants.py`
  - `research_gsure/03_baselines/B1_VARIANT_LEADERBOARD_PLAN_DRAFT.md`
  - `research_gsure/03_baselines/B1_AUTORESEARCH_LADDER.md`
- Commands:
  - `python -m py_compile research_gsure/03_baselines/scripts/rank_b1_segmentation_variants.py research_gsure/03_baselines/scripts/evaluate_b1_segmentation_predictions.py research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`
  - `python research_gsure/03_baselines/scripts/rank_b1_segmentation_variants.py --synthetic-self-test`
  - `python research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`
- Metrics:
  - Ranker self-test: PASS
  - Current checker stage: `ready_for_smoke_approval`

### Remaining uncertainty
- No real smoke checkpoint, full-fit checkpoint, OOF prediction map,
  segmentation evaluation summary, or variant leaderboard exists yet.

### Next recommended action
- Approve and run the bounded GPU4 B1 smoke command.

## 2026-06-23 — B1 segmentation metric evaluator

### Task
- Add the CPU-only metric harness needed to rank B1 segmentation baselines and
  later architecture/loss variants.

### Research question
- Once OOF prediction manifests exist, can B1 segmentation performance be
  measured reproducibly by per-subject and per-consortium metrics before moving
  to reliability labels or model variants?

### What I inspected
- `research_gsure/01_protocol/OOF_PREDICTION_RELIABILITY_CONTRACT.md`
- `research_gsure/03_baselines/BASELINE_CONTRACT.md`
- `research_gsure/01_protocol/RELIABILITY_METRIC_CONTRACT.md`
- `research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py`
- `research_gsure/02_audits/scripts/validate_prediction_artifacts.py`
- `research_gsure/02_audits/scripts/compute_reliability_metrics.py`
- `research_gsure/03_baselines/B1_AUTORESEARCH_LADDER.md`
- `research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`

### Decision / action
- Added `evaluate_b1_segmentation_predictions.py`.
- It evaluates already-generated full-volume OOF prediction manifests only.
- It loads probability maps and target masks, thresholds with the manifest
  `threshold_value`, and computes per-subject plus grouped summary metrics.
- It writes per-subject CSV, summary CSV, and summary JSON only when an output
  directory is explicitly provided.
- It does not train, infer, generate probability maps, tune thresholds, or
  create reliability labels.
- Updated the B1 ladder to list the evaluator and updated the status checker so
  OOF prediction manifests lead to segmentation evaluation before reliability
  labels.

### Result
- `py_compile` passed.
- Synthetic self-test passed with expected Dice `0.875000`.
- Status checker self-test still passed.
- Current status remains `ready_for_smoke_approval`.

### Interpretation
- Baseline/variant selection now has a planned measurement step:
  Dice, IoU, precision, recall, predicted/GT volume ratio, Dice<=0.8 failure
  rate, lesion-size bins, and worst-consortium guard metrics.
- This does not create real performance evidence yet because no real OOF
  prediction maps exist.

### Insight tags
- ✅ SUCCESS: The baseline ladder now has a concrete segmentation performance
  evaluator before reliability modeling.
- ⚠️ RISK: The evaluator can only be trusted on prediction manifests that pass
  metadata and artifact validation.
- 🧪 NEXT: After GPU4 smoke and full LOCO prediction, run OOF manifest
  validation, artifact validation, then this evaluator.
- 🔁 DO NOT REPEAT: Do not compare architecture/loss variants using ad hoc
  single-fold Dice or preview outputs.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/evaluate_b1_segmentation_predictions.py`
  - `research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`
  - `research_gsure/03_baselines/B1_AUTORESEARCH_LADDER.md`
- Commands:
  - `python -m py_compile research_gsure/03_baselines/scripts/evaluate_b1_segmentation_predictions.py`
  - `python research_gsure/03_baselines/scripts/evaluate_b1_segmentation_predictions.py --synthetic-self-test`
  - `python -m py_compile research_gsure/03_baselines/scripts/evaluate_b1_segmentation_predictions.py research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`
  - `python research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py --self-test`
  - `python research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`
- Metrics:
  - Synthetic rows: 1
  - Synthetic Dice: 0.875000
  - Current checker stage: `ready_for_smoke_approval`

### Remaining uncertainty
- No real smoke checkpoint, full fit checkpoint, OOF prediction map, or
  segmentation result table exists yet.

### Next recommended action
- Approve and run the bounded GPU4 B1 smoke command, then continue to full LOCO
  fit only if smoke validation passes.

## 2026-06-23 — B1 post-OOF evaluation command planner

### Task
- Add a CPU-only planner for B1 post-prediction validation and segmentation
  evaluation commands.

### Research question
- After all LOCO held-out prediction manifests exist, can we move from OOF maps
  to validated baseline performance tables without ad hoc path selection?

### What I inspected
- `research_gsure/03_baselines/scripts/plan_b1_predict_commands.py`
- `research_gsure/03_baselines/scripts/evaluate_b1_segmentation_predictions.py`
- `research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py`
- `research_gsure/02_audits/scripts/validate_prediction_artifacts.py`
- `research_gsure/03_baselines/B1_AUTORESEARCH_LADDER.md`

### Decision / action
- Added `plan_b1_evaluation_commands.py`.
- Generated `B1_EVALUATION_COMMAND_PLAN_DRAFT.md`.
- The planner emits the required order:
  1. OOF prediction metadata/schema validation.
  2. NIfTI artifact value/geometry validation.
  3. Combined OOF segmentation evaluation.
- It blocks evaluation when expected prediction manifests are absent.

### Result
- `py_compile` passed.
- Planner self-test passed.
- Current plan correctly reports `BLOCKED: missing prediction manifests`.
- Expected post-prediction rows are:
  - MU-Glioma-Post: 203
  - UCSD-PTGBM: 178
  - UPENN-GBM: 611
  - UTSW: 622
- Current Autoresearch status remains `ready_for_smoke_approval`.

### Interpretation
- The baseline pipeline now has a complete planned path from prediction
  manifests to validated segmentation metrics, but no real performance result
  exists until smoke, full fit, and prediction are actually run.

### Insight tags
- ✅ SUCCESS: Post-OOF validation/evaluation command sequence is explicit and
  reproducible.
- ⚠️ RISK: The plan is intentionally blocked because OOF prediction manifests do
  not exist yet.
- 🧪 NEXT: GPU4 smoke remains the next executable training gate after explicit
  approval.
- 🔁 DO NOT REPEAT: Do not skip artifact validation and jump directly from
  prediction manifests to reported Dice.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/plan_b1_evaluation_commands.py`
  - `research_gsure/03_baselines/B1_EVALUATION_COMMAND_PLAN_DRAFT.md`
  - `research_gsure/03_baselines/B1_AUTORESEARCH_LADDER.md`
- Commands:
  - `python -m py_compile research_gsure/03_baselines/scripts/plan_b1_evaluation_commands.py research_gsure/03_baselines/scripts/evaluate_b1_segmentation_predictions.py`
  - `python research_gsure/03_baselines/scripts/plan_b1_evaluation_commands.py --self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_evaluation_commands.py`
  - `python research_gsure/03_baselines/scripts/plan_b1_evaluation_commands.py --output-md research_gsure/03_baselines/B1_EVALUATION_COMMAND_PLAN_DRAFT.md`
  - `python research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`
- Metrics:
  - Planner self-test: PASS
  - Current plan gate: blocked, missing 4/4 prediction manifests.

### Remaining uncertainty
- No GPU4 smoke output, full-fit checkpoints, prediction manifests, or real
  segmentation metrics exist yet.

### Next recommended action
- Approve and run the bounded GPU4 B1 smoke command.

## 2026-06-23 — Current B1A execution-chain pointer

### Task
- Record the current authoritative B1A plan chain at the end of the scratchpad.

### Research question
- Same B1 segmentation baseline question; this is a traceability pointer.

### What I inspected
- Latest next-action output and B1A-specific command plans.

### Decision / action
- Use the B1A-specific plan chain, not the generic DRAFT plans.

### Result
- Current status: `ready_for_smoke_approval`.
- Next-action packet:
  `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_081116.md`.
- B1A smoke plan:
  `research_gsure/03_baselines/B1_SMOKE_COMMAND_PLAN_20260623_080846_b1a_unet3d_dice_bce_bc16_d4_smoke.md`.
- B1A full-fit plan:
  `research_gsure/03_baselines/B1_FULL_FIT_COMMAND_PLAN_20260623_080846_b1a_unet3d_dice_bce_bc16_d4_fit.md`.
- B1A prediction plan:
  `research_gsure/03_baselines/B1_PREDICT_COMMAND_PLAN_20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict.md`.
- B1A evaluation plan:
  `research_gsure/03_baselines/B1_EVALUATION_COMMAND_PLAN_20260623_080846_b1a_unet3d_dice_bce_bc16_d4_eval.md`.

### Interpretation
- The full B1A plan chain is prepared, but no real result exists.

### Insight tags
- ✅ SUCCESS: Current scratchpad tail now points to the B1A-specific chain.
- ⚠️ RISK: No GPU smoke has run yet.
- 🧪 NEXT: Approve or defer B1A-specific bounded GPU4 smoke.
- 🔁 DO NOT REPEAT: Do not report performance before smoke, fit, prediction,
  and evaluation artifacts exist.

### Evidence
- Commands:
  - `python research_gsure/03_baselines/scripts/plan_b1_next_action.py`
  - `git diff --check`

### Remaining uncertainty
- No smoke/full-fit/prediction/evaluation artifact exists yet.

### Next recommended action
- Approve B1A-specific bounded GPU4 smoke execution, or explicitly defer GPU.

## 2026-06-23 — Current GPU4-fixed B1 gate

### Task
- Record the current GPU4-fixed execution gate at the end of the scratchpad.

### Research question
- Can B1 segmentation baseline execution proceed under a single fixed GPU
  binding without accidental non-GPU4 execution?

### What I inspected
- GPU inventory, B1 planners, training runtime guard, smoke/fit validators,
  plan-chain validation, and next-action controller.

### Decision / action
- Keep `CUDA_VISIBLE_DEVICES=4` as the only allowed CUDA binding for B1 smoke,
  fit, and prediction.
- Do not launch GPU training in this step.

### Result
- GPU 4 is present as an NVIDIA B200.
- Smoke, fit, and prediction planners reject non-4 `--gpu` values.
- `train_b1_segmentation.py` refuses CUDA execution unless
  `CUDA_VISIBLE_DEVICES=4`.
- Smoke and fit validators require runtime summaries to report GPU4 binding.
- Current status remains `ready_for_smoke_approval`.
- Latest plan-chain validation:
  `research_gsure/03_baselines/B1_PLAN_CHAIN_VALIDATION_20260623_084634.md`.
- Latest next-action packet:
  `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_085000.md`.

### Interpretation
- The execution path is GPU4-fixed and internally consistent. No segmentation
  performance result exists because smoke/full-fit/prediction/evaluation have
  not been run.

### Insight tags
- ✅ SUCCESS: GPU4 binding is enforced by command planners and runtime
  artifact validators.
- ⚠️ RISK: GPU 4 currently has active utilization, so smoke runtime may be
  noisy even if memory is sufficient.
- 🧪 NEXT: Run bounded B1A GPU4 smoke only after explicit approval.
- 🔁 DO NOT REPEAT: Do not proceed to full LOCO fit until smoke output passes
  `validate_b1_smoke_result.py`.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
  - `research_gsure/03_baselines/scripts/plan_b1_smoke_command.py`
  - `research_gsure/03_baselines/scripts/plan_b1_fit_commands.py`
  - `research_gsure/03_baselines/scripts/plan_b1_predict_commands.py`
  - `research_gsure/03_baselines/scripts/validate_b1_smoke_result.py`
  - `research_gsure/03_baselines/scripts/validate_b1_fit_results.py`
- Commands:
  - `nvidia-smi --query-gpu=index,name,memory.used,memory.total,utilization.gpu --format=csv,noheader`
  - `python -m py_compile ...`
  - `python research_gsure/03_baselines/scripts/validate_b1_smoke_result.py --self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_fit_commands.py --self-test`
  - `python research_gsure/03_baselines/scripts/validate_b1_fit_results.py --self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_predict_commands.py --self-test`
  - non-GPU4 planner guard checks with `--gpu 0`

### Remaining uncertainty
- No smoke artifact, full-fit checkpoint, prediction manifest, or Dice metric
  exists yet.

### Next recommended action
- Use the existing bounded smoke plan on GPU 4, then validate its artifact
  before any full-fit command.

## 2026-06-23 — Post-evaluation transition guard for B1 Autoresearch

### Task
- Add a CPU-only guard after B1 segmentation metric evaluation and before
  leaderboard ranking or variant promotion.

### Research question
- Can Autoresearch prevent model ranking/promotion unless the B1 evaluation
  summary is complete, LOCO-consistent, and validated?

### What I inspected
- Evaluation validator, variant ranker, promotion decision script, B1 status
  checker, and current B1 status.

### Decision / action
- Added `plan_b1_post_evaluation_transition.py`.
- The guard validates the metric summary, requires status stage
  `b1_evaluation_valid_ready_for_leaderboard`, and only then emits
  leaderboard and promotion-decision commands.
- Updated the B1 ladder document to make this the preferred step after CPU
  evaluation.

### Result
- Synthetic self-test passed.
- Current workspace run is correctly `BLOCKED` because no evaluation summary
  exists and the status checker is still `ready_for_smoke_approval`.

### Interpretation
- The B1 Autoresearch chain now has explicit guards from smoke through
  evaluation-to-leaderboard transition. This does not create any segmentation
  performance result; it prevents premature ranking once results exist.

### Insight tags
- ✅ SUCCESS: Post-evaluation ranking/promotion is now gated by strict
  evaluation validation.
- ⚠️ RISK: No real smoke/full-fit/prediction/evaluation artifact exists yet.
- 🧪 NEXT: Run bounded B1A GPU4 smoke after exact command approval, then follow
  the guard chain in order.
- 🔁 DO NOT REPEAT: Do not rank or promote variants from pooled Dice without
  validated official LOCO coverage and worst-consortium guard.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/plan_b1_post_evaluation_transition.py`
  - `research_gsure/03_baselines/scripts/validate_b1_evaluation_results.py`
  - `research_gsure/03_baselines/scripts/rank_b1_segmentation_variants.py`
  - `research_gsure/03_baselines/scripts/decide_b1_variant_promotion.py`
  - `research_gsure/03_baselines/B1_AUTORESEARCH_LADDER.md`
- Commands:
  - `python -m py_compile research_gsure/03_baselines/scripts/plan_b1_post_evaluation_transition.py`
  - `python research_gsure/03_baselines/scripts/plan_b1_post_evaluation_transition.py --self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_post_evaluation_transition.py`
  - `python research_gsure/03_baselines/scripts/validate_b1_plan_chain.py`
  - `git diff --check`

### Remaining uncertainty
- Real B1 metrics remain unavailable until smoke, full LOCO fit, prediction,
  and CPU evaluation are executed in order.

### Next recommended action
- Keep GPU execution fixed to GPU4 and run the bounded B1A smoke only after
  exact command approval.

## 2026-06-23 — Next-action controller aligned to transition guards

### Task
- Update the B1 Autoresearch next-action controller so it points to transition
  guard scripts at later stages.

### Research question
- Can the controller prevent Autoresearch from skipping artifact validation
  between smoke, fit, prediction, evaluation, leaderboard, and promotion?

### What I inspected
- `plan_b1_next_action.py`, status checker stages, and post-transition guard
  scripts.

### Decision / action
- Updated `plan_b1_next_action.py` stage mappings for post-smoke, post-fit,
  post-prediction, and post-evaluation states.
- Generated a fresh next-action packet:
  `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_091123.md`.
- Updated the ladder document to reference the fresh packet.

### Result
- Controller self-test passed.
- Current packet still recommends bounded B1A GPU4 smoke approval because no
  smoke output exists.
- Later stages now display the relevant transition guard script instead of
  implying a direct jump to ranking or promotion.

### Interpretation
- The Autoresearch controller is now consistent with the staged guard chain.
  This improves orchestration safety but does not produce segmentation
  performance evidence.

### Insight tags
- ✅ SUCCESS: Next-action controller now exposes transition guards.
- ⚠️ RISK: The active experimental state remains pre-smoke; no real metric
  exists.
- 🧪 NEXT: Run bounded B1A GPU4 smoke after exact command approval.
- 🔁 DO NOT REPEAT: Do not bypass post-smoke/post-fit/post-prediction/
  post-evaluation guards when moving to the next stage.

### Evidence
- Files:
  - `research_gsure/03_baselines/scripts/plan_b1_next_action.py`
  - `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_091123.md`
  - `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_091123.json`
  - `research_gsure/03_baselines/B1_AUTORESEARCH_LADDER.md`
- Commands:
  - `python -m py_compile research_gsure/03_baselines/scripts/plan_b1_next_action.py`
  - `python research_gsure/03_baselines/scripts/plan_b1_next_action.py --self-test`
  - `python research_gsure/03_baselines/scripts/plan_b1_next_action.py --timestamp 20260623_091123 --output-md research_gsure/03_baselines/B1_NEXT_ACTION_20260623_091123.md --output-json research_gsure/03_baselines/B1_NEXT_ACTION_20260623_091123.json`

### Remaining uncertainty
- No smoke/full-fit/prediction/evaluation artifacts exist yet.

### Next recommended action
- Execute the bounded GPU4 B1A smoke only after exact command approval, then
  validate with `validate_b1_smoke_result.py`.

## 2026-06-24 — B1 Autoresearch current gate refresh

### Task
- Refresh the current B1 Autoresearch state after the 2026-06-24 GPU4
  preflight, without launching GPU training.

### Research question
- Is the baseline chain actually ready for the next scientific step, and what
  is the next valid action before changing model structure?

### What I inspected
- Workspace status, B1 status checker, B1 plan-chain validator, the latest
  GPU4 smoke preflight, and current B1 outputs.

### Decision / action
- Generated a fresh CPU-only next-action packet:
  `research_gsure/03_baselines/B1_NEXT_ACTION_20260624_002039.md`.
- Kept the stage at `ready_for_smoke_approval`.
- Did not run GPU training, inference, full-fit, prediction, evaluation,
  ranking, or variant promotion.

### Result
- Official split is still valid.
- GPU preview artifacts are still valid.
- No smoke output exists.
- No full-fit checkpoints exist.
- No prediction manifests exist.
- No segmentation metric summary exists.
- The current next valid action remains explicit Min approval for bounded B1A
  smoke on GPU4.

### Interpretation
- There is no Dice/result evidence yet to support a claim that the model is good
  or bad.
- The project is correctly positioned at the first executable training gate:
  B1A smoke. Later architecture/loss/capacity variants must wait until B1A has
  complete OOF segmentation metrics.

### Insight tags
- ✅ SUCCESS: Current status and next-action artifacts are synchronized.
- ⚠️ RISK: Autoresearch can look busy while producing no model evidence if it
  keeps adding planners instead of running the approved training gate.
- 🧪 NEXT: After exact approval, run the bounded B1A GPU4 smoke command and
  immediately validate the output with `validate_b1_smoke_result.py`.
- 🔁 DO NOT REPEAT: Do not start B1B/B1C or G-SURE reliability heads before B1A
  smoke, full LOCO fit, prediction, and evaluation are complete.
- 📌 MIN DECISION: GPU4 smoke execution requires explicit approval.

### Evidence
- Files:
  - `research_gsure/03_baselines/B1_NEXT_ACTION_20260624_002039.md`
  - `research_gsure/03_baselines/B1_NEXT_ACTION_20260624_002039.json`
  - `research_gsure/03_baselines/B1A_SMOKE_PREFLIGHT_20260624_002039_gpu4_fixed.md`
- Commands:
  - `python research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`
  - `python research_gsure/03_baselines/scripts/validate_b1_plan_chain.py`
  - `python research_gsure/03_baselines/scripts/plan_b1_next_action.py --timestamp 20260624_002039 --output-md research_gsure/03_baselines/B1_NEXT_ACTION_20260624_002039.md --output-json research_gsure/03_baselines/B1_NEXT_ACTION_20260624_002039.json`
- Metrics:
  - status stage: `ready_for_smoke_approval`
  - checkpoint count: `0/4`
  - prediction manifest count: `0/4`
  - evaluation valid: `False`

### Remaining uncertainty
- Real training stability and segmentation performance remain unknown until the
  smoke and full LOCO gates are executed.

### Next recommended action
- Request exact approval for the bounded B1A smoke command in
  `research_gsure/03_baselines/B1A_SMOKE_PREFLIGHT_20260624_002039_gpu4_fixed.md`.
