# exp03 — Generalization (LOCO) + Mechanism of the prognostic amyloid headroom

exp02 showed baseline amyloid adds prognostic signal over morphometry+demo+APOE+severity+FU.
exp03 decides whether that is robust + mechanistically grounded.

- **Part A — cross-cohort transfer (LOCO):** fit ladder on one cohort, test on the other.
- **Part B — mechanism:** does baseline amyloid predict **future hippocampal atrophy** beyond
  baseline structure+demo? (→ amyloid upstream of neurodegeneration = why structure can't substitute).

Reuses exp02 `prognostic_core` + common primitives. `exp03_core.py`. CPU-only, leakage-clean.

## Result (executed 2026-06-14)

### Part A — LOCO transfer (Δ amyloid on held-out cohort)
| transfer | target | n_test (pos) | Δ AMYLOID [95% CI] | transfers? |
|---|---|---|---|---|
| OASIS→ADNI | cdr_slope | 783 | **+0.070 [0.042, 0.097]** | ★ yes |
| OASIS→ADNI | conv_any | 791 (162) | **+0.037 [0.019, 0.053]** | ★ yes |
| ADNI→OASIS | cdr_slope | 274 | +0.038 [−0.027, 0.102] | ns (underpowered) |
| ADNI→OASIS | conv_any | 282 (23) | +0.007 [−0.046, 0.068] | ns (23 converters) |

→ the amyloid increment **transfers to the well-powered (→ADNI) test**; →OASIS is ns because
OASIS is a tiny, converter-poor *test* set (power limitation, not a contradiction).

### Part B — amyloid → future atrophy (ADNI, n=783, leakage-clean)
- raw amyloid vs future hippocampal slope: **ρ ≈ −0.39** (more amyloid → faster atrophy)
- ladder: L0=0.383 · L1(+morph)=0.416 · **L2(+amyloid)=0.471**
- Δmorph/L0 = +0.033 **ns** | **ΔAMYLOID/L1 = +0.055 [0.023, 0.081] ★** | perm-null −0.001 (collapses)

→ baseline amyloid predicts future structural atrophy **beyond baseline structure+demo**, while
baseline morphometry itself does not. **Amyloid is upstream** — current structure cannot encode
the decline amyloid already signals.

## Verdict
- Prognostic amyloid headroom is **generalizable (transfers cross-cohort where powered)** and
  **mechanistically grounded (amyloid predicts future atrophy beyond structure → PET necessary)**.
- Combined exp01→02→03: amyloid's value is **prognostic, generalizable, mechanistic** — not
  cross-sectional, not substitutable by structural MRI. Multimodal direction validated.
- Honest scope: amyloid's prognostic role is partly established (ATN); contribution = leakage-clean,
  strict-bar, multi-cohort, **transfer-tested** incremental demonstration + the
  amyloid→future-atrophy dissociation.

## Next (GPU)
Can a 3D-CNN on T1 *image* recover any of this amyloid prognostic signal? (expected: no →
closes the "PET irreplaceable" loop).
