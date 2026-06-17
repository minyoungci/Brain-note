# minyoung3 — conditional 3D brain-MRI generation

Self-contained project. Use ONLY this directory's own assets — do not borrow corpora/code from
sibling projects (`minyoung2`, `minyoung4`, etc.). `/home/vlm/data` is read-only shared data;
physical presence there does not make a thing this project's asset.

## Direction
**Clinically-conditioned counterfactual 3D brain-MRI generation — Korean AD–SVD cohort (AJU).**
A conditional *latent* diffusion model (AutoencoderKL → conditional DiffusionModelUNet in latent space)
conditioned on a rich multimodal clinical vector; identity-preserving counterfactuals along clinically
meaningful axes (amyloid-PET status, WMH/Fazekas grade, SNSB executive-vs-memory, APOE, vascular subtype),
validated by a per-clinical-axis conditioning-fidelity readout. The contribution is the **per-axis
structural-encoding readout**, not generator fidelity. Target ACCV/MICCAI-tier.

- Current state + roadmap: **`SCRATCHPAD.md`**
- Full plan: `/home/jovyan/.claude/plans/glistening-booping-meadow.md`

## Layout
- `scripts/` — data assembly + AE/diffusion training + sampling/diagnostics (reproducible code).
- `manifests/` — assembled generation manifest (conditioning table + image index + splits). [gitignored]
- `results/` — generation diagnostics/montages. [gitignored]
- `runs/` — model checkpoints + caches. [gitignored]

## Key scripts
- `build_generation_manifest.py` — assemble conditioning table + image index + subject-level splits.
- `train_autoencoder.py` — AutoencoderKL pretrain on in-project multi-cohort T1 (Gate G1: recon PSNR/SSIM).
- `train_latent_diffusion.py` — conditional latent diffusion (CondEncoder + CFG; latents cached).
- `sample_m2_sanity.py` — conditional generation montage (the visual gate).
- `diag_*.py` — latent / reconstruction diagnostics.
- `run_pipeline.sh` — autonomous AE→diffusion orchestration (detached).

## Discipline
bf16 only (no fp16); GPU runs need prior approval + smoke-subset first; subject-level splits (no leakage);
3D AE must be conv-only (attention OOMs at these resolutions); detached runs via `nohup`/`setsid` (kill by PID,
never `pkill -f <scriptname>`); report FID but do NOT claim generator superiority; memorization audit;
ALWAYS verify generation visually — low loss ≠ working (the montage is the truth).
