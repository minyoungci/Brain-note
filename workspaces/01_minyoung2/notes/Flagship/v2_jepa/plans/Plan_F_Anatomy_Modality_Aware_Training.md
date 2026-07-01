# Plan F: Anatomy- and Modality-Aware Brain MRI Foundation Training

## 0. One-Line Thesis

Large-scale 3D Brain MRI foundation model은 CT VoCo의 장기 위치 예측 objective를 복제하는 것이 아니라, brain anatomy prior를 이용해 **anatomy-aware context prediction**, **modality-aware latent consistency**, **site/scanner-held-out transfer**를 동시에 검증하는 robust SSL framework로 설계한다.

```text
Brain MRI Foundation
  = DINO/JEPA/MAE-style robust SSL
  + brain-anatomy-aware context prediction
  + modality-aware T1/FLAIR/DWI consistency
  + site/scanner-held-out downstream benchmark
  + scaling law / data quality ablation
```

## 0.1 Evidence Update: A10-A15 Gates

Updated: 2026-07-01 UTC

The current Brain-JEPA pilot evidence changes the next-step policy. Simple global correction, coarse-anatomy correction, frozen anatomy heads, and shared pseudo-tissue dense prediction have now been tested and rejected.

| Branch | Source-probe | Task1 AUROC | Brain-age Pearson | Task5 AUROC | Decision |
|---|---:|---:|---:|---:|---|
| A10 dense S3D distill `w=0.05` | 0.0778 | 0.8077 | 0.6085 | 0.8976 | best JEPA research branch, not final |
| A11 dense + global align `w=0.02` | 0.2130 | 0.6827 | 0.6929 | 0.8194 | reject: shortcut returns |
| A12 dense + anatomy summary `w=0.10` | 0.1685 | 0.4038 | 0.7038 | 0.6233 | reject: coarse target damages classification |
| A13 frozen A10 + `shared+anatsum` | 0.0852 | 0.7212 | 0.5846 | 0.8837 | reject: source-safe but no brain-age recovery |
| A14 dense + pseudo-tissue `w=0.05` | 0.1574 | 0.6346 | 0.7770 | 0.9201 | reject: morphology improves, Task1 fails |
| A15 dense + pseudo-tissue `w=0.02` | 0.1648 | 0.4038 | 0.7591 | 0.9462 | reject: Task5/age strong, Task1 collapses |

Conclusion:

```text
Do not continue global-align, anatomy-summary-weight, frozen-anatomy-head, or pseudo-tissue-weight sweeps.
```

A13 is particularly important: freezing the encoder prevented the severe A12 Task5 collapse, but still failed to improve brain-age. Therefore the failure is not only destructive gradient flow into the shared encoder. The low-frequency anatomy-summary target itself is too weak.

A14/A15 are equally important in the opposite direction: a richer dense pseudo-tissue target does recover brain-age and Task5, but damages Task1 even when the weight is reduced. Therefore the next blocker is feature coupling. Morphology-sensitive targets should not be forced into the same single shared feature without a separate morphology/task representation design.

## 0.2 Launch Rules For The Next JEPA Experiment

The next JEPA run must satisfy all of the following before launch:

```text
1. It changes the target structure, not only a weight.
2. It uses richer anatomy than the rejected low-frequency summary.
3. It has a pre-registered gate against A10:
   source <= 0.10 preferred, <= 0.17 hard max
   Task1 >= 0.80 preferred, no worse than 0.72 hard floor
   Brain-age > 0.6085 minimum; >0.672 preferred
   Task5 >= 0.88 minimum
4. It includes an explicit stop rule at the first checkpoint if the gate fails.
```

Current local filesystem check did not find ready atlas/tissue/ROI label volumes in the project tree. A14/A15 used unsupervised pseudo-tissue targets and showed that the signal is useful but too coupled to the shared representation. Until atlas/tissue/ROI targets or a structural disentanglement implementation exists, the only valid next directions are:

- **source-heldout-selection**: no new pretraining; evaluate existing A10/S3D representations under source-held-out or A2-orthogonalized protocols.
- **multi-head morphology/task disentanglement**: keep the A10 shared feature, train morphology-specific pseudo-tissue/atlas heads separately, and evaluate `shared`, `morphology`, and `shared+morphology` features independently.
- **atlas/ROI-context**: only after a reproducible atlas/tissue preprocessing path exists.

Status update:

```text
A16 implements the multi-head morphology/task disentanglement path:
  frozen A10 encoder
  + separate pseudo-tissue morphology head
  + feature spaces: shared, morph, shared_plus_morph

Launch:
  Flagship/v2_jepa/runs/pilot_a16_frozen_a10_pseudotissue_morph_g192e128_seed4500_gpu0_20260701

First decision:
  evaluate ckpt_step1000.pt.
```

Step1000 result:

| Feature | Source-probe | Task1 AUROC | Brain-age Pearson | Task5 AUROC | Decision |
|---|---:|---:|---:|---:|---|
| A16 `shared_plus_morph` | 0.0815 | 0.7981 | 0.6573 | 0.8854 | continue to 10k |
| A10 reference | 0.0778 | 0.8077 | 0.6085 | 0.8976 | current best JEPA research branch |

This is the first post-A10 branch that improves brain-age without the A14/A15 Task1 collapse or A11/A14 source leakage. It is not a final replacement yet, but it validates morphology/task feature separation as the next direction.

Final 10k result:

| Feature | Source-probe | Task1 AUROC | Brain-age Pearson | Task5 AUROC | Decision |
|---|---:|---:|---:|---:|---|
| A16 `shared_plus_morph` | 0.1185 | 0.8077 | 0.7064 | 0.9201 | best balanced JEPA research candidate so far |
| A10 reference | 0.0778 | 0.8077 | 0.6085 | 0.8976 | stronger source robustness, weaker global biology |
| S3D+InfoNCE wg0.5 reference | 0.3105 | 0.7212 | 0.7924 | 0.9566 | production reference |

A16 confirms the architecture direction:

```text
Do not force morphology targets into the shared JEPA representation.
Use a separated morphology feature space and combine it with the shared feature only at evaluation/fine-tuning time.
```

Next branch:

```text
A17 = A16 + source-adversarial regularization or source-gated early stopping
goal: keep A16 downstream gains while pushing source-probe back toward A10 (~0.08).
```

A17 step1000 update:

| Branch | Source-probe | Task1 AUROC | Brain-age Pearson | Task5 AUROC | Status |
|---|---:|---:|---:|---:|---|
| A17 adv `0.05` | 0.0944 | 0.7500 | 0.6350 | 0.9375 | continue to 10k |
| A17 adv `0.10` | 0.1037 | 0.7788 | 0.6646 | 0.8785 | continue to 10k |
| A16 step10000 | 0.1185 | 0.8077 | 0.7064 | 0.9201 | current best balanced JEPA |

A17 confirms that adversarial morphology-head regularization can reduce source-probe, but the first checkpoint loses too much downstream signal. Continue to 10k only because A16 also improved substantially after step1000.

A17 final 10k update:

| Branch | Source seed100 | Source mean seeds 100/101/102 | Task1 AUROC | Brain-age Pearson | Task5 AUROC | Decision |
|---|---:|---:|---:|---:|---:|---|
| A17 adv `0.05` | 0.1167 | — | 0.7500 | 0.7219 | 0.9427 | reject as best: Task1 weak |
| A17 adv `0.10` | 0.1167 | 0.1130 | 0.8654 | 0.7122 | 0.9080 | current best JEPA research candidate |
| A16 step10000 | 0.1185 | 0.1259 | 0.8077 | 0.7064 | 0.9201 | previous best balanced JEPA |

A17 adv `0.10` becomes the current best JEPA research candidate because it improves A16 on mean source-probe, Task1, and brain-age while keeping Task5 above the gate. It is not a final foundation-model claim yet; source-held-out downstream and richer anatomy/modality objectives are still required.

