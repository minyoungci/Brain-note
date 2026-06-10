# Brain MRI VLM 선행연구와 text-alignment 설계 메모

Created UTC: `2026-05-18`
Workspace: `/home/vlm/minyoungi/literature`

## 한 줄 결론

3D T1w MRI + ROI/segmentation mask + 합성 clinical/report text를 CLIP류 contrastive VLM으로 학습하는 방향은 **충분히 시도할 가치가 있다**. 단, 성능이 나려면 “합성 report를 정답 문장으로 외우게 하는 report-generation 문제”가 아니라, **ROI-grounded visual representation이 clinical/PET/longitudinal endpoint와 정렬되는지 검증하는 language-supervised representation learning**으로 설계해야 한다.

가장 안전한 연구 질문은 다음이다.

> Can ROI-grounded 3D MRI representations align with structured clinical language and expensive PET/ATN or longitudinal endpoints without collapsing to template, diagnosis, age, scanner, or cohort shortcuts?

한국어:

> ROI로 시각적 초점을 준 3D MRI 표현이, 템플릿/진단명/나이/스캐너/코호트 shortcut에 무너지지 않고 구조화 임상 언어 및 PET/ATN·longitudinal endpoint와 정렬되는가?

---

## 1. 반드시 직접 읽어야 하는 VLM / Brain MRI 관련 논문

### Tier 0 — 우리 연구와 직접 충돌하거나 바로 설계에 반영해야 함

#### 1. ADLIP — A vision-language foundation model for Alzheimer's disease diagnosis using MRI and clinical data

- Source: PMC / Wiley, *Alzheimer's & Dementia*, 2025
- URL: <https://pmc.ncbi.nlm.nih.gov/articles/PMC12745493/>
- Model: ADLIP, Alzheimer's Disease Language and Image Pre-Training
- 핵심:
  - 3D T1-weighted MRI와 structured clinical records를 contrastive learning으로 align.
  - Bio_ClinicalBERT 계열 text encoder + 3D image encoder.
  - AD/MCI/CN classification, zero-shot diagnosis, longitudinal evaluation, subgroup generalization을 주장.
- 우리에게 중요한 이유:
  - “3D MRI + structured clinical text VLM”은 이미 AD domain에서 나왔다. 따라서 단순히 MRI+clinical text CLIP을 만든다는 것만으로는 novelty가 부족하다.
  - 우리가 차별화하려면 ROI grounding, PET/ATN privileged supervision, multi-cohort held-out, leakage-control, clinical-only/ROI-only baseline을 반드시 넣어야 한다.
- 정독 시 체크할 것:
  - text가 정확히 어떤 structured field로 구성되는지.
  - diagnosis/MMSE 등 target-leaky field가 caption에 들어가는지.
  - train/test subject split과 cohort split.
  - clinical-only baseline과 MRI-only baseline 유무.
  - zero-shot claim이 template prompt selection에 얼마나 민감한지.

#### 2. NeuroVLM — A Contrastive Vision-Language Model for Medical Reasoning in Alzheimer's Disease Diagnosis

- Source: WACV 2026 Workshops / CVF Open Access
- URL: <https://openaccess.thecvf.com/content/WACV2026W/P2P/html/Sajib_NeuroVLM_A_Contrastive_Vision-Language_Model_for_Medical_Reasoning_in_Alzheimers_WACVW_2026_paper.html>
- 핵심:
  - ADNI T1-weighted MRI와 structured clinical captions로 CLIP ViT-B/32를 fine-tune.
  - image-text retrieval benchmark를 제시.
  - 검색 결과/abstract 기준: 2,294 T1w MRI scans, 639 subjects, image-to-text retrieval R@1 약 53.77%를 보고.
- 우리에게 중요한 이유:
  - “ADNI T1 MRI + structured caption + CLIP retrieval”은 이미 매우 가까운 선행연구다.
  - 우리 쪽 novelty는 더 큰 multi-cohort, 3D encoder, ROI mask prompt, PET/ATN/longitudinal endpoint, leakage/template shortcut audit로 가야 한다.
