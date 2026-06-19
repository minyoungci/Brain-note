# exp02 Ceiling Probe — Pre-GPU Measurement Contract

> **Status: pre-GPU contract.** NO GPU run and NO CTEC implementation under this document.
> **Purpose:** pre-register the single go/no-go that decides whether the CTEC direction
> (`docs/context/ctec_method_claim_draft.md`) is pursued.
> Decision rule, endpoints, units, strata, and no-go thresholds are fixed here **before** any
> image model is trained, to prevent post-hoc strata fishing (multiple-testing inflation).

## Question

Does the strongest **unconstrained** 3D image model add IDH-discriminative value **beyond** the
clinical age/sex shortcut, under leave-one-consortium-out (LOCO)? If not, a **constrained** model
(CTEC) cannot, and the direction is dropped.

## Models under comparison

- **Clinical baseline (exp01 B0):** `M_clin = age_sex`. OOF LOCO predictions already exist:
  `experiments/exp01_clinical_shortcut_baseline/runs/B0_clinical_only/.../predictions.csv`.
  `age_only` OOF probabilities are required alongside `age_sex` for the shortcut diagnostics;
  if they are absent or not LOCO OOF, the probe is invalid.
- **Upper-bound image model:** `M_img` = strongest unconstrained 3D image baseline.
  - Primary: `B2` Res3DNet proxy.
  - Secondary: `B1` 3D ResNet image-only.
  - The ceiling = **MAX incremental value across {B1, B2}** — a true upper bound: if the best of
    them fails to beat clinical, a constrained CTEC cannot. `max` is used **only** for the go/no-go
    here; the final paper reports `B1`, `B2`, and CTEC **separately** in the main table (no max
    cherry-pick).
- **Combined:** `M_comb = age_sex + image_score` (clinical-adjusted). Estimator below.

## Primary endpoint (single, pre-registered)

Clinical-adjusted incremental value of image over `age_sex`, **full cohort**, LOCO:

```
ΔAUC   = AUC(M_comb)   − AUC(M_clin)
ΔAUPRC = AUPRC(M_comb) − AUPRC(M_clin)     # mutant = positive
ΔBrier = Brier(M_clin) − Brier(M_comb)     # positive = improvement
```

All on subject-level out-of-fold LOCO predictions over the full eligible cohort.

## Prediction unit

Subject-level (`dataset::subject_id`) **out-of-fold LOCO** prediction. Each subject appears once,
scored by the fold in which its consortium is held out. No subject in train and test of the same fold.

## Estimator for `M_comb` (leakage constraints — mandatory)

- `M_comb` is a logistic combiner over `[age, sex, image_score]`, fit **train-only** within each
  LOCO fold.
- `image_score` for **training** subjects must come from **nested out-of-fold** image predictions
  (inner CV), NOT in-sample image scores — otherwise the combiner sees optimistic scores → leakage.
- **If nested-OOF image scores are unavailable, `M_comb` is invalid: that result is
  diagnostic-only and CANNOT drive the GO decision.**
- `image_score` for the **heldout** consortium = the image model's OOF prediction for that consortium.
- Normalization / augmentation / operating-threshold: train-only or per-volume (carry exp01 rules).
- **Sensitivity (not primary):** age-residualized image score — regress image logit on `age+sex`
  (train-only), test whether the residual adds AUC. Reported alongside; does NOT drive the decision.

## Bootstrap

- Subject-level **paired** bootstrap over OOF predictions, **stratified by heldout consortium**
  (resample subjects within each heldout consortium, preserving LOCO structure).
- Same resample indices applied to `M_clin` and `M_comb` → paired Δ distribution.
- **10,000 resamples.** Report 95% percentile CI for ΔAUC, ΔAUPRC, ΔBrier.
- Folds/strata with an undefined metric (no positives) are excluded from that metric's resample and logged.

## Strata (reporting roles — only the FULL-COHORT primary drives the decision)

| stratum   | role                          | metric reported |
|-----------|-------------------------------|-----------------|
| full      | **PRIMARY (decision)**        | ΔAUC/ΔAUPRC/ΔBrier + 95% CI |
| 40_59     | supportive (pooled OOF only)  | pooled ΔAUC — per-fold underpowered (UCSD 5 / UPENN 9 / MU 10 mutants) |
| 60_69     | exploratory                   | ΔAUC where defined; folds w/ 0 positives → undefined, no CI claim |
| 70_plus   | specificity / calibration only| specificity @ train-fixed operating point + Brier/ECE (0 mutants → no discrimination) |

Supportive/exploratory strata are **NOT** used to declare GO. They contextualize only. This is the
multiple-testing guard (addresses the disjunction/H1 inflation issue).

## Diagnostics (age/site shortcut; lesion diagnostics deferred to exp03)

- Spearman `corr(image OOF logit, age)` and `corr(image OOF logit, age_only OOF logit)`.
- `p_age_only` is mandatory. The implementation must not silently fall back to `age_sex`
  probabilities for this diagnostic.
- Brain-age-shortcut signature = image logit near-collinear with age (r above a pre-set threshold)
  **and** ~0 adjusted Δ (== primary). That combination is a no-go contributor.
- Lesion-grounding diagnostics (sensitivity to lesion removal, extra-lesional insensitivity) are
  **not available at exp02** (no lesion model yet) — they belong to exp03/CTEC.

## Decision rule (pre-registered, conjunctive)

**GO** (promote to exp03 CTEC) requires ALL:

1. Full-cohort **ΔAUC 95% CI lower bound > 0**.
2. ΔAUPRC and ΔBrier directionally consistent (point estimate > 0; not negative-with-CI-excluding-0).
3. Age/site diagnostic does NOT show the image score is near-collinear with age while adding ~0 value.

**HARD NO-GO** if ANY:

- Full-cohort adjusted **ΔAUC 95% CI overlaps 0** (lower bound ≤ 0).
- Age diagnostic shows the image score is explained by age (shortcut signature).
- (exp03 only) lesion diagnostics fail — not evaluated here.

## Out of scope (forbidden under this contract)

- No GPU training run.
- No CTEC implementation (perturbations / regularizer) until exp02 returns GO.
- No change to the LOCO split, cohort definition, or B0 clinical baseline.

## Pre-conditions (must hold before the probe is RUN, per IMPLEMENTATION_PLAN)

- Cohort definition locked: 1,457 IDH-eligible vs 1,444 conflict-excluded must be resolved; the probe
  uses the locked exp01 B0 cohort. This does not change the contract structure above.
- Subject-level imaging-unit policy locked and reused by outer and nested image OOF generation.
  The draft lexical first-unit policy is smoke-only. `earliest_numeric` is explicit and reproducible,
  but still requires interpretation as "earliest available imaging", not proven pre-treatment imaging.
- Strong unconstrained baseline regimen locked before any NO-GO is considered valid: model capacity,
  target resolution, epochs, train-only augmentation, bf16 CUDA path, reproducibility controls, and
  geometry checks.
- exp02 image OOF predictions produced under the IMPLEMENTATION_PLAN approval chain (protocol approval
  → loader/split smoke test → code review → command preview → Min approval).

## Inputs / artifacts

- Clinical OOF: exp01 `B0_clinical_only` `predictions.csv`.
- Image OOF: produced later by exp02 `B1`/`B2` runs (GPU; not under this document).
- This probe is a **metrics/analysis step over OOF predictions**; it does not itself train models.
