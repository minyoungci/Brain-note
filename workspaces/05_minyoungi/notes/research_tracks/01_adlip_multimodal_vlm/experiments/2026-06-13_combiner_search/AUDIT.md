# Code audit — combiner search pipeline (2026-06-13)

Independent audit by `code-auditor` agent of `dump_brainage_rich.py`,
`fusion_lab.py`, `merge_rich.py` (+ `model.py`). Read-only, line-level.

## Verdict: LEAKAGE-FREE
Held-out cohort labels/statistics never reach any train-stage fit:
- morph NA-fill uses **train** median for both train & test (`dump:174-175`).
- StandardScaler fit on `Xtr` only; amean/astd from train age only.
- All combiners fit on `split=='train'`, evaluated on `split=='test'`.
- `precision_subj` uses only model uncertainties — no held-out labels.
- Q3: deep TRAIN preds are in-sample (optimistic), but this **handicaps fitted
  combiners** (mis-estimates their weights), it does **not inflate** held-out test
  eval (test cohort never trained on). → not leakage. Caveat: a negative result
  for fitted combiners is partly self-inflicted by this handicap — interpret the
  *negative* cautiously; precision_subj (no label fit) is the unbiased test.

## Non-leakage correctness threats — FIXED in analysis code (fusion_lab/merge_rich)
| id | issue | fix |
|----|-------|-----|
| C-4 | Mode B `merged` used positional `.values` join (fragile silent shuffle) | eval now self-consistent on `run_fitted_loco` output frame; no cross-frame join + NaN assert |
| C-3 | `age_cond_apply` `np.empty` uninitialized → garbage if NaN predicted-age | `np.full(nan)` + plain-mean fallback for uncovered rows |
| C-5 | per-cohort multiple comparisons uncorrected | Holm-Bonferroni reported for any candidate that beats mean |
| C-2 | deep_std ddof / scale | ddof=1 + fillna(0); note: scale absorbed by precision_subj train calibration |
| M-7 | merge could double-count duplicate fold parquets | assertions: 1 test cohort/fold, fold count == parquet count, cohort not split across folds |

## Known limitations — NOT yet fixed (deliberate; documented for honesty)
- **H-1 cudnn nondeterminism**: `dump_brainage_rich.py` does not set
  `cudnn.deterministic` / `worker_init_fn`. Deep predictions vary run-to-run, so
  the seed-ensemble "epistemic std" carries some cudnn noise. **NOT touched now**
  because the λ=0 and λ=1 waves must run on *identical* code (changing it mid-run
  would confound the GRL ablation). → Before any "reproducible" claim in a paper,
  re-run the FINAL configuration with `cudnn.deterministic=True` + fixed worker
  seeds. Current runs are for *exploration* (which combiner family wins), not the
  publication-grade reproducible numbers.
- **In-sample train preds** (Q3) not replaced with out-of-fold — fitted combiners
  are handicapped. If a fitted combiner shows promise despite this, OOF retraining
  would strengthen it; if it loses, the loss is partly the handicap.
- BatchNorm last-batch / `drop_last=True` (C-1): minor, noted.

## Interpretation rule for this experiment
- The clean novelty test = **precision_subj vs mean** (no label fit, unbiased).
- Fitted combiners (ridge_stack, BLUE, age_cond, biascorr) losing to mean is
  *expected and partly handicap-driven* — it supports "learned fusion overfits
  cross-cohort" only weakly; do not oversell.
- Any candidate beating mean must survive Holm correction before being called a win.
