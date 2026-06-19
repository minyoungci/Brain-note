# CTEC (draft): Lesion-grounded behavioral regularization for IDH prediction

> **Status: NOT LOCKED.** Working hypothesis / candidate direction only.
> **Promotion gate:** advance to `experiments/exp03_ctec_tumor_evidence_consistency/`
> ONLY if the exp02 ceiling probe shows positive clinical-adjusted incremental imaging
> value (see §7). Until then this is not a committed research topic.
> Reviewed once by an independent research-critic (verdict: original framing rejected,
> conservative rewrite required); this file is that rewrite, not a final claim.

## Problem

Whole-brain 3D CNNs can predict IDH partly from extra-lesional anatomy correlated with
brain age (`age_only` LOCO AUC `0.890952`). Pooled AUC therefore overstates
lesion-specific imaging value.

Goal: a **training-time** method that encourages the imaging model to base IDH evidence
on the lesion and to **reduce reliance on extra-lesional anatomy**, while keeping
inference mask-free.

We do **not** claim causal identification and we do **not** remove age. Age is a
legitimate, biologically linked predictor of IDH; we only discourage the imaging branch
from sourcing it implicitly from non-lesional brain morphology.

## Scope / fork

- **Main method (A):** image-only CTEC, mask-free at inference. This is the method
  contribution and must read as pure-vision.
- **Comparator (B), in the main results table (not appendix):** image+clinical fusion as
  an upper-bound/reference, so the `age_sex ≈ 0.89` shortcut is never hidden from review.

## Core idea (training-time only)

Tumor segmentation provides **training-time lesion supervision for behavioral
regularization** — not a causal mask, not an inference input. Two behaviors are encouraged:

- **Lesion sensitivity (sign-agnostic):** when lesion evidence is removed, the prediction
  should **contract toward the clinical prior `M_clin = age_sex`** (lose lesion-specific
  confidence). Both mutant and wildtype carry lesion evidence, so we do **not** push the
  logit in a fixed class direction; we require collapse toward the prior. **Site is not in
  the prior** (see §3).
- **Extra-lesional insensitivity:** realistic perturbation of non-lesional voxels should
  change the prediction little. Stated as an **extra-lesional perturbation sensitivity
  test/penalty**, deliberately **not** called a "brain-age counterfactual".

Inference: whole-brain 4-channel MRI only; no mask, no perturbation.

## 1. Mask taxonomy

- **Primary mask:** enhancing + non-enhancing **tumor core**. Drives the main regularizer.
- **Supportive (separate analysis):** peritumoral ring / edema. Reported separately
  because edema segmentation is scanner/protocol-sensitive and its IDH signal is confounded.
- Coverage: **1439/1457 (98.8%)** seg-eligible across all 4 consortia
  (UTSW/MU/UCSD/UPENN).
- Train-only. Subjects without segmentation are kept for the classification loss and
  excluded from the regularizer terms (N is not shrunk).

## 2. Perturbations (distribution-preserving — hard prerequisite)

- **Lesion removal `x~L`:** replace tumor-core voxels with healthy-appearing tissue
  (contralateral mirror or intensity-matched inpaint). **NOT zero-fill.**
- **Extra-lesional perturbation `x~E`:** realistic intensity / bias-field / mild-warp
  change on non-lesional voxels only, lesion core intact.
- **Edit-detectability gate (mandatory):** a held-out classifier must **not** distinguish
  edited from real MRI above chance. Any perturbation that is detectable is discarded —
  otherwise the regularizer learns the edit artifact, not biology.

## 3. Objective (functional form intentionally NOT fixed here)

```
L = L_cls(f(x), y)                          # class-weighted/focal, train-only resampling
  + λ_s · D( f(x~L), prior_clin )           # prior_clin = detached M_clin = age_sex (NO site); sign-agnostic
  + λ_e · | f(x) - f(x~E) |                 # extra-lesional insensitivity
```

`prior_clin` is the **detached** clinical prior `= M_clin = age_sex` (exp01 B0 prediction).
**Site is excluded from the prior:** a site term would let the regularizer learn a
dataset-label prior, reintroducing the consortium confound CTEC is meant to avoid. Exact
losses, margins, and `λ` values are locked only **after** exp02, not in this draft.

## 4. Inference path

`f(x)`, whole-brain MRI, mask-free, perturbation-free → identical test-time compute to
Res3DNet, enabling a fair head-to-head comparison.

## 5. Primary endpoint + baselines

**Primary endpoint:** clinical-adjusted **incremental imaging value over `age_sex`** under
LOCO (paired ΔAUC / ΔAUPRC / ΔBrier, heldout-consortium stratified subject-level paired
bootstrap), **plus lesion-grounding diagnostics** (contraction under lesion removal;
insensitivity to extra-lesional perturbation). This is not a raw-AUC race.

**Baselines / ablations:**

- `B0` clinical-only (`age_sex`)
- 3D ResNet image-only
- Res3DNet proxy
- mask-as-input (naive mask use)
- multitask seg+IDH (shared backbone)
- image, no regularizer
- **CTEC (ours)**
- **[B comparator]** image+clinical fusion (main table, upper bound)
- Ablate: `-lesion-sensitivity`, `-extra-lesional`, zero-fill vs inpaint.

## 6. Novelty delta (desk-reject defense)

- **vs ACAT (Fontanella 2023, counterfactual attention):** we anchor on ground-truth
  lesion masks, use bidirectional behavioral constraints, and keep inference mask- and
  counterfactual-free.
- **vs segmentation-guided / multitask seg+IDH:** those inject masks as input or auxiliary
  labels at train/inference; we use masks only to shape behavior-under-perturbation and
  never at inference.
- **vs brain-age / disease disentanglement (Ouyang 2022, Zhao 2020):** we do not
  disentangle or remove age; we regularize spatial evidence sourcing. (These priors are
  exactly why brain-age disentanglement is demoted to an evaluation axis, not a novelty.)

## 7. Go/No-go (decided by exp02 BEFORE building CTEC)

Upper bound of age-independent imaging value = the strongest **unconstrained** image
model's clinical-adjusted incremental ΔAUC / ΔAUPRC / ΔBrier over `age_sex`
(pooled `40_59` + LOCO, paired bootstrap).

- If that CI sits at ~0: imaging adds nothing beyond age under control → a **constrained**
  model (CTEC) cannot exceed it → **do not promote; pivot.**
- If positive: CTEC must retain incremental value **and** pass lesion-grounding
  diagnostics. Only then promote to
  `experiments/exp03_ctec_tumor_evidence_consistency/`.

## Open risks (unresolved)

- **Weak residual signal:** lesion-specific IDH signal may be small; then every constrained
  method yields a negative result regardless of design. exp02 is the test.
- **Post-treatment inpainting:** MU-Glioma-Post and UCSD-PTGBM are post-treatment cohorts
  with resection cavities / treatment effect. "Replace lesion with healthy-appearing tissue"
  is ill-defined over a surgical cavity and is likely to fail the edit-detectability gate.
  Lesion-removal feasibility must be checked per consortium before exp03.
- **Prior coupling:** `prior_clin` (= `age_sex`, B0) ties CTEC quality to B0; a weak B0
  weakens the sensitivity target.
- **Mask label granularity:** the core/edema taxonomy (§1) assumes segmentation labels
  separate tumor core from edema. Verify per consortium **before exp03**; if only binary
  whole-tumor masks exist, downgrade the taxonomy to whole-tumor and drop the core/edema split.
