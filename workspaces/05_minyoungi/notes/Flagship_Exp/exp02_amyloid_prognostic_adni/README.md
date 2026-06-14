# exp02 — Prognostic Amyloid Headroom (ADNI/OASIS longitudinal)

**The decisive multimodal gate.** exp01 showed amyloid barely adds *cross-sectionally* (atrophy
already captures present cognition). Amyloid is an *early molecular* event → its value should be
**prognostic**. This tests whether **baseline amyloid predicts FUTURE decline beyond baseline
morphometry + demographics + APOE + baseline severity + follow-up time** (a strict bar).

## Design
Strict prognostic ladder (features at BASELINE, labels in the FUTURE):

| level | features |
|---|---|
| L0 | age, sex, APOE4, **baseline CDR-SB**, **follow-up yrs** (+cohort dummy) |
| L1 | L0 + morphometry (26 FS ROI vols, ICV-normalized) |
| L2 | L1 + amyloid (baseline centiloid) |

Targets (future): `conv_any` (AUC), `conv_mci_ad` (MCI→AD, baseline-MCI only, AUC),
`cdr_slope` (Spearman). Subjects: 1,644 (ADNI 1,202 + OASIS 442) with amyloid+label+morphometry.
Controls: subject-level OOF · multi-seed · paired bootstrap CI · permutation null · confound audit.

## Sources
amyloid + baseline clinical = `minyoung2/data/amyloid_label_table.csv` (ADNI UCBERKELEY + OASIS
centiloid); future labels = validated `build_long_labels()` (visit_level_cdr_v7 ⊕
v4_longitudinal_manifest); baseline morphometry = canonical real_final (join by tensor path).
Code: `prognostic_core.py` (imports `../common/headroom_core.py`).

## Result (executed 2026-06-14, leakage-clean — permutation null collapses to −0.0005)
| target | n (pos) | L1(+morph) | L2(+amyloid) | Δ morph/L0 | **Δ AMYLOID/L1 [95% CI]** |
|---|---|---|---|---|---|
| conv_any (ADNI) | 791 (162) | 0.639 | 0.690 | −0.006 ns | **+0.051 [0.019, 0.084] ★** |
| conv_any (pooled) | 1073 (185) | 0.699 | 0.742 | +0.016 ns | **+0.043 [0.013, 0.062] ★** |
| MCI→AD (ADNI, gold) | 329 (76) | 0.811 | 0.843 | −0.007 ns | **+0.032 [0.002, 0.058] ★** |
| cdr_slope (ADNI) | 783 | 0.253 | 0.322 | +0.079 sig | **+0.069 [0.037, 0.097] ★** |
| cdr_slope (pooled) | 1057 | 0.235 | 0.293 | +0.088 sig | **+0.058 [0.035, 0.084] ★** |

## Verdict — gate PASSED
- **Amyloid adds significant prognostic signal over the full strict bar on every future target.**
  Effect sizes (+0.03–0.07) are 3–5× exp01's cross-sectional +0.013.
- **Decisive dissociation:** for *conversion*, baseline morphometry adds **nothing** (ns) but
  amyloid adds **significantly** — amyloid is the prognostic signal structure lacks (Jack cascade:
  early-molecular vs late-macroscopic). For *slope*, both add (amyloid more).
- **The multimodal direction is alive** — first clean beat of the morphometry+clinical bar with a
  real effect size in minyoung2/3/4. Amyloid's value is **prognostic, not cross-sectional**.
- Honest scope: amyloid→conversion is partly established (ATN); contribution = leakage-clean,
  multi-cohort, strict-bar incremental demonstration + structure-vs-amyloid dissociation.

## Next
exp03 — spatial/learned PET fusion (beat the scalar?) + can T1 *image* recover amyloid's
prognostic signal (likely not).
