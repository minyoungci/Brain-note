# Clinical/Biomarker Availability Audit — v0

Generated: 2026-05-21T01:10:02.017950+00:00

## 기준 manifest

```text
/home/vlm/minyoungi/manifests/v2_integrated/vlm_ready_manifest_v2_integrated_oasis_included_v0.csv
```

## 산출물

```text
/home/vlm/minyoungi/manifests/v2_integrated/clinical_biomarker_availability_v0/row_level_availability_v0.csv
/home/vlm/minyoungi/manifests/v2_integrated/clinical_biomarker_availability_v0/cohort_availability_summary_v0.csv
/home/vlm/minyoungi/manifests/v2_integrated/clinical_biomarker_availability_v0/core_class_feature_availability_v0.csv
/home/vlm/minyoungi/manifests/v2_integrated/clinical_biomarker_availability_v0/source_candidate_feature_inventory_v0.csv
/home/vlm/minyoungi/manifests/v2_integrated/clinical_biomarker_availability_v0/clinical_feature_dictionary_v0.csv
```

## 핵심 결론

- 현재 integrated manifest는 **T1w MRI + basic clinical label/demographic manifest**로는 사용 가능하다.
- 현재 manifest 안에서 row-level로 신뢰 가능한 공통 clinical field는 주로 `diagnosis_3class`, `age`, `sex`, `cdr_global`, `cdrsb`, `scanner`, `field_strength`, image/mask/QC metadata다.
- `has_amyloid_pet`, `has_tau_pet`, `has_csf_*`, `has_apoe`는 대부분 `NOT_JOINED_*` sentinel이므로 **현재 manifest 기준 biomarker value-ready가 아니다**.
- 예외적으로 KDRC는 `has_amyloid_pet=True`, `has_apoe=True` availability flag가 전 row에 있으나, current manifest에는 실제 amyloid read/SUVR/APOE genotype value column이 없으므로 **caption/target feature로 바로 쓰면 안 된다**.
- ROI/native-grid feature는 `roi_final_ready=False`, `roi_current_status=BLOCKED_PROVISIONAL`이므로 아직 사용 금지다.

## Core training 기준 cohort별 availability

| cohort   |   rows |   subjects |   core_clinical_minimal_available_n |   core_clinical_minimal_available_pct |   cdr_global_available_n |   cdr_global_available_pct |   cdrsb_available_n |   cdrsb_available_pct |   scanner_protocol_available_n |   scanner_protocol_available_pct |   any_joined_biomarker_available_n |   any_joined_biomarker_available_pct |   t1w_image_pair_available_n |   t1w_image_pair_available_pct |
|:---------|-------:|-----------:|------------------------------------:|--------------------------------------:|-------------------------:|---------------------------:|--------------------:|----------------------:|-------------------------------:|---------------------------------:|-----------------------------------:|-------------------------------------:|-----------------------------:|-------------------------------:|
| ADNI     |   4849 |       1577 |                                4849 |                                   100 |                     4755 |                       98.1 |                4849 |                 100   |                           4849 |                            100   |                                  0 |                                    0 |                         4849 |                            100 |
| AIBL     |    988 |        617 |                                 988 |                                   100 |                      987 |                       99.9 |                   0 |                   0   |                            988 |                            100   |                                  0 |                                    0 |                          988 |                            100 |
| AJU      |   1241 |        955 |                                1241 |                                   100 |                     1241 |                      100   |                1241 |                 100   |                            938 |                             75.6 |                                  0 |                                    0 |                         1241 |                            100 |
| KDRC     |    920 |        920 |                                 920 |                                   100 |                      899 |                       97.7 |                 899 |                  97.7 |                              0 |                              0   |                                920 |                                  100 |                          920 |                            100 |
| NACC     |   1592 |       1140 |                                1592 |                                   100 |                     1592 |                      100   |                1592 |                 100   |                           1505 |                             94.5 |                                  0 |                                    0 |                         1592 |                            100 |
| OASIS    |   1609 |        749 |                                1609 |                                   100 |                     1420 |                       88.3 |                1402 |                  87.1 |                              0 |                              0   |                                  0 |                                    0 |                         1609 |                            100 |

## Biomarker sentinel 값 확인

```json
{
  "has_amyloid_pet": {
    "NOT_JOINED_IN_PARTIAL_V0": 9191,
    "NOT_JOINED_IN_INTEGRATED_V0": 1615,
    "True": 944
  },
  "has_tau_pet": {
    "NOT_JOINED_IN_PARTIAL_V0": 9191,
    "NOT_JOINED_IN_INTEGRATED_V0": 1615,
    "NOT_JOINED_IN_PARTIAL_V1": 944
  },
  "has_csf_abeta": {
    "NOT_JOINED_IN_PARTIAL_V0": 9191,
    "NOT_JOINED_IN_INTEGRATED_V0": 1615,
    "NOT_JOINED_IN_PARTIAL_V1": 944
  },
  "has_csf_ptau": {
    "NOT_JOINED_IN_PARTIAL_V0": 9191,
    "NOT_JOINED_IN_INTEGRATED_V0": 1615,
    "NOT_JOINED_IN_PARTIAL_V1": 944
  },
  "has_csf_ttau": {
    "NOT_JOINED_IN_PARTIAL_V0": 9191,
    "NOT_JOINED_IN_INTEGRATED_V0": 1615,
    "NOT_JOINED_IN_PARTIAL_V1": 944
  },
  "has_apoe": {
    "NOT_JOINED_IN_PARTIAL_V0": 9191,
    "NOT_JOINED_IN_INTEGRATED_V0": 1615,
    "True": 944
  }
}
```

