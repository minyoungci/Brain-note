# Candidate C — Seg-Safe ResEnc (architecture figure)

Clean publication-quality methodology/architecture figure for a MICCAI paper. Left-to-right horizontal flow, white background, minimal academic style, neutral palette with ONE accent color (orange) for the novelty module.

FLOW (left → right):
1. Input: a 3D brain MRI volume icon, label "3D Volume (anat + DWI, z-norm)".
2. Augmentation block: "MAE masking + light aug".
3. Encoder: a CNN "ResEnc-L U-Net Encoder" drawn as a stack of residual conv blocks (clearly a CNN, NOT a transformer), with downsampling stages and skip-connection stubs.
4. Two branches:
   - TOP from the bottleneck features → "SimPool (attention pooling)" → "Global-distill head" → output "L_global (cls / reg)".
   - BOTTOM through a "U-Net Decoder" (with skip connections from the encoder) → reconstructed-volume thumbnail → output "L_dense = MAE / S3D recon".
5. CENTRAL highlighted module in ORANGE (prominent, novelty): "Adaptive Balancing (non-additive): L = balance(L_dense, L_global)". Both losses feed in.
6. "EMA Teacher" box (grayed) with a DASHED feedback arrow into the global-distill head.
7. Small side annotation box: "KoLeo (anti-collapse)". Note (small text): "no register/Gram — CNN backbone".

Visually contrast with the ViT candidates: this is a CNN U-Net with skip connections. Orange Adaptive Balancing module is the focal point.
