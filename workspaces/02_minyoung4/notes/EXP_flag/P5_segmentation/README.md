# P5 — Segmentation track: treatment-effect-aware glioma segmentation

Created 2026-06-20. Pivot to **segmentation** because it is where imaging genuinely works (Dice GT,
no clinical-floor confound) — unlike molecular prediction (IDH = age ceiling; MGMT = no imaging
signal, both verified). See memory `glioma-multiconsortium-dead-directions`.

## Direction (literature-gated 2026-06-20)
- **DEAD**: architecture swap (nnU-Net Revisited, MICCAI 2024 — arch gains are validation artifacts).
- **THIN/CROWDED**: generic DG-seg loss (SmaRT/CDDSA/FedDG/causal-invariance occupy it; FeTS shows
  multi-site generalizes on average). → use our LOCO-collapse only as the **setting/motivation**.
- **✅ DEFENSIBLE (chosen) — D2: treatment-effect-vs-tumor disentangled segmentation.**
  The post-treatment ambiguity (enhancement = true tumor OR treatment effect / radiation necrosis)
  is clinically central but **no segmentation loss models it** — GLI-post winner ("Faking It",
  GliGAN-aug + ensemble) does not claim a representation/loss for it. Unclaimed gap.

## D2 claim (draft)
> A segmentation objective that **factorizes enhancing-tissue representation into a tumor component
> and a treatment-effect component**, weakly supervised by longitudinal persistence (MU), reduces
> treatment-effect false-positives on post-treatment glioma vs a strong nnU-Net trained on pre+post
> data. Capability-loss ablation: removing the disentanglement head brings back a *specific* failure
> — over-segmenting treatment-effect enhancement as tumor on MU/UCSD, while pre-treatment cohorts
> (UPENN/UTSW) are unaffected.

## Feasibility gate — PASSED (2026-06-20)
MU is longitudinal + **co-registered across timepoints (12/12 sampled: same shape+affine)**, so a
**voxel-level weak label is derivable**: enhancing (label 3) voxels that PERSIST across timepoints =
tumor-like; that DISAPPEAR (no regrowth) = treatment-effect-like. Per-patient T0→T1 persistence is
highly variable (0.00–0.77), confirming a learnable signal. 155 MU patients have ≥2 timepoints.
Caveat (must quantify): persistence is NOISY (registration error, re-seg variability, intervening
treatment). Quantify label noise; the weak label is supervision, not ground truth.

## Plan (autonomous phases)
1. **(running) Strong seg baseline** — MONAI UNet, whole-tumor binary (per-site label map:
   classic BraTS {1,2,4} for UPENN/UTSW; post-tx {1,2,3} excl. resection-cavity-4 for MU/UCSD), LOCO,
   per-consortium Dice. `seg_orchestrator.sh` (detached). Output: `reports/baseline_seg_eval.json`
   (does Dice degrade on held-out consortium = the shift SETTING).
2. **D2 weak labels** — per-(patient,timepoint) voxel treatment-effect-vs-tumor map from MU
   longitudinal persistence (+ cohort structure: pre vs post-treatment).
3. **D2 method** — disentangled seg head (tumor vs treatment-effect components) + disentangle/
   contrastive loss; capability-loss ablation (treatment-effect false-positive volume on MU/UCSD).
4. **Eval** — vs required baselines: nnU-Net (ResEnc, properly tuned — the killer), MedNeXt,
   SwinUNETR, BigAug, "Faking It" GliGAN-aug+ensemble (GLI-post SOTA), nnU-Net pre+post (the
   no-disentanglement ablation control).

## Reviewer attacks to pre-empt (from the scout)
nnU-Net Revisited rigor (tuned ResEnc baseline + no spacing artifact + capability-loss ablation);
weak-label noise (quantify, show gain isn't label-leakage); SmaRT (TTA) differentiation (train-time
vs test-time); "tumors genuinely change" (D2 permits tumor change, constrains only treatment-effect).

## Directory
```
P5_segmentation/
  scripts/  train_seg.py (baseline)  seg_eval.py  seg_orchestrator.sh
            [next] make_te_weak_labels.py  train_seg_d2.py  (D2 method)
  runs/     seg_{MU,UCSD,UPENN,UTSW}_v1/   [next] d2/
  reports/  baseline_seg_eval.json  [next] d2_eval.json
  logs/     orchestrator.log
```
Reuses P3 image cache + exp02 data layer. SSH-resilient via `setsid nohup`.

## Status
- Seg baseline orchestrator running (4 folds, autonomous). D2 feasibility PASSED. Next: D2 weak
  labels + disentangled-seg method.
