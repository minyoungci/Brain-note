# Prior-Work Mechanistic Gap Analysis for Higher-Performance IDH Experiments

검토일: 2026-06-18

## Executive Conclusion

목표를 "3D CNN보다 좋은 모델"로 잡으면 기준선은 **Res3DNet external AUC 0.872**, **Choi hybrid CNN+radiomics external AUC 0.86-0.94**, **Swin Transformer external AUC 0.868/0.878**, **FoundBioNet/MTS-UNET IDH AUC 약 0.90대**, **Glio-LLaMA-Vision IDH AUC 0.85-0.95**까지 올려야 한다.

따라서 성능 향상을 기대할 수 있는 방향은 단순 backbone 교체가 아니다. 가장 방어 가능한 전략은 다음이다.

> **Segmentation-free inference를 유지하되, 학습 중에는 segmentation/tumor-context를 auxiliary signal로 쓰고, clinical/scanner shift를 명시적으로 통제하는 3D tumor-context prompt model.**

핵심은 세 가지다.

1. **Res3DNet보다 낫게**: whole-brain 3D CNN만 쓰지 말고 tumor/context token, modality-specific interaction, imbalance-aware loss를 추가한다.
2. **FoundBioNet/MTS-UNET보다 낫게**: mask에 과의존하지 않도록 mask dropout, weak-mask/no-mask inference, leave-consortium-out 성능을 전면에 둔다.
3. **Glio-LLaMA-Vision과 다르게**: radiology report가 없는 상황에서 report-generation VLM을 흉내 내지 않고, 3D volumetric representation과 shift robustness를 주 novelty로 둔다.

## Prior Work: 구조와 학습법 분해

| Work | 모델 구조 | 학습 방법 | 강점 | 취약점 / 개선 여지 |
|---|---|---|---|---|
| M3D-DenseNet, 2018 | 4-channel 3D DenseNet. T1/T1Gd/T2/FLAIR를 channel concat. lesion mask로 crop. | 5-fold CV, data augmentation, 3D DenseNet depth 비교. | 3D multimodal end-to-end baseline의 출발점. | n=167로 작고, mask crop 의존. clinical/domain shift 통제 없음. |
| Choi hybrid CNN+radiomics, 2021 | Model 1: 3D U-Net segmentation. Model 2: ResNet-34 style 2D slice classifier + 3D shape/loci radiomics + age. | segmentation 후 maximum tumor slice 주변 5 slices 사용. ResNet warm-up 후 numeric fusion fine-tune. | fully automated pipeline, internal+2 external validation, shape/location/age 활용. | 2D slice 기반이고 segmentation pipeline에 의존. MRI intensity protocol shift에 민감. |
| Swin Transformer segmentation-free, 2022 | 2D Swin Transformer vs ResNet-101. T2 slices, bbox/mask/ROI 7개 input strategy. | Adam, StepLR, early stopping. slice probability 평균으로 patient prediction. age/location hybrid. | Transformer가 ResNet보다 강하고, 1.0x bbox가 refined mask보다 좋음을 보임. | 2D T2-only, manual bbox/mask 준비, true 3D context 부족. |
| Radiomics XGBoost, 2024 | PyRadiomics 2364 features + XGBoost. | segmentation VOI, MinMaxScaler, correlation removal, SMOTE, randomized search. | 해석 가능한 non-DL baseline, 외부 AUC 0.835. | handcrafted/segmentation 의존, representation learning novelty 없음. |
| Res3DNet, 2025/2026 | whole-brain 4-channel residual I3D-style 3D CNN. large 7x7x7 conv 대신 3x3x3 residual conv stack. | supervised IDH classification, alpha oversampling, 3D augmentation/histogram matching. ResNet/I3D/Transformer/radiologist 비교. | segmentation-free 3D CNN 기준선으로 매우 중요. external AUC 0.872, TCGA AUC 0.912. | plain image-only model. clinical prompt, explicit tumor/context supervision, domain generalization은 약함. |
| FoundBioNet, 2025 | BrainSegFounder-Tiny/SWIN-UNETR + TAFE + CMD + DSF. | Dice segmentation auxiliary + IDH classification joint loss. A100, batch 2, Adam, 100 epochs, early stopping. | foundation 3D Transformer + segmentation-guided tumor-aware features. T2-FLAIR mismatch를 CMD로 명시. | mask 품질/availability에 의존. UPENN 등 skewed cohort에서 취약. |
| MTS-UNET, 2025 | BrainSegFounder/SWIN-UNETR multi-task network. segmentation, IDH, 1p/19q, grade heads. | BrainSegFounder pretraining, 96^3 crop, z-score, multi-task training. TAFE/CMD/DSF. | multi-task foundation model 방향의 강한 prior. | segmentation 의존과 imbalanced external cohort 성능 저하를 스스로 한계로 인정. |
| Glio-LLaMA-Vision, 2026 | BiomedCLIP ViT + 2-layer MLP projection to soft tokens + frozen LLaMA 3.1 8B + classifier. 2D slice feature averaging. | PMC 2.79M image-text autoregressive feature-alignment pretraining. MRI-report pair fine-tuning. classifier CE + report generation. | 직접 VLM 경쟁 연구. joint RRG가 molecular classifier 성능을 올렸다는 ablation. | radiology report pair 필요. 3D는 slice-average라 volumetric inductive bias가 약함. hallucination/paired-report scarcity 한계. |

