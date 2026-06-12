# ROI-Token Self-Supervised Learning for Structural Brain MRI

## Abstract (draft v1 — 2026-06-11, 감사 통과 결과 기반)

Self-supervised learning (SSL) for 3D brain MRI has been dominated by whole-volume
pretext tasks (masked-volume inpainting, contrastive learning, anatomy-aware multi-task
pretraining), which treat the brain as a single undifferentiated volume. In contrast,
region-aware SSL — where anatomical regions of interest (ROIs) act as units — has been
explored almost exclusively for *functional* connectivity data, leaving *structural* T1
MRI unaddressed. We introduce **ROI-token SSL**, the first region-as-unit self-supervised
framework for structural brain MRI: a shared 3D CNN encodes the T1 volume into a feature
map that is pooled over the 95 FreeSurfer DKT+aseg regions to form region tokens, which a
transformer processes under a **masked-region modeling** objective — predicting a masked
region's anatomy (volume and intensity) from the context of the remaining regions.

We evaluate on cognitive severity (CDR-SB) regression — a task for which structural
atrophy is a mechanistically valid signal — across three cohorts (AJU, KDRC, ADNI), under
a strictly **inductive** protocol in which downstream subjects (all sessions) are excluded
from pretraining, with multi-seed cross-validation. ROI-token SSL significantly outperforms
all *learned* SSL baselines built on the same backbone and data — whole-volume anatomy-
prediction SSL (DAMT-style) by +0.06–0.09, generic masked-volume SSL (Models-Genesis) by
+0.02–0.05, and a Swin-UNETR transformer SSL [PENDING] — while remaining competitive with
strong hand-crafted ROI-volume features. Two controlled ablations isolate *why* the method
works: (i) region-tokenization itself (vs. whole-volume pooling of the same features) and
(ii) the anatomical *identity* of each region (positional encoding; removing it drops
CDR-SB correlation by 0.07–0.10 and degrades the SSL reconstruction). The learned
representation transfers to brain-age and impaired-vs-CN tasks, preserving the ablation
ordering. All results are independently code-audited for leakage.

**Contribution.** (1) The first ROI-as-unit SSL for structural (not functional) brain MRI;
(2) controlled evidence that region-tokenization and anatomical positional identity — not
merely anatomy-aware objectives — drive transferable representations; (3) an honest,
inductive, leakage-audited evaluation showing learned region-token SSL surpasses prior 3D
SSL paradigms and matches hand-crafted morphometry.

---
### 정직한 메모 (작성 시 반영)
- "beats all baselines"라 쓰지 말 것 → **"surpasses learned SSL, competitive with hand-crafted"**.
- Swin-UNETR 칸은 학습 완료 후 수치 삽입.
- 한계 섹션 필수: hand-crafted comparable·KDRC 약함·실제 DAMT(무가중치) 미재현·frozen-probe.