해석:

- `True`만 실제 joined availability로 계산했다.
- `NOT_JOINED_IN_PARTIAL_V0`, `NOT_JOINED_IN_PARTIAL_V1`, `NOT_JOINED_IN_INTEGRATED_V0`는 availability가 아니라 **미조인 상태 표시자**다.

## 현재 manifest에서 바로 사용 가능한 feature tier

### Tier 0 — 공통/안전 후보

- T1w preprocessed image path
- brain mask path
- image QC status / final shape
- age
- sex
- diagnosis_3class, 단 target으로만 사용하고 caption에는 task에 따라 금지

### Tier 1 — 조건부 clinical 후보

- CDR global
- CDR-SB
- scanner
- field strength
- visit / scan_date

주의:

- CDR/CDRSB는 diagnosis와 강하게 결합되어 있어 diagnosis task caption에는 leakage 위험이 크다.
- scanner/field_strength는 cohort/site shortcut 위험이 커서 caption에 넣기 전 missingness/shortcut audit이 필요하다.

### Tier 2 — 현재 manifest에서는 사용 금지/보류

- amyloid PET / centiloid / SUVR: KDRC availability flag만 current manifest에 있고 실제 값은 없음; ADNI/AIBL/OASIS source 후보는 별도 join 필요
- tau PET
- CSF Aβ / p-tau / t-tau
- APOE: KDRC availability flag만 current manifest에 있고 실제 genotype 값은 없음
- atlaswide ROI/native-grid features

이유: source 후보는 있으나 current integrated manifest row에 harmonized join되어 있지 않거나, ROI transfer가 BLOCKED_PROVISIONAL이다.

## 컨소시엄별 source 후보 inventory

| cohort                         | source                  | features                                                                 | status                                                                             |
|:-------------------------------|:------------------------|:-------------------------------------------------------------------------|:-----------------------------------------------------------------------------------|
| ADNI                           | raw ADNI PET            | amyloid PET status, centiloids, summary/ROI SUVR                         | raw source exists; NOT joined to current integrated manifest                       |
| ADNI                           | raw ADNI FSx7           | FreeSurfer regional volumes/thickness/surface/QC                         | raw source exists; ROI/native-grid use still blocked                               |
| AIBL                           | raw AIBL APOE           | APOE genotype fields                                                     | raw source exists; NOT joined                                                      |
| AIBL                           | raw AIBL PET metadata   | amyloid/PIB/AV45 and FDG/PET metadata candidates                         | raw source exists; NOT harmonized/joined                                           |
| AIBL                           | raw AIBL neuropsych/lab | MMSE/neuropsych/lab candidates                                           | raw source exists; NOT joined                                                      |
| OASIS                          | OASIS demographics      | APOE field present                                                       | source exists; NOT joined to current integrated manifest                           |
| OASIS                          | OASIS UDS diagnosis     | amylpet, amylcsf, taupetad, csftau, fdgad fields present                 | source exists; NOT joined to current integrated manifest                           |
| OASIS                          | OASIS CDR/cognitive     | MMSE, CDRSUM/CDRTOT, MoCA components                                     | partly joined for CDR; extended cognitive not joined                               |
| NACC/AJU/ADNI/OASIS old subset | final_3841 wide tables  | wide clinical/neuropsych/biomarker columns plus derived imaging features | old 3,841-row derivative; not canonical for current v2 integrated manifest         |
| KDRC                           | KDRC raw clinical xlsx  | diagnosis/CDR fields joined; biomarker fields not audited in this pass   | clinical label source used; biomarker availability unknown until xlsx column audit |

## 다음 작업 제안

1. **Clinical feature dictionary v0** 생성: allowed/common/conditional/forbidden field를 명시한다.
2. **Biomarker alignment audit v0** 별도 생성: ADNI/AIBL/OASIS raw biomarker source를 `cohort, subject_id, session/date` 기준으로 current manifest에 매칭 가능한지 계산한다.
3. **Caption policy와 연결**: diagnosis task, PET/ATN task, retrieval/pretraining task별로 allowed/forbidden text fields를 분리한다.
4. **Shortcut baseline**: cohort-only, missingness-only, age/sex/CDR-only, scanner-only가 diagnosis를 얼마나 맞히는지 먼저 측정한다.

## Stop rule

이 audit 이전/현재 상태에서는 biomarker column을 보고 "tau/PET/APOE가 사용 가능하다"고 말하면 안 된다. 현재는 **source 후보가 존재**하는 것과 **manifest row에 harmonized joined feature가 존재**하는 것을 분리해야 한다.
