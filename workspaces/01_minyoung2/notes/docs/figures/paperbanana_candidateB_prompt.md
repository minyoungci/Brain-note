# Candidate B — BalancedDINO-MAE (architecture figure)

Clean publication-quality methodology/architecture figure for a MICCAI paper. Left-to-right horizontal flow, white background, minimal academic style, neutral palette with ONE accent color (orange) for the novelty module.

FLOW (left → right):
1. Input: a 3D brain MRI volume icon, label "3D Volume (anat + DWI, z-norm)".
2. Augmentation block: "Multi-crop + HIGH masking (60–90%)".
3. Encoder block: a 3D Vision Transformer labeled "ViT, patch 8³ (Primus-style)". Emphasize a FINE patch grid (small 8³ patches → long token sequence), a [CLS] token, and four "register tokens".
4. Two branches leaving the encoder:
   - TOP branch from the [CLS] token → box "DINO head" → output "L_global (cls / reg)".
   - BOTTOM branch from the patch tokens → box "Conv Decoder (S3D / SparK)" → a small reconstructed-volume thumbnail → output "L_dense = MAE recon".
5. CENTRAL highlighted module in ORANGE (prominent, novelty): "Adaptive Balancing (non-additive): L = balance(L_dense, L_global)". Both losses feed in.
6. "EMA Teacher" box (grayed) with a DASHED feedback arrow into the global head.
7. Small side annotation boxes: "KoLeo", "Gram anchoring", and "80% masking → 40% less VRAM".

Visually emphasize the fine 8³ patch grid and the convolutional decoder (the dense-first design). Orange Adaptive Balancing module is the focal point.
