# Why 3D Brain MRI Representation Learning Is Hard

Create a publication-ready conceptual diagram explaining why representation learning on
multi-consortium 3D brain MRI (Alzheimer's) underperforms. Grounded in measured evidence.

Title: Why 3D Brain MRI Representation Learning Is Hard

Central thesis (put as a prominent banner across the top):
"The signal you want (disease) is SMALL and LOW-VARIANCE; the signals you don't (scanner,
age, site) are LARGE, HIGH-VARIANCE, and CONFOUNDED with biology."

Layout: landscape 16:9, three stacked horizontal bands (left label per band), clean boxes,
muted academic palette, arrows showing how nuisance dominates the learned representation.

BAND 1 — "Data-level obstacles" (red-tinted):
- Site/scanner shortcut: image appearance alone predicts the consortium at balanced
  accuracy 0.565 (chance 0.143). Model learns the scanner, not the disease.
- Resolution heterogeneity: native voxel alone predicts consortium at 0.70 — an
  INDEPENDENT axis that intensity correction (N4) cannot remove.
- Site == population confound: Korean (AJU/KDRC) vs Western cohorts — scanner is tangled
  with real biology, so harmonization risks erasing the signal of interest.
- Tiny signal-to-nuisance: Alzheimer's atrophy is mm-scale and diffuse; age, head size,
  sex, and scanner explain far MORE variance than disease.
- Weak/noisy labels: CDR/clinical coverage gaps; clinical diagnosis is not pathology;
  CN -> MCI -> AD is a continuum, not discrete classes.

BAND 2 — "Method-level obstacles" (amber-tinted):
- 3D compute cost: ~8M voxels per volume -> small batches, shallow nets, limited augmentation.
- No web-scale pretraining corpus (unlike ImageNet/LAION for natural images) -> weak transfer.
- High dimensionality, few subjects (thousands) -> overfitting and shortcut learning.
- Evaluation leakage: subject/site leakage inflates scores; honest leave-site-out drops them.

BAND 3 — "Why self-supervised representation learning specifically struggles" (blue-tinted):
- SSL objectives encode the DOMINANT structure = scanner / site / global anatomy, not disease.
- Unclear what is invariant (scanner) vs signal (atrophy); medical 3D augmentation is immature.
- The useful axis (disease) is low-variance and entangled with high-variance nuisances ->
  disentanglement fails without explicit guidance.

Bottom takeaway box (green): "Mitigations: N4 (halves scanner bias, preserves population),
scanner-aware splits, leave-site-out evaluation, site-probe monitoring, light augmentation —
but a confound-free representation is not achievable from images alone."

Keep text concise inside boxes; use icons/arrows; ensure legibility at paper scale.
