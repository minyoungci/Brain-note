# Leakage and Temporal Risk Report (read-only audit, 2026-06-21)

Risk audit of every asset considered for benchmark expansion / DPO / stress testing. Read-only.

## Risk classes
- **Label leakage**: target (dx/amyloid/CDR) present in the same record an agent would summarize → agent can
  read the answer.
- **Temporal leakage**: outcome-time information used as if available at baseline (e.g., follow-up dx leaking
  into a "baseline prediction").
- **Held-out contamination**: training on ClaimTrap30 (or its derivatives) → invalidates the test.
- **PHI**: identifiers / dates / partial DOB.
- **Target-proximal wording**: free/templated text that states the conclusion.

## Per-asset risk
| asset | label leak | temporal leak | held-out contam | PHI | verdict |
|---|---|---|---|---|---|
| canonical manifest (non-ClaimTrap rows) | MED (dx/amyloid in row) | LOW (no calendar date) | none (if rows disjoint) | LOW | usable as artifact pool after subject-disjointness check |
| korean manifests / subject-level | MED | LOW | none | LOW | usable artifact pool |
| `korean_clinical_text.csv` (templated) | **HIGH** (dx/MMSE/amyloid in text) | LOW | none | LOW | neutralize before use as input |
| `aju_final_v2_3841.csv` (raw) | **HIGH** (per-visit dx) | **HIGH** (visit dates) | none | **MED** (partial DOB+date) | audit: strip DOB, separate dx, control ordering |
| KDRC `clinical.xlsx[데이터]` | MED | MED (assessment date; cross-sectional) | none | MED (date) | audit: header/threshold/date |
| ClaimTrap30 gold | n/a | n/a | **CRITICAL if trained** | LOW | freeze; test only |
| `runs/*` agent outputs | n/a | n/a | **CRITICAL if trained** (on ClaimTrap30) | LOW | eval only |
| 5-case benchmark | gold-leak (deprecated) | n/a | n/a | LOW | not formal evidence |

## Temporal structure (longitudinal availability)
Multi-session subjects per cohort (canonical manifest): A4 793, ADNI 849, OASIS 363, NACC 361, **AJU 286**,
AIBL 178, **KDRC 0 (cross-sectional)**. BUT the canonical manifest has **no calendar dates** — only `session_id`.
The only source with true visit dates + per-visit diagnosis is **AJU raw** (`aju_final_v2_3841.csv`:
VISITMO/DAY/YR + NPPDX*). Therefore any temporal/longitudinal (E3) or conversion endpoint depends on auditing
and joining the AJU raw visit dates — and is the single largest unlock, and the single largest temporal-leakage
risk, in the dataset.

## Specific temporal-leakage hazard (must control before E3 / conversion work)
AJU raw mixes baseline features and per-visit follow-up diagnosis in one wide row (1350 cols). Constructing a
"baseline → future outcome" artifact from this without explicit visit ordering would leak the follow-up dx into
the baseline input. Control: (1) split by VISITYR/MO/DAY into ordered visits; (2) define baseline vs follow-up
windows; (3) ensure the agent input contains only baseline-available fields; (4) keep outcome strictly in the
scoring view (dual-view principle).

## Held-out integrity (ClaimTrap30)
- 30 LOCKED cases = 10 `real_oasis_derived` + 20 `constructed_probe`; gold levels L1.5:10 / L1:17 / L0:3.
- All 18 run directories operate on these 30 → none is trainable.
- Required guard before any DPO: a contamination scan asserting zero overlap (by subject_id and by
  artifact-construction) between the train pool and the 30 ClaimTrap cases.

## De-identification posture
- Canonical + korean manifests + subject-level + templated text: de-identified (research ids, no dates) →
  low PHI.
- AJU raw: partial DOB (BIRTHMO/YR) + visit dates → MED PHI; strip before use, never paste content externally.
- KDRC raw: research-dispensed (MCD coded) + assessment date → MED; date handling required.
- Standing rule: no raw clinical text or PHI to external APIs; no PHI in committed artifacts.
