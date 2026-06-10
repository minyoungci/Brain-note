# F04 Guideline-Grounded Anatomical QA Evidence

Updated: 2026-06-02

## Verdict

The previous ROI-grounded QA experiment was a feasibility benchmark using internal train-split quantiles. It should not be presented as a medical-guideline VQA dataset.

The current guideline-grounded QA schema is now source-linked and restricted to anatomical evidence questions. It explicitly forbids standalone Alzheimer's disease diagnosis, dementia diagnosis, amyloid/tau inference, and treatment recommendations from T1w MRI ROI evidence alone.

## Active Artifacts

| artifact | path | role |
|---|---|---|
| source registry | `results/f04_roi_evidence_encoder/20260602_083000_guideline_grounded_qa_schema_v1/source_registry.json` | official/peer-reviewed source claims and QA implications |
| QA schema | `results/f04_roi_evidence_encoder/20260602_083000_guideline_grounded_qa_schema_v1/qa_schema.json` | source-linked question templates and safety policy |
| schema report | `results/f04_roi_evidence_encoder/20260602_083000_guideline_grounded_qa_schema_v1/REPORT.md` | human-readable schema summary |
| executable builder | `scripts/run_f04_guideline_grounded_qa_builder.py` | builds source-linked QA rows from schema |
| generated dataset | `results/f04_roi_evidence_encoder/20260602_083320_guideline_grounded_qa_dataset_v1/guideline_grounded_qa_dataset.csv` | 96,376 QA rows with source IDs and caveats |

## Evidence Sources

| source_id | source | QA implication |
|---|---|---|
| `AA_2024_REVISED_CRITERIA_OVERVIEW` | Alzheimer's Association 2024 criteria overview | AD is biologically defined; T1w ROI evidence alone must not be framed as diagnosis or treatment guidance |
| `AA_2024_REVISED_CRITERIA_PUBMED` | Revised criteria for diagnosis and staging of AD, 2024 | structural MRI evidence should be framed as neurodegeneration/staging context rather than standalone AD-defining evidence |
| `NIAAA_2018_RESEARCH_FRAMEWORK` | NIA-AA research framework, 2018 | MRI atrophy is neurodegeneration/injury evidence but nonspecific for AD |
| `ACR_DEMENTIA_2024` | ACR Appropriateness Criteria Dementia, 2024 update | non-contrast brain MRI is an appropriate imaging modality in cognitive impairment/suspected AD scenarios |
| `ACR_NPH_DIFFERENTIAL_2024` | ACR dementia variant for suspected normal pressure hydrocephalus | ventricular enlargement questions require a differential caveat and cannot be treated as AD-specific |
| `SCHELTENS_MTA_SCALE_SECONDARY_VALIDATION` | MTA visual rating validation literature | MTA evidence can be linked to hippocampal height and CSF-space/temporal horn concepts |
| `MTA_NORMATIVE_VALUES_2019` | MTA and posterior atrophy normative values | publication-grade QA thresholds should prefer normative or validated visual-rating cutoffs |

## Allowed Question Families

- low hippocampal volume evidence
- medial temporal lobe atrophy evidence
- ventricular enlargement relative to brain volume
- low hippocampus-to-ventricle ratio as an anatomical burden proxy
- longitudinal ventricular enlargement progression
- longitudinal medial temporal volume decrease

## Forbidden Question Families

- Does this MRI diagnose Alzheimer's disease?
- Does this MRI diagnose dementia?
- Is amyloid or tau positive?
- Should treatment be started?
- Does ventricular enlargement prove AD?

## Threshold Status

The current generated dataset uses train-reference percentiles as a controlled research proxy because our current ROI tables do not include validated age/sex/head-size normative cutoffs. Every generated row is marked:

`threshold_validity = research_proxy_not_clinical`

This is acceptable for model-screening experiments but not sufficient for a final clinical benchmark. The next publication-grade step is to replace proxy thresholds with normative or validated visual-rating thresholds.
