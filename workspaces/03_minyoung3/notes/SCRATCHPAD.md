# SCRATCHPAD — current experiment state

## Direction (LOCKED 2026-06-16, user-approved plan)
**Clinically-conditioned counterfactual 3D brain MRI generation — Korean AD–SVD cohort (AJU).**
Contribution = NOT a generator; = per-axis **structural-encoding READOUT** via identity-preserving
counterfactuals along clinically meaningful axes (amyloid-PET status, WMH/Fazekas grade,
SNSB executive-vs-memory dissociation, APOE, vascular subtype) + a per-variable conditioning-fidelity
battery. Ties to S×M / morphometry-oracle finding: amyloid/executive axes → ~0 structural change
(= finding, T1-blind), atrophy/WMH → strong localized change. Venue MICCAI/MIDL.
Plan: `/home/jovyan/.claude/plans/glistening-booping-meadow.md`.

Why this (vs all prior): 11 supervised directions hit the morphometry ceiling; negative meta-paper
literature-pre-empted (Schulz/Bzdok, Bron); generator-quality competition lost at N≈1000 (Pinaya 31,740).
Only open niche = vascular + cognitive-domain counterfactuals (Western counterfactual work is all
AD/amyloid/age). Full record: insights/I01–I12.

## Verified assets
- On-disk AJU images (192×224×192 1mm RAS z-score, same grid): T1w 1001, FLAIR 985, T2, amyloid-PET 992.
  `/home/vlm/data/preprocessed_official/v2/AJU/subjects/<id>/<ses>/{t1w,flair,t2,pet_amyloid}/`
- **DTI NOT on disk** (manifest `tensor_exists=True` is a FALSE flag, I03 trap) → dropped.
- Conditioning ~1000, ~97–100% cov: `korean_multimodal_manifest.csv` (consortium==AJU) + SNSB z from
  `raw/AJU/metadata/임상역학정보 분양_all.xlsx`. amyloid bal 656neg/344pos, WMH grade 628/312/61,
  vascular-spectrum ~261 (Vascular-MCI 104/AD+SVD 58/Subcortical-VaD 44/AD+vascular 38/Multi-infarct 11),
  dx MCI606/AD190/CN119/OtherDem86, SNSB domains all 1001.
- In-project pretraining corpus (own assets only): preprocessed T1 at SAME 192³ grid —
  ADNI 10074 / NACC 3752 / OASIS 3230 / AJU 2574 / AIBL 1980 t1w/final_tensor files (incl. masks →
  ~10k+ actual T1 images). **VERIFIED on disk + grid-consistent.** Exclude AJU val/test from AE pretrain.

## Model architecture (decided)
**Conditional LATENT diffusion** (Pinaya/Stable-Diffusion family), two stages:
1. **AutoencoderKL** (conv-only — 3D attention OOMs): 192³ → latent **(4, 24, 28, 24)** (~128×). Unconditional.
2. **Conditional DiffusionModelUNet** in latent space: the actual generator. Conditioning lives HERE.
- **Where the technical depth/novelty goes (NOT the backbone):** keep the diffusion UNet STANDARD
  (fancy generators lose at N≈1000 + overfit). Invest engineering in:
  (a) **conditioning encoder** — per-variable embeddings (continuous=Fourier/MLP, categorical, ordinal),
      **missingness mask tokens + modality dropout** so each axis is independently set/ablated;
  (b) **counterfactual mechanism** — DDIM-inversion to recover subject latent → edit ONE axis → re-denoise
      (identity-preserving); per-axis **classifier-free guidance**; (cross-check latent-SCM, MICCAI-DGM-2025);
  (c) **vendor/scanner conditioning** to prove counterfactuals aren't scanner shifts (minimality);
  (d) small-N regularization: EMA, strong aug, v-prediction, **memorization audit**.
- **Open methods-novelty surface:** clinical axes are *correlated* in training (amyloid↔dx↔atrophy) →
  producing *independently-controllable* counterfactuals ("change amyloid, hold atrophy fixed") is the
  real research problem (causal/disentangled conditioning). This is the "what's the new method" answer.

## Milestones / status
- [x] Topic selection + critical lit verification (2 literature-scouts) + asset audit (insights I11/I12)
- [x] **M0 (CPU): `manifests/generation_manifest.csv`** — N=1001, T1 1001/FLAIR 985/PET 992 on disk, 192³,
      split 707/147/147 subject-level dx-strat, 48-col missingness mask, amyloid/WMH balance preserved.
      `scripts/build_generation_manifest.py`. CAVEAT: scanner GE-dominant 752/1001 → held-out-scanner check weak.
