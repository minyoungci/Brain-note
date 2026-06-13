# F04 ROI Normative Calibration and Construct Linkage Plan

Updated: 2026-06-03

## Executive Verdict

The defensible route is not to claim that published clinical cutoffs directly apply to our ROI variables. They do not. The defensible route is:

1. Use official and peer-reviewed literature to define the clinical/anatomical construct.
2. Map that construct to our available ROI variables as a proxy, with explicit limitations.
3. Build an internal normative calibration model using cognitively unimpaired/stable reference sessions from the training split only.
4. Convert raw ROI values into age/sex/head-size/cohort-adjusted percentiles or z-scores.
5. Use percentile-based labels for QA, marked as `normative_reference_cutoff` if calibrated, or `research_proxy_not_clinical` if still using unadjusted train quantiles.
6. Validate against external anchors whenever possible: visual MTA ratings, progression outcomes, within-cohort stability, and AEB prediction fidelity.

This design is scientifically stronger than applying arbitrary q25/q75 thresholds, but it still must avoid diagnostic wording. Structural T1w ROI evidence supports anatomical/neurodegeneration evidence only; it does not diagnose Alzheimer's disease by itself.

## Why Direct Literature Cutoffs Are Not Enough

Our ROI variables are:

- `log1p_roi_hippocampus_vol`
- `log1p_roi_mtl_sum_vol`
- `log1p_roi_ventricle_sum_vol`
- `roi_ventricle_to_brain_proxy`
- `roi_hippocampus_to_ventricle`
- `roi_mtl_to_brain_proxy`

The literature usually reports one of the following:

- visual rating scales, especially Scheltens MTA 0-4
- hippocampal volume, often age/sex/head-size adjusted
- normative centiles/nomograms
- ventricular volume or ventricular volume as percent of ICV
- biomarker frameworks where MRI atrophy is neurodegeneration/staging evidence

Those constructs are related to our variables but not identical. Therefore, the correct claim is:

> We operationalize literature-defined anatomical constructs using ROI-derived proxies, and calibrate these proxies against a reference population before using them as QA labels.

The incorrect claim is:

> Literature cutoff X directly proves our ROI value Y is clinically abnormal.

## Source-Backed Construct Table

| construct | literature basis | our operational proxy | label direction | allowed QA wording | forbidden wording |
|---|---|---|---|---|---|
| hippocampal volume evidence | hippocampal volume is widely used as structural MRI marker; normative percentiles are needed because aging affects hippocampal volume | `log1p_roi_hippocampus_vol`, adjusted for age/sex/head-size/cohort | low percentile | "low hippocampal volume evidence" | "AD diagnosis" |
| medial temporal atrophy evidence | MTA scale assesses choroid fissure, temporal horn, and hippocampal height; MTA norms are age-dependent | `log1p_roi_mtl_sum_vol`, `roi_mtl_to_brain_proxy`, `roi_hippocampus_to_ventricle` | low MTL percentile or low ratio percentile | "medial temporal atrophy evidence" | "Alzheimer-specific atrophy" |
| ventricle enlargement evidence | ventricular volume increases with aging and neurodegeneration, but differential diagnoses exist including NPH | `log1p_roi_ventricle_sum_vol`, `roi_ventricle_to_brain_proxy` | high percentile | "ventricular enlargement evidence relative to brain volume" | "ventricular enlargement proves AD" |
| hippocampus-to-ventricle burden | derived proxy linking hippocampal tissue volume and CSF-space expansion, conceptually related to MTA components | `roi_hippocampus_to_ventricle` | low percentile | "anatomical burden proxy" | "validated MTA score" unless calibrated to MTA ratings |
| longitudinal ventricular enlargement | ventricular expansion is used in aging/MCI/AD imaging studies as global tissue-loss proxy | annualized `delta_roi_ventricle_to_brain_proxy`, `delta_log1p_roi_ventricle_sum_vol` | high positive reliable change | "meaningful ventricular enlargement progression" | "AD progression confirmed" |
| longitudinal medial temporal volume loss | hippocampal/MTL atrophy rate is progression-relevant but nonspecific | annualized `delta_log1p_roi_mtl_sum_vol`, `delta_log1p_roi_hippocampus_vol` | high negative reliable change | "meaningful MTL volume decrease" | "cause of cognitive decline" |

