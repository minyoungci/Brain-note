# F04 VQA/QA Generation Guideline and Provenance Review

Updated: 2026-06-03

## Current Verdict

The current generated dataset is best described as ROI-grounded anatomical QA that can be attached to T1w MRI images for VQA training. It is not yet free-form medical VQA and it is not a clinical diagnosis dataset.

The answer labels are derived from calibrated FreeSurfer ROI evidence in the official N4 manifest, not from diagnosis labels. Clinical fields are used to define the train-only normative reference population and stable longitudinal reference pairs.

Active calibration:

- `results/f04_roi_evidence_encoder/20260603_031352_official_manifest_n4_normative_calibration_v6_global_cdr_primary`
- manifest: `/home/vlm/data/preprocessed_official/official_manifest_full_n4.csv`
- primary reference: `CN + Global CDR = 0 + train split + no diagnosis worsening + no Global CDR increase`
- session reference: 3,303 sessions / 1,802 subjects
- pair reference: 1,222 pairs / 439 subjects from ADNI and AIBL
- generated QA rows: 58,330
- templates: 6
- threshold validity: `normative_reference_cutoff`

## Input Data Used

### Image/VQA Input

For session-level VQA, the image is the session T1w N4 tensor:

- `final_tensor_n4_path`
- `final_mask_n4_path`
- `join_key = consortium:subject_id:session_id`

For pair-level VQA, the image input should be either:

- baseline T1w image + follow-up T1w image + question, or
- a structured pair object with `baseline_sample_global_id`, `followup_sample_global_id`, and `delta_years_num`

### ROI Evidence Used For Labels

Manifest-derived ROI variables are computed from:

- `fs_vol_hippocampus_L`, `fs_vol_hippocampus_R`
- `fs_vol_amygdala_L`, `fs_vol_amygdala_R`
- `fs_vol_entorhinal_L`, `fs_vol_entorhinal_R`
- `fs_vol_parahippocampal_L`, `fs_vol_parahippocampal_R`
- `fs_vol_lateral_ventricle_L`, `fs_vol_lateral_ventricle_R`
- `fs_vol_inf_lat_vent_L`, `fs_vol_inf_lat_vent_R`
- `fs_BrainSegVol`

Derived targets:

- `log1p_roi_hippocampus_vol_manifest`
- `log1p_roi_mtl_sum_vol_manifest`
- `roi_mtl_to_brain_proxy_manifest`
- `log1p_roi_ventricle_sum_vol_manifest`
- `roi_ventricle_to_brain_proxy_manifest`
- `roi_hippocampus_to_ventricle_manifest`

Pair targets:

- `annualized_delta_roi_ventricle_to_brain_proxy_manifest`
- `annualized_delta_log1p_roi_mtl_sum_vol_manifest`

### Clinical Data Used Only For Reference Selection

Clinical fields used:

- `clin_dx_label`
- `cdr_global`
- `clin_age`
- `clin_sex`
- longitudinal pair flags for diagnosis worsening and Global CDR increase

Primary reference now uses Global CDR because it is available across more consortium datasets than CDR-SB:

- include: `clin_dx_label == CN`
- include: `cdr_global == 0`
- exclude: observed diagnosis worsening
- exclude: observed Global CDR increase
- split: train only

CDR-SB is now a sensitivity reference, not the primary cross-consortium criterion.

## QA Templates And Label Rules

| sample | question_id | question meaning | evidence target | positive rule | data source |
|---|---|---|---|---|---|
| session | `normqa_low_hippocampal_volume` | low hippocampal volume evidence | `hippocampal_volume_percentile` | percentile <= 0.10 | residual percentile of `log1p_roi_hippocampus_vol_manifest` |
| session | `normqa_mtl_atrophy_evidence` | medial temporal atrophy proxy | `mtl_volume_percentile` | percentile <= 0.10 | residual percentile of `log1p_roi_mtl_sum_vol_manifest` |
| session | `normqa_ventricle_enlargement` | ventricular enlargement relative to brain volume | `ventricle_to_brain_percentile` | percentile >= 0.90 | residual percentile of `roi_ventricle_to_brain_proxy_manifest` |
| session | `normqa_low_hippocampus_to_ventricle_ratio` | low hippocampus-to-ventricle burden proxy | `hippocampus_to_ventricle_percentile` | percentile <= 0.10 | residual percentile of `roi_hippocampus_to_ventricle_manifest` |
| pair | `normqa_longitudinal_ventricle_increase` | meaningful ventricular enlargement progression | `annualized_delta_ventricle_to_brain_percentile` | change percentile >= 0.90 | annualized pair delta vs stable Global CDR reference pairs |
| pair | `normqa_longitudinal_mtl_decrease` | meaningful MTL volume decrease | `annualized_delta_mtl_volume_percentile` | change percentile <= 0.10 | annualized pair delta vs stable Global CDR reference pairs |

## How Answers Are Produced

Session answer generation:

1. Fit a train-only reference model on Global CDR-stable CN sessions.
2. Model each ROI target using:
   - age
   - age squared
   - sex
   - log brain proxy
   - consortium
   - field strength
3. Compute adjusted residuals for all scoreable sessions.
4. Convert residuals to empirical percentiles against the train-only reference residual distribution.
5. Apply template-specific percentile rule.
6. Generate `answer_label`, `answer_text`, `evidence_value`, and `evidence_percentile`.