- [x] **In-project corpus gate PASS** (~10k T1, 192³, grid-consistent — see assets).
- [x] **Conditional-gen smoke PASS** (`scripts/smoke_conditional_gen.py`): 3D cond DDPM trains bf16/B200,
      loss 0.39→0.039, cond sampling works, CN-vs-AD effect 0.48 → conditioning wired & used.
- [x] **AE smoke PASS** (`scripts/smoke_autoencoder.py`, GPU3): conv-only AutoencoderKL 9.7M, 192³→(4,24,28,24),
      recon L1 0.167→0.116, holdout PSNR 22.4dB (low = smoke), peak 46.5GB.
- [~] **M1 proper RUNNING** (`python -u scripts/train_autoencoder.py`, GPU3, PID 1487973, nohup→`runs_ae_pretrain.log`):
      full AutoencoderKL pretrain on **corpus T1=10,641** (AJU val/test excluded) + L1/KL/perceptual/PatchGAN,
      12k steps, **~1.12s/it ≈ 3.7h**, loss logged every 100 steps, val+ckpt every 2500 → `runs/ae_pretrain/ae_step*.pt`.
      Health @step100: reconL1 0.138, perc 1.17 (OK). **Gate G1** = recon PSNR/SSIM at convergence (target ~>25dB/SSIM>0.85).
      LESSONS: use `python -u` (block-buffering hid loss for 1.7h); NEVER `pkill -f train_autoencoder.py` (self-matches
      launch cmd → kills shell, I04-P4) — kill by PID. TODO after G1: extend T1→2ch T1+FLAIR.
- [x] **M2 pipeline smoke PASS** (`scripts/train_latent_diffusion.py`, GPU2): frozen AE→latent (4,24,28,24),
      **CondEncoder (per-variable embed + learned MISSING tokens, 46K)** + conditional latent UNet (81.3M, attn at 12³/6³)
      + CFG dropout; precompute-latents + checkpointing; loss↓, condition→decode→full 3D image works.
- [x] **AUTONOMOUS PIPELINE LIVE** (`scripts/run_pipeline.sh`, PID 1384144, **setsid own-session → SSH-disconnect-safe**):
      waits for AE `ae_step12000.pt` → **G1 gate** (proceed iff AE val SSIM≥0.80; trajectory 0.884→0.933) →
      auto-launches M2 full (GPU3, 50k steps, ckpt every 5k → `runs/ldm/`) → logs to `runs_pipeline.log`.
      AE (PID 1487973, nohup) also disconnect-safe. AE val: PSNR ~28dB / SSIM ~0.93 (G1 passing). Logs:
      `runs_pipeline.log` / `runs_ae_pretrain.log` / `runs_ldm.log`. **No human needed for AE→M2 completion.**
- [ ] M3 (GPU+CPU): counterfactual gen + per-axis fidelity battery (SynthSeg + WMH seg). Gate G2.
- [ ] M4: per-axis structural-signature map + writeup.

## Decisions / open
- [DECIDED] Image channels: **T1+FLAIR**, phased (T1 first to pass G1 → add FLAIR channel before vascular-axis experiments).
- [DECIDED] Proceed to M1 GPU build (smoke-first satisfied; corpus verified).
- [OPEN] Cohort identity = BICWALZS (Son et al. Psychiatry Investig 2022)? confirm with PI — affects framing/citation.
  Note: our N (MRI 1001, PET 992) > BICWALZS reported (817/713) → possibly larger/newer release. Frame conservatively meanwhile.
- [OPEN] Venue MICCAI vs MIDL.

## Discipline (do NOT violate)
bf16 only (no fp16); GPU runs need prior approval + smoke subset first; `/home/vlm/data` read-only;
use ONLY minyoung3 own assets ([[project-isolation-rule]]); subject-level splits (no leakage);
multi-seed + subject-bootstrap CIs; 3D AE conv-only (attention OOMs); GPU3–5 (GPU0/6/7 shared/busy);
report FID but DON'T claim generator superiority; memorization audit; NO "synthetic augmentation improves
diagnosis" claim (information-capped, I04 trap). Always log new failures/insights to `insights/`.