- 정독 시 체크할 것:
  - MRI를 2D slice로 썼는지, 3D volume 정보를 얼마나 보존했는지.
  - caption template 종류와 negative pair 구성.
  - retrieval metric이 diagnosis/age/sex template shortcut으로 가능한지.
  - ADNI-only limitation.

#### 3. Leveraging a Vision-Language Model with Natural Text Supervision for MRI Retrieval, Captioning, Classification, and Visual Question Answering

- Source: PubMed record, preprint
- PMID: `40027630`
- URL: <https://pubmed.ncbi.nlm.nih.gov/40027630/>
- 핵심:
  - vector retrieval + contrastive learning으로 brain MRI concept를 natural language supervision에서 학습.
  - MRI retrieval, captioning, classification, VQA를 하나의 framework로 시도.
  - AD에서 brain에 영향을 주는 factor를 joint embedding으로 식별하는 방향.
- 우리에게 중요한 이유:
  - “진짜 radiology report가 없어도 clinical description/text prompt로 brain MRI VLM을 만들 수 있다”는 근거가 된다.
  - 단, preprint이므로 final evidence보다는 방법론 후보로 취급.
- 정독 시 체크할 것:
  - caption 생성 방식: free text인지 structured-to-text인지.
  - classification에서 text/covariate가 inference에 들어가는지.
  - visual evidence를 어떻게 검증했는지.

#### 4. M3D / M3D-LaMed — Advancing 3D Medical Image Analysis with Multi-Modal Large Language Models

- arXiv: `2404.00578`
- URL: <https://arxiv.org/abs/2404.00578>
- 핵심:
  - 3D medical image + text/VQA/report generation을 위한 대규모 3D medical MLLM benchmark/model.
  - M3D-Data는 약 120K 규모 3D medical tasks를 포함한다고 보고.
- 우리에게 중요한 이유:
  - 3D VLM/MLLM 구현 시 architecture, token compression, image-text retrieval, report generation evaluation의 baseline reference.
  - AD-specific은 아니지만 3D volume을 language model에 연결하는 일반 방법론 anchor.
- 정독 시 체크할 것:
  - 3D encoder 구조와 visual token compression.
  - report generation vs retrieval vs VQA objective balance.
  - synthetic VQA/report 생성 quality control.

#### 5. CT-CLIP / CT-RATE / CT-CHAT 계열

- Example source: CT-RATE HuggingFace page, CT-CLIP GitHub/search result
- URL: <https://huggingface.co/datasets/ibrahimhamamci/CT-RATE>
- 핵심:
  - 3D CT volume과 radiology text report를 paired dataset으로 만들고, CT-CLIP/CT-CHAT류 모델을 학습.
- 우리에게 중요한 이유:
  - 3D image-text contrastive learning에서 “report가 있는 경우”의 상한선/표준 디자인을 보여준다.
  - 우리 데이터는 report가 없으므로 CT-RATE처럼 보고서 원문이 있다는 가정을 하면 안 된다.
- 정독 시 체크할 것:
  - report pair가 있을 때 alignment objective를 어떻게 구성했는지.
  - organ/local finding grounding이 global report alignment보다 왜 중요한지.
  - 우리의 ROI mask prompt 설계에 옮길 수 있는 부분.

### Tier 1 — 방법론/평가 설계 anchor

#### 6. Med3DVLM — An Efficient Vision-Language Model for 3D Medical Image Analysis

- arXiv search result: `2503.20047`
- 핵심:
  - 3D VLM에서 compute 부담과 3D spatial feature-text alignment 문제를 다룸.
  - SigLIP류 pairwise sigmoid contrastive loss, 3D encoder, dual-stream projector 등 제안.
- 우리에게 중요한 이유:
  - 작은 batch/큰 3D volume 환경에서 CLIP loss가 어려울 때 SigLIP류 objective가 실용적일 수 있음.

#### 7. CT-GLIP — 3D Grounded Language-Image Pretraining with CT Scans and Radiology Reports

