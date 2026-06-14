# exp01 — Multimodal Amyloid Incremental-Value Audit (cross-sectional)

**Question:** does amyloid (PET centiloid) add cognitive/diagnostic information **beyond
structural morphometry + demographics + APOE**? i.e. is it the first non-circular modality to
break the morphometry+clinical ceiling that defeated every T1-image method in minyoung2/3/4?

## Design
Incremental ladder, OASIS+NACC (GAAIN centiloid, comparable), n_amyloid=1,563:

| level | features |
|---|---|
| L0 | demographics + APOE (age, sex, apoe_e4_count) |
| L1 | L0 + morphometry (26 FreeSurfer ROI volumes, ICV-normalized) |
| L2 | L1 + amyloid (centiloid) |

**Headroom = L2 − L1.** ⚠️ m01 (minyoung2) used morphometry-**only** as the bar (→ 6/6); the
honest bar here is morphometry+demo+APOE.

Controls: subject-level GroupKFold · fold-internal impute+scale · multi-seed OOF · paired
bootstrap CI · **permutation null** · confound audit · CN-stratification. CPU, manifest scalars.

## Files
- `01_amyloid_headroom.ipynb` — executed notebook (figures embedded; 0 error cells).
- `build_notebook.py` — regenerates it (imports `../common/headroom_core.py`).
- `results/ladder_results.json` — executed numbers.

## Result (executed 2026-06-14, leakage-clean)
| target | L1(+morph) | L2(+amyloid) | Δ amyloid [95% CI] | verdict |
|---|---|---|---|---|
| dx CN-vs-impaired (AUC) | 0.809 | 0.822 | **+0.013 [0.006, 0.026]** | **★ real headroom** |
| CDR-SB (Spearman) | 0.387 | 0.400 | +0.014 [−0.000, 0.030] | ns (marginal) |
| MMSE (Spearman) | 0.293 | 0.311 | +0.018 [−0.004, 0.038] | ns |
| CDR-SB, CN-only | 0.186 | 0.184 | −0.002 [−0.003, 0.009] | ns |
| permutation-null (CDR-SB) | — | — | −0.0005 [−0.001, 0.001] | ✓ collapses → clean |

## Verdict (honest)
- Amyloid is the **first non-circular modality to add over the full morphometry+demo+APOE bar —
  but only on the diagnostic axis, and modestly (+0.013 AUC)**. Pipeline leakage-clean.
- Cross-sectional cognition (CDR-SB/MMSE) and within-CN: **marginal/ns** once age+APOE are in
  the bar — weaker than m01 because m01's bar was morphometry-only (META_INSIGHTS #1/#9).
- Mechanistically coherent (Jack cascade): cross-sectional cognition is atrophy-driven
  (morphometry-captured); amyloid's largest value is **prognostic** → see exp02 (ADNI longitudinal).
- A well-posed result, not an overclaim: modest diagnostic positive + honest nulls elsewhere.