## Literature Evidence and How We Use It

### Alzheimer's Association 2024 Revised Criteria

Use: diagnostic safety boundary.

The Alzheimer's Association states that the 2024 criteria define AD biologically, that diagnosis is by abnormalities on core biomarkers, and that the criteria are not step-by-step clinical practice guidelines. It also recommends against clinical diagnostic testing in cognitively unimpaired individuals outside research contexts. This means our QA must not answer "does this MRI diagnose AD?" from structural ROI evidence.

Implementation consequence:

- All QA answers must say "image-derived anatomical evidence only."
- AD/dementia diagnosis, treatment recommendation, and amyloid/tau inference are forbidden labels.
- Structural MRI ROI findings can be used as neurodegeneration/anatomical-burden evidence, not as AD-defining evidence.

Source:

- Alzheimer's Association. Criteria for Diagnosis and Staging of Alzheimer's Disease. 2024. https://www.alz.org/research/for_researchers/diagnostic-criteria-guidelines

### ACR Appropriateness Criteria Dementia 2024

Use: modality scope and differential caveat.

ACR lists dementia/cognitive-impairment imaging variants, including MCI/suspected AD and suspected normal pressure hydrocephalus. Non-contrast brain MRI is considered an appropriate initial imaging modality in these contexts. The separate NPH variant is important because ventricular enlargement must not be interpreted as AD-specific.

Implementation consequence:

- T1w MRI anatomical QA is appropriate as an imaging-evidence task.
- Ventricular enlargement answers must include a differential/nonspecific caveat.
- Clinical diagnosis and treatment decisions remain outside QA scope.

Source:

- American College of Radiology. ACR Appropriateness Criteria Dementia, 2024 update. https://acsearch.acr.org/docs/3111292/Narrative

### NIA-AA 2018 Research Framework

Use: neurodegeneration label policy.

The NIA-AA framework places MRI atrophy in the neurodegeneration/neuronal injury category and emphasizes that these measures are not specific for AD pathology. This directly supports our "anatomical evidence, not diagnosis" framing.

Implementation consequence:

- MRI ROI labels should use terms like "neurodegeneration evidence", "atrophy evidence", or "anatomical burden evidence."
- Avoid "AD-positive" or "amyloid/tau-positive" from MRI ROI evidence.

Source:

- Jack CR Jr. et al. NIA-AA Research Framework: Toward a biological definition of Alzheimer's disease. Alzheimer's & Dementia. 2018. https://pubmed.ncbi.nlm.nih.gov/29653606/

### Scheltens MTA Scale and MTA Normative Values

Use: construct anchor for MTL/hippocampal atrophy.

Scheltens-type MTA rating uses visually assessed medial temporal structures: choroid fissure width, temporal horn width, and hippocampal height. Later normative work emphasizes that MTA score interpretation depends on age and that percentile distributions are useful for proper atrophy assessment.

Implementation consequence:

- `log1p_roi_hippocampus_vol` maps to hippocampal height/tissue-loss direction.
- `roi_ventricle_to_brain_proxy`, `log1p_roi_ventricle_sum_vol`, and `roi_hippocampus_to_ventricle` partially map to CSF-space expansion concepts, but they are not direct temporal horn/choroid fissure ratings.
- We may call this "MTA-consistent ROI evidence" only after calibration; before that, call it "MTL/hippocampal anatomical proxy."

Sources:

- Scheltens P. et al. Visual assessment of medial temporal lobe atrophy on magnetic resonance imaging: interobserver reliability. https://pubmed.ncbi.nlm.nih.gov/8551316/
- Ferreira D. et al. MTA normative values. NeuroImage: Clinical. 2019. https://pmc.ncbi.nlm.nih.gov/articles/PMC6690662/
- Inter-modality assessment of medial temporal lobe atrophy in a non-demented population. https://pubmed.ncbi.nlm.nih.gov/34328536/

### Hippocampal Volume Nomograms and Centile Models

Use: normative calibration model design.

Large-scale hippocampal volume work from UK Biobank provides age-related normative percentiles and emphasizes the need for age-related norms to categorize hippocampal volume. BrainChart-style work uses age, sex, and TIV-adjusted centile scoring for hippocampal volume and supports individual-level interpretability.