Pair answer generation:

1. Keep pairs with both baseline and follow-up sessions in the official manifest.
2. Compute annualized ROI change from manifest-derived ROI values.
3. Define stable reference pairs with:
   - train split
   - baseline diagnosis CN
   - baseline Global CDR 0
   - no diagnosis worsening
   - no Global CDR increase
   - valid scan interval
4. Convert annualized delta to empirical change percentile.
5. Apply template-specific change percentile rule.

## Answer Text Policy

All positive and negative answers must stay within anatomical evidence scope.

Allowed:

- "low hippocampal volume evidence"
- "medial temporal lobe atrophy evidence"
- "ventricular enlargement evidence"
- "longitudinal structural change evidence"

Forbidden:

- "this MRI diagnoses Alzheimer's disease"
- "this image proves dementia"
- "amyloid/tau positive"
- "treatment recommendation"
- "ventricular enlargement is AD-specific"

Every answer includes a caveat that structural MRI ROI evidence is not sufficient by itself to diagnose AD, dementia, amyloid/tau status, or treatment eligibility.

## Critical Review

Strengths:

- Labels are image/ROI-derived rather than diagnosis-derived.
- Reference fitting is train-only, reducing split leakage.
- Global CDR primary reference improves cross-consortium coverage and brings AIBL into longitudinal reference.
- Source IDs and caveats are attached to every QA row.

Weaknesses:

- The current QA is templated binary QA, not rich natural clinical VQA.
- The label source is FreeSurfer ROI values, not direct visual expert rating.
- The 10th/90th percentile thresholds are internal normative reference cutoffs, not official clinical abnormality cutoffs.
- MTL and hippocampus-to-ventricle questions are ROI proxies; they are not validated Scheltens MTA scores.
- Pair VQA needs two-image handling; a single image cannot answer longitudinal change questions.

Required guardrails for experiments:

- Do not provide `clin_dx_label`, `cdr_global`, `cdrsb`, or progression labels as model input for VQA.
- For image-only VQA, input should be image tensor plus question text only.
- For ROI-oracle QA, clearly label it as an upper-bound teacher task.
- For AEB-based VQA, label it as image-derived anatomical evidence prediction.
- Evaluate cohort-stratified performance to detect hidden cohort shortcuts.
- Use `cohort_dx_cdr_age_sex` matched session QA as the primary shortcut-resistant benchmark when reporting session QA/VQA performance.

## Shortcut-Resistant Matched Benchmark

The v6 label sanity audit showed that raw session QA labels correlate with diagnosis/CDR context. This is expected for anatomical abnormality labels but unsafe for model evaluation if clinical fields leak into the input.

The mitigation is:

- active run: `results/f04_roi_evidence_encoder/20260603_034225_v6_clinical_matched_qa_probe`
- primary protocol: `cohort_dx_cdr_age_sex`
- matching fields: cohort, diagnosis label, Global CDR, age bin, sex
- positive/negative ratio: 1:1 within each matched stratum

Primary protocol test rows:

- low hippocampal volume: 704
- low hippocampus-to-ventricle ratio: 528
- MTL atrophy evidence: 726
- ventricle enlargement: 580

Clinical-context AUC under this protocol is near chance:

- low hippocampal volume: 0.500
- low hippocampus-to-ventricle ratio: 0.549
- MTL atrophy evidence: 0.523
- ventricle enlargement: 0.516

ROI-oracle rule remains 1.000 for all four session questions. Therefore, this matched benchmark keeps the anatomical evidence task while substantially reducing the clinical shortcut.

## Recommended Next Experiment

Use v6 QA as the calibrated QA source, but report the matched session benchmark as the primary shortcut-resistant result. Run three controlled VQA/QA baselines:

1. ROI-oracle QA: true calibrated ROI percentiles as input. This defines the upper bound.
2. AEB-evidence QA: AEB image-derived evidence as input. This tests whether the image encoder captures the right anatomy.
3. Image-only VQA: T1w image plus question text, no clinical fields. This is the real VQA setting.

The expected scientific contribution is not "MRI diagnoses AD"; it is whether an anatomical evidence bottleneck improves faithful T1w MRI VQA while resisting clinical-data shortcut learning.

## Image-Only Baseline Result

The first direct image-only pilot has now been run:

- active run: `results/f04_roi_evidence_encoder/20260603_035910_v6_image_only_matched_vqa_pilot`
- benchmark: `cohort_dx_cdr_age_sex` matched session QA
- model input: cached T1w 2.5D slabs plus question ID only
- excluded inputs: clinical fields, ROI values, AEB features, evidence percentiles
- subject split overlap: 0
- session `join_key` split overlap: 0
- test macro AUC: 0.732
- test macro balanced accuracy: 0.663

Question-level image-only AUC:

- low hippocampal volume: 0.658
- low hippocampus-to-ventricle ratio: 0.774
- MTL atrophy evidence: 0.633
- ventricle enlargement: 0.855

This supports that T1w images contain usable signal under clinical matching, especially for ventricular enlargement and hippocampus-to-ventricle burden. It also confirms the main bottleneck: fine hippocampal/MTL evidence remains weak for both AEB and direct image-only CNN baselines. The next model should therefore be localization-aware rather than simply larger.
