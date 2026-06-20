# EXP_flag — Research Tracks (glioma 4-consortium)

> Recovery note (2026-06-20): this dir was accidentally `rm -rf`'d and rebuilt from the session
> transcript. Recovered + verified: P1_01 split generator (content hash `dc288827`, N=1444),
> P1_02 eval harness (self-test 7/7), P3 strong-IDH training. Some METHOD/review docs for completed
> dead-end work (P2 floor, S0/S1/S2/M0a reviews) live in the transcript + memory and are restored
> on demand. exp02 runs, docs/, data/, and memory were outside EXP_flag and untouched.

## Where we are (2026-06-20)
Three *method* directions were gated and walled (see memory `glioma-multiconsortium-dead-directions`):
1. **Molecular (IDH/MGMT)** — but the "ceiling" rested on a WEAK B2 proxy (LOCO test AUC ~0.73,
   below age-only 0.89). A genuinely strong model was never run → **that is the current experiment.**
2. **Longitudinal progression** — data-starved (M0a leakage-clean cohort N≤28).
3. **Label-heterogeneity seg** — conflict concentrated in 2 post-tx sites (RC/cellularity).

Per the standing goal: **actually train a strong model, beat prior work via technical novelty, and
pin down exactly where it fails.** The molecular ceiling was never tested with a strong model.

## Active track — P3: strong 3D IDH, then technical novelty
- `P3_idh_strong/scripts/train_idh_strong.py` — MONAI **DenseNet121-3D** (~11M, vs weak B2 ~3M),
  proper recipe (pos_weight, augment, cosine LR, bf16, best-val selection), LOCO, reuses the audited
  exp02 data layer (`build_records`/`GliomaImageDataset`/`stratified_validation_split`).
- `eval_p3.py` — per-/worst-consortium + pooled held-out AUC vs B2 proxy (0.73) and age (0.89).
- Running (2026-06-20): UTSW/UPENN/MU folds on GPU 2/3/4 (96×128×128, 60 ep). UCSD queued.
- **Reference to beat**: B2 proxy per-fold {UCSD 0.591, UPENN 0.844, UTSW 0.732, MU 0.772}; published
  Res3DNet external ~0.872; Glio-LLaMA-Vision IDH ~0.89 (≈ our age confound, never age-adjusted).
- After baseline numbers: add the model novelty (candidates: stronger/foundation backbone,
  T2-FLAIR-mismatch-aware fusion, shift-robust component — decided from where the baseline fails).

## Harness inventory (recovered)
- `P1_01_cohort_loco_split/` — LOCO split generator + artifact (N=1444, hash `dc288827`). The
  canonical subject-isolated split; conflict-excluded; verified leakage-free.
- `P1_02_eval_harness/` — calibration (ECE eq-width/eq-mass, Brier), subject-level metrics +
  worst-consortium + low-prev pooling, generic PAIRED bootstrap, OOF schema/IO. Self-test 7/7.
- `P2_01_progression_floor/` — (dead-end record) the M0a leakage case study.
- `P3_idh_strong/` — active strong-model training + eval.

## Hard gates
- GPU runs use free GPUs (2/3/4), bf16, no raw-data writes. (Standing goal authorizes training.)
- Generate ≠ verify: every script gets an independent code-auditor review before its result is trusted.
- No novelty/SOTA claim without literature grounding.