Implementation consequence:

- Our calibration should output percentiles, not only raw volume thresholds.
- Required covariates: age, sex, head-size proxy, cohort/scanner/protocol proxy.
- Preferred method: GAMLSS/quantile regression or residual empirical percentile after covariate adjustment.

Sources:

- Nobis L. et al. Hippocampal volume across age: Nomograms derived from over 19,700 people in UK Biobank. NeuroImage: Clinical. 2019. https://pmc.ncbi.nlm.nih.gov/articles/PMC6603440/
- BrainChart hippocampal volume age, sex and TIV adjusted centile scores in Alzheimer's disease. https://pmc.ncbi.nlm.nih.gov/articles/PMC11714940/
- Brain charts for the human lifespan. Nature. 2022. https://pmc.ncbi.nlm.nih.gov/articles/PMC9021021/

### Ventricular Volume Normative and Differential Evidence

Use: ventricle construct calibration and caveat.

Ventricular volume is a global indicator of brain tissue loss in aging and dementia research, but it is nonspecific. Normative ventricular volume references can be age/sex/ICV-adjusted. ACR's NPH variant further supports adding a differential caveat to ventricle answers.

Implementation consequence:

- `roi_ventricle_to_brain_proxy` should be percentile-calibrated as "high ventricle burden relative to brain proxy."
- A high ventricle percentile should never be equated with AD.
- Longitudinal ventricle increase should be annualized and evaluated against stable-reference reliable change.

Sources:

- Mapping dynamic changes in ventricular volume onto baseline cortical surfaces in normal aging, MCI, and Alzheimer's disease. https://pmc.ncbi.nlm.nih.gov/articles/PMC4138607/
- Establishment of age- and sex-specific reference cerebral ventricle volumes. https://pmc.ncbi.nlm.nih.gov/articles/PMC11729395/
- ACR Appropriateness Criteria Dementia, suspected NPH variant. https://acsearch.acr.org/docs/3111292/Narrative

## Proposed Calibration Design

### Authoritative Manifest

For the next calibration implementation, use:

`/home/vlm/data/preprocessed_official/official_manifest_full_n4.csv`

Rationale:

- contains N4 image paths: `final_tensor_n4_path`, `final_mask_n4_path`
- contains FreeSurfer-derived ROI volumes: hippocampus, amygdala, entorhinal, parahippocampal, lateral ventricle, inferior lateral ventricle, and brain segmentation volumes
- contains clinical fields needed for reference selection: `clin_dx_label`, `cdr_global`, `cdrsb`, `clin_age`, `clin_sex`
- contains acquisition/scanner covariates: `acq_scanner`, `acq_field_strength`

Audit result:

- rows: 13,022
- subjects: 7,231
- QC image usable rows: 13,022
- ROI-ready rows: 12,978
- clinical-ready rows: 13,022
- age/sex-ready rows after second missing-value repair: 12,840
- strict CN/CDR0/CDRSB0 reference candidates with age/sex: 4,318
- broad CN reference candidates with age/sex: 5,766

Implemented calibration result with Global CDR primary reference:

- active run: `results/f04_roi_evidence_encoder/20260603_031352_official_manifest_n4_normative_calibration_v6_global_cdr_primary`
- script: `scripts/run_f04_official_manifest_normative_calibration.py`
- primary session reference: train-only CN / Global CDR 0 / no diagnosis or Global CDR worsening, 3,303 sessions / 1,802 subjects
- session reference cohorts: ADNI 1,213, AIBL 493, AJU 15, KDRC 178, NACC 726, OASIS 678
- CDR-SB strict sensitivity reference: 2,596 sessions
- session scoring: 12,840 sessions with finite age/head-size-adjusted residual percentiles across 6 ROI targets
- longitudinal reference: train pair-level baseline CN / Global CDR 0 / no diagnosis or Global CDR progression with valid scan interval and manifest ROI, 1,222 ADNI/AIBL pairs / 439 subjects
- longitudinal scoring: 3,485 finite ADNI/AIBL pairs with stable-reference change percentiles
- generated QA: 58,330 rows, 6 templates, `threshold_validity=normative_reference_cutoff`

Critical limitation:

