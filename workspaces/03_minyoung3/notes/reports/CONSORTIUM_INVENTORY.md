# Per-consortium data inventory (manifest-verified)

Sessions per consortium (real_final): {'ADNI': 4742, 'A4': 1811, 'AIBL': 987, 'NACC': 1866, 'OASIS': 1420, 'AJU': 1287, 'KDRC': 909}

## imaging/QC  (non-null % by consortium)
| field | ADNI | A4 | AIBL | NACC | OASIS | AJU | KDRC |
|---|--:|--:|--:|--:|--:|--:|--:|
| final_tensor_n4_path | 100 | 100 | 100 | 100 | 100 | 100 | 100 |
| final_qc_status | 100 | 100 | 100 | 100 | 100 | 100 | 100 |
| fs_qc_status | 100 | 100 | 100 | 100 | 100 | 100 | 100 |
| acq_scanner | 100 | 100 | 100 | 81 | 100 | 86 | 50 |
| acq_field_strength | 100 | 100 | 100 | 81 | 100 | 83 | 0 |

## demographics  (non-null % by consortium)
| field | ADNI | A4 | AIBL | NACC | OASIS | AJU | KDRC |
|---|--:|--:|--:|--:|--:|--:|--:|
| clin_age | 99 | 100 | 100 | 100 | 100 | 100 | 85 |
| clin_sex | 100 | 100 | 100 | 100 | 100 | 100 | 85 |
| clin_education | 0 | 100 | 0 | 100 | 0 | 100 | 0 |

## clinical-dx/severity  (non-null % by consortium)
| field | ADNI | A4 | AIBL | NACC | OASIS | AJU | KDRC |
|---|--:|--:|--:|--:|--:|--:|--:|
| clin_dx_label | 99 | 100 | 100 | 100 | 85 | 96 | 85 |
| cdr_global | 100 | 100 | 100 | 100 | 100 | 100 | 100 |
| cdrsb | 100 | 100 | 0 | 100 | 99 | 100 | 100 |
| clin_cdrsb | 99 | 0 | 0 | 100 | 100 | 96 | 0 |

## cognition  (non-null % by consortium)
| field | ADNI | A4 | AIBL | NACC | OASIS | AJU | KDRC |
|---|--:|--:|--:|--:|--:|--:|--:|
| clin_mmse | 99 | 100 | 100 | 16 | 100 | 100 | 52 |
| clin_moca | 0 | 0 | 0 | 100 | 0 | 0 | 0 |

## genetics(APOE)  (non-null % by consortium)
| field | ADNI | A4 | AIBL | NACC | OASIS | AJU | KDRC |
|---|--:|--:|--:|--:|--:|--:|--:|
| clin_apoe | 94 | 100 | 0 | 76 | 100 | 100 | 59 |
| clin_apoe_e4n | 94 | 0 | 0 | 76 | 100 | 100 | 0 |

## amyloid-PET  (non-null % by consortium)
| field | ADNI | A4 | AIBL | NACC | OASIS | AJU | KDRC |
|---|--:|--:|--:|--:|--:|--:|--:|
| a4_amyloid_suvr | 0 | 100 | 0 | 0 | 0 | 0 | 0 |
| a4_amyloid_positive | 0 | 100 | 0 | 0 | 0 | 0 | 0 |
| oasis_amyloid_centiloid | 0 | 0 | 0 | 0 | 74 | 0 | 0 |
| oasis_amyloid_positive | 0 | 0 | 0 | 0 | 74 | 0 | 0 |
| oasis_amyloid_tracer | 0 | 0 | 0 | 0 | 74 | 0 | 0 |
| nacc_amyloid_centiloid | 0 | 0 | 0 | 28 | 0 | 0 | 0 |
| nacc_amyloid_positive | 0 | 0 | 0 | 28 | 0 | 0 | 0 |
| nacc_amyloid_tracer_code | 0 | 0 | 0 | 28 | 0 | 0 | 0 |
| kdrc_amyloid_suvr | 0 | 0 | 0 | 0 | 0 | 0 | 53 |
| kdrc_amyloid_visual | 0 | 0 | 0 | 0 | 0 | 0 | 59 |
| aju_amyloid | 0 | 0 | 0 | 0 | 0 | 100 | 0 |

