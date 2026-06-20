# P1 OOF (out-of-fold prediction) schema

Universal long format every P1 model emits and the eval harness consumes. One row per
(model, fold, subject) for the held-out test subjects (and optionally nested-OOF train rows). Binds
to the S1 split via `stable_split_id` + `source_manifest_sha256` (G7 frozen-OOF contract).

| column | type | meaning |
|---|---|---|
| `stable_split_id` | str | S1 split id; must match across all model files being compared |
| `source_manifest_sha256` | str | manifest hash from S1 (provenance) |
| `model_id` | str | e.g. `erm`, `ermpp`, `coral`, `groupdro`, `ours` |
| `fold_id` | str | `loco_<heldout>` |
| `heldout_dataset` | str | held-out consortium for this fold |
| `dataset` | str | the subject's consortium (the evaluation group) |
| `subject_id` | str | |
| `uid` | str | `dataset::subject_id` (== leakage_group_id) |
| `role` | str | `test` (held-out) or `train`/`val` (nested-OOF, optional) |
| `idh_label` | int | ground truth: mutant=1 / wildtype=0 |
| `p_mutant` | float | predicted P(mutant) in [0,1] |
| `prob_kind` | str | `raw` \| `temp` \| `isotonic` \| `bbse` (which calibration produced `p_mutant`) |
| `pos_label` | int | positive class = 1 (mutant); recorded for unambiguous metrics |

Rules:
- Evaluation metrics are computed on `role == 'test'` rows only; `dataset` is the grouping unit
  for per-consortium / worst-consortium aggregation.
- A model-vs-model comparison requires all files to share `stable_split_id` and the same test uid
  set (paired). The harness asserts this before any paired bootstrap.
- Test labels never feed calibration/prior-correction fitting (those use val/source only).
