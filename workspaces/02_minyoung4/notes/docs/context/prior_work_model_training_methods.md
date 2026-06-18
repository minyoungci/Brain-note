# Prior Work: Models and Training Methods for Glioma MRI IDH / Molecular Prediction

검증일: 2026-06-18

## 요약 결론

선행 연구는 이미 단순 3D CNN을 넘어섰다. 경쟁축은 크게 네 가지다.

1. **VLM / report-generation 계열**: Glio-LLaMA-Vision이 가장 직접적인 경쟁 연구다. MRI-report pair와 PMC image-text pretraining을 사용해 IDH 예측과 radiology report generation을 동시에 학습했다.
2. **Foundation 3D Transformer / segmentation-guided 계열**: FoundBioNet과 MTS-UNET은 BrainSegFounder/SWIN-UNETR 기반으로 segmentation과 IDH classification을 multi-task로 묶었다.
3. **Clinical-text multimodal Transformer 계열**: AVLT는 MRI와 임상 텍스트를 cross-modal attention, adaptive normalization, contrastive alignment로 결합한다. 다만 공개 HTML의 일부 수치가 placeholder처럼 보이므로 벤치마크 수치로 쓰기 전 PDF/code 검증이 필요하다.
4. **Radiomics / 2D Transformer baseline 계열**: XGBoost radiomics와 2D Swin Transformer가 외부검증 IDH baseline으로 강하다.

따라서 우리의 novelty는 "IDH 예측 모델을 만들었다"가 아니라, **multi-consortium public MRI에서 3D CNN보다 강하고, site/scanner shift와 mask dependency를 정면으로 통제한 3D prompt/transformer-style molecular prediction framework**로 잡아야 한다.

## 선행 연구별 모델과 학습 방법

| Work | Model | Training / loss | Validation | Key result | Implication for us |
|---|---|---|---|---|---|
| Glio-LLaMA-Vision, 2026 | BiomedCLIP ViT vision encoder + MLP projection + LLaMA 3.1 8B + classifier | PMC 2.79M image-text pair로 autoregressive feature-alignment pretraining, 이후 MRI-report pair와 age/sex로 fine-tuning. Molecular classifier는 cross-entropy. LLM은 freeze, vision/projection/classifier fine-tune. | Internal, AMC, TCGA, UCSF | IDH AUC 0.85-0.95 | VLM 직접 경쟁 연구. 우리에게 radiology report pair가 없으면 report-generation VLM claim은 피해야 한다. |
| FoundBioNet, 2025 | BrainSegFounder-Tiny 62M SWIN-UNETR + TAFE + CMD + DSF classifier | Segmentation Dice loss + IDH classification loss. Classification loss/checkpointing/early stopping을 IDH 성능 중심으로 둠. | Six public datasets, independent test sets | 여러 외부셋에서 AUC 약 65-91% 범위 | 3D CNN baseline보다 강한 mask-aware 3D Transformer competitor로 포함해야 한다. |
| MTS-UNET, 2025 | BrainSegFounder/SWIN-UNETR 기반 multi-task network | Segmentation, grade, IDH, 1p19q를 multi-task로 학습. TAFE/CMD/DSF 사용. 96x96x96 crop, z-score normalization. | 2249 glioma patients from seven public datasets | Dice 약 84%, IDH AUC 약 90% reported | "segmentation + molecular multi-task"는 이미 있음. 우리는 shift-robust/prompted 3D evidence 쪽으로 차별화해야 한다. |
| AVLT, 2025 | Vision encoder + ClinicalBERT/text encoder + cross-modal attention + adaptive gating/ANM | Task loss + contrastive alignment + auxiliary losses + student-teacher/self-distillation style setup. | Within-dataset and LODO-style cross-dataset validation | 수치 사용 전 재검증 필요 | Clinical-text conditioning, domain-specific normalization, LODO ablation 구조는 참고할 가치가 있다. |
| External radiomics XGBoost IDH, 2024 | PyRadiomics features + XGBoost | Semi-auto segmentation VOI에서 2364 radiomics features 추출, MinMaxScaler, correlated feature removal, SMOTE, RandomizedSearchCV. | 377 internal, 207 external | Internal AUC 0.862, external AUC 0.835 | Non-deep baseline으로 강하다. segmentation/radiomics 의존 baseline으로 비교 가능. |
| Swin Transformer segmentation-free IDH, 2022 | 2D Swin Transformer vs ResNet-101 + optional clinical hybrid | T2 slice, 256x256 input, bbox/mask/ROI 전략 비교, Adam, StepLR, early stopping. Patient-level averaging. | TCIA internal, AHXZ external | Swin external AUC 0.868, hybrid AUC 0.878 | Transformer가 CNN/ResNet보다 낫다는 기존 근거. 우리 논문은 2D가 아니라 3D shift-robust setting으로 넘어가야 한다. |

## 현재 연구 설계에 반영할 기준선

필수 baseline:

- 3D CNN: 3D ResNet / DenseNet / EfficientNet 계열 중 최소 1개.
- 2D Transformer: Swin segmentation-free 방식의 slice/bbox/ROI baseline.
- Radiomics: mask 기반 PyRadiomics + XGBoost.
- Segmentation-guided 3D Transformer: FoundBioNet/MTS-UNET style의 mask-aware competitor 또는 재현 가능한 proxy.
- Clinical-only: age/sex/scanner/site/logistic or XGBoost. IDH는 dataset/site confounding이 강하므로 반드시 필요.

필수 ablation:

- MRI only vs MRI + age/sex vs MRI + clinical prompt.
- Whole volume vs tumor crop vs mask channel vs mask dropout.
- Random split vs subject split vs leave-one-consortium-out.
- Without domain/site regularization vs with domain/site regularization.
- Calibration/ECE and external AUC, not only internal AUC.

## 우리에게 유리한 novelty 문장

가능한 claim:

> We introduce a shift-aware 3D molecular prediction framework for glioma MRI that explicitly benchmarks against 3D CNN, radiomics, 2D Transformer, and segmentation-guided foundation-model baselines under subject-isolated and leave-consortium-out evaluation.

피해야 할 claim:

- "First VLM for glioma IDH prediction": Glio-LLaMA-Vision 때문에 불가능하다.
- "First segmentation + IDH multi-task model": FoundBioNet/MTS-UNET 계열 때문에 불가능하다.
- "External validation만으로 novelty": 이미 radiomics, Swin, VLM 계열에 외부검증이 있다.

## Sources

- Glio-LLaMA-Vision: https://www.nature.com/articles/s41746-026-02581-x
- FoundBioNet: https://papers.miccai.org/miccai-2025/paper/4377_paper.pdf
- MTS-UNET: https://arxiv.org/pdf/2503.06828
- AVLT: https://www.mdpi.com/2227-9059/13/12/2864
- External radiomics XGBoost IDH: https://academic.oup.com/noa/article/6/1/vdae157/7808961
- Swin Transformer segmentation-free IDH: https://www.mdpi.com/2077-0383/11/15/4625
