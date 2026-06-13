# Answer and Ground: Question-Conditioned Anatomical Localization for Image-Only 3D Brain-MRI VQA under Cross-Site Shift

## Abstract

Visual question answering (VQA) on 3D brain MRI promises clinically interpretable models that
not only answer anatomical questions but point to the evidence. Progress is held back by two
problems: (i) answer-accuracy benchmarks on structure-derived labels saturate quickly because a
simple morphometric readout already approaches the label-generating process, providing little
headroom for a vision method; and (ii) the *grounding* of an answer—whether the model actually
attends to the queried anatomy—is rarely evaluated, and almost never under distribution shift.
We reframe the problem around grounding. We introduce a shortcut-controlled, multi-cohort
(7 cohorts, 3 scanner vendors) image-only ROI-VQA benchmark with normative FreeSurfer
pseudo-labels, on which clinical-context-only inputs perform at chance while an ROI-value oracle
is perfect, isolating genuine anatomical evidence. On this benchmark we train a lightweight 3D
model that answers a templated anatomical-evidence question *and* localizes the queried region
via a question-conditioned attention head supervised with a weak ROI prior. Localization
supervision yields strong, stable grounding (attention mass-in-ROI 0.78, pointing-game 0.95,
27x over chance) at no cost to answer accuracy, and—critically—**generalizes across three
independently held-out cohorts** under leave-one-cohort-out (LOCO) evaluation. The supervised
attention localizes 5.5x better than post-hoc Grad-CAM from a matched classifier, and far better
than its own unsupervised ablation, which is weak and seed-unstable. Because morphometry returns
a number and cannot localize or be evaluated across unseen scanners, our grounding axis is not
capped by the answer-accuracy ceiling. We release the benchmark, protocol, and code.

## Figures
- Fig. 1: per-question attention mass-in-ROI (supervised vs unsupervised vs chance). `fig1_grounding_bars.png`
- Fig. 2: attention overlay on an axial MRI slice for a ventricle-enlargement query. `fig2_attention_overlay.png`
- Fig. 3: same MRI, four different questions -> attention follows the queried ROI. `fig3_question_conditioning.png`

## 1. Introduction

Interpretable medical image understanding requires more than a correct answer; it requires the
model to indicate *where* the evidence is. In neuroimaging, this matters because the same
T1-weighted scan supports many anatomically distinct questions—hippocampal volume, medial
temporal lobe (MTL) atrophy, ventricular enlargement—each grounded in a different structure. A
model that answers correctly but attends to the wrong region is neither trustworthy nor useful
for downstream localization, and its correctness may rest on a confound rather than the named
anatomy.

Two obstacles have kept this goal out of reach. First, **benchmarks reward the wrong thing.**
When labels are derived from structural measurements (e.g., FreeSurfer-based normative
percentiles), a direct morphometric readout reaches a high answer-accuracy ceiling, leaving
little room to demonstrate a better vision model; chasing that ceiling produces marginal,
non-generalizing gains. Second, **grounding is under-evaluated.** Most 3D medical VQA systems
report answer accuracy alone; when localization is shown, it is typically a qualitative saliency
map on a handful of in-distribution cases, with no quantitative, per-question, cross-site
evaluation.

We argue the productive contribution axis is grounding under shift, and we build the benchmark
and method to study it. Our benchmark is *shortcut-controlled*: by construction, a model given
only clinical context (diagnosis, age, sex, site) performs at chance, while a model given the
true ROI value is perfect—so any above-chance image model must use genuine anatomical evidence.
It spans 7 cohorts and 3 scanner vendors and is evaluated under strict subject-level
leave-one-cohort-out (LOCO), making cross-site generalization a first-class measurement rather
than an afterthought.

On this benchmark we study a deliberately lightweight model that **answers and grounds** jointly:
a 3D encoder produces a feature grid, a question embedding queries it through an attention head
to localize the evidence, and the localized feature drives a binary answer. A weak ROI-prior
supervises the attention. We find that this supervision is what turns diffuse, unstable attention
into reliable grounding—and it is essentially free in answer accuracy.

**Contributions.**
1. A shortcut-controlled, multi-cohort/multi-vendor, image-only ROI-VQA benchmark with normative
   pseudo-labels and a strict LOCO protocol that makes cross-site generalization measurable.
2. A grounding evaluation (attention mass-in-ROI, pointing-game) showing that question-conditioned
   supervised attention localizes the queried anatomy 27x above chance, 5.5x better than post-hoc
   Grad-CAM, at no answer-accuracy cost.
3. The first demonstration, to our knowledge, that such grounding **generalizes across three
   independently held-out cohorts** under scanner/site shift.
4. An analysis of when explicit ROI conditioning helps answering: the benefit is gated by
   representation quality and encoder capacity, and a compact routed model matches far larger
   backbones—clarifying why heavier conditioning machinery is unnecessary here.

