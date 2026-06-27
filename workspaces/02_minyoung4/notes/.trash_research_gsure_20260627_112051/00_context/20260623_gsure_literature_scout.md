# 2026-06-23 G-SURE Literature Scout

## Scope

This is a first-pass literature scout for the G-SURE direction:

```text
glioma MRI segmentation -> visual grounding / reliability / error localization
```

It is not a full systematic review. The purpose is to identify obvious prior
work that could make the proposed direction non-novel or force stronger
baselines.

Literature status:

```text
INITIAL SCOUT + TARGETED 2024-2026 UPDATE VERIFIED IN THIS SESSION; NOT EXHAUSTIVE
```

Do not claim "first", "novel", "SOTA", "robust", or "clinically useful" from
this memo alone.

## Immediate Conclusion

G-SURE cannot be framed as:

- first segmentation uncertainty map,
- first brain tumor segmentation uncertainty study,
- first segmentation quality-control model,
- first segmentation error prediction model,
- first visual explanation for medical segmentation.

Those areas already have strong prior work.

The defensible opening is narrower:

```text
multi-consortium glioma full-volume segmentation reliability under LOCO shift,
with out-of-fold prediction-derived error labels, quantitative error
localization, and explicit comparison to uncertainty/QC baselines.
```

If this narrower claim cannot beat strong uncertainty and QC baselines, the
paper should become a benchmark/protocol or negative-result study rather than a
method paper.

## Key Prior Work and Risks

| area | prior work | what it already covers | G-SURE risk |
|---|---|---|---|
| Brain tumor segmentation uncertainty | Jungo et al., "On the Effect and Usefulness of MRI Uncertainty Estimation for MRI Segmentation" | Brain tumor segmentation uncertainty, calibration, segmentation error identification, failure detection | A basic uncertainty/reliability map is not new |
| Segmentation failure prediction | DeVries and Taylor, "Leveraging Uncertainty Estimates for Predicting Segmentation Quality" | Uses segmentation and uncertainty maps to predict segmentation quality without GT at test time | Subject-level quality prediction is not new |
| Brain tumor uncertainty benchmark | QU-BraTS / BraTS uncertainty challenge | Evaluates uncertainty in BraTS tumor segmentation | BraTS uncertainty baselines are expected |
| Brain tumor segmentation QC | QCResUNet | Predicts subject-level DSC/NSD and voxel-level error maps for brain tumor segmentation quality control | Error-map prediction for brain tumor segmentation is a direct novelty threat |
| Image-specific segmentation QC | Fournel et al., MICCAI 2025 | Predicts case-specific quality thresholds from inter-observer agreement and segmentation difficulty | Global Dice-threshold failure detection is too weak; G-SURE should report lesion/difficulty strata and not rely only on a fixed failure threshold |
| Calibrated/evidential uncertainty | DEviS and related evidential segmentation work | Improves uncertainty calibration and lesion segmentation uncertainty | Calibration-only claims are weak |
| Uncertainty-error training objective | Accuracy-versus-Uncertainty loss | Trains segmentation uncertainty to align with correct/incorrect predictions | Reliability-error alignment loss is not automatically novel |
| Shape/image uncertainty | CRISP and related work | Uses shape/image priors to predict plausible segmentation distributions | Need compare against strong uncertainty baselines if claiming spatial reliability |
| Foundation segmentation reliability | U-MedSAM and SAM/MedSAM reliability papers | Reliability/uncertainty for promptable medical segmentation | Foundation-model framing alone is not enough |
| Foundation-model data uncertainty | 2026 visual-foundation-model aleatoric uncertainty preprint | Uses foundation-model features to score sample difficulty/uncertainty and guide training | Data-difficulty or noisy-label filtering is not enough for G-SURE novelty |

## Source Notes

1. Jungo et al. analyze uncertainty estimation for brain tumor MRI segmentation,
   including calibration, segmentation error localization, and segmentation
   failure detection. They also report that voxel-level segmentation error
   detection from uncertainty is challenging, which is directly relevant to the
   G-SURE reliability target.
   Source: https://www.frontiersin.org/journals/neuroscience/articles/10.3389/fnins.2020.00282/full

2. DeVries and Taylor train a model to predict segmentation quality from an
   input image, predicted segmentation, and uncertainty map. This makes
   segmentation QC a required baseline family, not a novelty claim.
   Source: https://arxiv.org/abs/1807.00502

3. QCResUNet is especially important because it targets brain tumor segmentation
   quality control and predicts both subject-level quality and voxel-level
   segmentation error maps.
   Sources:
   - https://conferences.miccai.org/2023/papers/524-Paper0839.html
   - https://pubmed.ncbi.nlm.nih.gov/40945175/
   - https://umu.diva-portal.org/smash/record.jsf?pid=diva2%3A1690582

4. BraTS 2020 included an uncertainty quantification task for glioma region
   segmentation, rewarding uncertainty maps that are confident when correct and
   uncertain when incorrect. QU-BraTS later analyzed ranking scores and
   benchmarking results.
   Sources:
   - https://www.med.upenn.edu/cbica/brats2020/tasks.html
   - https://pmc.ncbi.nlm.nih.gov/articles/PMC10060060/

