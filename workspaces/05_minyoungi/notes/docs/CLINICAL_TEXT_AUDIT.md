# Clinical Text Audit (read-only, 2026-06-21)

Deep audit of every text-bearing asset. No PHI content pasted; structure/columns only.
Machine-readable: `outputs/data_audit/clinical_text_inventory.csv`.

## CRITICAL FINDING
**The project contains NO raw clinical free-text.** A repo-wide + data-root scan for radiology reports,
clinical notes, MRI/PET reports, neuropsychology narratives, or diagnostic summaries found none. Every
"text" asset is either (a) a **templated caption generated from structured fields**, or (b) a **structured
coded table** (NACC-UDS / MCD codes). Consequence: a "clinical-text over-claim benchmark/DPO on realistic
clinical notes" is **not feasible** with current data. The viable modality is **structured-artifact → claim**
(exactly what ClaimTrap-AD and the Claim Safety Controller already operate on).

## Per text asset

### 1. `Clinical/consortiums/Korean/korean_clinical_text.csv` — Grade **B**
- cohort AJU+KDRC; columns `text_v0/v1/v2` + subject_id/session_id + `text_core_complete`.
- **Templated, not raw**: leading-40-char prefixes repeat ("Older patient. On cognitive assessment, …" ×252;
  "Older patient. Cognitive testing: MMSE …" ×182); English vocab ≈79 tokens over 300 sampled rows;
  maxlen ≈415, meanlen ≈269. → machine-generated from the structured manifest.
- subject/visit map: **yes** (subject_id, session_id) but **no calendar date**.
- de-id: **by construction** (synthetic from de-identified structured fields) → PHI risk **LOW**.
- **label-leakage risk HIGH**: the text states dx / MMSE / amyloid directly (target-proximal). If used as an
  agent INPUT, these phrases must be neutralized first (same principle that fixed the constructed-probe leak
  in ClaimTrap30).
- temporal-leakage: LOW (cross-sectional, no dates).
- preference-pair feasibility as "clinical text": **LOW** (synthetic). Usable as a neutralized INPUT artifact
  for benchmark/stress only.

### 2. `Clinical/consortiums/Korean/korean_vlm_pairs.csv` (text_v*) — Grade **B**
- Same templated text + image paths (T1w/FLAIR/PET) + `train_ready`. VLM scope, out of current claim-text work.

### 3. `aju_final_v2_3841.csv` (AJU raw) — Grade **C** (structured, not free text)
- 976 rows × 1350 cols, **NACC-UDS coded**: VISITMO/VISITDAY/VISITYR, BIRTHMO/BIRTHYR, CDRSUM/CDRGLOB,
  NACCMMSE, NACCAPOE, NPPDXA–G (per-visit diagnoses), WHODIDDX, DXMETHOD + radiomics/volumetrics.
- This is **structured**, not narrative text — but it is the only source with **visit dates + per-visit dx**.
- de-id: research ids **but partial DOB (BIRTHMO/YR) + visit dates present** → PHI risk **MED**.
- label-leakage: **HIGH** (per-visit dx in the same table as features). temporal-leakage: **HIGH** (visit
  ordering enables both legitimate longitudinal endpoints AND leakage if mishandled).
- → requires provenance audit before any use (strip DOB, separate per-visit dx, control baseline/follow-up
  ordering).

### 4. KDRC `clinical.xlsx[데이터]` — structured, Grade C-ish
- 286 cols, MCD-coded, Korean headers, `평가 날짜` (assessment date) + `진단` + `뇌 Amyloid PET`. Multi-row
  header (parse with field dictionary). Cross-sectional. Coded → not free text.

## A/B/C/D grade summary
- **A (DPO-ready clinical text)**: NONE. No de-identified, date-mappable, leakage-controllable free-text exists.
- **B (benchmark/stress input)**: `korean_clinical_text.csv`, `korean_vlm_pairs.csv` (templated; neutralize first).
- **C (provenance audit needed)**: `aju_final_v2_3841.csv`, KDRC `데이터` (structured, dates/PHI/threshold issues).
- **D (forbidden)**: realistic clinical free-text corpus — does not exist; any future ingest of real notes
  would land here until PHI + temporal + leakage controls are in place.

## Answers (clinical-text questions)
- **Q2 — Korean AJU/KDRC clinical text use**: (a) **train preference corpus?** Not as "text" — the only Korean
  text is templated; use the **structured** AJU/KDRC tables as artifact sources instead. (b) **external stress
  test?** YES — Korean structured artifacts are a strong cross-population stress set vs the Western-derived
  ClaimTrap. (c) **Korean clinical-text overclaim benchmark?** Only with the templated captions as neutralized
  inputs; not a realistic clinical-note benchmark (no real notes exist).
- **Q3 — which text must NOT be used for training**: the templated captions (`korean_clinical_text.csv`,
  `korean_vlm_pairs.csv`) contain target-proximal dx/label phrasing → label leakage; AJU raw has per-visit dx +
  dates → label + temporal leakage. None may enter training without neutralization / de-id / temporal control.