ADNI/A4 `clin_sex`, AIBL `clin_age`, AJU `clin_dx_label`, and OASIS age/sex metadata have been substantially repaired. Global CDR is now the primary cross-consortium reference criterion because CDR-SB is unavailable or incomplete in important cohorts, especially AIBL. Remaining data limitations still matter: Global CDR is coarser than CDR-SB, A4 `CN_preclinical` is excluded from primary reference to avoid preclinical-enrichment contamination, and OASIS/KDRC/ADNI retain limited missing clinical fields. This is acceptable for controlled screening and model debugging, but it is not sufficient as final publication-grade clinical labeling without CDR-SB sensitivity analysis, cohort sensitivity analysis, and preferably external visual-rating or expert-review anchors.

Important definition issue:

The old F04 dataset and the official N4 manifest have highly correlated hippocampus, MTL, and ventricle volumes, but the brain proxy definition differs substantially. The manifest uses `fs_BrainSegVol` as the brain proxy, while the older F04 exported dataset used a different proxy definition. Therefore, ratio variables must be recomputed from the manifest and suffixed or versioned, e.g.:

- `roi_mtl_to_brain_proxy_manifest`
- `roi_ventricle_to_brain_proxy_manifest`
- `roi_hippocampus_to_ventricle_manifest`

Do not mix old F04 ratio labels with manifest-derived N4 calibration labels.

### Stage 1. Define Reference Population

Reference set must be selected only from the training split to avoid leakage.

Preferred inclusion:

- `split == train`
- `roi_summary_available == True`
- ROI pass flags are valid for included regions
- diagnosis is CN
- `cdr_global == 0`
- no diagnosis worsening over available follow-up
- no Global CDR increase over available follow-up when longitudinal data exist

Exclusion:

- MCI/AD diagnosis
- CDR global > 0
- failed ROI QC
- missing age/sex for models that require them
- cohorts with too few reference observations unless pooled with cohort random/fixed effects

Sensitivity references:

1. `cdrsb_strict_stable_cn`: CN, Global CDR=0, CDR-SB=0, no diagnosis/CDR-SB/Global CDR worsening.
2. `broad_cn_global_cdr0`: CN/Global CDR=0 regardless of longitudinal stability.
3. `cohort_internal_cn`: reference fit within cohort where n is sufficient.
4. `cn_preclinical_sensitivity`: optional A4/CN-preclinical sensitivity only, not primary reference.

### Stage 2. Cross-Sectional Normative Model

For each ROI target:

- hippocampus: `log1p_roi_hippocampus_vol`
- MTL: `log1p_roi_mtl_sum_vol`, `roi_mtl_to_brain_proxy`
- ventricle: `log1p_roi_ventricle_sum_vol`, `roi_ventricle_to_brain_proxy`
- derived burden: `roi_hippocampus_to_ventricle`

Model candidates:

1. Residual percentile model:
   - Fit on reference training sessions:
     - `y ~ spline(age) + sex + log1p(roi_brain_proxy_vol) + consortium`
   - Compute residuals.
   - Convert each subject's residual to empirical percentile among reference residuals.

2. Quantile regression:
   - Estimate conditional q05/q10/q25/q50/q75/q90/q95 directly.
   - More robust for skewed ratios and ventricles.

3. GAMLSS-style model:
   - Model location, scale, and skewness as functions of age/sex/head-size.
   - Best aligned with BrainChart-style centile scoring, but more implementation work.

Recommended first implementation:

`residual_empirical_percentile_v1`

Reason: transparent, fast, easy to audit, and adequate for internal screening. It can later be replaced by GAMLSS/BrainChart-style centiles.

### Stage 3. Percentile Direction Rules

Use construct-specific direction:

| construct | percentile rule | screening label |
|---|---:|---|
| low hippocampal volume | percentile <= 10 or <= 5 | `low_hippocampal_volume_evidence` |
| low MTL volume | percentile <= 10 or <= 5 | `mta_consistent_low_mtl_evidence` |
| high ventricle burden | percentile >= 90 or >= 95 | `ventricle_enlargement_evidence` |
| low hippocampus-to-ventricle ratio | percentile <= 10 or <= 5 | `high_anatomical_burden_proxy` |
| borderline low/high | 10-25 or 75-90 | `borderline_evidence` |
| normal reference range | 25-75 or 10-90 depending strictness | `not_elevated_evidence` |

