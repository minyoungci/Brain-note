# 3D Brain Representation Learning Root-Cause Plan

Updated: 2026-05-21

## Primary goal

The top-level objective is **3D brain representation learning**, not maximizing a short-term CN/MCI/AD classifier. CN/MCI/AD is a downstream probe used to test whether the representation captures disease-relevant neuroanatomical structure.

## Collected evidence

Machine-readable collection:

```text
/home/vlm/minyoungi/experiments/roi_to_image_distill_v0/REPRESENTATION_FAILURES_COLLECTED_V0.json
```

Existing ROI/bias audits:

```text
/home/vlm/minyoungi/experiments/roi_to_image_distill_v0/ROI_BIAS_DIRECTIONALITY_AUDIT_V0.json
/home/vlm/minyoungi/experiments/roi_to_image_distill_v0/ROI_SOURCE_PATH_AUDIT_SAMPLE.json
/home/vlm/minyoungi/experiments/roi_to_image_distill_v0/roi_overlay_qc_sample/
/home/vlm/minyoungi/experiments/roi_to_image_distill_v0/REPRESENTATION_FAILURE_DIAGNOSTIC_ROI_CEILING.json
```

## Failure summary so far

### 1. Image-only CNN baseline

3 seeds, 80/class diagnostic runs:

```text
mean balanced accuracy ≈ 0.4028
mean macro F1          ≈ 0.3429
failure mode: CN collapse / MCI or AD overprediction
```

Evidence: seed 20260522 and 20260523 predicted no CN at all.

### 2. CNN ROI-distill v0

```text
internal_test balanced accuracy = 0.4458
macro F1                       = 0.4432
CN/MCI/AD recall                = 0.4000 / 0.3625 / 0.5750
```

Improved CN collapse and macro F1, but ROI imitation was unstable in last-epoch evaluation.

### 3. ViT + GroupNorm + SmoothL1/Corr/RKD

```text
ROI imitation improved:
  roi_z_mae = 0.7323
  status_macro_f1 = 0.4546

Frozen diagnosis probe did not improve:
  balanced accuracy = 0.3917
  macro F1 = 0.3913
  CN/MCI/AD recall = 0.4875 / 0.3625 / 0.3250
```

Interpretation: ROI head can learn targets, but embedding geometry does not automatically become diagnosis-relevant.

### 4. Teacher-latent ViT

Teacher input: ROI z/status + age + sex. Student input: image + brain mask only.

```text
teacher internal_test balanced accuracy = 0.5292
student frozen probe balanced accuracy  = 0.4208
student frozen macro F1                 = 0.4226
CN/MCI/AD recall                         = 0.5125 / 0.3375 / 0.4125
```

Interpretation: teacher-latent objective helps relative to pure ViT ROI-distill, but small ViT still does not absorb teacher geometry fully.

## Current root-cause hypotheses

### H1. ROI teacher is weak/miscalibrated, not necessarily wrong

Evidence for not-garbage:

```text
16/16 ROI directionality checks match expected AD anatomy.
ROI z-only probe bal_acc ≈ 0.5292.
FastSurfer native overlay sample: no gross off-brain misregistration in inspected cases.
```

Evidence for weak/miscalibrated:

```text
MaskVol proxy, not eTIV/ICV.
Volume-only; no cortical thickness.
Reference is mixed train, not CN-only normative.
Only 6-case gross overlay QC so far.
Cohort/scanner effects are nonzero.
Race/ethnicity unavailable in current manifest.
```

Resolution path:

1. Build ROI teacher variants:
   - current raw ROI v0
   - CN-only age/sex residual z
   - ComBat(batch=cohort, covariates=age+sex)
   - ComBat + CN-only normative z
2. Compare disease directionality, ROI-only probe, cohort/scanner prediction, and MCI placement.
3. Expand overlay QC to cohort × diagnosis samples.

### H2. Cohort/scanner/domain bias contaminates ROI and image representations

Evidence:

```text
scanner and field_strength are missing for entire KDRC/OASIS and partially missing elsewhere.
scanner is strongly cohort-confounded.
cohort diagnosis distribution is imbalanced: AJU mostly MCI; OASIS mostly CN; etc.
```

Resolution path:

1. Use ComBat as an audit/harmonization branch, not blindly as final truth.
2. Batch candidate: cohort first; scanner-only is unsafe globally because of missing/confounding.
3. Preserve only age/sex covariates initially; do not preserve diagnosis in the primary unsupervised/teacher artifact.
4. Add cohort-held-out and per-cohort recall gates.

### H3. Student architecture/objective mismatch

Evidence:

```text
ViT learned ROI imitation but not diagnosis-relevant frozen embedding.
Teacher-latent ViT improved but still below CNN ROI-distill v0 and below teacher ceiling.
```

Resolution path:

1. Test CNN/hybrid Conv-stem student with teacher-latent loss.
2. Compare CLS/embedding probe vs predicted ROI probe vs teacher latent probe.
3. Do not proceed to VLM until image encoder passes representation gates.

### H4. MCI label heterogeneity is a real ceiling

Evidence:

```text
ROI teacher itself has low MCI recall (~0.275–0.325).
MCI is clinically heterogeneous and may not form one separable class from T1 morphology alone.
```

Resolution path:

1. Treat CN/AD disease axis separately from hard 3-class classification.
2. Evaluate MCI projection along CN→AD axis and uncertainty rather than only recall.
3. If PET/ATN/progression labels become available, use them for MCI subgroup validation.

### H5. Direct ROI-space alignment to final_tensor is not yet verified

Evidence:

```text
FastSurfer native: 256x256x256, native/conformed affine.
Student final_tensor: 192x224x192, identity affine RAS tensor.
```

Scalar ROI values are okay for current teacher, but voxel-wise ROI masks/crops need transform validation.

Resolution path:

