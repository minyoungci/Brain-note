# Manual Review Anchor Synthesis

Created: 2026-05-16

Source artifacts:
- `registry/manual_review_anchor_extraction.md`
- `registry/pmc_fulltext_snippets.md`
- `data/external_index/20260516/manual_review_anchor_records.csv`
- `data/external_index/20260516/pmc_fulltext_snippets.json`

## Bottom line

현재 API/PMC full-text snippet 기준으로, 우리의 주장은 **T1w MRI가 PET을 대체한다**가 아니라 **PET/ATN을 privileged endpoint로 쓰는 T1w-only 또는 sparse-modality representation이 기존 non-image/clinical shortcut과 cross-cohort shift를 얼마나 넘어서는가**로 제한해야 한다.

## Evidence-backed anchors

### B1. AJNR 2025 — MRI로 amyloid PET status 예측

Observed from PMC snippets:
- Development: `4056 examinations`
- External Stanford test: `149 examinations`
- Inputs: T1w-only vs T1w + T2 FLAIR EfficientNet
- Internal held-out:
  - multicontrast AUC `0.67`, accuracy `0.63`
  - T1w-only AUC `0.61`, accuracy `0.59`
- External test:
  - multicontrast AUC `0.65`, accuracy `0.62`
- Cognitive subgroup: MCI AUC `0.71`

Interpretation:
- This is a direct competitor/benchmark for our T1w→amyloid direction.
- T1w-only signal is real but modest. If our T1w-only model is not clearly above covariate and disease-axis baselines, reviewer will not accept biological novelty.
- FLAIR adds value in this paper; if we use T1w-only, we must frame it as constrained deployment / missing-modality robust learning, not maximal performance.

Reviewer objection:
- “Your T1w-only model is just reproducing a known modest amyloid proxy; where is external validation, covariate comparison, and MCI-only utility?”

### B2. Radiology 2023 — MRI + diagnostic data로 ATN status 예측

Observed from PMC snippets:
- PET-MRI pairing window: within `30 days`
- PET/MRI pairs:
  - amyloid: `2099`
  - tau: `557`
  - FDG: `2768`
- Split: random `70% train / 10% validation / 20% test`
- Test AUCs:
  - amyloid `0.79`
  - tau `0.73`
  - neurodegeneration `0.86`
- Uses MRI and “readily available diagnostic data” per abstract/snippet.

Interpretation:
- Strong benchmark but likely includes diagnostic/clinical covariates, so it is not a clean T1w-only imaging benchmark.
- This is useful for reviewer expectations: amyloid/tau/FDG PET status can be partially predicted, but modality/covariate contributions must be separated.

Reviewer objection:
- “If prior MRI+diagnostic-data ATN AUC is 0.79/0.73/0.86, what exactly does your representation add beyond diagnosis/age/site and PET-proximal clinical information?”

### C2. NeuroImage: Clinical 2021 — cross-cohort generalizability

Observed from PMC snippets:
- ADNI baseline cohort included:
  - AD `336`
  - CN `520`
  - MCI converters `231`
  - MCI non-converters `628`
- ADNI AD-vs-CN cross-validation:
  - SVM modulated GM AUC `0.940`
  - SVM minimally processed T1w AUC `0.801`
  - CNN modulated GM AUC `0.933`
  - CNN T1w AUC `0.898`
- External PND performance dropped by about `0.04–0.07` for AD-CN and `0.04–0.10` for MCI prediction.

Interpretation:
- This paper is a required reviewer-risk anchor. It shows that ADNI performance does not automatically generalize.
- It also warns that preprocessing representation matters: modulated GM maps can outperform minimally processed T1w for conventional ML.

Reviewer objection:
- “Is your method robust across cohorts, or just optimized to ADNI/OASIS acquisition/preprocessing idiosyncrasies?”

### C3. Human Brain Mapping 2020 — structural MRI dementia score across datasets

Observed from PMC snippets:
- Training: ADNI baseline stable NC `423` and stable DAT `330`
- Independent test images from ADNI follow-up/AIBL/OASIS-1/OASIS-2/MIRIAD
- Total validation/testing scale: `8834 images`
- Uses T1w MRI volume/FreeSurfer-derived structural features.
- Reported high separation for stable NC vs stable DAT; independent validation emphasized.

Interpretation:
- This is a strong disease-axis precedent. A CN/AD structural score is not novel by itself.
- Our possible distinction must be transfer of such disease-axis representation to PET/amyloid/centiloid, MCI stratification, longitudinal movement, or missing-modality robust learning.

Reviewer objection:
- “A structural MRI AD score across ADNI/AIBL/OASIS/MIRIAD already exists; why is your disease-axis representation new?”

### D1. Frontiers Digital Health 2021 — MRI/PET fusion diagnosis baseline

Observed from PMC snippets:
- ADNI sample: `381 subjects` = AD `95`, MCI `160`, NC `126`
- 10-fold setup with train/validation/test folds.
- FDG-PET preprocessing described.
- High AD-vs-NC/MCI-vs-NC classification accuracies reported.

Interpretation:
- This supports the warning that MRI/PET diagnosis-fusion literature is saturated and often ADNI-only.
- It should be used as a baseline/cautionary reference, not as our novelty direction.

Reviewer objection:
- “Another MRI/PET AD diagnosis classifier is incremental and likely not top-tier unless the task is reframed.”

## Current priority order for full human review

1. B1 AJNR 2025: extract exact model, data splits, subgroup definitions, Centiloid thresholds, external validation, and limitations.
2. B2 Radiology 2023: separate MRI-only vs MRI+clinical/diagnostic contributions if reported.
3. C2 NeuroImage Clinical 2021: extract cross-cohort design and preprocessing-dependent performance drop.
4. C3 Human Brain Mapping 2020: extract disease-score feature construction and external validation logic.
5. A1/A2 ADNI protocol papers: record acquisition/preprocessing/scanner harmonization caveats.
6. D1/D2 fusion papers: keep as saturated diagnosis-fusion baselines only.

## Working research implication

The most defensible next project frame remains:

> PET-privileged, missing-modality robust structural T1w MRI representation learning for amyloid-risk / ATN transfer under multi-cohort domain shift.

Mandatory claim gates:
- T1w-only imaging vs non-image covariates.
- MRI embedding-only vs embedding+covariates.
- MCI-only and close MRI-PET interval subgroup.
- ADNI↔OASIS or leave-one-cohort-out validation.
- Random/disease-axis/ROI baselines.
- Explicit statement that diagnosis-only MRI/PET fusion is not the novelty target.