For QA:

- binary screening may use strict q10/q90.
- three-class QA should use `low/high`, `borderline`, `reference-range`.
- final paper should report sensitivity analyses at q05/q95, q10/q90, and q25/q75.

### Stage 4. Longitudinal Reliable Change Model

Use stable-reference pairs from training split only.

For each pair:

- compute annualized delta:
  - `(followup_roi - baseline_roi) / delta_years`
- fit expected normal change among stable CN:
  - `annualized_delta ~ spline(baseline_age) + sex + baseline_roi_percentile + delta_years + cohort`
- compute residual change percentile or reliable change index:
  - `RCI = observed_delta - expected_delta / SD_reference_residual`

Rules:

| construct | longitudinal rule |
|---|---|
| ventricle progression | annualized ventricle burden residual percentile >= 95 |
| hippocampal/MTL loss | annualized hippocampus/MTL residual percentile <= 5 |
| ratio burden worsening | annualized hippocampus-to-ventricle residual percentile <= 5 |

Important: longitudinal labels must not use raw absolute delta q75 as publication-grade threshold. That remains only a screening proxy.

### Stage 5. MTA Visual-Rating Anchor

This is the strongest publication-grade bridge.

Minimum annotation plan:

- Sample 200-500 scans across age, cohort, and ROI percentiles.
- Include enriched tails:
  - hippocampal percentile <= 10
  - ventricle percentile >= 90
  - middle reference-range controls
- Have trained raters assign MTA 0-4, ideally left/right and max/mean score.
- Use blinded rating, no diagnosis labels.

Validation:

- ordinal correlation between ROI composite and MTA score
- weighted kappa if ROI composite is discretized into MTA-like grades
- AUROC for MTA abnormal threshold if age-specific abnormality is defined
- calibration plot by age bin

After this, QA wording can change from:

> "MTL anatomical proxy"

to:

> "MTA-consistent evidence"

Only if this anchor validates.

### Stage 6. AEB Calibration Against Normative Labels

Once true ROI normative labels exist:

1. Compute true ROI percentiles and labels.
2. Compute AEB-predicted ROI percentiles using the same calibration transform.
3. Evaluate AEB label agreement:
   - macro-F1
   - balanced accuracy
   - sensitivity at q10/q90
   - calibration slope
   - Brier score if probabilistic
4. Report by cohort and within-cohort.

This directly tests whether AEB can support guideline-grounded QA.

## Construct-to-ROI Composite Scores

### Hippocampal Low-Volume Evidence

Inputs:

- `log1p_roi_hippocampus_vol`
- optional: `roi_hippocampus_to_ventricle`

Primary score:

`hippocampal_low_volume_percentile = adjusted_percentile(log1p_roi_hippocampus_vol)`

Interpretation:

- `<= 5`: strongly low
- `<= 10`: low
- `10-25`: borderline low
- `> 25`: not low by reference threshold

### MTL Atrophy Proxy

Inputs:

- `log1p_roi_mtl_sum_vol`
- `roi_mtl_to_brain_proxy`
- `roi_hippocampus_to_ventricle`

Composite:

`mtl_atrophy_proxy_score = mean(z_low_mtl_volume, z_low_mtl_to_brain, z_low_hippocampus_to_ventricle)`

Where `z_low_*` is oriented so higher means more atrophy burden.

Use:

- QA label only after calibration.
- MTA-consistent wording only after visual-rating validation.

### Ventricle Enlargement Evidence

Inputs:

- `log1p_roi_ventricle_sum_vol`
- `roi_ventricle_to_brain_proxy`

Primary score:

`ventricle_burden_percentile = adjusted_percentile(roi_ventricle_to_brain_proxy)`

Backup:

`log_ventricle_volume_percentile = adjusted_percentile(log1p_roi_ventricle_sum_vol)`

Interpretation:

- `>= 95`: strongly high ventricle burden
- `>= 90`: high ventricle burden
- `75-90`: borderline high
- `< 75`: not high by reference threshold

Caveat:

Ventricle enlargement is nonspecific. It can reflect generalized atrophy, hydrocephalus-related processes, or other etiologies.

### Hippocampus-to-Ventricle Burden Proxy

Input:

- `roi_hippocampus_to_ventricle`

