# ADNI amyloid join / transport feasibility check (2026-06-25)

## Question
Can we pivot from single-site AJU AT(N) description to an ADNI -> AJU transportability design using ADNI amyloid + hippocampal N-axis?

## Current local facts
- Official full manifest is available: `/home/vlm/data/preprocessed_official/official_manifest_full_n4_real_final.parquet`.
- ADNI official rows: 4,742 rows, 1,580 subjects.
- ADNI hippocampus / BrainSegVol are usable:
  - `fs_BrainSegVol`: 4,742/4,742
  - `fs_vol_hippocampus_L/R`: 4,742/4,742
  - cross-sectional rows with age + MMSE + BrainSegVol + bilateral hippocampus: 4,643 rows, 1,527 subjects.
- ADNI longitudinal T1 manifest exists:
  - `/home/vlm/data/preprocessed_official/v2/manifests/official_v2_longitudinal_manifest.csv`
  - ADNI longitudinal rows: 4,153 rows, 870 subjects.
  - `session_time_unit=date`; intervals are explicit day offsets from baseline.
  - ADNI subjects with >=2 usable MMSE + hippocampus visits from full manifest: 840.

## Amyloid gate: standard scalar path
- Current official full manifest has **no ADNI amyloid scalar columns populated**.
- Current v2 T1-PET pair manifest exists:
  - `/home/vlm/data/preprocessed_official/v2/manifests/official_v2_t1w_pet_pair_manifest.csv`
  - ADNI AV45 PET pair references: 2,697 rows.
  - But `pet_target_value` and `pet_target_column` are empty for all ADNI rows.
  - `pair_qc_status` indicates PET source references only, not preprocessed/scalar targets.
- Historical inventory documents the required source:
  - `/home/vlm/data/raw/ADNI/PET/UCBERKELEY_AMY_6MM_30Mar2026.csv`
  - reported as 4,728 rows with `RID`, `VISCODE`, `SCANDATE`, `TRACER`, `AMYLOID_STATUS`, `CENTILOIDS`, `SUMMARY_SUVR`.
- That file is **not present now**. `/home/vlm/data/raw/ADNI` itself is absent in the current filesystem.
- Historical OBSERVATORY notes report a derived table:
  - `minyoung2/data/amyloid_label_table.csv`
  - ADNI UCBERKELEY + OASIS centiloid, ADNI n about 1,202.
  - Current `/home/vlm/minyoung2/data` is empty; the table is not present.

This is not a permanent scientific blocker. It is a data-acquisition blocker: with ADNI/LONI access, the UCBERKELEY scalar table should be re-downloadable and then joinable by RID/PTID + scan date / visit code. It should still be treated as a gate because the current workspace cannot reproduce the join.

## Amyloid gate: non-standard tensor path
The stale note about preprocessed ADNI SUVR tensors was correct. Current local tensor-derived PET exists:

- `pet_amyloid` directories: 1,793 subject-sessions, 669 subjects.
- `pet_suvr_1mm_RAS_192x224x192.nii.gz`: 1,792 files.
- `pet_suvr_dl_192.nii.gz`: 1,792 files.
- `pet_amyloid_qc.json`: 1,792 files, all `PASS`.
- QC JSON contains `global_mean_suvr` for 1,792 rows; observed range 0.85-2.14, median 1.31.
- 1,731 PET sessions join to official manifest rows with clinical MMSE/age/hippocampus/BrainSegVol; 661 subjects.

This path is deliberately deprioritized for the manuscript gate. It is internally useful, but it is not the same as a standard UCBERKELEY Centiloid/status table. It lacks the clean public scalar provenance reviewers expect, and would force us to defend a local PET preprocessing / reference-region / threshold policy. Use it only for engineering sanity checks or exploratory work, not as the primary A-axis for a transportability manuscript.

## Value gate
Even if the UCBERKELEY scalar table is re-downloaded, the pivot is not automatic. The scientific value must be re-gated because:

- ADNI amyloid predicting decline is already well established; a simple replication has low novelty.
- ADNI is not an external validation set for the AJU real-world Korean finding; it is a different research-cohort frame.
- AJU's distinctive findings, especially WMH-null and vascular-label demotion, do not transport cleanly to ADNI without comparable vascular labels / WMH definitions.
- MMSE / K-MMSE, visit structure, and recruitment differences make calibration fragile; ranking/discrimination is safer than absolute prediction.

Therefore, ADNI transportability is a separate, more ambitious paper direction, not a strict upgrade of the current AJU paper.

## Decision
The ADNI -> AJU transportability pivot is **not the current manuscript path**.

It becomes technically GO only if one of these is restored or re-downloaded:
1. `/home/vlm/data/raw/ADNI/PET/UCBERKELEY_AMY_6MM_30Mar2026.csv`, or
2. a reproducible derived ADNI amyloid label table with RID/PTID, scan date, tracer, centiloid/status, and join provenance.

Without the standard scalar table, ADNI can support N-only longitudinal sanity checks and non-standard PET-tensor exploratory work. That is not enough for the proposed A+N transportability paper and should not replace the current AJU AT(N) manuscript direction.

## Practical recommendation
- Do **not** pivot the manuscript yet.
- Keep current AJU line as primary on its own merits: real-world Korean MCI, robust N-axis, amyloid age-dependence, WMH null, vascular demoted.
- Treat ADNI transportability as a conditional upgrade:
  - if UCBERKELEY scalar source is re-downloaded, first re-run a value gate, not the full pivot by default;
  - if not re-downloaded, use ADNI only as descriptive N-axis context or omit it.