5. The 2025 Medical Image Analysis record for QCResUNet strengthens, rather than
   weakens, the direct novelty threat: brain-tumor segmentation QC with both
   subject-level quality prediction and voxel-level error maps is now a journal
   prior, not only a workshop/conference warning. G-SURE must therefore compare
   against a QCResUNet-style baseline before making method claims.
   Sources:
   - https://pubmed.ncbi.nlm.nih.gov/40945175/
   - https://arxiv.org/html/2412.07156v2

6. MICCAI 2025 image-specific segmentation QC work argues that fixed global DSC
   thresholds are insufficient because segmentation difficulty varies by input.
   It is not a glioma paper, but it makes simple threshold-based failure
   detection a weak framing. G-SURE should include difficulty/lesion-size strata
   and report whether reliability remains useful beyond easy size/shape cues.
   Source: https://papers.miccai.org/miccai-2025/0232-Paper4042.html

7. Foundation-model segmentation reliability papers, including U-MedSAM and
   prompt-triggered SAM uncertainty work, make "medical foundation segmentation
   with uncertainty" a crowded framing. G-SURE should not pivot to a foundation
   model claim unless the contribution remains LOCO full-volume glioma
   reliability/error localization with strong baselines.
   Sources:
   - https://arxiv.org/html/2408.08881v2
   - https://openaccess.thecvf.com/content/ICCV2025W/CVAMD/papers/Zhang_Enhancing_the_Reliability_of_Auto-Prompting_SAM_for_Medical_Image_Segmentation_ICCVW_2025_paper.pdf

8. A 2026 visual-foundation-model aleatoric uncertainty preprint uses foundation
   model feature diversity to estimate sample difficulty and guide filtering or
   optimization. Treat this as a novelty warning for any G-SURE claim based only
   on data difficulty, noisy-label filtering, or adaptive uncertainty-weighted
   training.
   Source: https://arxiv.org/html/2604.10963v1

## Working Novelty Delta

The strongest defensible G-SURE delta, if experiments support it, is:

1. **Evaluation setting**
   - leave-one-consortium-out,
   - subject-level split,
   - full-volume out-of-fold segmentation predictions,
   - no mask-centered test-time inference.

2. **Target construction discipline**
   - reliability/error labels generated only from OOF predictions,
   - prediction metadata and artifact validators required before label creation,
   - fixed initial threshold policy before inspecting predictions.

3. **Spatial reliability task**
   - not only subject-level quality prediction,
   - voxel/region-level localization of false-positive, false-negative, and
     boundary-risk regions,
   - reliability calibration by consortium and lesion-size strata.

4. **Baseline discipline**
   - compare against entropy, MC dropout/TTA, ensemble disagreement,
     DeVries-style QC, QCResUNet-style QC/error-map prediction, and
     uncertainty-error alignment losses where feasible,
   - include lesion-size/predicted-volume and image-difficulty proxies before
     claiming a learned reliability model adds value.

5. **Possible method contribution**
   - only after baselines reveal a gap,
   - proposed model must improve error localization or reliability calibration
     under held-out consortium shift, not merely improve Dice.

## Reviewer Attack Points

- "This is just uncertainty estimation for segmentation."
- "This is just segmentation quality control."
- "QCResUNet already predicts error maps for brain tumor segmentation."
- "Recent segmentation QC work already predicts image-specific segmentation
  difficulty or quality thresholds."
- "Foundation medical segmentation papers already add uncertainty/reliability."
- "The reliability labels are generated from the same model family and may only
  learn model-specific artifacts."
- "Dataset-specific annotation style may dominate reliability maps."
- "LOCO performance collapse may make reliability labels uninterpretable."

## Baseline Implications

The baseline list should be strengthened before GPU work:

1. Plain segmentation baseline.
2. Entropy/confidence map.
3. TTA uncertainty.
4. MC dropout uncertainty, if architecture supports it.
5. Ensemble disagreement.
6. DeVries-style quality predictor using image, prediction, and uncertainty.
7. QCResUNet-style subject-level QC plus voxel-level error map predictor.
8. Lesion-size/predicted-volume/image-difficulty proxy baselines.
9. Reliability head without grounding constraint.
10. G-SURE full method only after the above reveal room.

## Go / No-Go Implication

Proceed toward a method paper only if the first OOF segmentation baseline shows:

- non-degenerate segmentation on held-out consortia,
- meaningful error maps,
- simple uncertainty baselines do not already explain most error localization,
- QC-style baselines leave measurable room for improvement.

Otherwise, pivot to:

- benchmark/protocol paper, or
- negative result on cross-consortium segmentation reliability.

## Next Literature Steps

Before method lock:

1. Use the targeted prior-work matrix:
   `research_gsure/00_context/20260623_gsure_prior_work_matrix.md`.
2. Use the uncertainty/QC baseline contract:
   `research_gsure/03_baselines/UNCERTAINTY_QC_BASELINE_REQUIREMENTS.md`.
3. Identify 2024-2026 medical segmentation reliability and foundation-segmentation
   uncertainty papers. A targeted update has been added here, but it is not a
   systematic review.
4. Expand the related-work matrix with:
   - task,
   - input,
   - prediction target,
   - split/evaluation,
   - datasets,
   - whether voxel-level error localization is evaluated,
   - whether cross-site external validation exists.