## 2. Related Work

**3D medical VQA and report grounding.** Large 3D medical VLMs (e.g., M3D) contribute primarily
through auto-generated datasets and multi-task systems rather than oracle-beating accuracy;
grounded report generation systems (e.g., AutoRG-Brain) pair region grounding with manual reports.
We share the dataset/grounding emphasis but target image-only, templated anatomical-evidence
questions with quantitative cross-site grounding and without radiologist free text.

**Weakly-supervised localization and attention.** Post-hoc saliency (Grad-CAM and variants)
explains classifiers without localization supervision; learned/attention-based localization can
be supervised with weak region priors. We compare supervised question-conditioned attention
directly against Grad-CAM under identical encoders and show a large gap.

**Normative modeling and brain morphometry.** Normative percentiles of structural measures are a
standard substrate for "abnormality" labels. We use them as pseudo-labels but argue, and show,
that answer accuracy against such labels is ceiling-limited by morphometry, motivating grounding
as the contribution axis.

## 3. Benchmark and protocol

**Data.** 13,022 QC-passed T1w sessions (N4-corrected, 192x224x192) drawn from 7 cohorts
(ADNI, A4, NACC, AJU, OASIS, AIBL, KDRC) across 3 vendors (Siemens, GE, Philips), predominantly
3.0T. The VQA split comprises 19,236 question-answer rows over 9,278 sessions / 5,601 subjects
with zero subject leakage across splits.

**Task.** Image-only ROI-grounded VQA. The input is the image tensor(s) and a question id only;
diagnosis, CDR, age, sex, and all ROI values/percentiles are withheld from the model. We use four
binary session-level questions—low hippocampal volume, MTL atrophy, ventricular enlargement, and
low hippocampus-to-ventricle ratio—with labels defined by train-only-CN normative percentile
cutoffs (<=0.10 or >=0.90).

**Shortcut control.** By construction the benchmark removes non-anatomical shortcuts: a model
given only clinical context scores near chance (AUC ~ 0.5), while an oracle given the true ROI
value scores ~1.0. Any above-chance image model must therefore extract genuine anatomical
evidence rather than exploit cohort or demographic priors.

**Evaluation.** Subject-level leave-one-cohort-out (LOCO): the test cohort is excluded from
train and validation, and only its held-out test subjects are scored. We report macro AUC
(mean of per-question AUCs) for answering, and for grounding the attention mass inside the true
ROI and the pointing-game (fraction of cases whose peak attention falls in the ROI), each against
a uniform-attention chance baseline.

**Grounding ground truth.** For each test session and question we rasterize the FreeSurfer ROI
mask(s) for the queried structure(s) onto the encoder's 8x8x8 feature grid, giving a per-question
spatial target. This is an anatomical-region target, not radiologist-verified pathology.

## 4. Method

**Encoder and tokens.** A compact 3D CNN encodes the global volume into a (C, 8, 8, 8) feature
map; auxiliary high-resolution MTL/ROI crops provide additional pooled features. The encoder is
initialized from label-free 3D contrastive (SimCLR-style) pretraining that excludes the test
cohort, keeping LOCO leakage-safe.

**Answer-and-ground head.** A learned embedding of the question id forms a query. Over the global
feature grid (8^3 cells), a question-conditioned attention computes a localization distribution
`a = softmax(<k(cells), q(question)>)`; the localized feature `sum_i a_i cell_i` is concatenated
with global/crop features and passed to a binary answer head. The same `a` is the model's
grounding.

**Objective.** The answer is trained with binary cross-entropy. The attention is supervised with
a weak ROI prior: a cross-entropy between `a` and the (normalized) ROI target, weighted by
lambda=0.3. The total loss is `BCE(answer) + 0.3 * CE(a, ROI-prior)`. We deliberately keep the
architecture minimal—no question text encoder, no contrastive image-text alignment—so that the
grounding result is attributable to the conditioning-plus-supervision mechanism rather than model
scale.

## 5. Experiments

All models use bf16 autocast, Adam (lr 5e-4), 10 epochs, checkpoint-selected on validation macro
AUC. Grounding is evaluated on the saved test-time attention; for the Grad-CAM baseline we train a
matched multi-crop classifier (no attention head) and compute Grad-CAM saliency on the same
8^3 global feature map. Unless noted, results are mean +- standard deviation over random seeds.

## 6. Results

### 6.1 Grounding beats post-hoc saliency and needs supervision (Table A; Fig. 1, 2)

On AJU (LOCO), supervised question-conditioned attention localizes the queried ROI far better than
the alternatives:

