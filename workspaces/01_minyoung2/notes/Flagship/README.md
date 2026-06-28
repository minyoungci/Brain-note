# Flagship Research Workspace

이 폴더는 FOMO challenge 제출물과 분리된 **foundation model 기술 novelty 검증 및 논문용 figure/table 제작 공간**이다.

## 분리 원칙

- `Challenge_Submission/`은 제출 컨테이너, validator, downstream task별 제출 준비만 다룬다.
- `Flagship/`은 지금까지의 challenge downstream 성능 개선과 무관하게, foundation model 자체의 기술적 novelty와 강점을 보여주는 figure/table을 준비한다.
- 이 폴더에는 challenge 제출용 `.sif`, raw data, private label dump를 저장하지 않는다.
- challenge 결과는 필요한 경우 motivation/background로만 인용하고, `Flagship`의 주된 성공 기준으로 삼지 않는다.

## 현재 중심 가설

```text
ResEnc + S3D-style anti-leakage dense branch + InfoNCE global branch is a
technically defensible 3D brain MRI foundation model design because it solves
three foundation-level problems: masked skip leakage, dense-global objective
imbalance, and CNN global representation collapse.
```

## 현재 모델 요약

- Foundation checkpoint: `experiments/phase_b/resenc_s3d_wg0.5/latest.pt`
- Architecture: ResEnc shared encoder + S3D-style masked dense reconstruction + InfoNCE global contrastive branch
- Selected variant: `wg0.5`, because it balances dense/seg and global cls/reg transfer
- Downstream task results are not the organizing axis of this folder.
- The organizing axis is: architecture, objective design, failure mode analysis, pretraining diagnostics, and paper-ready visual evidence.

## 문서 구성

```text
Flagship/
├── README.md
├── 00_project_brief.md
├── Risk_Register.md
├── Decision_Log.md
├── Scope.md
├── plans/
│   ├── Plan_A_Methods_Conference.md
│   ├── Plan_B_External_Consortium_SCI.md
│   ├── Plan_C_FewShot_Segmentation.md
│   └── Plan_D_Brain_JEPA_3D_Multimodal.md
├── experiments/
│   ├── Experiment_Matrix.md
│   ├── Baselines_and_Statistics.md
│   ├── Foundation_Novelty_Matrix.md
│   └── Task2_R4_Frozen_Protocol.md
├── figures/
│   └── Figure_Plan.md
├── tables/
│   └── Table_Plan.md
└── manuscript/
    └── Outline.md
```

## 가장 중요한 다음 산출물

Challenge 제출 성능이 아니라, foundation model 자체의 novelty를 설명하는 figure/table packet을 먼저 완성한다.

Priority packet:

```text
Figure 1. Overall architecture: ResEnc + S3D-style dense + InfoNCE global
Figure 2. Anti-leakage S3D dense branch: re-mask/submanifold-style mechanism
Figure 3. Dense-global objective balance and collapse prevention
Figure 4. Pretraining diagnostics: leakage, collapse, gradient/objective behavior
Table 1. Module-by-module novelty and design rationale
Table 2. Ablation matrix for foundation-level claims
Plan D. Brain-JEPA 3D Multimodal as the next foundation-model candidate
```

Downstream/few-shot results may later support the paper, but they do not define the scope of `Flagship`.
