# 3D ViT (8³ patch, Primus-style) Foundation Backbone — detailed architecture figure

A DETAILED, publication-quality architecture diagram of the foundation model BACKBONE itself (the dense-first 3D Vision Transformer encoder kept as the single transferable checkpoint). This is the model architecture, NOT the pretraining loss graph. White background, clean academic style, neutral palette with ONE accent color for the kept backbone. Left-to-right main flow with a zoomed-in transformer-block inset and a spec panel.

TITLE (top): "3D ViT (8³ patch, Primus-style) Foundation Backbone — dense-first encoder"

MAIN FLOW (left → right):
1. Input: a 3D brain MRI sub-volume cube, label "Input crop 96³ (single channel)".
2. "3D Patch Embedding" block: "Conv3D, kernel = stride = 8³ (fine tokenizer)" → arrow → label "→ 12×12×12 = 1728 patch tokens, dim D=768". Emphasize that the FINE 8³ patch makes the token grid MUCH denser (and the sequence ~8× longer) than a 16³ ViT — this is the dense-first design.
3. Token-assembly row: "[CLS] + 4 [REG] register tokens + 1728 patch tokens"; below "+ 3D positional embedding"; output "sequence 1733 × 768".
4. "Transformer Encoder × 12–24 blocks (FlashAttention, gradient checkpointing for long sequence)" — large stacked box, with a DASHED zoom-in to one block: "LayerNorm → Multi-Head Self-Attention → ⊕ → LayerNorm → MLP (GELU) → ⊕".
5. Outputs on the right:
   - "[CLS] token → GLOBAL representation (cls / reg)"
   - "patch tokens (12×12×12 × 768) → DENSE representation (segmentation) — high spatial resolution"
   - "[REG] tokens → internal (not used downstream)"

SPEC PANEL (corner): "Primus-style ViT | patch 8³ (vs 16³) → 8× longer sequence | dim ~768 | FlashAttention + grad-checkpoint | high-mask MAE path → 40% less VRAM | bf16"

BANNER (bottom): "Fine 8³ patch = richer DENSE features for segmentation, at higher sequence/compute cost. This encoder IS the foundation model (single checkpoint)."

Emphasize the very fine 8³ patch grid (denser than the 16³ ViT figure) and the long token sequence. Accent color on the encoder.