## 개선 가능성이 큰 지점

### 1. Whole-brain 3D CNN의 한계 보완

Res3DNet는 segmentation-free라 실용적이지만, whole-brain input만으로는 tumor signal을 직접 구조화하지 않는다. Grad-CAM이 tumor를 본다는 사후 해석은 있지만, 학습 목적 자체가 tumor/context를 분리하지 않는다.

개선 실험:

- 3D encoder에 **global token / tumor token / peritumoral token**을 분리해서 넣는다.
- segmentation은 inference requirement가 아니라 **training-time auxiliary guide**로만 사용한다.
- mask dropout을 넣어 `mask available`, `mask missing`, `mask corrupted` 상황을 모두 학습시킨다.
- final inference는 mask-free 또는 weak-bbox mode까지 지원한다.

기대 효과:

- Res3DNet의 실용성은 유지하면서 FoundBioNet의 tumor-aware 장점을 일부 흡수한다.

### 2. T2-FLAIR mismatch를 단순 feature가 아니라 auxiliary objective로 사용

FoundBioNet/MTS-UNET의 CMD는 T2-FLAIR mismatch를 잘 이용한다. 하지만 mismatch cue는 acquisition, edema, tumor boundary 품질에 민감하다.

개선 실험:

- T2/FLAIR difference branch를 둔다.
- tumor/context region에서 contrastive objective를 걸어 `mutant-like mismatch`와 `wildtype-like enhancement/edema` representation을 분리한다.
- CMD branch output을 final classifier에 바로 concat하지 말고 uncertainty gate로 조절한다.

기대 효과:

- mismatch signal이 강한 케이스에서는 성능을 올리고, mismatch가 애매한 케이스에서는 과신을 줄일 수 있다.

### 3. Clinical prompt는 "성능 치트"가 아니라 shift control로 설계

age는 IDH와 강하게 연관되어 있고, scanner/vendor/site는 shortcut risk다. 그냥 image+tabular concat을 하면 성능은 오를 수 있지만 논문 방어력이 약하다.

개선 실험:

- age/sex는 final prompt로 허용하되, scanner/vendor/site는 `domain regularization` 또는 `diagnostic report stratification`에 사용한다.
- prompt fusion은 단순 concat, FiLM/adaptive normalization, cross-attention을 비교한다.
- prompt-shuffle ablation을 넣어 prompt mechanism이 실제로 의미 있는지 검증한다.

기대 효과:

- Swin hybrid의 age/location 개선, Glio-LLaMA의 age/sex conditioning을 3D setting으로 확장하면서 leakage 논란을 줄인다.

### 4. Leave-one-consortium-out을 optimization target으로 둔다

대부분 선행연구는 external validation을 하지만, 모델 선택과 학습 objective가 leave-consortium robustness를 직접 최적화하지는 않는다.

개선 실험:

- ERM baseline.
- group DRO by consortium.
- CORAL/MMD feature alignment.
- domain adversarial head.
- domain-specific normalization vs shared normalization.
- worst-consortium AUC/MCC를 model selection metric으로 둔다.

기대 효과:

- pooled AUC 경쟁보다 더 설득력 있다. 우리 데이터는 UTSW 28.30% mutant vs UPENN 3.62% mutant라 이 축 자체가 연구 contribution이 될 수 있다.

### 5. Imbalance-aware training + calibration을 성능 주장에 포함

IDH mutant가 적고 consortium별 rate가 크게 다르다. AUC만 높아도 minority recall, calibration, subgroup reliability가 무너질 수 있다.

개선 실험:

- class-balanced focal loss vs weighted CE vs logit-adjusted CE.
- oversampling은 subject-level/group-aware로만 적용.
- validation consortium 기반 temperature scaling.
- ECE, Brier, AUPRC, MCC, balanced accuracy, sensitivity at fixed specificity를 모두 보고.

