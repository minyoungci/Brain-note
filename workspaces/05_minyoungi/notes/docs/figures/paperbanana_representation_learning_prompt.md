# PaperBanana Prompt — 3D Brain Representation Learning Roadmap

Create a publication-ready methodology block diagram for a 3D brain MRI representation learning project.

Title: 3D Brain MRI Representation Learning Before VLM Scaling

Canvas/layout:
- Landscape 16:9.
- Three horizontal bands:
  Band 1: Inputs and preprocessing gates
  Band 2: Representation learning branches
  Band 3: Evaluation and route decision
- Use clean arrows, grouped boxes, muted colors.

Content to show:
Inputs:
- 3D T1w final_tensor
- FastSurfer scalar ROI stats
- controlled captions: age bucket + sex only
- ROI morphology captions from image-derived ROI stats

Preprocessing gate:
- Image-only final_tensor PASS
- scalar ROI stats usable
- voxel-wise ROI masks require Option B QC before training

Learning branches:
1. Image anatomy encoder
   - flatpool diagnostic CNN
   - external 3D SSL/foundation baseline
   - future ROI-local pooling if masks pass QC
2. ROI teacher branch
   - Teacher-S: signal-preserving
   - Teacher-B: bias-reduced
   - DKT-Vol expansion
3. Text/caption branch
   - leakage-safe controlled captions
   - ROI morphology captions
4. Alignment objectives
   - image↔ROI-caption retrieval
   - anatomical auxiliary tasks
   - disease-axis probes

Evaluation:
- CN vs AD axis
- MCI projection
- age/anatomy probe
- cohort/scanner shortcut probe
- CN/MCI/AD is downstream probe, not main novelty

Decision gates:
- If external SSL wins: move to SSL/foundation adaptation
- If DKT teacher improves: strengthen anatomical teacher
- If all weak: re-audit data/evaluation/preprocessing
- No large VLM scaling before gates pass

Style constraints:
- Flowchart/block diagram only.
- No decorative icons.
- Keep labels concise and readable.
- Spell exactly: Teacher-S, Teacher-B, DKT-Vol, final_tensor, VLM.
