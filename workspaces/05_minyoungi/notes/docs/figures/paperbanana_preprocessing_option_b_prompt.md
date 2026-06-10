# PaperBanana Prompt — Option B ROI Final-Tensor Preprocessing QC

Create a publication-ready scientific flowchart, not a decorative illustration.

Title: Option B: Safe ROI Mask Transfer into 3D MRI Final Tensor Space

Canvas/layout:
- Landscape 16:9.
- Use five left-to-right stages with arrows.
- Use muted journal colors, clean boxes, short readable labels.
- Include one red/orange blocked warning box and one green conditional-go box.

Exact stages to show once each:
1. Existing FastSurfer outputs preserved
   - aparc/aseg labels
   - scalar ROI stats usable
2. Reuse final_tensor preprocessing transform
   - RAS orientation
   - 1mm resampling
   - crop/pad to 192×224×192
3. Label transfer candidate branch
   - nearest-neighbor only
   - no overwrite of final_tensor or FastSurfer
4. Numeric + visual QC
   - volume error
   - centroid shift
   - inside-brain fraction
   - cohort/ROI issue table
   - overlay contact sheet
5. Conditional approval
   - subject/ROI pair readiness
   - roi_final_ready remains false until reviewed
   - only approved masks unlock ROI-local training

Critical warning box:
- Previous affine-only transfer failed: median relative volume error ≈ -0.892.
- Therefore voxel-wise ROI loss/crop/attention is blocked until Option B QC passes.

Style constraints:
- No cartoons, no brain clipart clutter, no 3D render.
- Avoid paragraphs inside boxes.
- Text must be readable.
- Spell exactly: FastSurfer, final_tensor, nearest-neighbor, roi_final_ready.
