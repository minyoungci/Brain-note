# Data Asset Inventory for Agent Learning (read-only audit, 2026-06-21)

Scope: inventory data usable with the ClaimTrap-AD / medical-research-agent line. Read-only. No LLM calls, no
data sent externally, no PHI content pasted, no files modified. All facts below were verified by direct
inspection (parquet/csv/xlsx column scans), not directory globs. Machine-readable tables:
`outputs/data_audit/{data_asset_inventory,clinical_text_inventory,dpo_candidate_assets,blocked_or_forbidden_assets}.csv`.

## TL;DR
- The project's real asset is **structured biomedical tables**, not clinical free-text.
- **There is NO raw clinical free-text** (radiology reports, clinical notes, narrative summaries) anywhere.
  All "text" is templated captions derived from structured fields.
- ClaimTrap30 is the **locked held-out** benchmark; every existing agent run is on it → none of it is
  trainable.
- DPO is **possible only after building a ClaimTrap-disjoint preference corpus from the structured manifests**;
  no preference pairs exist yet and generating them needs LLM (currently paused) + human verification.

## Confirmed assets (status)
| asset | what | status | recommended use |
|---|---|---|---|
| `official_manifest_full_n4_real_final.parquet` (13022×141, 7 cohorts) | canonical structured clinical+biomarker+ROI+scanner+raw-paths | **USABLE_NOW** | controller eval source; ClaimTrap expansion; cross-cohort stress; DPO artifact pool (non-ClaimTrap) |
| `korean_multimodal_manifest.csv` (2196×93, AJU+KDRC) | structured multimodal + labs | **USABLE_NOW** | Korean artifact pool; stress test |
| `korean_clinical_subject_level.csv` (1898×51) | Korean subject-level (labs/amyloid/dx/gds/fazekas) | **USABLE_NOW** | DPO artifact source (Korean); label provenance |
| `korean_clinical_text.csv` (2196×7, text_v0/v1/v2) | **templated captions** (synthetic, derived) | USABLE_WITH_CAUTION | ClaimTrap-style INPUT artifact after neutralization; NOT a clinical-note corpus |
| `korean_vlm_pairs.csv` (2196×26) | VLM image-text pairs | USABLE_WITH_CAUTION | VLM track (out of current scope) |
| `aju_final_v2_3841.csv` (976×1350) | **AJU NACC-UDS coded per-visit clinical** + radiomics; visit dates + per-visit dx | **NEEDS_AUDIT** | temporal/longitudinal endpoint recovery; ClaimTrap expansion; label provenance |
| `aju_session_labels/metadata/inventory.csv` | AJU session↔label linkage | USABLE_WITH_CAUTION | AJU longitudinal linkage |
| `clinical.xlsx[데이터]` (KDRC, 286 cols) | MCD-coded clinical; assessment date + dx + amyloid PET; cross-sectional | **NEEDS_AUDIT** | label provenance; cross-cohort stress; Korean pool |
| `kdrc_clinical_field_dictionary.csv` | KDRC code dictionary | USABLE_NOW (reference) | decode KDRC |
| `claimtrap30_gold.jsonl` (30, LOCKED) | held-out benchmark | **FORBIDDEN (train)** | held-out evaluation ONLY |
| `runs/*/{generic,verification,controller}_agent_outputs.jsonl` | agent claim outputs (preference-shaped) | **FORBIDDEN (train)** | eval/analysis only (tied to held-out) |
| 5-case `gold_claim_trap_cases.jsonl` | gold-leak benchmark | **FORBIDDEN (evidence)** | structural reference only |
| `*/preproc_qc/session_qc.csv` (×7) | imaging QC + scanner/site metadata | USABLE_NOW | scanner/site shortcut-case construction |
| `/home/vlm/data/FOMO300K` | 300K brain-MRI pretraining (public) | OUT_OF_SCOPE | ignore for claim work |

## Cohort-by-cohort status
- **OASIS** (1420 sess): amyloid centiloid clean (only cohort with a defensible label lock, partial). Real seed
  for ClaimTrap (10 cases). 363 multi-session.
- **NACC** (1866): amyloid centiloid present but LABEL_UNVERIFIED; 361 multi-session. Structured artifact pool.
- **ADNI** (4742): largest; 849 multi-session; amyloid label NOT joined in manifest. Artifact pool / stress.
- **A4** (1811): amyloid SUVR present but **single-class (FORBIDDEN as task)**; 793 multi-session. Stress only.
- **AIBL** (987): 178 multi-session; amyloid label absent in manifest.
- **AJU** (1287 sess / ~1001 subj, 286 multi-session): **richest Korean** — NACC-UDS coded per-visit clinical
  with visit dates + per-visit dx + CDR/MMSE/APOE + amyloid visual. NEEDS_AUDIT (PHI/temporal).
- **KDRC** (909, cross-sectional): MCD-coded; amyloid SUVR (partial lock candidate) + assessment date + dx.
  NEEDS_AUDIT.

## Usable now / after audit / forbidden
- **Usable now**: canonical manifest, korean manifests/subject-level, KDRC dict, session_qc, (templated text with caution).
- **After audit**: AJU raw (PHI strip + temporal control), KDRC raw (header/threshold/date).
- **Forbidden**: ClaimTrap30 gold + all runs (held-out), 5-case (gold-leak), FOMO300K (out of scope).

## Biggest blocker
No raw clinical free-text + no per-visit calendar dates in the canonical manifest. The only place with
visit dates + per-visit diagnosis is the AJU raw source (`aju_final_v2_3841.csv`), which carries PHI (partial
DOB) and temporal-leakage risk and must be audited before use.

## Top-5 next actions
1. Define a **ClaimTrap30-disjoint artifact pool** from the canonical manifest (exclude the 10 OASIS-derived
   seeds + any rows overlapping the 20 probes) — this is the DPO/expansion source.
2. **Audit AJU raw** (`aju_final_v2_3841.csv`): extract per-visit dx + visit-date deltas, strip partial DOB,
   confirm de-id. Unblocks temporal/longitudinal (E3) artifacts.
3. **Parse KDRC `데이터` sheet** with the correct header offset (via field dictionary); lock the amyloid
   threshold provenance (currently UNVERIFIED → partial).
4. **Neutralize** label-proximal phrasing in `korean_clinical_text.csv` if it is to be used as agent input.
5. Keep ClaimTrap30 + all runs **frozen** as held-out; do not let any of it enter a training split.

See `docs/CLINICAL_TEXT_AUDIT.md`, `docs/DPO_DATA_CANDIDATE_PLAN.md`, `docs/LEAKAGE_AND_TEMPORAL_RISK_REPORT.md`.
