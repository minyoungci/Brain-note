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

**Global branch.** A SimPool-attention-pooled global vector trained with an **InfoNCE contrastive objective**
(in-batch, student view vs. EMA-teacher embeddings; explicit negatives prevent representational collapse —
`train.py --global_mode infonce`, confirmed from the released-checkpoint launch config), with KoLeo regularization.
(The codebase also offers DINO/Sinkhorn global modes; the released checkpoints use **InfoNCE**, not those.)

**Objective.** `L = L_dense + w_global * L_global`, where `L_dense` is masked-voxel MSE and `w_global` controls the
dense/global balance. We pretrain on the FOMO300K corpus (226,793 preprocessed volumes from 36 public sources) under a fixed
preprocessing pipeline — crop-to-nonzero, 1mm-isotropic resampling, RAS orientation, stored as [0,1]-scaled float16
(no skull-stripping, no bias-field correction). At training time each 96³ crop is **per-crop z-normalized**
(`data.py::_znorm`, confirmed in code); the same z-normalization is applied at evaluation (`eval_harness::load_subject`),
so the model input is standardized (mean 0, std 1), not raw [0,1]. Trained 150k steps in bf16.

> **Positioning.** Our technical contributions (3.2–3.4) are *not* a new pretraining loss or architecture. The
> headline (TC2) is a **cautionary finding + open problem**: (i) a *finding* that effective rank decouples from
> transfer under joint dense+global objective balancing (rank monotonic, transfer inverted-U), so RankMe-style
> rank-maximization selection picks the *worst* checkpoint (regret 0.194, CI-separated); and (ii) a pre-registered
> screen showing that no tested label-free spectral criterion (α-ReQ, EVR, silhouette) reliably locates the interior
> optimum on a symmetric single-task grid — a genuine open problem, not a solved selector (a dense/off-center-optimum
> task test is pre-registered as the decisive follow-up, `docs/10`). Complemented by a scratch-convergence diagnostic
> + budget/protocol-adaptive transfer method (TC1) and a shortcut-controlled external evaluation methodology (TC3,
> validation rigor). Scale (FOMO300K, 226,793 volumes) is the regime that makes label-free selection necessary, not a
> contribution in itself. We do NOT claim rank selects the optimum, nor that a label-free selector exists, nor that
> external validation is complete.

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
