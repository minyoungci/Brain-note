# Candidate A — BalancedDINO-iBOT (architecture figure)

Clean publication-quality methodology/architecture figure for a MICCAI paper. Left-to-right horizontal flow, white background, minimal academic style, neutral palette with ONE accent color (orange) reserved for the novelty module.

FLOW (left → right):
1. Input: a 3D brain MRI volume icon (single channel), label "3D Volume (anat + DWI, z-norm)".
2. Augmentation block: "Multi-crop: 2 global (96³) + N local (48³) + masking".
3. Encoder block: a 3D Vision Transformer labeled "ViT-L, patch 16³". Inside show a [CLS] token, four small "register tokens", and a grid of patch tokens.
4. Two branches leaving the encoder:
   - TOP branch from the [CLS] token → box "DINO head" → output "L_global (cls / reg)".
   - BOTTOM branch from the patch tokens → box "iBOT masked-patch head" → output "L_dense (seg)".
5. CENTRAL highlighted module in ORANGE (visually prominent, this is the novelty): "Adaptive Balancing (non-additive): L = balance(L_dense, L_global)". Both L_global and L_dense feed into it with arrows.
6. "EMA Teacher" box (grayed, same encoder) with a DASHED feedback arrow back into the heads (self-distillation).
7. Two small side annotation boxes near the encoder: "KoLeo (anti-collapse)" and "Gram anchoring (dense stability)".

Labels readable, arrows clear. The orange Adaptive Balancing module is the focal point.
