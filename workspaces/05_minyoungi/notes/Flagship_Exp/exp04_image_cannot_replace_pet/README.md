# exp04 — Can a *learned* T1-image representation replace amyloid PET? (necessity closure)

exp02/03 showed engineered morphometry can't substitute for amyloid. This adds the stronger
test: a **learned 3D-image representation** (RT-SSL, 128-d, frozen — no GPU/training) as a
feature block. Does it recover amyloid's prognostic signal?

## Design
Arms over the L1 bar (demo+APOE+baseline severity+FU+cohort+morphometry):
`+image` (RT-SSL emb), `+amyloid` (centiloid), `+image+amyloid`. Key stat: **amyloid-over-image**
(does amyloid add once the learned image is already in?). Subjects: exp02 prognostic set
(ADNI+OASIS), RT-SSL embed coverage **1644/1644**. Reuses exp02 loader + common primitives.
`exp04_core.py`. CPU, leakage-clean.

## Result (executed 2026-06-14)
| target | L1 | +image | +amyloid | Δ image | Δ amyloid | **amyloid OVER image [CI]** |
|---|---|---|---|---|---|---|
| conv_any [POOLED] | 0.699 | 0.684 | 0.742 | **−0.016** | +0.043 | **+0.037 [0.012, 0.054] ★** |
| conv_any [ADNI] | 0.639 | 0.606 | 0.690 | **−0.033** | +0.051 | **+0.042 [0.022, 0.071] ★** |
| cdr_slope [ADNI] | 0.253 | 0.226 | 0.322 | **−0.027** | +0.069 | **+0.066 [0.040, 0.095] ★** |

## Verdict — PET irreplaceable by structural MRI
- The learned RT-SSL T1 embedding **does not add** (Δ_image negative/ns — mild overfit, no signal
  beyond morphometry), while **amyloid adds significantly even on top of the learned image**.
- Combined with exp02/03 (engineered morphometry ns): **no T1-derived representation — engineered
  OR learned — recovers amyloid's prognostic signal.** Matches minyoung3's image→amyloid ~chance
  null. Necessity loop closed: **amyloid PET is not substitutable by structural MRI for prognosis.**
- Honest scope: frozen RT-SSL probe (not an end-to-end CNN trained for this target). A from-scratch
  CNN is GPU + already ~chance for amyloid in minyoung3 (m04 overfit, small n) → only a low-yield
  confirmatory GPU run remains.
