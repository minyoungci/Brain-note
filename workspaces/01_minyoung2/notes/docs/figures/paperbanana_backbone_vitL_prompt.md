# 3D ViT-L Foundation Backbone — detailed architecture figure

A DETAILED, publication-quality architecture diagram of the foundation model BACKBONE itself (the 3D Vision Transformer encoder that is KEPT as the single transferable checkpoint). This is the model architecture, NOT the pretraining loss graph. White background, clean academic style, neutral palette with ONE accent color for the kept backbone. Left-to-right main flow with a zoomed-in inset of one transformer block and a spec panel.

TITLE (top): "3D ViT-L Foundation Backbone — the single transferable encoder"

MAIN FLOW (left → right):
1. Input: a 3D brain MRI sub-volume cube, label "Input crop 96³ (single channel)".
2. "3D Patch Embedding" block: "Conv3D, kernel = stride = 16³" → arrow → label "→ 6×6×6 = 216 patch tokens, dim D=1024".
3. Token-assembly row: a horizontal strip of tokens showing one "[CLS]" token, four "[REG]" register tokens, then "216 patch tokens"; below it "+ 3D positional embedding"; output label "sequence 221 × 1024".
4. "Transformer Encoder × 24 blocks" — a large stacked box (show it is repeated 24 times). From it, a DASHED zoom-in callout to a single block detail:
   - "LayerNorm → Multi-Head Self-Attention (16 heads, FlashAttention) → ⊕ (residual) → LayerNorm → MLP (4096, GELU) → ⊕ (residual)".
5. Outputs on the right, three arrows from the encoder:
   - "[CLS] token → GLOBAL representation (cls / reg tasks)"
   - "patch tokens (6×6×6 × 1024) → DENSE representation (segmentation)"
   - "[REG] tokens → internal computation (not used downstream)"

SPEC PANEL (bottom-right corner box): "ViT-L  |  depth 24  ·  dim 1024  ·  heads 16  ·  MLP 4096  ·  ~300M params  ·  patch 16³  ·  +4 registers  ·  bf16"

BANNER (bottom, subtle): "This encoder IS the foundation model — one checkpoint for all 7 downstream tasks. Pretraining heads (DINO/iBOT) and EMA teacher are scaffolding, NOT part of it."

Emphasize the encoder (accent color), make the transformer-block inset clearly detailed, keep labels readable.
