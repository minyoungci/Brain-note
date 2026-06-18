# Experiment sweep — best conditional diffusion (review each montage; brain vs noise)

- **kl1e3_eps** — montage `experiments/kl1e3_eps/montage.png` | cond-effect(CN-AD)=0.2133 | ckpt runs/ldm_kl1e3/ldm_step50000.pt
- **kl1e3_vpred_minsnr** — montage `experiments/kl1e3_vpred_minsnr/montage.png` | cond-effect(CN-AD)=0.2068 | ckpt runs/ldm_kl1e3_v/ldm_step50000.pt
- **kl1e2_eps** — montage `experiments/kl1e2_eps/montage.png` | cond-effect(CN-AD)=0.1902 | ckpt runs/ldm_kl1e2/ldm_step50000.pt
- **kl1e2_vpred_minsnr** — montage `experiments/kl1e2_vpred_minsnr/montage.png` | cond-effect(CN-AD)=0.1690 | ckpt runs/ldm_kl1e2_v/ldm_step50000.pt

## Gen-quality metrics (DDPM-1000, N=48; 2.5D-Inception FID, MS-SSIM diversity, NN-SSIM memorization)
| model | FID↓ | div gen/real | mem NN-SSIM max |
|---|---|---|---|
| kl1e3_eps | 75.3 | 0.76/0.78 | 0.83 |
| kl1e3_vpred_minsnr | 63.5 | 0.77/0.78 | 0.88 |
| **kl1e2_eps (BEST)** | **53.0** | 0.78/0.78 | 0.87 |
| kl1e2_vpred_minsnr | 54.8 | 0.78/0.78 | ~ |
All: healthy diversity (no mode collapse), no memorization (<0.95). KL=1e-2 > KL=1e-3. NOTE: FID = unconditional
quality; conditioning FIDELITY (per-axis: AD→atrophy, WMH3→WMH) is the next, separate eval (the paper's readout).
IMPORTANT: generation requires FULL 1000-step DDPM (100-step ancestral / DDIM-200 diverge to noise).
