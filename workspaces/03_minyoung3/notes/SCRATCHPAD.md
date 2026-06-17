# SCRATCHPAD — conditional 3D brain-MRI generation (current state)

## Direction
**Clinically-conditioned counterfactual 3D brain-MRI generation — Korean AD–SVD cohort (AJU).**
A conditional *latent* diffusion model (AutoencoderKL → conditional DiffusionModelUNet in latent space)
conditioned on a rich multimodal clinical vector; identity-preserving counterfactuals along clinically
meaningful axes (amyloid-PET status, WMH/Fazekas grade, SNSB executive-vs-memory, APOE, vascular subtype).
**Contribution = per-axis conditioning-fidelity READOUT** (which clinical axes are structurally encoded in
T1, measured generatively), not generator fidelity. Target ACCV/MICCAI-tier. Plan:
`/home/jovyan/.claude/plans/glistening-booping-meadow.md`.

## Data / assets (AJU, on disk, 192×224×192 1mm RAS z-score, same grid)
- Images: T1w 1001, FLAIR 985, T2, amyloid-PET 992. `/home/vlm/data/preprocessed_official/v2/AJU/subjects/<id>/<ses>/{t1w,flair,t2,pet_amyloid}/`
- Conditioning ~1000, ~97–100% cov: `korean_multimodal_manifest.csv` (consortium==AJU) + SNSB z from
  `raw/AJU/metadata/임상역학정보 분양_all.xlsx`. amyloid 656neg/344pos, WMH grade 628/312/61, vascular-spectrum ~261,
  dx MCI606/AD190/CN119/OtherDem86, SNSB domains all 1001. (DTI NOT on disk — dropped.)
- In-project AE-pretrain corpus (own assets only): T1 at 192³ — ADNI 10074/NACC 3752/OASIS 3230/AJU 2574/AIBL 1980
  t1w/final_tensor (~10k images). Exclude AJU val/test from AE pretrain.
- Assembled: `manifests/generation_manifest.csv` (N=1001, split 707/147/147 subject-level dx-strat, 48-col missingness mask).
  Built by `scripts/build_generation_manifest.py`.

## Model architecture
**Conditional LATENT diffusion** (two stages):
1. **AutoencoderKL** (conv-only — 3D attention OOMs): 192³ → latent (4,24,28,24). Unconditional.
2. **Conditional DiffusionModelUNet** in latent: the generator. Conditioning HERE via **CondEncoder**
   (per-variable embeddings: continuous MLP + categorical embed + learned MISSING tokens) → cross-attention,
   + classifier-free guidance. Latents precomputed (cached) → fast training.
- Backbone STANDARD (fancy generators lose at N≈707). Novelty goes into conditioning + counterfactual, not backbone.

## Current state / open blocker
- **M1 AutoencoderKL DONE — G1 passed**: PSNR 28.33dB / SSIM 0.934. `runs/ae_pretrain/ae_step12000.pt`.
- **M2 conditional latent diffusion: BLOCKED — generates noise, root cause diagnosed.**
  - AE roundtrip = clear brain (L1 0.029); z_sigma tiny (H1 innocent); **partial-noise reconstruction t=200/500/800 = brains**
    → diffusion LEARNED the manifold; only from-pure-N(0,I) sampling fails → **PRIOR GAP**: latent is unit-moment (per-channel
    norm) but NOT Gaussian (KL=1e-6 = no regularization → far from N(0,I)). Textbook LDM failure.
  - Diagnostics: `scripts/diag_m2.py`, `diag_latent.py`, `diag_recon.py` (+ `results/diag_*.png`, `m2_sanity_montage.png`).
- **FIX (next): retrain AE with proper latent regularization** — Option A: KL weight 1e-6 → ~1e-3 (cheap, standard, try first);
  Option B: VQ-VAE/VQGAN latent (SOTA 3D-brain-CF choice). Then re-run M2 → montage must show real brains (the gate).

