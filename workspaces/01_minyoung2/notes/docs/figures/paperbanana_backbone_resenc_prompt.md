# ResEnc-L (CNN U-Net) Foundation Backbone — detailed architecture figure

A DETAILED, publication-quality architecture diagram of the foundation model BACKBONE itself — a 3D CNN Residual-Encoder U-Net (ResEnc-L) kept as the single transferable checkpoint. This is the model architecture, NOT the pretraining loss graph. White background, clean academic style, neutral palette with ONE accent color for the kept backbone. Classic U-Net shape (encoder down, decoder up, skip connections).

TITLE (top): "ResEnc-L (CNN U-Net) Foundation Backbone — segmentation-strong encoder"

STRUCTURE (U-Net layout):
1. Input (left): a 3D brain MRI patch, label "Input patch (e.g. 128³, single channel)".
2. ENCODER (descending, left side): a stack of residual conv stages with progressive downsampling. Label each stage with channel/resolution, e.g.:
   - "Stage 1: ResBlocks, 32ch, 128³"
   - "Stage 2: ↓, 64ch, 64³"
   - "Stage 3: ↓, 128ch, 32³"
   - "Stage 4: ↓, 256ch, 16³"
   - "Stage 5: ↓, 320ch, 8³"
   Each stage = "Residual Conv Block ×N (Conv3D-Norm-Act)". Emphasize this is a CNN (no tokens/attention).
3. BOTTLENECK (bottom center): "Bottleneck features (320ch, 8³)".
4. DECODER (ascending, right side): mirror stages with upsampling (transpose conv) and SKIP CONNECTIONS drawn as horizontal arrows from each encoder stage to the matching decoder stage.
5. TWO output taps:
   - From the BOTTLENECK → "Global feature (for cls/reg downstream)" (note: a SimPool attention-pool can convert bottleneck feature-map → a global vector, since CNNs have no CLS token).
   - From the DECODER output → "Dense voxel features (for segmentation)".

SPEC PANEL (corner): "ResEnc-L (MIC-DKFZ nnU-Net) | residual conv encoder + U-Net decoder | ~5 stages, 32→320 ch | strong 3D segmentation (OpenMind: on-average strongest) | efficient inference | bf16"

BANNER (bottom): "CNN U-Net with skip connections — no tokens/attention. Segmentation-strong, inference-efficient. This encoder(+decoder) IS the foundation model (single checkpoint)."

Make it clearly a CNN U-Net (skip connections, conv blocks), visually CONTRASTING with the ViT token-based backbones. Accent color on the encoder path.