1. Do not use voxel-wise ROI supervision until transform is verified.
2. For direct registration QC, resample FastSurfer masks to final_tensor and create overlays.
3. Compare scalar volume derived from native mask vs resampled mask as a sanity check.

## Gates before full VLM training

### Gate A: ROI teacher validity

Must pass:

```text
AD directionality preserved across ROI variants.
Cohort/scanner prediction reduced after harmonization.
ROI-only probe does not collapse after ComBat/CN-normative z.
Expanded overlay QC has no systematic gross failures.
```

### Gate B: Image representation validity

Must pass:

```text
Frozen probe balanced accuracy >= ROI teacher ceiling - acceptable gap, target initially >= 0.48.
Macro F1 >= 0.45 initially, then >= 0.50.
No class recall collapse: CN/AD recall >= 0.45; MCI evaluated also by disease-axis placement.
3-seed stability.
Per-cohort recall reported.
```

### Gate C: VLM readiness

Only after A and B:

```text
Run small frozen-image ROI-caption retrieval smoke.
No full VLM claim until image encoder representation gate is met.
```

## Immediate execution order

1. Build ROI harmonization audit artifacts: raw vs CN-normative vs ComBat vs ComBat+CN-normative.
2. Expand ROI overlay QC to 54 cases: 6 cohorts × 3 labels × 3 samples.
3. Implement final_tensor-space ROI mask resampling QC on a small subset.
4. Select the best ROI teacher artifact by disease signal retained and cohort/scanner bias reduced.
5. Train CNN/hybrid Conv-stem teacher-latent student on the selected teacher.
6. Run 3-seed stability and per-cohort audit.

## 2026-05-21 Latest ROI harmonization/QC audit update

Policy: keep this as the single rolling failure/root-cause document; avoid scattering many result notes. Latest machine-readable audit is overwritten at:

```text
/home/vlm/minyoungi/experiments/roi_to_image_distill_v0/REPRESENTATION_ROOT_CAUSE_LATEST_AUDIT.json
/home/vlm/minyoungi/experiments/roi_to_image_distill_v0/REPRESENTATION_ROOT_CAUSE_OVERLAY_CONTACT_SHEET.png
```

### Audit design

- Complete-case rows: `11199`
- ROI features: 16 AD-relevant FastSurfer volume ROIs
- ComBat: `batch=cohort`, preserved covariates `age + sex`, diagnosis not preserved.
- Scanner was not used as global batch because scanner/field-strength missingness is cohort-confounded, especially KDRC/OASIS.

### Variant comparison

- `current_mixed_train_maskvol_z`
  - directionality: 16/16 expected AD-anatomy direction
  - diagnosis probe internal_test: bal_acc=0.5193, macro_f1=0.4847, recalls={'CN': 0.6066666666666667, 'MCI': 0.3385416666666667, 'AD': 0.6127450980392157}
  - cohort probe internal_test: bal_acc=0.3772, macro_f1=0.3175
  - mean R2: cohort=0.0185, scanner=0.0150, diagnosis=0.1188
- `cn_age_sex_residual_z`
  - directionality: 16/16 expected AD-anatomy direction
  - diagnosis probe internal_test: bal_acc=0.5558, macro_f1=0.5172, recalls={'CN': 0.6411111111111111, 'MCI': 0.3645833333333333, 'AD': 0.6617647058823529}
  - cohort probe internal_test: bal_acc=0.3567, macro_f1=0.2987
  - mean R2: cohort=0.0237, scanner=0.0189, diagnosis=0.1132
- `combat_cohort_age_sex_then_train_z`
  - directionality: 16/16 expected AD-anatomy direction
  - diagnosis probe internal_test: bal_acc=0.4947, macro_f1=0.4476, recalls={'CN': 0.6133333333333333, 'MCI': 0.21875, 'AD': 0.6519607843137255}
  - cohort probe internal_test: bal_acc=0.1575, macro_f1=0.1486
  - mean R2: cohort=0.0041, scanner=0.0059, diagnosis=0.1059
- `combat_then_cn_age_sex_residual_z`
  - directionality: 16/16 expected AD-anatomy direction
  - diagnosis probe internal_test: bal_acc=0.5063, macro_f1=0.4617, recalls={'CN': 0.6133333333333333, 'MCI': 0.2534722222222222, 'AD': 0.6519607843137255}
  - cohort probe internal_test: bal_acc=0.1366, macro_f1=0.1264
  - mean R2: cohort=0.0001, scanner=0.0053, diagnosis=0.1002

### Immediate interpretation

1. ROI directionality is robust: all four variants preserve 16/16 expected AD-anatomy directions.
2. CN-only age/sex residual z gives the best current diagnosis probe (`bal_acc≈0.556`) but does not reduce cohort R2; it may improve normative calibration but not harmonization.
3. ComBat variants strongly reduce cohort predictability (`cohort probe bal_acc≈0.158` and `0.137`, near/below 6-cohort chance level) and reduce mean cohort R2, but also reduce diagnosis probe (`bal_acc≈0.495–0.506`).
4. This means ComBat is useful as a bias-reduction branch, but it may remove some disease-correlated between-cohort signal. We should not blindly make it the only teacher until per-cohort/held-out behavior is checked.
5. Current best candidate for representation teacher comparison is therefore two-branch: `cn_age_sex_residual_z` for signal strength vs `combat_then_cn_age_sex_residual_z` for bias-reduced robustness.

### Overlay QC update

- Rendered a single 54-case FastSurfer native-space contact sheet: 6 cohorts × CN/MCI/AD × 3 samples where available.
- Gross visual check: no obvious off-brain ROI or global misregistration on the contact sheet.
- Limitation: this is low-resolution gross QC only; not sufficient for fine hippocampus/entorhinal boundary QC.
- Still unresolved: FastSurfer native-space ROI to `final_tensor` 192×224×192 space transform/resampling QC.

### Updated next steps