## 0.3 A18 Paired-Modality Result And A19 Policy

Updated: 2026-07-01 UTC

A18 tested the most direct modality-aware idea:

```text
same subject/session + same shape
context = T1, target = FLAIR or T2
loss = paired-modality JEPA + masked S3D dense distillation + source adversary
```

Step5000 gate:

| Branch | Source-probe | Task1 AUROC | Brain-age Pearson | Task5 AUROC | Protocol Task1 | Protocol Task5 | Decision |
|---|---:|---:|---:|---:|---:|---:|---|
| A18 T1-FLAIR | 0.0981 | 0.6827 | 0.7568 | 0.9774 | 0.4423 | 0.9045 | stop |
| A18 T1-T2 | 0.1056 | 0.4231 | 0.7568 | 0.8715 | not run | not run | stop |
| A17 adv `0.10` | 0.1130 mean | 0.8654 | 0.7122 | 0.9080 | 0.8173 | 0.8976 | best JEPA research candidate |
| S3D+InfoNCE wg0.5 | 0.3105 mean | 0.7212 | 0.7924 | 0.9566 | 0.8269 | 0.9010 | production reference |

Conclusion:

```text
Paired-modality prediction is useful, but not as the only shared-vector target.
It improves age/global morphology while keeping source-probe low,
but it damages pathology-sensitive and protocol-heldout Task1 signal.
```

Therefore A19 must not be another paired-modality shared-vector run. The next valid architecture is:

```text
A19 = A17-style source-safe shared representation
    + separate modality-invariant anatomy branch
    + separate pathology/global task-sensitive branch
    + nuisance/source branch or covariance penalty

paired-modality loss -> anatomy branch only
S3D dense/local distill -> shared/local path
source adversary -> nuisance-sensitive branch and/or morphology branch
downstream feature gate -> shared, anatomy, pathology, shared+heads
```

Pre-registered A19 gates:

| Gate | Minimum | Promotion target |
|---|---:|---:|
| Source-probe | `<=0.17` | near A17 `0.113` or lower |
| Random Task1 | `>=0.80` | beat A17 `0.865` or S3D `0.721` depending protocol |
| Brain-age | `>0.756` preferred | approach S3D `0.792` |
| Random Task5 | `>=0.90` | match S3D `0.956` or A18 T1-FLAIR `0.977` without protocol collapse |
| Protocol Task1 | `>=0.817` | match/beat S3D `0.827` |
| Protocol Task5 | `>=0.897` | match/beat S3D `0.901` |

Stop rule:

```text
If protocol-group Task1 fails below 0.72 at the first evaluated checkpoint,
stop immediately even if source-probe or brain-age is strong.
```

A19 result:

| Branch | Best source feature | Source-probe | Task1 AUROC | Decision |
|---|---|---:|---:|---|
| A19 T1-FLAIR | shared_plus_a19_task | 0.1685 | 0.4712 | stop |
| A19 T1-T2 | a19_task | 0.1352 | 0.4712 | stop |

Conclusion:

```text
A19 confirms that anatomy/modality consistency can be source-safe,
but it still does not preserve multi-modal pathology classification.
Do not continue A19 as-is.
```

Updated next policy:

```text
Best completed JEPA research candidate remains A17 adv=0.10.

Before launching A20, require one of:
  1. a pathology-preserving SSL target that is not just anatomy/modality alignment;
  2. external/source-heldout validation of A17 to decide whether JEPA is already useful enough as a confound-aware research model;
  3. a clear segmentation/dense-transfer gate showing local features improve where global Task1 does not.
```

## 1. Why Not Copy CT VoCo Directly

VoCo의 핵심 철학은 맞다.

```text
3D medical images have anatomical geometric priors.
```

하지만 CT abdominal organ setting과 brain MRI는 다르다.

