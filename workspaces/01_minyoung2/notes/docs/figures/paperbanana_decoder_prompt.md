# Shared Decoder Design — detailed architecture figure

A DETAILED, publication-quality architecture diagram of the SHARED segmentation decoder for the foundation model (pretrained via MAE, transferred to few-shot segmentation). White background, clean academic style, neutral palette with ONE accent color (orange) for the key novelty/enabler. U-Net-like shape: encoder on the left feeding a skip-connected upsampling decoder on the right.

TITLE (top): "Shared Decoder — MAE-pretrained, transferred to few-shot segmentation"

LAYOUT:
1. INPUT (far left): "3D volume" → a small "Conv-Stem (shallow 3D convs)" block that produces HIGH-RESOLUTION early feature maps. From the conv-stem, draw a HIGHLIGHTED (orange) skip arrow labeled "high-res skip (enables fine localization at 16³)".
2. ENCODER (left, going right/down): "ViT Encoder (Candidate A/B backbone)" drawn as stacked transformer blocks. From FOUR depths (e.g. layers 6/12/18/24) draw skip arrows to the decoder, labeled "UNETR multi-depth skips".
3. BOTTLENECK: coarse patch tokens reshaped to a small 3D feature grid (e.g. 6×6×6).
4. DECODER (right side, ascending U-Net): a stack of "Up-block: TransposeConv → concat skip → ResConv" stages that progressively upsample back to full resolution, each merging the corresponding encoder/conv-stem skip (draw the skip arrows connecting in).
5. TWO output heads from the decoder's final full-resolution feature map:
   - "MAE recon head" → small reconstructed-volume thumbnail → label "(pretraining objective — DISCARDED after SSL)" drawn grayed/dashed.
   - "Segmentation head" → voxel label map thumbnail → label "(downstream few-shot — finetuned)" drawn solid/accent.
6. A SEPARATE short path from the encoder's "[CLS] token" going straight to a small "cls / reg head" box, BYPASSING the decoder, labeled "classification/regression: no decoder".

ANNOTATION (bottom banner): "Decoder is pretrained end-to-end via MAE reconstruction, then transferred to segmentation (re-head). Single checkpoint = encoder + decoder. cls/reg tasks use only the CLS token."

Emphasize: the orange conv-stem high-res skip (fine-localization enabler), the U-Net skip-connected upsampling, and the pretrain(recon, discarded)→transfer(seg, kept) story. Readable labels.
