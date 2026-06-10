# PaperBanana Prompt — MTKD Training Flow for MRI Encoder Warm-start

Create a publication-ready academic methodology figure showing the Multi-Teacher Knowledge Distillation (MTKD) training flow used as an optional MRI encoder warm-start for an Alzheimer/dementia 3D MRI-language VLM study.

## Figure title
Multi-Teacher Knowledge Distillation (MTKD) for 3D MRI Encoder Warm-start

## Central message
MTKD is a supervised MRI encoder pretraining step, not the final VLM contrastive learning objective. Two binary teacher classifiers trained on ambiguous dementia boundaries provide soft probability distributions to a student 3D MRI classifier. The student learns from both hard CN/MCI/AD labels and teacher soft targets using cross-entropy plus KL-divergence. The trained student encoder initializes or warm-starts the downstream MRI-language VLM image encoder.

## Required layout
Use a clean left-to-right flowchart with 5 columns. Use muted journal colors. Use blue for MRI input, purple for teacher/student networks, orange for losses, green for downstream VLM use, and red for caution/claim boundaries. Do not use cartoons or decorative icons.

### Column 1 — Input and labels
Title: 1. MRI classification pretraining data
Show:
- 3D T1w MRI volume
- subject-disjoint train/validation split
- hard diagnosis labels: CN, MCI, AD
- optional ROI/segmentation input if available, but label it optional
Add note: No clinical/biomarker text is required for MTKD itself.

### Column 2 — Train teacher classifiers
Title: 2. Binary teacher models
Show two parallel teacher branches:
- Teacher A: AD vs CN classifier
- Teacher B: MCI vs CN classifier
Each teacher receives 3D T1w MRI and outputs a probability distribution.
Label outputs:
- p_A(AD), p_A(CN)
- p_B(MCI), p_B(CN)
Add small note: Teachers capture boundary-specific uncertainty.

### Column 3 — Build soft supervision
Title: 3. Soft target construction
Show teacher outputs being converted/combined into soft targets for the three-class task.
Label:
- teacher soft probabilities
- uncertainty-aware class similarity
- soft target distribution over CN / MCI / AD
Add note: The exact mapping can be implementation-specific and should be reported.

### Column 4 — Student MTKD training
Title: 4. Student 3D MRI classifier
Show student network:
- 3D T1w MRI → student 3D DenseNet/ResNet encoder → classification head
Output:
- student probabilities: q(CN), q(MCI), q(AD)
Show two losses going into the student:
- Hard-label loss: Cross-entropy with CN/MCI/AD label
- Distillation loss: KL divergence between teacher soft targets and student probabilities
Show formula:
L_MTKD = L_CE(y, q) + λ L_KL(p_teacher, q)
Add note: λ controls teacher influence.

### Column 5 — Output and downstream use
Title: 5. Warm-start for MRI–Language VLM
Show:
- trained student MRI encoder
- remove or replace classification head
- initialize downstream image encoder
- downstream stage: MRI/ROI visual embedding aligned with controlled clinical/ROI text embedding by InfoNCE
Add boundary note in red:
MTKD is a supervised warm-start / ablation module, not the main VLM contribution.

## Bottom caution box
Add a clear caution strip at the bottom:
Because MTKD uses CN/MCI/AD labels, report it separately from self-supervised or contrastive VLM learning. Include ablations: no MTKD, supervised CE-only pretraining, and MTKD warm-start.

## Style constraints
- Clean academic block diagram.
- Readable labels.
- Do not imply biomarkers or clinical text are used inside MTKD.
- Do not show PET/CSF as MTKD input.
- Do not call MTKD zero-shot learning.
- Do not make the final output look like diagnosis is the only study target; show it as image encoder warm-start for later VLM.
- No fake numbers, no decorative brain rendering, no generic AI robot icons.