- arXiv: `2404.15272`
- 핵심:
  - global image-report alignment보다 organ/finding-level grounded alignment가 중요하다는 방향.
- 우리에게 중요한 이유:
  - ROI mask visual prompt를 단순 augmentation이 아니라 **grounded language-image alignment**로 주장할 수 있는 근거.

#### 8. Argus / 3D radiology report generation benchmark 계열

- arXiv search result: `2406.07146`
- 핵심:
  - 3D report generation에서 vision encoder pretraining, token compression, scaling, benchmark가 중요함.
- 우리에게 중요한 이유:
  - 합성 report generation을 하더라도 BLEU/ROUGE 같은 surface metric은 위험하고, clinical correctness/grounding/label leakage audit이 필요하다는 경고.

---

## 2. Report가 없는 경우 text alignment를 어떻게 만들 수 있는가

우리 상황은 chest X-ray/CT-RATE처럼 radiology report pair가 있는 문제가 아니다. 따라서 text는 “의사의 자유 판독문”이 아니라 다음 중 하나로 정의해야 한다.

### A. Structured clinical language caption

입력 가능한 field 예시:

- age, sex
- diagnosis, CDR global, CDR-SB, MMSE 등 clinical state
- cohort/scanner/field strength는 metadata로는 보존하되, caption에 직접 넣을지는 task별로 결정
- PET/amyloid/tau/FDG status는 target task에서는 금지하고, privileged supervision task에서만 허용

문제:

- diagnosis를 caption에 넣고 diagnosis retrieval/classification을 하면 leakage.
- age/sex/cohort/scanner만으로도 일부 label을 맞힐 수 있음.
- template가 고정되면 모델이 MRI가 아니라 sentence pattern을 배움.

### B. ROI-grounded pseudo-report

MRI volume + segmentation/ROI volume에서 정량 feature를 뽑아 자연어로 바꾼다.

예시:

```text
The scan shows relatively low hippocampal volume percentile for age and sex, with medial temporal atrophy-like pattern. Global cortical gray matter volume appears reduced compared with cognitively normal references.
```

중요:

- “hippocampal atrophy” 같은 표현은 FreeSurfer/segmentation percentile 등 측정 가능한 feature에 근거해야 한다.
- absolute label을 쓰기보다 percentile/bin/uncertainty로 표현.
- text를 정답 label로 쓰는 것이 아니라 ROI-aware representation target으로 사용.

### C. Multi-template stochastic caption

고정 template 하나를 쓰지 말고, 같은 row에 대해 여러 paraphrase를 생성한다.

- Field dropout: 일부 field를 랜덤 제거.
- Order shuffle: age/sex/clinical/ROI 순서 변경.
- Synonym/paraphrase: “mild cognitive impairment” / “MCI-stage clinical profile” 등.
- Numeric jitter/binning: exact CDR-SB 대신 bin 또는 range.
- Negative caption: matched hard negative를 만들어 trivial template matching 방지.

목표:

- 모델이 exact sentence form이 아니라 underlying clinical/visual concept에 align되도록 한다.

### D. Text as privileged supervision, not required at inference

가장 안전한 형태:

- Training: image + ROI mask + synthetic/structured text + endpoint label.
- Inference: image-only 또는 image+allowed clinical only.
- Evaluation: text를 넣었을 때만 좋아지는 모델은 “실제 MRI visual learning” claim에서 제외.

즉 text는 MRI encoder를 regularize/align하는 역할이어야지, downstream target을 직접 알려주는 input이면 안 된다.

---

## 3. Template collapse / text shortcut을 막는 설계

### 금지해야 할 쉬운 실패

1. Target label을 caption에 넣고 같은 target을 예측.
2. 모든 caption이 같은 순서/문법/길이를 가져서 template ID가 label proxy가 됨.
3. cohort/scanner/site가 diagnosis 분포를 대변.
4. PET-positive caption을 보고 PET-positive를 맞힘.
5. ROI text percentile을 만들 때 downstream label을 이용해 bin을 정의.
6. train/test split이 subject-disjoint가 아니어서 동일 subject template/scan pattern이 새는 경우.