Primary score:

`hvr_percentile = adjusted_percentile(roi_hippocampus_to_ventricle)`

Interpretation:

- low percentile means smaller hippocampal volume relative to ventricle burden.

Caveat:

This is not an established clinical scale. It is a model-derived proxy inspired by the relationship between hippocampal tissue loss and CSF-space expansion in medial temporal atrophy ratings.

## Label Provenance Codes

Every QA label should carry one of:

| code | meaning | publishability |
|---|---|---|
| `research_proxy_not_clinical` | internal unadjusted train quantile or exploratory cutoff | screening only |
| `normative_reference_cutoff` | age/sex/head-size/cohort adjusted percentile from training reference population | defensible for method paper, with caveats |
| `visual_rating_anchored_cutoff` | calibrated against blinded MTA or radiology visual ratings | strongest for anatomical QA |
| `external_normative_cutoff` | uses external published normative model/tool compatible with our measurement pipeline | strong if pipeline compatibility is demonstrated |

## Concrete Implementation Plan

### Script 1: Build Reference Cohort

Proposed file:

`scripts/run_f04_build_normative_roi_reference.py`

Outputs:

- `reference_session_table.csv`
- `reference_pair_table.csv`
- `reference_selection_report.md`

Key checks:

- train split only
- subject overlap with val/test impossible by existing split, but re-audit
- cohort counts
- age/sex coverage
- ROI QC pass counts

### Script 2: Fit Normative Models

Proposed file:

`scripts/run_f04_fit_roi_normative_calibration.py`

Inputs:

- session ROI table
- reference table

Outputs:

- `normative_model_manifest.json`
- `roi_normative_scores_session.csv`
- `roi_normative_scores_pair.csv`
- `calibration_diagnostics.csv`
- figures: percentile histograms, age residual plots, cohort residual plots

Model:

- start with residual empirical percentile
- fit separately by ROI target
- include `age`, `sex`, `log1p_roi_brain_proxy_vol`, `consortium`
- optionally compare cohort-pooled vs within-cohort calibration

### Script 3: Build Normative QA Dataset

Proposed file:

`scripts/run_f04_guideline_normative_qa_builder.py`

Changes from current builder:

- replace `current_proxy_quantile` thresholds with calibrated percentile columns
- write `threshold_validity = normative_reference_cutoff`
- include `percentile`, `z_score`, and `reference_model_id`
- keep `source_ids` and caveats

### Script 4: Validate AEB Against Normative QA

Proposed file:

`scripts/run_f04_aeb_normative_qa_probe.py`

Inputs:

- true ROI normative QA labels
- AEB predicted ROI evidence

Outputs:

- AEB-only QA metrics
- true ROI oracle metrics
- clinical-only metrics
- AEB+clinical metrics
- within-cohort metrics
- error analysis by construct

## Statistical Gates Before Claiming Publication-Grade QA

Minimum gates:

1. Reference cohort has sufficient n per age/cohort bin or pooled model with cohort adjustment.
2. Normative percentiles are approximately uniform in held-out stable reference validation.
3. No subject leakage across train/val/test.
4. AEB QA performance exceeds clinical-only and question-only baselines.
5. AEB performance is not limited to pooled cohort; it survives within-cohort or cohort-matched evaluation.
6. Ventricle-only labels are not framed as AD-specific.
7. At least one visual-rating or external-normative anchor is provided before using "MTA-consistent" as a headline claim.

Recommended reporting:

- macro-F1 and balanced accuracy
- sensitivity/specificity for abnormal-tail labels
- calibration plots
- cohort-stratified performance
- label provenance distribution
- failure cases with low AEB evidence fidelity

## Recommended Paper Framing

Strong framing:

> We propose an anatomical evidence bottleneck that converts T1w MRI into source-linked, normatively calibrated anatomical evidence tokens. These tokens support constrained VQA over hippocampal/MTL atrophy and ventricular enlargement evidence while explicitly avoiding standalone AD diagnosis.

Weak or unsafe framing:

> The model diagnoses Alzheimer's disease from T1w MRI and answers clinical questions.

## Next Action

Implement the normative reference and calibration scripts. The current guideline-grounded QA dataset should remain marked `research_proxy_not_clinical` until this calibration is complete.