1. Do not run full VLM yet.
2. Implement final_tensor-space ROI resampling QC as a minimal single-contact-sheet check.
3. Train/evaluate CNN-or-hybrid teacher-latent student twice: once with `cn_age_sex_residual_z`, once with `combat_then_cn_age_sex_residual_z`.
4. Select teacher by representation gates: frozen probe, per-cohort recall, seed stability, and reduced cohort predictability.

## Failure-localized execution protocol v1

목표: **3D brain representation learning**을 단계별로 복구한다. 각 단계는 성공/실패 gate를 갖고, 실패 시 원인 위치와 다음 조치를 명확히 한다. 산출물은 계속 최소화한다.

### Artifact policy

- Rolling plan/report는 이 문서 하나를 계속 업데이트한다.
- Latest audit JSON은 덮어쓴다: `/home/vlm/minyoungi/experiments/roi_to_image_distill_v0/REPRESENTATION_ROOT_CAUSE_LATEST_AUDIT.json`
- Latest overlay/contact sheet는 덮어쓴다: `/home/vlm/minyoungi/experiments/roi_to_image_distill_v0/REPRESENTATION_ROOT_CAUSE_OVERLAY_CONTACT_SHEET.png`
- 모델 학습 run은 비교에 필요한 최소 2-branch × controlled seed부터 시작하고, 실패 run은 요약만 이 문서에 남긴다.

---

## Stage 0. Fixed evaluation contract

### Purpose

이후 모든 실험이 같은 기준으로 비교되도록 evaluation contract를 고정한다.

### Inputs

- Manifest: `vlm_ready_manifest_v2_integrated_oasis_included_v0.csv`
- Split: existing `train / val / internal_test`
- Labels: `CN / MCI / AD`
- Primary representation metric: frozen embedding probe, not training head accuracy.

### Required metrics

Every representation run must report:

```text
1. Frozen probe: bal_acc, macro_f1, per-class recall
2. Student direct head/logit performance if available
3. ROI/teacher reconstruction/alignment metrics
4. Cohort probe from frozen embedding
5. Per-cohort CN/MCI/AD recall
6. 3-seed stability once a candidate passes single-seed gate
```

### Failure localization

- If frozen probe poor but direct head good: embedding/head decoupling.
- If both poor but teacher strong: student architecture/objective failure.
- If teacher poor: ROI/teacher validity failure.
- If diagnosis good but cohort probe high: shortcut/domain bias failure.

---

## Stage 1. ROI teacher validity and harmonization

### Variants to maintain

Use exactly two active teacher branches after audit:

```text
T1_signal = cn_age_sex_residual_z
T2_bias_reduced = combat_then_cn_age_sex_residual_z
```

Rationale:

- `T1_signal` currently has strongest ROI-only diagnosis probe.
- `T2_bias_reduced` most strongly reduces cohort predictability.

### Gate 1A. Anatomy directionality

Pass if:

```text
>= 15/16 ROIs preserve expected AD direction.
Critical ROIs must pass:
  hippocampus ↓ in AD
  entorhinal ↓ in AD
  lateral/3rd ventricle ↑ in AD
```

Fail means:

```text
ROI normalization/harmonization is invalid.
```

Next action if fail:

```text
1. Inspect per-ROI distributions by cohort and diagnosis.
2. Remove failing ROI from teacher candidate.
3. Recompute z using train-CN reference only.
4. If multiple critical ROIs fail, stop representation training and fix ROI extraction/QC.
```

### Gate 1B. Teacher signal

Pass target:

```text
ROI-only internal_test bal_acc >= 0.50
CN recall >= 0.55
AD recall >= 0.55
MCI recall can be lower but should not collapse below 0.20
```

Fail means:

```text
Teacher cannot support disease-relevant representation beyond weak morphology.
```

Next action if fail:

```text
1. Add/locate better features: cortical thickness, eTIV/ICV, hippocampal subfields, whole-brain GM/WM/ventricle volumes.
2. Treat MCI as axis/uncertainty instead of hard class.
3. Do not train VLM/large student on this teacher.
```

### Gate 1C. Bias reduction

Pass for bias-reduced branch if:

```text
cohort probe bal_acc substantially decreases vs current ROI v0
mean R2_cohort decreases
AD directionality remains intact
diagnosis probe does not drop below chance-like range
```

Fail means:

```text
ComBat design is either insufficient or removes too much disease signal.
```

Next action if fail:

```text
1. Try mean-only ComBat.
2. Try cohort-batch only on train-fitted parameters if transformation procedure supports it.
3. Try site/scanner subset analysis where scanner is available.
4. Keep T1_signal as main teacher but require stronger per-cohort evaluation.
```

---

## Stage 2. ROI spatial QC and final_tensor-space verification

### Purpose

Scalar ROI teacher can proceed with native-space QC, but voxel-wise ROI supervision/crops require final_tensor-space verification.

### Gate 2A. FastSurfer native-space gross QC

Already partially passed:

```text
54-case contact sheet, no obvious gross off-brain/misregistration.
```

Remaining limitation:

```text
Fine hippocampus/entorhinal boundary QC is not proven.
```

### Gate 2B. final_tensor-space resampling QC

Required next check:

```text
FastSurfer ROI mask -> final_tensor 192x224x192 space
Generate one overwritten contact sheet.
Compare native ROI volume vs resampled ROI volume.
```

Pass if:

```text
1. No gross off-brain/misaligned labels in contact sheet.
2. Median relative volume error is reasonable after resampling.
3. No cohort-specific transform failure.
```

Fail means:

```text
The FastSurfer-to-final_tensor transform/resampling path is invalid.
```

Next action if fail:

```text
1. Do not use voxel-wise ROI masks/crops/losses.
2. Continue only scalar ROI teacher branch.
3. Recover original transform chain from preprocessing logs before any mask-guided learning.
```

---

## Stage 3. Student architecture/objective ablation

### Candidates

Do not jump to full VLM. Test two student configurations first:

```text
S1_CNN_or_ResNet3D
S2_Hybrid_ConvStem_Transformer
```

Use the same teacher-latent objective for both:

```text
L = teacher embedding alignment
  + teacher logit KL
  + auxiliary ROI reconstruction
```

Run first on one seed and controlled sample size. Only expand if gate passes.

### Branches

For each student:

```text
teacher = T1_signal
teacher = T2_bias_reduced
```

Minimal matrix:

```text
S1_CNN × T1_signal
S1_CNN × T2_bias_reduced
S2_Hybrid × T1_signal
S2_Hybrid × T2_bias_reduced
```

If compute/time must be minimized, start with:

```text
S1_CNN × T1_signal
S1_CNN × T2_bias_reduced
```

### Gate 3A. Teacher absorption

Pass if student frozen embedding approaches teacher ceiling:

```text
initial target: frozen bal_acc >= 0.48
macro_f1 >= 0.45
CN recall >= 0.45
AD recall >= 0.45
MCI evaluated separately by axis/uncertainty
```

Fail pattern A:

```text
Teacher strong, student frozen poor, student direct head decent.
```

Diagnosis:

```text
Embedding/head decoupling.
```

Next action:

```text
1. Apply probe directly on pre-head and pooled feature variants.
2. Add supervised contrastive/metric loss on teacher latent, not only head output.
3. Remove overly expressive prediction head that bypasses representation.
4. Add projector-head separation: train projector, evaluate backbone embedding.
```

Fail pattern B:

```text
Teacher strong, student frozen poor, direct head poor.
```

Diagnosis:

```text
Architecture/capacity/optimization failure.
```

Next action:

```text
1. Switch ViT -> CNN/hybrid if not already.
2. Increase resolution or use multi-scale crops only after spatial QC passes.
3. Check train loss convergence and batch size/learning rate.
4. Run tiny overfit test on 12–24 subjects; if cannot overfit, implementation bug or input issue.
```

Fail pattern C:

```text
Student works on T1_signal but fails on T2_bias_reduced.
```

Diagnosis:

```text
ComBat branch may have removed useful disease structure or made target too weak.
```

Next action:

```text
1. Keep T1 for representation learning.
2. Use T2 as bias audit / regularizer, not sole target.
3. Consider dual-objective: signal teacher + adversarial/cohort-invariant penalty.
```

Fail pattern D:

```text
Student works on T2_bias_reduced but not T1_signal.
```

Diagnosis:

```text
T1 may be too cohort/shortcut contaminated.
```

Next action:

```text
1. Prioritize T2.
2. Evaluate per-cohort and cohort-held-out behavior.
```

---

## Stage 4. Bias and generalization audit of candidate embeddings

### Gate 4A. Cohort predictability

Pass if:

```text
cohort probe from frozen embedding decreases vs image-only/CNN baseline
without collapsing diagnosis probe.
```

Fail means:

```text
Representation is encoding cohort/scanner shortcut.
```

Next action:

```text
1. Add cohort-balanced sampler.
2. Add domain-adversarial penalty only after baseline is stable.
3. Use T2_bias_reduced or dual-teacher objective.
4. Report per-cohort performance before any paper claim.
```

### Gate 4B. Per-cohort class recall

Pass if:

```text
No single large cohort has complete CN or AD collapse.
MCI failure is characterized as CN-like/AD-like projection, not hidden.
```

Fail means:

```text
Apparent performance is from cohort composition or label distribution.
```

Next action:

```text
1. Rebalance by cohort×label.
2. Evaluate leave-one-cohort-out if sample count allows.
3. Keep claim limited to internal representation smoke.
```

---

## Stage 5. Seed stability

Only run after a single-seed candidate passes Stage 3/4.

Pass if over 3 seeds:

```text
bal_acc std reasonably small
no repeated class collapse
macro_f1 direction stable
per-cohort failure modes consistent/explained
```

Fail means:

```text
Representation objective is unstable under current data/architecture.
```

Next action:

```text
1. Reduce objective complexity.
2. Increase batch balance and regularization.
3. Prefer simpler CNN/hybrid over pure ViT.
4. Do not proceed to VLM.
```

---

## Stage 6. VLM readiness gate

Full VLM is allowed only if:

```text
1. ROI teacher validity passes.
2. Spatial QC passes for any mask-based component.
3. Student frozen embedding passes representation gate.
4. Cohort/generalization audit is reported.
5. 3-seed stability is acceptable.
```

If not, only small VLM pipeline smoke is allowed:

```text
frozen image encoder + ROI caption retrieval smoke
No performance claim.
```

---

## Current immediate next command-level plan

1. Implement final_tensor-space ROI resampling QC with overwritten contact sheet/JSON.
2. If Stage 2B passes, implement CNN teacher-latent student with switchable teacher target:
   - `cn_age_sex_residual_z`
   - `combat_then_cn_age_sex_residual_z`
3. Run controlled single-seed S1_CNN × T1/T2.
4. Update this document only with results and failure localization.

## 2026-05-21 Stage 2B final_tensor-space ROI resampling QC

Artifacts kept minimal/overwritten:

```text
/home/vlm/minyoungi/experiments/roi_to_image_distill_v0/REPRESENTATION_ROOT_CAUSE_FINAL_TENSOR_QC.json
/home/vlm/minyoungi/experiments/roi_to_image_distill_v0/REPRESENTATION_ROOT_CAUSE_FINAL_TENSOR_QC_CONTACT_SHEET.png
```

### Test performed

FastSurfer native AD-relevant ROI mask was resampled to student `final_tensor` space using available NIfTI world affines only.

### Result

```text
n_cases = 54
n_ok = 54
n_resampled_nonzero = 52
nonzero_rate = 0.963
median_relative_volume_error = -0.892
p10/p90_relative_volume_error = -0.961 / -0.766
min/max_relative_volume_error = -1.000 / -0.674
```

