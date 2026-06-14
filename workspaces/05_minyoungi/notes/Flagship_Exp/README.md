# Flagship Exp — index

Rigorous, leakage-clean experiments testing the one direction the minyoung2/3/4 post-mortems
left live: **multimodal headroom** — does a *new modality* add over the morphometry+clinical
ceiling that defeated every T1-image method?

## Layout (per-experiment subdirectories)
```
Flagship_Exp/
├── common/headroom_core.py        # shared primitives: load, incremental ladder, subject-level
│                                   #   OOF, paired bootstrap CI, permutation null, confound audit
└── expNN_<name>/
    ├── README.md                  # this experiment's spec + executed result
    ├── build_notebook.py          # regenerates the notebook from cell sources
    ├── NN_<name>.ipynb            # executed notebook (figures embedded)
    └── results/                   # *.json outputs
```
Run an experiment: `cd expNN_<name> && python3 build_notebook.py && jupyter nbconvert --to
notebook --execute --inplace --ExecutePreprocessor.kernel_name=python3 NN_<name>.ipynb`
(must run from inside the experiment dir; the notebook imports `../common`).

## Experiments
| id | question | status | headline (honest) |
|---|---|---|---|
| **[exp01_amyloid_xsectional_headroom](exp01_amyloid_xsectional_headroom/)** | amyloid over morphometry+demo+APOE? (OASIS+NACC, cross-sectional) | ✅ executed | diagnosis +0.013 AUC (sig, clean); cognition/CN ns. **Modest, diagnosis-specific.** |
| **[exp02_amyloid_prognostic_adni](exp02_amyloid_prognostic_adni/)** | baseline amyloid → FUTURE decline over morpho+demo+APOE+**severity+FU**? (ADNI+OASIS, n=1644) | ✅ executed | **★ GATE PASSED** — conv +0.04–0.05, MCI→AD +0.03, slope +0.06–0.07 (all sig, clean). For conversion **morphometry ns, amyloid sig** (dissociation). |
| **[exp03_generalization_mechanism](exp03_generalization_mechanism/)** | does the prognostic headroom (A) transfer cross-cohort (LOCO) and (B) reflect amyloid being upstream of atrophy? | ✅ executed | **A: transfers** (OASIS→ADNI slope +0.07★, conv +0.04★; →OASIS underpowered). **B: amyloid→future atrophy +0.055★** over structure (morph ns), ρ≈−0.39. |
| **[exp04_image_cannot_replace_pet](exp04_image_cannot_replace_pet/)** | does a *learned* T1-image rep (RT-SSL, frozen) recover amyloid's prognostic signal? | ✅ executed | **No.** learned image Δ **negative/ns**; amyloid adds even *over* the image (+0.04–0.07★). PET irreplaceable. |

**Headline across exp01→04:** amyloid's prognostic value is **real, generalizable, mechanistically
upstream of atrophy, and irreplaceable by T1 (engineered OR learned)** — the principled,
leakage-clean case for the *multimodal* direction that every T1-only method in minyoung2/3/4
failed to deliver. The flagship arc is complete.

## Planned (next, optional)
- **exp05 (GPU, low-yield confirmatory)** — end-to-end 3D-CNN on T1 image for amyloid prognosis
  (expected ~chance per minyoung3 m04); only needed if a reviewer demands the learned-end-to-end
  control. Spatial/learned PET fusion vs centiloid scalar (m03/m04 showed naive < scalar).

## Principles (from META_INSIGHTS — every experiment obeys)
fair bar (morphometry+demo+APOE, not morphometry-only) · subject-level CV · bootstrap CI (no
point estimates) · permutation null · confound audit · CN-stratification · honest verdict
(report nulls; no overclaim). Generation ≠ verification.
