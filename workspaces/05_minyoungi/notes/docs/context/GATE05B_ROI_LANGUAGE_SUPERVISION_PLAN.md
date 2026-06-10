# Gate05b ROI/structured-language supervision plan

작성일: 2026-05-28
Workspace: `/home/vlm/minyoungi`
Experiment family: `experiments/voxelwise_feature_learning_v1`
Status: planning / no GPU training launched

## 0. 결론

다음 단계는 큰 VLM training이 아니다. 먼저 **Gate05b: training-only ROI/structured-language supervision, inference image-only**를 작은 gate로 고정한다.

핵심 원칙:

1. ROI 정보는 training-time privileged supervision으로만 사용한다.
2. Inference/evaluation은 T1w `final_tensor` image-only representation으로 한다.
3. Baseline06 image-only LOCO와 Baseline07 ROI text/status-only shortcut gate를 동시에 넘어야 한다.
4. Baseline07을 못 넘는 ROI-language/VLM 결과는 image-language representation evidence가 아니다.

## 1. 왜 Gate05b인가

Gate05a ROI-mask-assisted pooling은 upper-bound diagnostic이었다. 결과상 `m2_roi_pool_cosine`만 약한 positive signal을 보였지만 downstream gain은 작고 cohort-dependent였다.

근거:

- `m0_global_same_loss`: frozen AUC `0.8061`, ROI cosine `-0.0340`, baseline06 delta `-0.0026`
- `m1_roi_pool_same_loss`: frozen AUC `0.8029`, ROI cosine `0.0155`, baseline06 delta `-0.0058`
- `m2_roi_pool_cosine`: frozen AUC `0.8123`, ROI cosine `0.4702`, baseline06 delta `+0.0036`
- `m3_roi_token_cosine`: frozen AUC `0.7760`, ROI cosine `0.3770`, baseline06 delta `-0.0327`

판정:

- `m2`는 버리기 아까운 약한 신호다.
- 그러나 `m2`를 믿고 scaling하기에는 효과가 너무 작고 AIBL/NACC fold regression이 있다.
- `m3` naive ROI token aggregation은 현재 구조로 반복하면 안 된다.
- ROI mask를 inference input으로 계속 강화하는 방향은 최종 deployable VLM representation claim과 맞지 않는다.

따라서 다음 방어 가능한 방향은 **training-only ROI/structured-language supervision으로 image-only encoder를 개선하는지 검증**하는 것이다.

## 2. 고정 비교 기준

### 2.1 Baseline06 — image-only direct CNN LOCO

Registry:

```text
/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/baselines/baseline_06_3d_cnn_loco_cn_vs_ad/
```

역할:

- CN/AD image-only direct supervised 3D CNN baseline.
- Gate05b image-only representation이 최소한 이 기준보다 cohort-held-out에서 좋아야 한다.

등록 수치:

- LOCO mean AUC: `0.8087`
- LOCO mean bACC: `0.7146`

Fold 기준:

| heldout | baseline06 AUC | baseline06 bACC |
|---|---:|---:|
| ADNI | 0.7572 | 0.6952 |
| AIBL | 0.8576 | 0.7827 |
| AJU | 0.8081 | 0.6495 |
| KDRC | 0.8395 | 0.7543 |
| NACC | 0.7968 | 0.7275 |
| OASIS | 0.7932 | 0.6786 |

### 2.2 Baseline07 — ROI text/status-only shortcut gate

Registry:

```text
/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/baselines/baseline_07_roi_quality_text_status_probe_v0/
```

역할:

- ROI quality/mask status + ROI text severity features만으로 CN/MCI/AD 신호가 얼마나 있는지 측정한 non-image shortcut baseline.
- ROI-language/VLM 모델이 이 baseline을 못 넘으면, MRI representation이 아니라 deterministic ROI status/text/QC metadata를 재포장했을 가능성이 높다.

등록 primary row:

- feature set: `quality_plus_severity_onehot`
- internal macro OvR AUC: `0.7212`
- internal bACC: `0.5494`
- LOCO mean bACC: `0.5411 ± 0.0299`
- LOCO mean macro OvR AUC: `0.7027`

해석상 주의:

- Baseline07은 CN/MCI/AD multiclass다.
- 기존 `baseline_comparison.csv`의 `test_roc_auc` column은 binary baseline 중심 이름이므로 Baseline07에서는 multiclass macro OvR AUC로 해석한다.
- Gate05b가 CN/AD binary만 평가하면 Baseline07과 직접 1:1 비교할 수 없다. 이 경우 Gate05b에는 반드시 별도 CN/MCI/AD probe 또는 Baseline07-compatible evaluation을 붙인다.

## 3. Gate05b research question

> ROI-derived anatomical/text supervision을 training 때만 사용했을 때, T1w image-only encoder의 frozen representation이 Baseline06 image-only LOCO와 Baseline07 ROI-text/status shortcut gate를 넘어서는가?

