# ROI Usability Report — option_b final-grid ROI masks

_Generated 2026-06-01. Scope: the 13,022 MRIs in `official_manifest.csv`. Validation-only._

## TL;DR
- **99.54% (12,962/13,022)** pass all *automated* gates (numeric transfer-faithfulness + geometric anatomical sanity).
- **5 MRIs** have a genuine one-hemisphere under-segmentation in a medial-temporal ROI → that ROI is unusable for those sessions.
- **11 MRIs** need a human read (borderline asymmetry / fragmentation).
- **44 MRIs** are not candidates (numeric fail / uncovered; all but 5 are A4).
- **`roi_final_ready` is False for ALL 13,022** — fail-closed. Automated gates ≠ anatomical sign-off.

## What "usable" does and does NOT mean here
Three independent gates, weakest-link:

| Gate | What it proves | Status |
|---|---|---|
| 1. Numeric transfer QC | mask is a faithful copy of FastSurfer's seg onto the 192³ final grid | 12,978/13,022 pass (99.7% covered) |
| 2. Auto-anatomical QC | mask has no gross geometric pathology (containment, no leak, symmetric, single-component/hemi) | 12,932 PASS / 46 FLAG |
| 3. Vision QC | FastSurfer's *own* segmentation is anatomically correct | **NOT done at scale** (gap) |

Gate 2 PASS ⇏ Gate 3 PASS. A boundary error that is correctly located, symmetric, inside-brain and single-component is invisible to gates 1–2.

## Usability table (this run)
```
USABLE_AUTO        12932   numeric + auto-geometry pass (vision pending)
USABLE_W_CAVEAT       30   FLAG but benign: ventricle asymmetry (22) / thin-structure frag (8)
REVIEW_REQUIRED       11   FLAG borderline: asym 0.40-0.60 (10) + PHC frag 0.22 (1) -> human read
ROI_UNUSABLE           5   FLAG real: one hemisphere of an MTL ROI under-segmented
NOT_CANDIDATE         44   numeric fail/uncovered (39 A4 + 5 others)
```
Per-cohort breakdown: see `manifest_roi_qc_final.parquet` (`roi_usability` column).

## The 5 ROI_UNUSABLE (vision-confirmed, 4/5 viewed individually)
- `OASIS_OAS30805_d7028` — parahippocampal R=0 (right MTL missing); hippo L:R = 3261:555
- `OASIS_OAS30805_d5456` — same subject, parahippocampal asym 0.97 (right MTL)
- `ADNI_127_S_4197_20150921` — left MTL under-seg: PHC L:R = 20:263, hippo 993:2683
- `NACC_NACC124125_I11044252` — left amygdala under-seg L:R = 174:1035
- `NACC_NACC188891_I10964571` — left amygdala under-seg L:R = 152:1037

These fail the segmentation on ONE hemisphere of ONE+ ROI; other ROIs/hemisphere may still be fine.

## PASS reliability screen (Gate-3 spot check)
Stratified random PASS sample, n=21 (3 per cohort), high-res 5-ROI montages reviewed by eye:
- **0/21 gross segmentation errors.** All ROIs correctly localized, bilaterally present, plausible boundaries. Atrophied brains correctly segmented (atrophy ≠ error).
- Crude 95% upper bound on *gross*-error rate among PASS ≈ 14% (rule-of-three, n=21).
- **Limitation:** montage resolution catches gross errors only. Sub-voxel/few-mm boundary errors are NOT quantified here and require the documented human κ-rating protocol on a larger sample (see `VISUAL_QC_CRITERIA.md`).

## Threshold validation (why 46, not more/fewer)
ASYM threshold 0.40 sits **above p99 for every ROI** → flags distribution outliers, not the bulk.
lateral_ventricle dominates the flags (25) and is precisely the ROI where high asymmetry is
most often benign anatomy — confirmed by eye. FRAG, containment, leak contribute little.

## Bottom line for "can we use it?"
- For **representation-learning / pretraining** where occasional ROI noise is tolerable:
  the 12,932 USABLE_AUTO (+30 caveat) are a defensible training pool **today**, with the 5
  ROI_UNUSABLE excluded and 11 held for review.
- For **any claim requiring anatomically-correct ROIs** (e.g. ROI-wise biomarker analysis):
  NOT yet — Gate 3 (systematic human vision QC) must run first. `roi_final_ready` stays False.

## Artifacts
- `manifest_roi_qc_final.parquet` — 13,022 rows + `auto_verdict`, `vision_category`, `roi_usability`, `roi_final_ready`
- `reports/autoqc_full.parquet` — per-ROI metrics for 12,978 candidates
- `reports/flag_review_worksheet.csv` — 46 FLAGs + vision category
- `reports/pass_sample_worksheet.csv` — 21 PASS-sample vision verdicts
- `montages/flag_review/`, `montages/flag_sheets/`, `montages/pass_sample/` — review images