| 항목 | CT VoCo-style setting | Brain MRI setting |
|---|---|---|
| 주요 prior | 장기별 coarse spatial layout | tissue/ROI/network/hemisphere/context relation |
| 입력 contrast | CT intensity가 비교적 표준화 | T1/FLAIR/DWI/ADC/SWI 등 sequence-dependent |
| 위험 | organ-position prediction으로도 유효 | registration/template/age/site shortcut 위험 큼 |
| 그대로 복사 시 문제 | 장기 위치 class assignment | brain에서는 atlas 위치 암기 또는 template shortcut이 될 수 있음 |

따라서 가져올 것은 "의료영상의 해부학적 구조 prior를 SSL target에 넣는다"는 철학이고, 버릴 것은 "CT 장기 위치를 그대로 class처럼 맞히는 objective"다.

## 2. Proposed Model Family

Working name:

```text
Brain Anatomy-Modality JEPA (BAM-JEPA)
```

Core architecture:

```text
multi-sequence 3D MRI
  -> modality-specific stem
  -> shared ResEnc / hierarchical 3D encoder
  -> local feature pyramid + global vector

context view
  -> context encoder
  -> predictor
  -> predicted target latent

target view
  -> EMA target encoder
  -> stop-gradient target latent
```

The current `Flagship/v2_jepa/code/brain_jepa/` prototype already implements the minimal skeleton:

- context encoder
- EMA target encoder
- 3D predictor
- latent prediction loss
- variance/collapse monitor

But it is not yet a full training pipeline. This plan defines what must be added.

## 3. SSL Objectives

### 3.1 Local Anatomy-Aware JEPA

Predict target latent representations of anatomically meaningful target regions from distributed context.

```text
visible context blocks -> predictor -> target ROI/tissue latent
EMA target encoder(target blocks) -> stop-grad target latent
```

Target sampling should be anatomy-aware, not random only.

Examples:

- cortex vs white matter vs CSF/ventricle
- left/right homologous regions
- subcortical structures
- cerebellum/brainstem
- lesion-sensitive periventricular or cortical-subcortical context

Important: atlas/tissue labels are used for **sampling and stratification**, not as a supervised disease label. The model should not be trained to classify subject identity, site, or diagnosis.

### 3.2 Modality-Aware Latent Consistency

For subjects with multiple sequences:

```text
T1 context    -> shared anatomy latent
FLAIR context -> shared anatomy latent
DWI/ADC       -> shared anatomy latent
```

The objective is latent agreement for the same anatomical region, not raw cross-modal synthesis.

Recommended loss:

```text
L_mod = distance(z_T1_roi, stopgrad(z_FLAIR_roi))
      + distance(z_FLAIR_roi, stopgrad(z_DWI_roi))
      + variance/covariance regularization
```

Guardrail:

```text
Do not force complete modality invariance.
```

The representation should preserve modality-specific information needed for pathology. Use:

- shared anatomy head
- modality-specific residual/head
- modality token or stem id

### 3.3 Global DINO/InfoNCE Branch

Keep a global branch because downstream classification/regression needs a stable global vector.

```text
global crop v1 -> student global vector
global crop v2 -> EMA teacher global vector
loss = DINO-style distillation or InfoNCE
```

For our history, InfoNCE is safer than pure DINO/Sinkhorn because it fixed global collapse in the current ResEnc setup.

### 3.4 Optional MAE/S3D Auxiliary

MAE reconstruction should be demoted to an auxiliary, not the central claim.

```text
L_dense_aux = masked voxel or feature reconstruction
```

Use only if it improves segmentation transfer or stabilizes local representations.

### 3.5 Final Loss

Initial recommended objective:

```text
L = L_local_jepa
  + w_mod   * L_modality_consistency
  + w_global * L_global_infonce
  + w_var   * L_variance_covariance
  + w_aux   * L_s3d_or_mae_aux
  + w_koleo * L_koleo
```

Start weights:

```text
w_mod    = 0.25
w_global = 0.5
w_var    = 1.0
w_aux    = 0.0 for first pilot, then 0.25 ablation
w_koleo  = existing stable value from v1 if compatible
```

