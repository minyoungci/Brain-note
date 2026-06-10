# 2026-05-21 manifest-data matching audit

Generated: 2026-05-21T00:13:53.306681+00:00

## Audited manifest

```text
/home/vlm/minyoungi/manifests/v2_partial/vlm_ready_manifest_v2_partial_non_oasis_v1_kdrc_union.csv
```

## Verdict

현재 구성된 non-OASIS partial manifest는 실제 v2 T1w tensor/mask path와 잘 매칭된다. Core usable row에서 path missing이나 non-classifiable leakage는 발견되지 않았다.

## Global checks

```text
rows: 10135
columns: 58
cohorts: ADNI, AIBL, AJU, KDRC, NACC
row_id unique: True
duplicate cohort-subject-session: 0
t1w_preproc_path exists: 10121 / 10121
brain_mask_path exists: 10121 / 10121
image_ready_true: 10096
image_ready_but_path_missing: 0
path_ok_but_not_image_ready: 25
core_usable: 9590
core_path_missing: 0
core_nonclassifiable: 0
rows_with_final_shape: 10121
unique_final_shape: {'192x224x192': 10121}
```

## By cohort

```text
cohort  rows  subjects  image_ready  path_ok  clinical_joined  core_usable  shape_nonempty
  ADNI  5037      1754         5023     5037             4863         4849            5037
  AIBL   991       618          988      990              991          988             990
   AJU  1287      1001         1287     1287             1241         1241            1287
  KDRC   944       944          931      931              944          920             931
  NACC  1876      1420         1867     1876             1597         1592            1876
```

## Core usable class counts

```text
cohort diagnosis_3class    n
  ADNI               AD  298
  ADNI               CN 2577
  ADNI              MCI 1974
  AIBL               AD  129
  AIBL               CN  720
  AIBL              MCI  139
   AJU               AD  220
   AJU               CN   23
   AJU              MCI  998
  KDRC               AD  284
  KDRC               CN  312
  KDRC              MCI  324
  NACC               AD  174
  NACC               CN 1062
  NACC              MCI  356
```

## OASIS availability check

```json
{
  "ready_manifest": "/home/vlm/data/preprocessed_official/v2/OASIS/manifests/oasis_t1w_full_preprocessed_ready_manifest_1615.csv",
  "rows": 1615,
  "subjects": 750,
  "t1w_image_ready": 1609,
  "final_tensor_path_exists": 1615,
  "final_mask_path_exists": 1615,
  "roi_current_status_counts": {
    "BLOCKED_PROVISIONAL": 1615
  }
}
```

## Immediate recommendation

1. Rebuild manifest as a new version under `/home/vlm/minyoungi/manifests/v2_integrated/` or `/home/vlm/minyoungi/manifests/v2_partial/`, now including OASIS.
2. Do not include A4 in core training manifest yet; reserve it as external validation once preprocessing finishes.
3. Before training, create `dataset_role`, `include_core_training`, `include_external_validation`, and `caption_allowed_policy` columns.
4. Generate subject-disjoint splits only after OASIS clinical labels are joined and class balance is re-audited.