### Visual interpretation

Contact sheet shows ROI edges are mostly tiny, partial, near image boundaries, or inconsistent with full anatomical ROI coverage. Volume retention is poor: median resampled volume is about 11% of native ROI volume.

### Gate decision

**Stage 2B fails for affine-only native FastSurfer -> final_tensor mask transfer.**

This does **not** invalidate scalar FastSurfer ROI features or scalar ROI teacher branches. It does invalidate any voxel-wise ROI crop/mask/supervision that assumes native FastSurfer masks can be mapped to `final_tensor` using only stored NIfTI affines.

### Failure localization

```text
Failure location: spatial transform / final_tensor-space ROI mask alignment.
Not teacher scalar validity.
Not student architecture yet.
```

### Action

1. Do not use voxel-wise ROI masks/crops/losses yet.
2. Continue next representation experiment with scalar teacher only.
3. If voxel-wise ROI supervision becomes necessary, recover preprocessing transform chain or regenerate ROI masks directly in final_tensor space.

## 2026-05-21 Stage 3 initial CNN teacher-latent T1/T2 controlled run

Artifact kept minimal/overwritten:

```text
/home/vlm/minyoungi/experiments/roi_to_image_distill_v0/REPRESENTATION_ROOT_CAUSE_CNN_TEACHER_LATEST.json
```

### Run setup

```text
student = small 3D CNN + GroupNorm + global average pooling
input = final_tensor T1w image only
sample = 80/class train, 80/class val, 80/class internal_test
epochs = 5
teacher_epochs = 150
teacher branches:
  T1 = CN-only age/sex residual z
  T2 = ComBat(cohort, preserve age+sex) then CN-only age/sex residual z
```

### T1_signal result

```text
teacher internal_test:
  bal_acc = 0.5458
  macro_f1 = 0.5459
  recalls CN/MCI/AD = 0.6125 / 0.4000 / 0.6250

student direct head internal_test:
  bal_acc = 0.3333
  macro_f1 = 0.1667
  recalls CN/MCI/AD = 0.0000 / 1.0000 / 0.0000

frozen embedding internal_test:
  bal_acc = 0.4417
  macro_f1 = 0.3652
  recalls CN/MCI/AD = 0.5750 / 0.0250 / 0.7250
  cohort_probe_bal_acc = 0.1979
```

### T2_bias_reduced result

```text
teacher internal_test:
  bal_acc = 0.4875
  macro_f1 = 0.4812
  recalls CN/MCI/AD = 0.5875 / 0.2750 / 0.6000

student direct head internal_test:
  bal_acc = 0.3333
  macro_f1 = 0.1667
  recalls CN/MCI/AD = 0.0000 / 1.0000 / 0.0000

frozen embedding internal_test:
  bal_acc = 0.4042
  macro_f1 = 0.3816
  recalls CN/MCI/AD = 0.3500 / 0.2000 / 0.6625
  cohort_probe_bal_acc = 0.2167
```

### Gate decision

**Stage 3 initial CNN teacher-latent fails representation gate.**

Reasons:

1. Frozen embedding does not reach initial target `bal_acc >= 0.48` and `macro_f1 >= 0.45`.
2. T1 frozen embedding preserves CN/AD partly but MCI collapses almost completely (`MCI recall=0.025`).
3. Student direct diagnosis head collapses to MCI for both T1 and T2 (`bal_acc=0.333`, `macro_f1=0.167`), despite teacher signal being nontrivial.
4. Cohort probe is low (~0.20), so the dominant failure is not obvious cohort shortcut in this run.

### Failure localization

```text
Failure location: student objective/optimization + MCI geometry.
Teacher T1 is strong enough for a target (bal_acc≈0.546), but the CNN student does not absorb teacher logits/latent into a useful frozen representation.
Spatial mask failure is separate and only blocks voxel-wise ROI use.
```

### Next action before any more large run

Run a tiny overfit/implementation diagnostic:

```text
T1_signal only
12–24 subjects/class
more epochs
check whether student direct head and frozen embedding can overfit train
```

Interpretation:

- If tiny overfit fails: implementation/objective/optimization bug. Fix loss scaling, add hard teacher CE, simplify head, inspect gradients.
- If tiny overfit succeeds but validation fails: generalization/data/architecture problem. Then try hybrid Conv-stem, stronger augmentation/balance, and MCI axis formulation.
- If direct head remains collapsed while frozen improves: head/KL objective issue. Add teacher hard-label CE or true-label auxiliary CE for diagnostic only.

## 2026-05-21 Stage 4A tiny overfit diagnostic

Artifact kept minimal/overwritten:

```text
/home/vlm/minyoungi/experiments/roi_to_image_distill_v0/REPRESENTATION_ROOT_CAUSE_TINY_OVERFIT_LATEST.json
```

### Run setup

```text
teacher = T1_signal only
tiny_train = 12/class from train split
probe_train80 = 80/class from train split, not held-out; used only to see whether tiny-learned rule generalizes inside train distribution
student = same small 3D CNN
input = final_tensor T1w image only
shape = 48x56x48
epochs = 40
```

Teacher sanity:

```text
teacher tiny_train: bal_acc=1.0000, macro_f1=1.0000
teacher probe_train80: bal_acc=0.4792, macro_f1=0.4691, recalls CN/MCI/AD=0.5000/0.2750/0.6625
```

### Variant results

### full

```text
tiny direct: bal_acc=0.4167, macro_f1=0.3183, recalls CN/MCI/AD=0.0000/0.3333/0.9167, pred_dist={'CN': 0, 'MCI': 14, 'AD': 22}
tiny frozen: bal_acc=0.5278, macro_f1=0.4642, recalls CN/MCI/AD=0.8333/0.0833/0.6667
probe80 direct: bal_acc=0.3083, macro_f1=0.2302, pred_dist={'CN': 0, 'MCI': 78, 'AD': 162}
loss first->last: emb 0.594->0.364, kl 3.774->3.676, roi 0.603->0.531, teacher_ce 1.157->1.072, total 4.519->4.172
```