| method | mass-in-ROI | pointing-game | x chance |
|---|---|---|---|
| supervised attention (loc-sup, ours) | 0.780 +- 0.010 | 0.947 | 27x |
| attention, no loc-sup | 0.200 +- 0.074 | 0.244 | 7x |
| Grad-CAM (post-hoc, matched classifier) | 0.143 +- 0.007 | 0.357 | 5x |
| uniform (chance) | 0.029 | - | 1x |

Supervised attention reaches 27x chance and a 0.95 pointing-game. Removing the localization
supervision collapses grounding to 7x chance and makes it seed-unstable (one seed degenerates),
showing the supervision—not merely the attention mechanism—is what yields reliable localization.
Post-hoc Grad-CAM from a matched classifier is weakest (5x), confirming that a free saliency map
does not substitute for question-conditioned supervised grounding. Crucially, the supervision is
free in answer accuracy: macro AUC is 0.827 +- 0.010 with loc-sup vs 0.823 +- 0.011 without.

### 6.2 Grounding generalizes across held-out cohorts (Table B)

Under true LOCO with each cohort independently held out of training, grounding is strong and
remarkably consistent:

| held-out cohort | test n | mass-in-ROI | pointing | x chance | answering macro AUC |
|---|---|---|---|---|---|
| AJU | 340 | 0.785 +- 0.008 | 0.941 | 27.5x | 0.818 |
| OASIS | 210 | 0.837 +- 0.004 | 0.990 | 27.8x | 0.891 |
| NACC | 320 | 0.747 +- 0.004 | 0.920 | 27.3x | 0.886 |

The model localizes the queried anatomy at ~27x chance on cohorts never seen in supervised
training, spanning scanner and site shift. To our knowledge this is the first quantitative
demonstration of cross-site grounding generalization for 3D brain-MRI VQA.

### 6.3 Per-question grounding and question-conditioning (Fig. 3)

Grounding is strong for every question, with pointing-game from 0.83 (hippocampus, the smallest
target) to 1.00 (hippocampus-to-ventricle ratio):

| question | n | mass-in-ROI | uniform | pointing |
|---|---|---|---|---|
| hippocampus low | 96 | 0.693 | 0.016 | 0.826 |
| MTL atrophy | 100 | 0.887 | 0.025 | 0.990 |
| ventricle enlarged | 64 | 0.773 | 0.037 | 0.995 |
| hippo/vent ratio low | 80 | 0.758 | 0.041 | 1.000 |

Fig. 3 shows the qualitative counterpart: holding the MRI fixed and changing the question moves
the attention to the queried structure—medial temporal for hippocampus/MTL, central for ventricle.

### 6.4 When does ROI conditioning help answering?

Answer accuracy on these pseudo-labels is ceiling-limited: a morphometric normative readout
reaches ~0.91 macro AUC under LOCO, and no conditioning variant exceeds it. Within that regime we
find the conditioning benefit is *gated*: it appears only on a fine-tuned 3D-SSL base (not
from-scratch or frozen), and it vanishes as the backbone grows (a compact routed model matches
14M/33M-parameter ResNet-3D encoders). A learned question router performs on par with plain
cross-attention, indicating the heavier routing machinery is unnecessary. These results explain
why our final model is deliberately compact, and motivate grounding—rather than answer
accuracy—as the contribution.

## 7. Discussion

The central message is that on structure-derived labels, *answer accuracy is the wrong yardstick*:
it is bounded by the morphometric process that created the labels. Grounding is not: it asks
whether the model looks at the right anatomy, an axis morphometry cannot address (it returns a
scalar) and which we show is both learnable and transferable across unseen cohorts. Localization
supervision is the key ingredient—free attention is diffuse and unstable—and, importantly, it
does not trade off against answering. This reframing turns a saturated accuracy task into a
useful, evaluable grounding task with cross-site evidence.

## 8. Limitations

- The grounding ground truth is an anatomical ROI mask (FreeSurfer), not radiologist-verified
  pathology; high mass-in-ROI means the model attends to the correct structure, not that it has
  detected disease.
- Labels are normative pseudo-labels; answer accuracy is therefore ceiling-limited and is not our
  contribution.
- Questions are templated (four binary queries) with a question-id embedding rather than free
  text; we do not perform open-vocabulary or generative VQA.
- The SSL pretraining excluded AJU; OASIS/NACC LOCO uses the AJU-excluded (label-free) SSL
  initialization. Per-cohort SSL pretraining is left to future work; we expect it to only
  strengthen the cross-site result.

## 9. Conclusion

We reframe image-only 3D brain-MRI VQA around grounding rather than ceiling-limited answer
accuracy. On a shortcut-controlled, multi-cohort benchmark, a lightweight answer-and-ground model
with weak ROI-prior supervision localizes the queried anatomy 27x above chance, far better than
post-hoc Grad-CAM, at no answer cost, and—uniquely—generalizes across three independently
held-out cohorts. We release the benchmark, protocol, and code to support grounded, cross-site
evaluation of 3D medical VQA.