## Method novelty (lock for paper — literature-verified)
**Decoupled CFG (per-axis guidance over the CORRELATED clinical vector) + per-axis counterfactual-fidelity readout.**
Standard CFG (one global scale) leaks across correlated axes (amyloid↔dx↔atrophy); partition conditioning into
intervened/invariant groups per clinical causal graph → decoupled guidance → "change amyloid, hold atrophy fixed".
Quantify leakage with the peer-reviewed fidelity battery (composition/effectiveness/minimality/realism) **per axis** →
readout of which clinical axes are structurally encoded in T1 (amyloid/executive ≈ null vs WMH/atrophy strong+localized).
- Anchors: Melistas et al. NeurIPS 2024 (CF benchmark) + 3D ext DGM4MICCAI 2025; competitor Peng et al. DGM4MICCAI 2025
  (VQ-VAE latent SCM). White space = vascular + cognitive-domain axes (competitors do ADNI age/amyloid). Scoop risk — move fast.
- Add-ons (ROI-ranked): adaLN/FiLM conditioning (data-efficient N≈707); SynthSeg anatomy-consistency for minimality.
- AVOID (hype/kitchen-sink at N≈707): flow-matching-as-contribution, consistency distillation, SSL/foundation conditioning, pure DiT.

## Autonomous sweep — find the BEST conditional diffusion (RUNNING)
`scripts/run_sweep.sh` (setsid, disconnect-safe) runs a diagnosis-ordered experiment queue; each =
train M2 (50k) → montage → record under `experiments/<name>/{montage.png,metrics.log}` + `experiments/SUMMARY.md`.
The montage is the gate (brain vs noise) — human reviews SUMMARY to pick best (brain-vs-noise can't be auto-judged).
Diagnosis: from-pure-noise fails / partial-noise→brain ⇒ high-noise regime under-trained (NOT "latent non-Gaussian"
fundamentally — diffusion handles non-Gaussian data). So v-prediction + min-SNR-γ (rebalance timesteps) is the targeted fix.
Queue:
- **E0 kl1e3_eps** (KL=1e-3 AE, epsilon) — baseline, currently training → runs/ldm_kl1e3.
- **E1 kl1e3_vpred_minsnr** (KL=1e-3 AE, `--pred v --min_snr 5`) — diagnosis-targeted fix, highest priority.
- **E2 kl1e2_eps** (train AE KL=1e-2 → M2 epsilon) — more-Gaussian-latent alternative.
- **E3 kl1e2_vpred_minsnr** (KL=1e-2 AE, v-pred+min-SNR) — combine.
New diffusion knobs (verified by smoke): `train_latent_diffusion.py --pred {epsilon,v} --min_snr <γ>`; ckpt stores `pred`
so `sample_m2_sanity.py` auto-matches the sampler. ETA ~11h total (E2 includes a 3.7h AE retrain). VQ-VAE = last fallback
(bigger detour, data-hungry at N=707, doesn't address the high-noise symptom).

## Roadmap
1. **GATE: fix AE latent (KL↑/VQ) → M2 → montage = real brains?** (whole direction hinges on this.)
2. + Decoupled CFG + FiLM conditioning (the method novelty).
3. T1+FLAIR 2-channel (FLAIR needed for the vascular counterfactual).
4. M3 — per-axis counterfactual fidelity battery (DDIM-inversion CF + SynthSeg/WMH-seg) = the readout.
5. M4 — writeup.

## Discipline
bf16 only; GPU runs need approval + smoke-subset first; `/home/vlm/data` read-only; use ONLY minyoung3 own assets
([[project-isolation-rule]]); subject-level splits; 3D AE conv-only (attention OOMs); GPU0/6/7 often shared — prefer free ones
(check nvidia-smi); detached runs via `nohup`/`setsid` (kill by PID, never `pkill -f <scriptname>` → self-kills shell);
report FID but DON'T claim generator superiority; memorization audit; ALWAYS verify generation visually (loss ≠ working —
montage is the truth). Long runs: `python -u` (block-buffering hides progress).
