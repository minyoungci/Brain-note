# Official v2 T1w Preprocessing Pipeline (with N4 harmonization)

Create a publication-ready left-to-right pipeline / flow diagram of a multi-consortium
brain MRI (T1w) preprocessing pipeline that produces model-ready tensors, ROI masks, and
an integrated manifest. Clean boxes, directional arrows, grouped stages, muted colors.

Title: Official v2 T1w Preprocessing & Harmonization Pipeline (13,022 sessions, 7 consortiums)

Layout: landscape 16:9, a main horizontal flow with two parallel branches that re-merge,
plus a QC/manifest band at the bottom.

MAIN FLOW (left to right boxes connected by arrows):
1. Raw input — DICOM / NIfTI per consortium (read-only). Label: "7 consortiums, heterogeneous scanners & resolution".
2. Stage 02 — Conversion & QC: dcm2niix (DICOM -> NIfTI), input QC (finite, voxel, shape). Output: raw_t1 NIfTI.
3. Then the flow SPLITS into two parallel branches from raw_t1:

   BRANCH A (image, top): 
   - HD-BET brain extraction -> native_t1w_hdbet (brain + mask)
   - canonicalize RAS -> resample 1mm isotropic -> crop/pad to fixed 192x224x192
   - robust z-score (1-99 percentile clip, brain-mask mean/std) -> final_tensor

   BRANCH B (labels, bottom):
   - FastSurfer segmentation (internal NU correction) -> aparc.DKTatlas+aseg
   - Option-B ROI transfer to final-tensor grid (affine-aware nearest-neighbor) -> ROI masks + FastSurfer volumes

4. N4 HARMONIZATION (highlight in a distinct color, placed AFTER FastSurfer on the image branch):
   - N4 bias-field correction (precise, shrink=2) applied to the brain, re-run through resample/crop/z-score
   - Output: final_tensor_n4 (scanner-bias-reduced model input). Note: "ROI masks unchanged (grid_match >= 0.99)".

BOTTOM BAND — QC gates & manifest (merge of both branches):
- 3 QC gates (fail-closed): (1) numeric ROI transfer QC, (2) auto-anatomical QC (asymmetry/fragmentation/leak), (3) vision QC — roi_final_ready stays False until human sign-off.
- Integrated manifest: official_manifest_full_n4 (13,022 x 101): paths (original + N4 tensors), voxel (100%), scanner (89%), FastSurfer volumes, clinical (age/sex/dx/CDR), QC flags.

Small callouts:
- "N4 halves scanner bias (within-ADNI 0.84 -> 0.66), preserves population biology"
- "Resolution is an independent site axis N4 cannot remove"

Keep boxes concise and legible; clearly show the split into image/label branches and the re-merge at the manifest.