기대 효과:

- Res3DNet의 alpha oversampling보다 더 체계적이고, 임상/AI conference reviewer가 보는 안정성 지표를 강화한다.

## Proposed Main Experiment

Working name:

**STaR-IDH: Shift-regularized Tumor-context 3D Representation for IDH Prediction**

구성:

1. **Backbone**
   - Baseline: 3D ResNet/Res3DNet-style CNN.
   - Main: 3D Swin/SWIN-UNETR-style encoder 또는 lightweight 3D Transformer.

2. **Inputs**
   - T1, T1ce/T1post, T2, FLAIR.
   - Optional training-time segmentation mask.
   - age/sex prompt.
   - scanner/vendor/site는 final predictor가 아니라 regularization/reporting axis.

3. **Representation**
   - global whole-brain token.
   - tumor token from mask/bbox/attention.
   - peritumoral context token from dilated-eroded mask ring.
   - modality-interaction token for T2-FLAIR and T1CE-FLAIR contrast.

4. **Loss**
   - IDH classification loss.
   - optional tumor-localization auxiliary loss.
   - contrastive tumor/context consistency loss.
   - domain generalization loss.
   - calibration-aware validation selection.

5. **Evaluation**
   - Subject-isolated.
   - leave-one-consortium-out.
   - scanner/vendor subgroup.
   - mask available vs mask dropped.
   - worst-group AUC/MCC and calibration.

## Minimum Baseline Ladder

| Tier | Baseline | Purpose |
|---|---|---|
| B0 | clinical-only age/sex/scanner logistic or XGBoost | shortcut ceiling 확인 |
| B1 | 3D ResNet / DenseNet | standard 3D CNN |
| B2 | Res3DNet reimplementation/proxy | strongest segmentation-free 3D CNN |
| B3 | 2D Swin bbox/slice baseline | transformer but not volumetric |
| B4 | radiomics XGBoost | handcrafted segmentation-based baseline |
| B5 | image+tabular concat | prompt mechanism의 trivial baseline |
| B6 | segmentation-guided SWIN-UNETR proxy | FoundBioNet/MTS-UNET style competitor |
| M1 | STaR-IDH without domain loss | architecture gain |
| M2 | STaR-IDH with domain loss | shift robustness gain |
| M3 | STaR-IDH with mask dropout | mask dependency reduction |

## Go / No-Go Criteria

Go 조건:

- LOCO mean AUC가 Res3DNet/proxy보다 높다.
- worst-consortium AUC 또는 MCC가 개선된다.
- clinical-only baseline 대비 유의미한 gain이 있다.
- scanner/vendor subgroup에서 특정 vendor collapse가 없다.
- mask 없는 inference에서도 성능이 유지된다.

No-Go 조건:

- pooled random split에서만 성능이 좋다.
- clinical-only 또는 age-only baseline과 큰 차이가 없다.
- UPENN/UCSD 같은 low-mutant cohort에서 recall이 붕괴한다.
- mask가 없으면 성능이 급락한다.
- scanner/site prompt가 사실상 label prior로 작동한다.

## Immediate Next Step

코드/학습으로 바로 가지 말고, 다음 산출물을 먼저 확정해야 한다.

1. `T1_structural_idh` split protocol: subject-level + leave-one-consortium-out.
2. full NIfTI header audit: shape/affine/orientation/spacing.
3. preprocessing policy: 1mm resampling 여부, crop size, normalization scope.
4. mask policy: zero-byte UCSD mask 제외/복구, UPENN missing 19 처리.
5. baseline scope: Res3DNet proxy까지 구현할지, original code를 참고해 재현할지.

## Sources

- Res3DNet: https://pmc.ncbi.nlm.nih.gov/articles/PMC12794414/
- Res3DNet code: https://github.com/YLiu-nju/Res3DNet/
- Glio-LLaMA-Vision: https://www.nature.com/articles/s41746-026-02581-x
- FoundBioNet: https://papers.miccai.org/miccai-2025/paper/4377_paper.pdf
- MTS-UNET: https://arxiv.org/pdf/2503.06828
- Choi hybrid CNN+radiomics: https://academic.oup.com/neuro-oncology/advance-article-abstract/doi/10.1093/neuonc/noaa177/5876011
- Swin Transformer IDH: https://www.mdpi.com/2077-0383/11/15/4625
- Systematic review/meta-analysis: https://link.springer.com/article/10.1007/s00330-025-11898-2
