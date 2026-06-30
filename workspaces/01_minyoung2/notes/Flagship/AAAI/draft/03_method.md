# 3. Method

> DRAFT — fixed/verified content only. `[VERIFY]` = confirm against code before final; `[EXTERNAL-PENDING]` = needs external data.

## 3.1 Single-Checkpoint Dense–Global Pretraining (backbone — prior art)

We pretrain a single 3D ResEnc U-Net checkpoint that exposes two transfer interfaces from one set of weights:
a dense multi-scale feature pyramid (for segmentation-style transfer) and a global pooled vector (for
regression/classification transfer).

**Backbone.** A residual-encoder U-Net (channels `(32,64,128,256,320)`, residual blocks `(1,2,2,2,2)`) operating
on `96^3` crops `[VERIFY exact crop/arch]`. The encoder produces a bottleneck of dimension 320 used as the global
representation.

**Dense branch (SparK-style; *not* our contribution).** The dense masked-reconstruction branch uses
submanifold-masked convolution: the input is masked before the stem and the binary visibility mask is downsampled
and re-applied after every encoder stage, so hidden voxels remain zeroed throughout the encoder while skip
connections are preserved. This is functionally equivalent to the sparse-convolution masked image modeling of
**SparK [Tian et al., ICLR 2023]** (cf. ConvMAE/MCMAE, SimMIM), and we treat it as an *adopted backbone component,
explicitly not a methodological novelty.*

**Global branch.** An attention-pooled (SimPool-style `[VERIFY]`) global vector trained with a self-distillation
objective using an EMA teacher `[VERIFY: exact global objective (DINO/Sinkhorn) for the released checkpoints]`,
with KoLeo regularization to discourage representational collapse.

**Objective.** `L = L_dense + w_global * L_global`, where `L_dense` is masked-voxel MSE and `w_global` controls the
dense/global balance. We pretrain on the FOMO300K corpus (226,793 preprocessed volumes from 36 public sources) under a fixed
preprocessing pipeline — crop-to-nonzero, volume-wise z-normalization, 1mm-isotropic resampling, RAS orientation
(no skull-stripping, no bias-field correction) — for 150k steps in bf16.

> **Positioning.** Our technical contributions (3.2–3.4) are *not* a new pretraining loss or architecture. The
> headline (TC2, under validation) is two-part: (i) a *finding* that effective rank decouples from transfer under
> joint dense+global objective balancing (rank monotonic, transfer inverted-U), so RankMe-style rank selection
> fails; and (ii) a *label-free criterion* that locates the transfer optimum, validated as a selection procedure
> (leave-one-task-out regret) — whose existence is gated on a candidate-metric screen. Complemented by a
> scratch-convergence diagnostic + budget/protocol-adaptive transfer method (TC1) and a shortcut-controlled
> external evaluation methodology (TC3, validation rigor). Scale (FOMO300K, 226,793 volumes) is the regime that
> makes label-free selection necessary, not a contribution in itself. We do NOT claim rank selects the optimum,
> nor that external validation is complete.

## 3.2 TC1 — Scratch-Convergence Diagnostic & Protocol-Adaptive Transfer

A recurring confound in 3D medical transfer is that **full fine-tuning lets a randomly-initialized baseline train
its own encoder, masking any benefit of pretraining.** We make this measurable. For a task, define the
**scratch-convergence gap**

```
gap(task) = Dice_scratch(full-FT) − Dice_scratch(frozen),
```

the amount by which a *scratch* model improves when it is allowed to train the encoder (full-FT) versus when it is
not (frozen, fresh decoder only). A large gap signals that full fine-tuning will hide pretraining value, so the
foundation prior must be evaluated under a *prior-preserving* protocol (frozen / low-LR) to be visible. This yields
a **protocol-adaptive prescription**: use frozen/low-LR for anatomy/tubular structures (where the prior helps) and
full fine-tuning for lesion detection (where it does not). The diagnostic requires only paired scratch runs and no
pretraining changes.

## 3.3 TC2 — Objective-Balance Trade-off & Rank-Based Selection

Sweeping `w_global` exposes a trade-off between **semantic information injected by the global objective** and the
**effective rank of the representation**. We characterize this with (i) a frozen linear/MLP probe of the global
vector (transfer quality) and (ii) `RankMe` (effective rank) of the representation, and show the balance point is a
selectable, label-free criterion (§4.2).

## 3.4 TC3 — Shortcut-Controlled Foundation Evaluation

Because the pretraining applies *no* intensity/resolution augmentation and the global objective enforces only
crop-invariance, the global vector is free to encode scanner/site signatures (verified: a random encoder predicts
site at near-ceiling on internal data). We therefore evaluate transfer under a pre-registered, three-stage
shortcut-control protocol — **measure** (site/scanner-prediction probe), **orthogonalize** (linear removal of the
site subspace, fit on training data only), and **hold out** (cross-cohort and within-cohort, with covariate
adjustment) — reporting all results as Δ-over-matched-random with bootstrap CIs (details and pre-registration in
`docs/07`, `docs/08`). Results: §4.4 `[EXTERNAL-PENDING]`.
