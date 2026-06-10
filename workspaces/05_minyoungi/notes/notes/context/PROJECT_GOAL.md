# PROJECT_GOAL — VLM/MLLM Brain MRI Research

Updated: 2026-05-19
Workspace: `/home/vlm/minyoungi`

## 결론

이번 연구의 중심은 **VLM/MLLM 기반 3D brain MRI representation learning**이다.

핵심 질문:

> 구조화 임상 정보를 자연어 supervision으로 바꿔 학습한 3D MRI 표현이, 치매 cohort 간 일반화되고 PET/ATN 또는 longitudinal endpoint와 정렬되는가?

## Main framing

권장 표현:

> Language-supervised multimodal neuroimaging representation learning for dementia progression and PET/ATN-aware validation.

한국어:

> 치매 진행 및 PET/ATN 검증을 위한 언어지도 멀티모달 뇌영상 표현학습.

## Scope

### 집중할 것

- 3D T1w MRI 중심의 brain MRI VLM/MLLM.
- ROI/segmentation mask 또는 ROI-token 기반 visual grounding.
- 구조화 임상/tabular metadata를 controlled natural language caption으로 변환.
- Caption leakage를 통제한 image-text representation learning.
- Multi-cohort generalization.
- Downstream image-only 또는 allowed-clinical inference.
- PET/ATN은 expensive biomarker alignment/validation 또는 privileged supervision branch로 사용.
- Longitudinal diagnosis/CDR/CDR-SB progression은 중요한 downstream validation axis.

### 지금 피할 것

- PET amyloid binary prediction을 main research로 축소하지 않는다.
- AD/CN/MCI 단순 classification을 main novelty로 두지 않는다.
- Radiology report VLM이라고 부르지 않는다. 현재 핵심 text source는 report가 아니라 structured clinical language다.
- Synthetic caption에 target label을 넣고 같은 target을 예측하는 leakage 설계를 하지 않는다.
- V4-Lite/longitudinal JEPA framing으로 기본 회귀하지 않는다.

## Working task hierarchy

### Task A — Main

**ROI-grounded 3D MRI + structured clinical language representation learning**

Question:

> ROI로 시각적 초점을 준 3D MRI 표현이 template, diagnosis, age, scanner, cohort shortcut에 무너지지 않고 structured clinical language와 정렬되는가?

Primary inputs:

- 3D T1w MRI
- segmentation/ROI mask or ROI tokens
- structured clinical captions with task-specific allowed fields

Primary outputs:

- image embedding
- text embedding
- image-text retrieval metrics
- downstream image-only probes
- shortcut/leakage audit metrics

### Task B — Longitudinal validation

**Progression-aware VLM representation**

Question:

> baseline MRI/text representation이 future diagnosis conversion 또는 CDR-SB change를 예측/정렬하는가?

Outputs:

- future CDR-SB change prediction
- MCI-to-AD/progression risk score
- longitudinal retrieval/case matching

### Task C — PET/ATN validation branch

**PET/ATN-aware privileged alignment**

Question:

> sparse PET/ATN endpoint가 MRI-text representation을 expensive biomarker direction으로 정렬시키는가?

Role:

- PET/ATN은 main task가 아니라 validation/supervision branch.
- PET status, centiloid, SUVR text는 PET prediction downstream에서는 forbidden field다.

## Required next context artifacts

다음 설계 산출물을 만들어야 한다.

1. `VLM_READY_MANIFEST_SPEC.md`
   - image path, ROI/mask availability, clinical fields, longitudinal labels, PET/ATN availability, split key.
2. `CAPTION_FIELD_POLICY.md`
   - task별 allowed/forbidden text fields.
3. `PAPER_READING_MATRIX.md`
   - ADLIP, NeuroVLM, Natural Text Supervision MRI, M3D/M3D-LaMed, CT-CLIP/CT-GLIP의 input/text/split/baseline/leakage 정리.
4. `BASELINE_GATE.md`
   - text-only, clinical-only, ROI-only, image-only, image+clinical, VLM 비교 기준.

## Baseline gate

VLM claim은 다음을 통과해야 한다.

- Text-only shortcut baseline보다 의미 있어야 한다.
- Clinical/tabular-only baseline보다 의미 있어야 한다.
- ROI-only baseline과 image-only baseline을 모두 비교해야 한다.
- Subject-disjoint split을 지켜야 한다.
- Cohort-held-out 또는 leave-one-cohort-out 평가를 포함해야 한다.
- Target field leakage가 없어야 한다.
- Scanner/cohort/site shortcut을 audit해야 한다.
