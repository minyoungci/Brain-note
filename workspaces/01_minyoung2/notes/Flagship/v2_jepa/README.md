# v2_jepa: Brain-JEPA 3D Multimodal Foundation Candidate

`v2_jepa`는 현재 foundation decoder 교체가 아니라, 다음 foundation pretraining 후보를 다룬다.

## Current Status

Parked. Do not run JEPA smoke tests, unit tests, training, or pilot experiments until the user explicitly resumes JEPA work.

Current active Flagship work is:

```text
Flagship/v1_evidence/ = existing foundation decoder replacement experiments
```

## Scope

- Brain-JEPA 3D multimodal SSL objective
- context encoder and EMA target encoder
- latent prediction instead of voxel reconstruction
- cross-modality / multi-view extension planning
- collapse diagnostics for JEPA-style objectives

## Boundary

`v2_jepa`는 Task2 decoder replacement를 다루지 않는다. 현재 foundation의 S3D decoder를 바꾸는 실험은 `Flagship/v1_evidence/`에만 둔다.

## Key Files

```text
plans/Plan_D_Brain_JEPA_3D_Multimodal.md
plans/Plan_F_Anatomy_Modality_Aware_Training.md
code/brain_jepa/
code/tests/test_brain_jepa.py
code/smoke_brain_jepa.py
code_review/Review_Pass_1_Static_API.md
code_review/Review_Pass_2_Shape_Gradient_EMA.md
code_review/Review_Pass_3_Scope_Integration.md
code_review/Review_Pass_4_Loss_Landscape_Geometry.md
```

## Parked Validation Commands

These commands are retained for future use only. Do not run them during the current v1 decoder-replacement phase.

```bash
python -m unittest Flagship.v2_jepa.code.tests.test_brain_jepa
python -m unittest Flagship.v2_jepa.code.tests.test_loss_geometry
python Flagship/v2_jepa/code/smoke_brain_jepa.py
```