## 4. Data and Preprocessing Plan

### 4.1 Dataset Tiers

Use tiers so scaling law and data quality claims are defensible.

| Tier | Data | Purpose |
|---|---|---|
| D0 | 1k smoke subset | loader, collapse, speed |
| D1 | 10k balanced subset | objective sanity, ablation |
| D2 | 50k curated subset | first real pretraining |
| D3 | 200k/300k full corpus | scaling law and final model |

If the final usable corpus is called FOMO200K rather than FOMO300K, the paper should report the exact post-QC number, not the raw collection size.

### 4.2 Required Metadata

Minimum manifest columns:

```text
subject_id
session_id
path
modality
source/cohort
site/scanner if available
spacing
shape
orientation
preprocess_version
qc_flag
```

If scanner/site metadata is missing in the pretraining corpus, use source/cohort as a proxy only for sampling. Do not claim scanner invariance from proxy alone.

### 4.3 Preprocessing

Default:

```text
crop_to_nonzero
RAS orientation
volume-wise z-normalization or robust percentile normalization
1mm isotropic for v1-compatible warm start
```

Add robustness augmentations:

- intensity shift/scale/gamma
- bias field
- noise/blur
- resolution/FOV jitter
- anisotropic downsample-upsample simulation
- random crop with anatomy-stratified target blocks

## 5. Anatomy Prior Construction

Use anatomy priors in increasing strength.

### A0: No Atlas, Geometry-Only

Baseline.

```text
random 3D blocks + distributed context
```

### A1: Template Coordinate / Hemisphere / Tissue-Aware Sampling

Low-risk first anatomy prior.

```text
target blocks stratified by coarse coordinate, hemisphere, tissue-like intensity cluster
```

Avoid explicit template class prediction at this stage.

### A2: Atlas/ROI-Aware Sampling

Use atlas or pseudo-segmentation labels only to choose target regions and balance sampling.

```text
sample target blocks from ROI groups
predict latent target, not ROI class
```

### A3: ROI Relation Prediction Auxiliary

Optional and risky. Predict weak relation labels such as:

- same/different hemisphere homolog
- adjacent vs distant ROI
- cortical vs subcortical context

This should be ablated carefully because it can become registration shortcut learning.

## 6. Training Stages

### Stage 0: Code Readiness

Deliverables:

- real dataset loader
- multi-modal batch sampler
- missing modality handling
- train script
- config system
- checkpoint save/resume
- AMP/bf16
- EMA schedule
- tensorboard/jsonl logging
- collapse diagnostics

Pass criteria:

```text
unit tests pass
synthetic smoke pass
real 8-subject smoke pass
loss finite for 500 steps
target encoder receives no gradient
feature variance does not collapse
```

### Stage 1: 1-GPU Pilot

Purpose: verify objective behavior, not final performance.

Config:

```text
data: D0 1k
crop: 96^3
batch: hardware-dependent
steps: 5k
backbone: small ResEnc
modalities: T1 + FLAIR first
objective: L_local_jepa + L_global_infonce + L_var
```

Stop if:

- feature std collapses
- effective rank drops below threshold
- global branch becomes constant
- target/context loss trivially goes to zero without useful variance

### Stage 2: 2-GPU / 4-GPU Ablation

Purpose: choose objective composition.

Core ablations:

| ID | Objective | Question |
|---|---|---|
| B0 | current v1 S3D+InfoNCE | baseline |
| B1 | JEPA only | can latent prediction learn useful local/global features? |
| B2 | JEPA + InfoNCE | does global branch prevent collapse and help cls/reg? |
| B3 | JEPA + modality consistency | does multimodal latent alignment help? |
| B4 | JEPA + anatomy-aware sampling | does brain prior improve seg transfer? |
| B5 | JEPA + S3D auxiliary | does reconstruction still help local seg? |

Evaluation after each:

- frozen global probe: brain age, infarct, polymicro with random baseline
- frozen/local seg probe: Task2/4 or external non-challenge data
- collapse diagnostics: std, covariance, rank
- site/source prediction probe: shortcut size

### Stage 3: Full Foundation Pretraining

Recommended initial full run:

```text
model: ResEnc-L or ResEnc-M depending memory
init: scratch and v1-warm-start as two arms
data: D2 50k first
steps: 150k
crop: 96^3
modalities: available T1/FLAIR/DWI/ADC groups
loss: B4 or B5 winner
precision: bf16
EMA: cosine or fixed 0.996 -> 0.9999
logging: every 100 steps
checkpoint: every 5k steps
eval: every 25k steps
```

Then scale:

```text
D3 full corpus
steps: 300k+
compare data size: 10k / 50k / 100k / full
compare data quality: raw-QC vs curated-QC
```

## 7. Downstream Benchmark Design

Challenge data alone is too small and attempt-limited. Use non-challenge held-out consortium data for the paper benchmark.

Required benchmark splits:

```text
site-held-out
scanner-held-out if metadata exists
cohort-held-out
within-cohort brain age
low-label segmentation N-shot curves
```

Report all performance as:

```text
absolute metric
delta over scratch
delta over random encoder
bootstrap CI
site/source shortcut probe
orthogonalized-site probe if needed
```

Primary downstream tasks:

- brain age regression
- disease classification
- tissue/ROI segmentation
- lesion segmentation if available
- scanner/site invariance or fairness probe

## 8. Scaling Law / Data Quality Ablation

This is essential for novelty beyond "we trained another SSL model".

### Data Scale

```text
N = 10k, 50k, 100k, full
```

Measure:

- global probe slope
- segmentation transfer slope
- collapse robustness
- site leakage slope

### Data Quality

Compare:

- all data
- QC-filtered data
- balanced-by-source data
- balanced-by-modality data
- high-resolution only vs mixed-resolution

Key question:

```text
Does more data help, or does poor-quality/protocol-confounded data hurt?
```

## 9. Success Criteria

Minimum publishable signal:

```text
BAM-JEPA > current v1 on at least one global task and one dense/local task
with CI excluding zero over random/scratch baselines.
```

Stronger AAAI-style signal:

```text
anatomy-aware sampling improves segmentation/local transfer
modality-aware latent consistency improves cross-sequence generalization
site-held-out performance remains positive after shortcut controls
scaling law shows predictable gains or clear data-quality law
```

Failure criteria:

- JEPA learns only site/source/protocol shortcuts.
- anatomy prior helps in same-site but fails site-held-out.
- modality consistency erases pathology-sensitive contrast.
- segmentation transfer is worse than current S3D+InfoNCE v1.

If failure occurs, the paper can still be reframed as:

```text
When and why anatomy-aware latent prediction fails under real multi-site brain MRI confounding.
```

## 10. Immediate Engineering TODO

Before any full training:

- [ ] Implement real FOMO `.npy` / NIfTI manifest loader.
- [ ] Implement modality-aware sampler.
- [ ] Add missing-modality masking and modality tokens.
- [ ] Add anatomy-aware target sampler A0/A1 first.
- [ ] Write `train_brain_jepa.py`.
- [ ] Add checkpoint save/resume with strict config manifest.
- [ ] Add collapse diagnostics JSONL logger.
- [ ] Add v1 warm-start loader for ResEnc-compatible weights.
- [ ] Run synthetic smoke.
- [ ] Run 8-subject real smoke.
- [ ] Run 1k-subject 5k-step pilot.

## 11. Positioning

Do not claim:

```text
We apply VoCo to brain MRI.
```

Claim:

```text
We design an anatomy- and modality-aware SSL framework for large-scale 3D brain MRI foundation modeling, using brain-specific context prediction and evaluating under site/scanner-held-out transfer.
```

This is more defensible because the novelty is the brain-MRI-specific objective and evaluation, not transplantation of a CT objective.