### 최소 방어 장치

- Task별 `allowed_text_fields` / `forbidden_text_fields` 명시.
- Text-only baseline: caption만으로 target을 얼마나 맞히는지 먼저 측정.
- Clinical-only/tabular-only baseline: MRI 없이 얼마나 되는지 측정.
- ROI-only baseline: segmentation/volume만으로 얼마나 되는지 측정.
- Image-only baseline: text alignment 없이 3D MRI encoder가 얼마나 되는지 측정.
- Image+text model은 image-only/ROI-only/clinical-only를 넘어야 함.
- Leave-one-cohort-out 또는 cohort-held-out 평가.
- Scanner/site prediction adversarial audit.
- Subject-level split, 가능하면 family/duplicate/session leakage audit.

### Caption augmentation recipe

각 row마다 4종류 caption을 생성한다.

1. `demographic_caption`
   - age/sex only; diagnosis/PET/CDR 금지.
2. `clinical_state_caption`
   - CDR/MMSE/diagnosis 등 clinical state; 단 해당 target task에서는 금지.
3. `roi_morphology_caption`
   - hippocampus/ventricle/cortical GM/WM/ICV-normalized percentile 등 image-derived text.
4. `biomarker_caption`
   - PET/ATN/amyloid/tau/FDG status; PET/ATN alignment pretraining에서만 사용, PET prediction downstream에서는 금지.

---

## 4. 3D MRI + ROI mask visual prompt + 합성 report + CLIP 구조의 기대 성능 판단

### 내 판단: 가능성은 있음. 하지만 그냥 붙이면 실패 가능성이 높다.

가능한 이유:

- ADLIP/NeuroVLM/Natural Text Supervision MRI 논문들이 이미 “MRI + structured text/caption + contrastive learning” 방향의 feasibility를 보여준다.
- ROI mask는 global CLIP보다 더 좋은 inductive bias를 줄 수 있다. AD에서는 hippocampus, medial temporal lobe, ventricle, cortical atrophy pattern 등 anatomical prior가 강하다.
- report가 없더라도 structured clinical fields와 ROI-derived morphology text는 weak language supervision으로 쓸 수 있다.

실패하기 쉬운 이유:

- synthetic report가 label/covariate shortcut을 너무 많이 포함하면 image encoder가 MRI를 안 봐도 된다.
- template가 고정되면 CLIP이 semantic alignment가 아니라 template matching을 배울 수 있다.
- ROI mask가 너무 강하면 모델이 raw image가 아니라 segmentation pipeline의 bias만 학습한다.
- AD/MCI/CN diagnosis 자체는 이미 saturated task라, VLM novelty가 약하다.

### 성능이 기대되는 조건

다음 조건을 만족하면 기대할 수 있다.

1. ROI mask는 input channel 또는 cross-attention prompt로 넣되, raw MRI channel을 반드시 유지.
2. Text는 target을 직접 말하지 않고, visual/clinical concept를 분리해서 제공.
3. Contrastive loss만 쓰지 말고 image-only SSL/MAE 또는 supervised endpoint loss를 같이 둔다.
4. Retrieval 성능뿐 아니라 downstream image-only probe에서 개선을 보여준다.
5. Cohort-held-out에서 clinical-only/ROI-only baseline보다 개선이 있어야 한다.
6. PET/ATN은 “정답 report text”가 아니라 expensive privileged endpoint로 두고, MRI representation이 biomarker와 align되는지 본다.

### 추천 architecture v0

```text
Input:
  - 3D T1w MRI volume
  - ROI/segmentation mask channels or ROI-token prompts
  - optional tabular clinical fields for allowed tasks

Image branch:
  - 3D ResNet / 3D Swin / MONAI encoder
  - ROI-aware pooling: global token + hippocampus token + ventricle token + cortical GM token

Text branch:
  - ClinicalBERT / BioClinicalBERT / PubMedBERT text encoder
  - Multi-template stochastic captions

Loss:
  - image-text contrastive loss, preferably SigLIP/InfoNCE variant
  - image-only SSL or reconstruction/MAE auxiliary loss
  - supervised probe loss for diagnosis/CDR/PET/longitudinal target, with forbidden text fields removed
  - optional ROI-token ↔ ROI-phrase local contrastive loss

Inference modes:
  - image-only
  - image + allowed clinical
  - retrieval / case search
```