Computable definition:

- Input at training: T1w `final_tensor` plus teacher/ROI/text supervision targets.
- Input at inference/evaluation: T1w `final_tensor` only.
- Outputs:
  - frozen image embedding
  - direct/frozen probe predictions
  - predicted ROI/status/text alignment diagnostics
  - row-level errors and fold-wise metrics
- Primary evaluation:
  - CN/AD LOCO AUC/bACC vs Baseline06
  - CN/MCI/AD macro OvR AUC/bACC vs Baseline07-compatible shortcut baseline
- Unit of analysis: manifest row / scan, grouped by subject for split hygiene.
- Required split: existing subject-disjoint and leave-one-cohort-out folds. Do not resplit silently.

## 4. Minimal variants

Keep to four variants. Do not add MLLM, report generation, multi-scale pooling, or broad architecture sweeps until these gates are interpretable.

### b0_global_teacher_ce

Purpose:

- Re-establish the current strongest image-only teacher-student recipe as the reference.

Design:

- Student input: T1w `final_tensor` only.
- Loss: Teacher-S KL + `0.1 * hard-label CE`.
- No ROI text/phrase contrastive loss.
- No ROI masks at inference.

Expected comparison:

- Should reproduce Gate04-ish behavior before adding new ROI-language terms.

### b1_global_roi_cos

Purpose:

- Test whether adding ROI prediction/cosine supervision improves image-only representation without mask-assisted inference.

Design:

- b0 + ROI target prediction/cosine head.
- ROI supervision from approved ROI scalar/status targets only.
- Inference still image-only.

Pass sign:

- Predicted-vs-true ROI cosine improves.
- Frozen probe does not regress vs b0.
- Fold-specific failures do not worsen AIBL/NACC.

### b2_region_prompt_phrase_contrastive

Purpose:

- Test ROI-derived phrase supervision as controlled regional language supervision, not clinical report generation.
- Replace the older global `b2_roi_phrase_siglip` idea. The NACC ROI distribution/sign-shift audit showed that whole-vector/global ROI alignment can worsen NACC AD alignment; global row-text phrase matching is too likely to hide the same failure.

Design:

- Training tuple proxy: `(X, M_roi, T_roi_safe)`.
- `X`: T1w `final_tensor`.
- `M_roi`: QC-approved final-tensor-grid ROI mask/prompt. If final-grid ROI masks are unavailable or not QC-approved, this variant is blocked rather than silently falling back to global text.
- `T_roi_safe`: deterministic train-reference ROI morphology phrase from approved `roi_text_v1` / official ROI quality text artifacts.
- Image encoder emits a 3D feature map; ROI mask pools local feature.
- Local ROI feature aligns with the corresponding ROI phrase via contrastive/alignment loss.
- Global diagnosis head remains anchored by Teacher-S KL + `0.1 * CE`.
- Inference/evaluation remains image-only.
- No report decoder. There are no verified report targets for this task.

Forbidden text:

- CN/MCI/AD, dementia, Alzheimer, diagnosis-derived severity words.
- PET/amyloid/tau/CSF/ATN.
- cohort/site/scanner.
- QC status as biological language.

Required shortcut/comparison gates:

- Compare against Baseline07 severity-only and quality+severity results.
- Track NACC AD sensitivity and ROI cosine/MSE; b2 must not reproduce b1's NACC AD alignment loss.
- Add per-target monitoring for the NACC failure targets localized by audit: `roi_std__lateral_ventricle`, `roi_std__amygdala`, `roi_std__thalamus`, `roi_q75__lateral_ventricle`, and `roi_q75__thalamus`.
- Add ROI phrase retrieval/local feature-to-phrase alignment, but do not treat retrieval improvement alone as representation success.
- If b2 improves phrase alignment but not image-only downstream probe beyond Baseline06/07, do not call it representation success.

### b3_roi_dropout_consistency

Purpose:

- Test whether ROI/background perturbation consistency improves robustness without overfitting to one ROI or QC artifact.

Design:

- b1 + mild ROI/background perturbation consistency.
- Use official brain/ROI masks only where QC-approved.
- Avoid overly strong augmentations that erase subtle atrophy morphology.

Pass sign:

- No drop in AD recall.
- Confidence/error profile improves on hard folds.
- Grad-CAM/ROI overlap does not become more background-heavy.

## 5. Required pre-gate audits

Before GPU training, complete or explicitly mark as blocker:

1. NACC failure audit
   - Teacher-S vs Teacher-B ceiling and calibration.
   - Label semantics/class distribution.
   - cohort/site/scanner/age/sex distribution where available.
   - ROI distribution/harmonization/QC differences.
   - Overlap with Baseline06 prediction errors.

2. AIBL regression audit
   - Gate04 transfer was good but Gate05a m2 worsened AIBL.
   - Check whether ROI-local forcing sacrifices global discriminative signal.
   - Report AD/CN recall, AP, confidence/error profile.

