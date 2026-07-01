# AAAI-27 — Rank–Transfer Decoupling in Dense+Global 3D Brain-MRI Foundation Models

**Official repository — confirmed content only.** Curated from the working repo
(`/home/vlm/minyoung2`) via `Flagship/AAAI/scripts/build_minyoung4_official.sh`. This repo holds
**only results/claims that are independently verified**; conditional or in-progress work stays in the
working repo until confirmed (see `Flagship/AAAI/STATUS.md`).

## What this paper is (confirmed contributions)
A **cautionary, externally-oriented empirical study** of checkpoint selection for single-checkpoint
dense+global 3D brain-MRI SSL foundation models. Not a new loss/architecture.

- **Foundation** (design of record): ResEnc U-Net + S3D dense branch (SparK **approximation**, cited,
  not a contribution) + SimPool **InfoNCE** global branch + KoLeo. Objective `L = L_dense + w_global·L_global`.
  Corpus **FOMO300K → 226,793 preprocessed volumes / 36 public sources (ADNI excluded)**, 150k steps bf16.
  Per-crop **z-normalized** input. Five checkpoints (w_global ∈ {0, .25, .5, .75, 1}).
- **TC1 — protocol/budget-adaptive transfer** (internal, paper-ready): a scratch-convergence diagnostic
  prescribes the transfer protocol. Trigeminal Task4 frozen **Δ+0.134** (CI-separated); diagnostic gap **+0.101**.
- **TC2 (FINDING, internal) — rank–transfer decoupling**: effective rank (RankMe) is monotone in w_global
  while transfer is not; **RankMe-max selection picks pure-dense (w_global=0), the worst checkpoint** (internal
  regret 0.194). **Selector METHOD = NO-GO**: no pre-registered label-free spectral criterion (α-ReQ, EVR,
  silhouette) locates the interior optimum on a finer 5-point grid (α-ReQ's 3-point peak was a coarse-grid
  artifact). Reported honestly as an open problem, not a solved selector.
- **Leakage**: external cohorts (A4/AIBL/AJU) are **4-level DISJOINT** from the 226,793-volume corpus.
- **External label table** (TC3 groundwork): foundation-input ↔ clinical join — brain-age n=2093,
  CN/MCI/AD (AIBL+AJU), amyloid, scanner + FreeSurfer morphometry.

## What is NOT here yet (pending confirmation — in working repo)
TC3 external transfer **results** (critic-conditional: needs ≥3 random seeds, paired-Δ/BCa/Holm, nonlinear
site probe, dx→secondary) · foundation baselines (from-scratch, BrainJEPA, BrainIAC) · FastSurfer dense-seg.
These migrate here once confirmed. See `Flagship/AAAI/STATUS.md` for the roadmap.

## Layout & running
Mirrors the working-repo layout so code runs unchanged (`Path(__file__).parents[3]` → this repo root).
- `pretrain/` foundation + eval code · `preprocessing/`, `baseline-codebase/` (yucca), `downstream/` eval code.
- `Flagship/AAAI/` — `scripts/` (confirmed pipeline), `docs/` (design of record), `draft/` (confirmed
  sections), `results/` (confirmed artifacts + `RESULTS_INDEX.md`).
- `.venv-train`, `.venv`, `experiments/phase_b` are **symlinks** into `/home/vlm/minyoung2` (working repo
  stays; checkpoints/venv not duplicated). GPU env = `.venv-train` (torch 2.12+cu130, B200, bf16).
- Data referenced by absolute path under `/home/vlm/data/` (not copied).

Sanity: `.venv-train/bin/python Flagship/AAAI/scripts/phase0_labelfree_screen.py --smoke`.