### no_roi

```text
tiny direct: bal_acc=0.4722, macro_f1=0.3804, recalls CN/MCI/AD=0.0000/0.5833/0.8333, pred_dist={'CN': 0, 'MCI': 19, 'AD': 17}
tiny frozen: bal_acc=0.4722, macro_f1=0.3945, recalls CN/MCI/AD=0.8333/0.0000/0.5833
probe80 direct: bal_acc=0.3292, macro_f1=0.2652, pred_dist={'CN': 0, 'MCI': 128, 'AD': 112}
loss first->last: emb 0.598->0.350, kl 3.776->3.680, roi 0.612->0.597, teacher_ce 1.160->1.074, total 4.374->4.030
```

### teacher_ce

```text
tiny direct: bal_acc=0.6389, macro_f1=0.6420, recalls CN/MCI/AD=0.7500/0.5833/0.5833, pred_dist={'CN': 11, 'MCI': 12, 'AD': 13}
tiny frozen: bal_acc=0.5833, macro_f1=0.5651, recalls CN/MCI/AD=0.8333/0.3333/0.5833
probe80 direct: bal_acc=0.3333, macro_f1=0.3345, pred_dist={'CN': 78, 'MCI': 105, 'AD': 57}
loss first->last: emb 0.673->0.700, kl 3.789->3.372, roi 0.615->0.628, teacher_ce 1.172->0.955, total 4.960->4.327
```

### true_ce_diag

```text
tiny direct: bal_acc=0.3333, macro_f1=0.1667, recalls CN/MCI/AD=0.0000/1.0000/0.0000, pred_dist={'CN': 0, 'MCI': 36, 'AD': 0}
tiny frozen: bal_acc=0.5833, macro_f1=0.5317, recalls CN/MCI/AD=0.8333/0.1667/0.7500
probe80 direct: bal_acc=0.3333, macro_f1=0.1667, pred_dist={'CN': 0, 'MCI': 240, 'AD': 0}
loss first->last: emb 0.672->0.657, kl 3.769->3.729, roi 0.620->0.639, teacher_ce 1.158->1.099, total 1.158->1.099
```


### Gate decision

**Tiny overfit diagnostic does not pass.**

Even on 12/class:

- `full` and `no_roi` do not memorize the tiny set.
- `teacher_ce` partially learns direct tiny labels (`bal_acc≈0.639`) but still does not overfit.
- `true_ce_diag` stays collapsed to MCI in direct head (`bal_acc=0.333`), even though frozen random/learned features allow some linear separation. This is diagnostic-only but important.

### Failure localization update

```text
Primary failure location: objective/optimization/head-training path.
Secondary issue: MCI geometry remains weak, but not the first thing to fix.
Not yet a generalization failure: the student cannot reliably overfit tiny train.
Not a voxel-wise ROI issue: scalar teacher was used here.
```

Interpretation:

1. The current cosine+KL(+ROI) objective is not forcing the image encoder/head to absorb teacher decision geometry.
2. ROI auxiliary loss is not the main cause: removing ROI (`no_roi`) does not fix overfit.
3. Hard teacher CE helps more than KL/cosine alone, so next objective should include explicit teacher-label or true-label diagnostic CE while debugging.
4. Because true CE alone also collapses, inspect the optimization path before scaling architecture: learning rate, head gradients, class-logit bias, feature variance, and whether the small CNN/global-average bottleneck is too weak for tiny memorization.

### Next immediate diagnostic

Do **not** run a larger representation experiment yet. Run a faster implementation/optimization audit:

```text
1. Head-only overfit on cached image features
   - freeze random/CNN encoder or precompute features
   - train only linear head on tiny set
   - if this fails: feature/head/data-label plumbing bug

2. Full CNN true-label CE overfit with stronger settings
   - tiny 12/class
   - remove grad clipping or raise clip
   - lr sweep: 1e-3, 3e-3, 1e-4
   - record logits mean/std and prediction distribution

3. Teacher CE + KL objective after CE path works
   - use teacher_ce as anchor because it was the only variant with partial direct learning
   - then re-add embedding/ROI losses one by one
```

Pass criterion for next step:

```text
tiny direct bal_acc >= 0.90 on 12/class
no single-class prediction collapse
```

Only after this passes should we return to 80/class representation training.

## 2026-05-21 Stage 4B head/optimization audit

Artifact kept minimal/overwritten:

```text
/home/vlm/minyoungi/experiments/roi_to_image_distill_v0/REPRESENTATION_ROOT_CAUSE_HEAD_OPT_AUDIT_LATEST.json
```

### Purpose

Stage 4A showed the previous small 3D CNN did not overfit 12/class with CE. This audit separates:

```text
label/CE plumbing
raw image tensor separability
frozen GAP-CNN feature separability
end-to-end GAP-CNN optimization
spatial-bottleneck architecture effect
```

Input sanity:

```text
shape = [36, 1, 48, 56, 48]
mean = -0.000015
std = 0.074407
per_sample_std_min/max = 0.068186 / 0.081890
nan_count = 0
```

### Results