3. KDRC transfer diagnostic completion
   - Teacher is strong but student transfer is unstable.
   - Complete row-level confidence-error profile and high-confidence miss pattern.
   - Avoid claiming KDRC rescue from single runs.

4. Text/caption leakage registry
   - Define task-specific `allowed_text_fields` and `forbidden_text_fields`.
   - For CN/MCI/AD, forbid diagnosis label and diagnosis-derived wording in training captions used for the same target.
   - For PET/ATN downstream probes, forbid PET/amyloid/tau/CSF/ATN fields in captions unless explicitly testing privileged-supervision leakage in a separate branch.
   - Keep cohort/scanner/site fields out of text.

## 6. Evaluation matrix

### 6.1 CN/AD image-only representation evaluation

Compare each Gate05b variant to Baseline06.

Required metrics:

- LOCO mean AUC and bACC
- fold-wise AUC/bACC
- AD recall and CN recall
- AP for AD where applicable
- direct head, frozen embedding probe, predicted ROI probe separately
- row-level predictions joined with cohort/age/sex/scanner metadata where available

Pass rule:

- Minimum: mean LOCO AUC above Baseline06 and no unresolved large regression on AIBL/NACC/KDRC.
- Stronger: at least 4/6 folds beat Baseline06 AUC, and hard fold failures are explained by teacher ceiling or data/QC audit.

### 6.2 CN/MCI/AD Baseline07-compatible evaluation

Compare ROI-language variants against Baseline07.

Required metrics:

- Internal subject-disjoint macro OvR AUC and bACC
- LOCO mean macro OvR AUC and bACC
- class-wise recall/F1 for CN/MCI/AD
- confusion matrix
- feature/text-only shortcut comparator from Baseline07

Pass rule:

- A ROI-language image model must beat Baseline07 on image-only evaluation under the same split family before claiming learned image-language representation.
- If it only beats Baseline07 when ROI text/status/QC is directly available at inference, that is not image-only VLM readiness.

### 6.3 Alignment diagnostics

Required:

- predicted ROI cosine/MSE vs true ROI teacher
- disease-axis separation by class
- text phrase retrieval only as secondary evidence
- row-level agreement between image prediction and ROI/status-only baseline
- Grad-CAM or perturbation diagnostic only for selected failure rows, not as global proof

## 7. Pass/fail labels

Use these labels, not vague success language.

- `fail`: below Baseline06 and below/near Baseline07; no representation value.
- `shortcut-pass-only`: beats Baseline07-like text/status baseline but not Baseline06 image baseline, or uses non-image information at inference.
- `image-baseline-partial-pass`: beats Baseline06 mean but has unresolved hard-fold regressions.
- `representation-readiness-pass`: beats Baseline06 mean, beats Baseline07-compatible shortcut baseline, has acceptable fold-wise stability, and inference is image-only.
- `vlm-scaling-ready`: only after representation-readiness-pass plus leakage/text-field audit pass.

Current evidence before Gate05b: **not VLM-scaling-ready**.

## 8. What not to do next

Do not do these now:

- Launch broad VLM/MLLM training.
- Add more than four Gate05b variants.
- Treat ROI pseudo-text as radiology reports.
- Report retrieval improvement as the main result without downstream image-only LOCO gains.
- Use ROI quality/mask status as if it were clean biological signal.
- Claim T1w MRI replaces PET/ATN.
- Re-run naive m3 ROI token aggregation unchanged.

## 9. Immediate implementation packet

Goal:

- Prepare Gate05b as a constrained, auditable experiment family; do not launch long/GPU jobs until Min approves the exact command.

Inputs:

- `baseline_06_3d_cnn_loco_cn_vs_ad` registry and fold metrics.
- `baseline_07_roi_quality_text_status_probe_v0` registry and shortcut metrics.
- ROI text/status artifacts under `manifests/v2_integrated/captions/`.
- Existing subject-disjoint and LOCO split logic.

Files to create/change next:

- `docs/context/GATE05B_ROI_LANGUAGE_SUPERVISION_PLAN.md` — this plan.
- `docs/context/CAPTION_FIELD_POLICY.md` or task-specific appendix if current policy is stale/missing.
- Optional script scaffold only after policy/audit is fixed:
  - `experiments/voxelwise_feature_learning_v1/scripts/vlm_gate_05b_roi_language_supervision_v0.py`

Validation before any training:

- Verify split reuse and subject disjointness.
- Verify allowed/forbidden text fields.
- Verify Baseline07 comparison rows are available.
- Dry-run dataloader on tiny CPU subset.
- Run `nvidia-smi`, `pwd`, `git status --short`, `git branch --show-current` and present command preview before GPU launch.

Done when:

- Gate05b plan and comparison criteria are committed.
- Min explicitly approves the first GPU command or asks for CPU-only scaffold/dry-run.