### 실험 순서

1. **Non-VLM baselines first**
   - clinical-only
   - ROI volume-only
   - image-only 3D CNN
   - image+clinical fusion

2. **VLM smoke test**
   - T1w 2.5D/slice or 3D low-res encoder + stochastic captions.
   - Evaluate image-text retrieval and text-only shortcut baseline.

3. **ROI-grounded VLM**
   - Add ROI mask channel/tokens.
   - Add ROI morphology captions.
   - Check whether attention/Grad-CAM/ROI ablation actually uses ROI regions.

4. **PET/ATN privileged alignment**
   - Train on rows with PET/ATN endpoint.
   - Test image-only PET/ATN probe on held-out/cohort-held-out.
   - Report MCI-only and close MRI-PET interval subgroup.

5. **Longitudinal evaluation**
   - Baseline MRI/text embedding predicts future CDR-SB change or MCI conversion.
   - Stronger claim than AD/MCI/CN classification.

---

## 5. 우리가 주장하면 안 되는 것 / 주장 가능한 것

### 위험한 claim

- “Radiology report VLM”
  - 실제 report가 없으면 공격받는다.
- “T1w MRI replaces PET”
  - PET signal은 T1w에서 제한적이고 indirect proxy다.
- “Synthetic report generation is clinically valid”
  - physician report가 아니라 structured pseudo-report다.
- “AD diagnosis VLM is novel”
  - ADLIP/NeuroVLM 등 가까운 선행연구가 있음.

### 더 안전한 claim

- “structured clinical language-supervised 3D brain MRI representation learning”
- “ROI-grounded vision-language alignment for dementia MRI”
- “PET/ATN-privileged language supervision under missing-modality and cohort-shift constraints”
- “image-only deployment after text-supervised pretraining”
- “multi-cohort evaluation with explicit text/covariate/leakage controls”

---

## 6. 바로 다음 action

1. ADLIP, NeuroVLM, Natural Text Supervision MRI 세 논문을 먼저 정독한다.
2. 각 논문에서 caption/template/field leakage/split/baseline을 table로 뽑는다.
3. 우리 manifest에 대해 task별 `allowed_text_fields` / `forbidden_text_fields` registry를 만든다.
4. VLM-ready manifest v0에는 최소한 다음 column을 둔다.
   - subject/session/image path
   - cohort/scanner/field strength
   - diagnosis/CDR/CDR-SB/MMSE/age/sex
   - ROI features availability
   - PET/ATN availability and MRI-PET interval
   - split group key
   - allowed/forbidden text field sets per task
5. 가장 작은 smoke test는 image-text retrieval이 아니라, **caption leakage audit + clinical-only/ROI-only/image-only baseline**부터 한다.

## 7. 현재 Min 질문에 대한 답

> 3D MRI + ROI mask로 Visual prompt를 주고 합성 report도 함께 CLIP과 같은 VLM 아키텍쳐로 학습시킨다면 성능을 기대할 수 있을까?

답: **기대할 수 있다. 다만 합성 report를 그대로 강한 supervision으로 쓰면 MRI를 안 보고 text/label/template shortcut만 배울 가능성이 크다.**

가장 좋은 형태는 다음이다.

> ROI mask로 visual inductive bias를 주고, 합성 report는 stochastic/field-controlled/ROI-grounded language supervision으로만 사용하며, 최종 성능은 image-only 또는 allowed-clinical-only inference에서 clinical-only·ROI-only·image-only baseline을 넘어서는지로 판단한다.

이 조건을 통과하면 VLM이라고 부를 수 있고, 통과하지 못하면 “좋은 caption generator” 또는 “clinical text shortcut model”에 가깝다.