```text
row_id_onehot_head:
  bal_acc=1.0000, macro_f1=1.0000, recalls=1.0000/1.0000/1.0000, pred_dist={'CN': 12, 'MCI': 12, 'AD': 12}

raw_image_random_projection_head:
  bal_acc=1.0000, macro_f1=1.0000, recalls=1.0000/1.0000/1.0000, pred_dist={'CN': 12, 'MCI': 12, 'AD': 12}

frozen_random_cnn_gap_head:
  bal_acc=0.6389, macro_f1=0.6397, recalls=0.6667/0.5833/0.6667, pred_dist={'CN': 13, 'MCI': 12, 'AD': 11}

gap_cnn_ce_lr1e-3_clip1:
  bal_acc=0.5556, macro_f1=0.4999, recalls=0.8333/0.0833/0.7500, pred_dist={'CN': 17, 'MCI': 5, 'AD': 14}

gap_cnn_ce_lr1e-3_no_clip:
  bal_acc=0.5278, macro_f1=0.4661, recalls=0.8333/0.0833/0.6667, pred_dist={'CN': 20, 'MCI': 3, 'AD': 13}

gap_cnn_ce_lr3e-3_no_clip:
  bal_acc=0.6111, macro_f1=0.5962, recalls=0.4167/0.5000/0.9167, pred_dist={'CN': 6, 'MCI': 10, 'AD': 20}

gap_cnn_ce_lr1e-4_no_clip:
  bal_acc=0.9722, macro_f1=0.9722, recalls=0.9167/1.0000/1.0000, pred_dist={'CN': 11, 'MCI': 13, 'AD': 12}

flatpool_cnn_ce_lr1e-3:
  bal_acc=1.0000, macro_f1=1.0000, recalls=1.0000/1.0000/1.0000, pred_dist={'CN': 12, 'MCI': 12, 'AD': 12}

flatpool_cnn_ce_lr3e-3:
  bal_acc=1.0000, macro_f1=1.0000, recalls=1.0000/1.0000/1.0000, pred_dist={'CN': 12, 'MCI': 12, 'AD': 12}
```

### Gate decision

**The basic data/label/CE path is valid.**

Evidence:

1. `row_id_onehot_head` memorizes perfectly.
2. `raw_image_random_projection_head` memorizes perfectly.
3. Input tensors have no NaNs and nonzero variance.

**The previous failure is localized to optimization + global-average bottleneck, not broken labels/data.**

Evidence:

1. GAP CNN at lr=1e-3, the previous scale, does not overfit.
2. GAP CNN at lr=1e-4 almost overfits (`bal_acc≈0.972`), so the architecture can learn but is sensitive to LR/optimization.
3. Flatpool CNN, which retains more spatial information before the head, overfits perfectly at lr=1e-3 and 3e-3.

### Updated root cause

```text
Primary root cause: the previous small CNN used too aggressive optimization for a low-dimensional global-average bottleneck. This produced class-collapse and poor teacher absorption.
Secondary architecture issue: global average pooling to 96→64 embedding is a weak bottleneck for memorization/teacher geometry. Retaining coarse spatial layout via adaptive 3x4x3 pooling fixes tiny overfit.
Not root cause: label plumbing, image tensor corruption, CE implementation, scalar ROI teacher validity.
```

### Next controlled step

Return to teacher-latent only after using a student that passes tiny overfit:

```text
student = flatpool CNN or GAP CNN with lr=1e-4
first objective = teacher CE only or teacher CE + KL
then add embedding loss
then add ROI auxiliary last
```

Recommended immediate run:

```text
12/class T1 teacher, flatpool CNN, teacher_CE + KL, 80-120 epochs
Gate: tiny direct bal_acc >= 0.90 and no single-class collapse
```

If it passes, scale carefully:

```text
80/class single-seed flatpool CNN, teacher_CE+KL
then add embedding loss if frozen probe is poor
then compare T1 vs T2
then 3 seeds
```

Do not return to full VLM until this teacher-student path passes.

## 2026-05-21 Stage 4C flatpool teacher-latent rerun

Artifacts kept minimal/overwritten:

```text
/home/vlm/minyoungi/experiments/roi_to_image_distill_v0/REPRESENTATION_ROOT_CAUSE_FLATPOOL_TEACHER_LADDER_LATEST.json
/home/vlm/minyoungi/experiments/roi_to_image_distill_v0/REPRESENTATION_ROOT_CAUSE_FLATPOOL_80CLASS_LATEST.json
```

Note: first 80/class attempt was stopped because uncached image loading was too slow. The script was updated to cache images in memory; no intermediate result was kept.

### Stage 4C-1: 12/class flatpool objective ladder

Setup:

```text
student = flatpool CNN, AdaptiveAvgPool3d(3,4,3)
teacher = T1_signal
tiny_train = 12/class
probe_train80 = 80/class from train split, diagnostic only
lr = 1e-3
epochs = 120
```

Teacher sanity:

```text
tiny teacher: bal_acc=1.0000, macro_f1=1.0000, recalls CN/MCI/AD=1.0000/1.0000/1.0000, pred_dist={'CN': 12, 'MCI': 12, 'AD': 12}
probe80 teacher: bal_acc=0.4792, macro_f1=0.4691, recalls CN/MCI/AD=0.5000/0.2750/0.6625, pred_dist={'CN': 78, 'MCI': 64, 'AD': 98}
```

Results:

```text
teacher_ce:
  tiny direct: bal_acc=1.0000, macro_f1=1.0000, recalls CN/MCI/AD=1.0000/1.0000/1.0000, pred_dist={'CN': 12, 'MCI': 12, 'AD': 12}
  probe direct: bal_acc=0.4917, macro_f1=0.4868, recalls CN/MCI/AD=0.6000/0.3625/0.5125, pred_dist={'CN': 95, 'MCI': 63, 'AD': 82}
  probe frozen: bal_acc=0.4958, macro_f1=0.4915, recalls CN/MCI/AD=0.6000/0.3750/0.5125, pred_dist={'CN': 95, 'MCI': 64, 'AD': 81}

teacher_ce + KL:
  tiny direct: bal_acc=1.0000, macro_f1=1.0000, recalls CN/MCI/AD=1.0000/1.0000/1.0000, pred_dist={'CN': 12, 'MCI': 12, 'AD': 12}
  probe direct: bal_acc=0.4750, macro_f1=0.4755, recalls CN/MCI/AD=0.5250/0.4375/0.4625, pred_dist={'CN': 82, 'MCI': 85, 'AD': 73}
  probe frozen: bal_acc=0.4708, macro_f1=0.4711, recalls CN/MCI/AD=0.5250/0.4375/0.4500, pred_dist={'CN': 83, 'MCI': 85, 'AD': 72}

teacher_ce + KL + emb:
  tiny direct: bal_acc=1.0000, macro_f1=1.0000, recalls CN/MCI/AD=1.0000/1.0000/1.0000, pred_dist={'CN': 12, 'MCI': 12, 'AD': 12}
  probe direct: bal_acc=0.4792, macro_f1=0.4784, recalls CN/MCI/AD=0.5500/0.4375/0.4500, pred_dist={'CN': 86, 'MCI': 80, 'AD': 74}
  probe frozen: bal_acc=0.4667, macro_f1=0.4662, recalls CN/MCI/AD=0.5375/0.4625/0.4000, pred_dist={'CN': 82, 'MCI': 90, 'AD': 68}

teacher_ce + KL + emb + ROI:
  tiny direct: bal_acc=1.0000, macro_f1=1.0000, recalls CN/MCI/AD=1.0000/1.0000/1.0000, pred_dist={'CN': 12, 'MCI': 12, 'AD': 12}
  probe direct: bal_acc=0.4917, macro_f1=0.4902, recalls CN/MCI/AD=0.5750/0.5000/0.4000, pred_dist={'CN': 88, 'MCI': 93, 'AD': 59}
  probe frozen: bal_acc=0.4917, macro_f1=0.4901, recalls CN/MCI/AD=0.5875/0.4875/0.4000, pred_dist={'CN': 88, 'MCI': 92, 'AD': 60}
```

Gate decision:

```text
PASS: all flatpool variants overfit 12/class with no class collapse.
```

This confirms the Stage 4B fix: using flatpool/coarse spatial layout removes the tiny overfit failure.

### Stage 4C-2: 80/class flatpool T1 controlled run

Setup:

```text
train = 80/class
val = 80/class
internal_test = 80/class
student = flatpool CNN
teacher = T1_signal trained on train80 ROI features
variants = teacher_ce, teacher_ce+KL+emb+ROI
lr = 1e-3
epochs = 40
```

Teacher ceiling in this sampled split:

```text
train80 teacher: bal_acc=1.0000, macro_f1=1.0000, recalls CN/MCI/AD=1.0000/1.0000/1.0000, pred_dist={'CN': 80, 'MCI': 80, 'AD': 80}
val80 teacher: bal_acc=0.4542, macro_f1=0.4426, recalls CN/MCI/AD=0.5375/0.2250/0.6000, pred_dist={'CN': 96, 'MCI': 58, 'AD': 86}
internal_test80 teacher: bal_acc=0.5167, macro_f1=0.5135, recalls CN/MCI/AD=0.6125/0.3750/0.5625, pred_dist={'CN': 95, 'MCI': 70, 'AD': 75}
```

Student results:

```text
teacher_ce:
  train direct: bal_acc=0.8417, macro_f1=0.8384, recalls CN/MCI/AD=0.9250/0.6750/0.9250, pred_dist={'CN': 86, 'MCI': 58, 'AD': 96}
  internal_test direct: bal_acc=0.4833, macro_f1=0.4749, recalls CN/MCI/AD=0.5250/0.3000/0.6250, pred_dist={'CN': 76, 'MCI': 60, 'AD': 104}
  internal_test frozen: bal_acc=0.4708, macro_f1=0.4692, recalls CN/MCI/AD=0.5750/0.4000/0.4375, pred_dist={'CN': 86, 'MCI': 77, 'AD': 77}

teacher_ce + KL + emb + ROI:
  train direct: bal_acc=0.9000, macro_f1=0.8994, recalls CN/MCI/AD=0.9375/0.8250/0.9375, pred_dist={'CN': 86, 'MCI': 70, 'AD': 84}
  internal_test direct: bal_acc=0.4917, macro_f1=0.4850, recalls CN/MCI/AD=0.5250/0.3375/0.6125, pred_dist={'CN': 79, 'MCI': 58, 'AD': 103}
  internal_test frozen: bal_acc=0.4792, macro_f1=0.4787, recalls CN/MCI/AD=0.5375/0.4125/0.4875, pred_dist={'CN': 81, 'MCI': 77, 'AD': 82}
```

### Interpretation

The critical implementation/optimization blocker is fixed enough to proceed:

```text
12/class overfit: PASS
80/class train absorption: partial/pass-ish
no single-class collapse: PASS
```

But the representation gate is still not fully solved:

```text
best internal_test direct ≈ 0.4917
best internal_test frozen ≈ 0.4792
current target for representation gate was frozen bal_acc >= 0.48 / macro_f1 >= 0.45
```

This is just at/below the gate and below teacher internal_test (`bal_acc≈0.5167`). The flatpool fix recovered MCI recall and removed collapse, but did not yet produce a strong frozen representation.

Important failure localization update:

```text
Previous blocker fixed: GAP/lr tiny-overfit failure.
Current blocker: generalization/teacher-transfer gap at 80/class, not basic optimization.
MCI no longer fully collapses, but remains modest.
Teacher itself is only moderate, so there is limited ceiling.
```

### Next controlled step

Do not jump to VLM yet. Next should be controlled generalization improvement:

```text
1. Run 3 seeds for the 80/class flatpool baseline only if we accept current single-seed as near-gate.
2. Compare T1_signal vs T2_bias_reduced using the same flatpool student.
3. Add cohort/generalization audit from frozen embeddings.
4. If T2 reduces cohort signal without losing too much diagnosis signal, use T2 or dual objective.
5. If both remain <=0.50, teacher ceiling/representation objective is the bottleneck, not implementation.
```

Recommended immediate next experiment:

```text
flatpool 80/class, same script, T1 vs T2, 3 seeds eventually.
Primary metrics: frozen internal_test bal_acc/macro_f1, class recalls, cohort probe.
```