## vascular/other  (non-null % by consortium)
| field | ADNI | A4 | AIBL | NACC | OASIS | AJU | KDRC |
|---|--:|--:|--:|--:|--:|--:|--:|
| kdrc_fazekas_pv | 0 | 0 | 0 | 0 | 0 | 0 | 32 |
| kdrc_fazekas_deep | 0 | 0 | 0 | 0 | 0 | 0 | 31 |
| aju_gds | 0 | 0 | 0 | 0 | 0 | 100 | 0 |

## freesurfer-ROI  (non-null % by consortium)
| field | ADNI | A4 | AIBL | NACC | OASIS | AJU | KDRC |
|---|--:|--:|--:|--:|--:|--:|--:|
| fs_vol_hippocampus_L | 100 | 100 | 100 | 100 | 100 | 100 | 100 |
| fs_vol_hippocampus_R | 100 | 100 | 100 | 100 | 100 | 100 | 100 |
| fs_vol_entorhinal_L | 100 | 100 | 100 | 100 | 100 | 100 | 100 |
| fs_vol_amygdala_L | 100 | 100 | 100 | 100 | 100 | 100 | 100 |
| fs_vol_lateral_ventricle_L | 100 | 100 | 100 | 100 | 100 | 100 | 100 |
| fs_BrainSegVol | 100 | 100 | 100 | 100 | 100 | 100 | 100 |

## Korean multimodal extras (AJU/KDRC) — labs + comorbidity (non-null %)
korean_multimodal rows=2196 consortia={'AJU': 1287, 'KDRC': 909}
  wbc=82%, rbc=82%, hb=83%, hct=83%, mcv=83%, mch=83%, mchc=83%, plt=83%, bun=83%, cr=83%, ast=83%, alt=83%, glucose=83%, hba1c=82%, tchol=83%, tg=83%, hdl=83%, ldl=83%, tsh=83%, ft4=83%, vitb12=82%, folate=79%, dm=83%, htn=83%, dyslipidemia=83%

## Amyloid binary usability (both pos&neg present?) — for fusion target/anchor
  OASIS: oasis_amyloid_positive -> {'negative': 718, 'positive': 330}
  NACC: nacc_amyloid_positive -> {0.0: 314, 1.0: 201}
  KDRC: kdrc_amyloid_visual -> {'Positive': 362, 'Negative': 172}
  AJU: aju_amyloid -> {'negative': 851, 'positive': 435}
  A4: a4_amyloid_positive -> {'positive': 1811}
  (A4 = positive-only -> exclude from binary; rest have both classes)

## Longitudinal structure (dates recovered from session_id)
| cohort | subjects | multi-tensor | dated-pair | dated >=1yr | date source |
|---|--:|--:|--:|--:|---|
| ADNI | 1754 | 870 | 870 | 858 | YYYYMMDD |
| A4 | 1787 | 1498 | 1498 | 1277 | VISCODE(approx) |
| AIBL | 617 | 178 | 178 | 175 | YYYYMMDD |
| NACC | 1420 | 365 | 0 | 0 | none |
| OASIS | 750 | 404 | 404 | 396 | dNNNN |
| AJU | 1001 | 286 | 286 | 0 | V#(ordinal) |
| KDRC | 931 | 0 | 0 | 0 | none |

TOTAL dated >=1yr longitudinal subjects: 2706 ; multi-tensor (date-agnostic SSL): 3601

## Fusable modalities per cohort (>=50% coverage) — what we can condition on, where
  ADNI: APOE, clinical-dx, cognition, demographics, freesurfer-ROI, imaging
  A4: APOE, amyloid-PET, clinical-dx, cognition, demographics, freesurfer-ROI, imaging
  AIBL: clinical-dx, cognition, demographics, freesurfer-ROI, imaging
  NACC: APOE, clinical-dx, cognition, demographics, freesurfer-ROI, imaging
  OASIS: APOE, amyloid-PET, clinical-dx, cognition, demographics, freesurfer-ROI, imaging
  AJU: APOE, amyloid-PET, clinical-dx, cognition, demographics, freesurfer-ROI, imaging, vascular
  KDRC: APOE, amyloid-PET, clinical-dx, cognition, demographics, freesurfer-ROI, imaging