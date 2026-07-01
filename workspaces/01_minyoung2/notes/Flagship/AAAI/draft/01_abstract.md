# Abstract (draft, 2026-07-01)

> Working title: **When Rank Misleads: A Cautionary, Shortcut-Controlled Study of Label-Free
> Checkpoint Selection for Dense+Global 3D Brain-MRI Foundation Models**
>
> Status: writable from confirmed/audited results. Numbers final except (i) ADNI→KDRC dementia leg
> (KDRC data in transfer) and (ii) minor CI refinement. Framing is **methodological/cautionary**, not a
> claim of state-of-the-art foundation performance.

---

## Abstract (~190 words)

Self-supervised 3D brain-MRI foundation models expose many checkpoints that differ in how they balance a
dense (local reconstruction) and a global (image-level) objective, and practitioners increasingly select
one **without labels** using effective-rank criteria such as RankMe. We show this can fail catastrophically.
Training a single residual-encoder U-Net (dense masked modeling + global contrastive) on 226,793 public
volumes and sweeping the dense/global weight, we find that **effective rank decouples from downstream
transfer**: rank is maximal for the pure-dense checkpoint, yet that checkpoint transfers *worst*. Under a
**shortcut-controlled external protocol** — scanner-subspace orthogonalization, matched random-init baselines,
BCa/Holm testing — across three dataset- and subject-disjoint cohorts (n>2000), the RankMe-selected checkpoint
is **statistically indistinguishable from a random-initialized encoder** for brain-age regression and **at
chance for cross-continent dementia classification** (fit on ADNI, tested on Korean and Australian cohorts),
whereas balanced/global checkpoints transfer significantly (AUROC ≈0.71). The failure persists against ViT and
a published brain foundation (BrainIAC). A **pre-registered** battery of label-free spectral criteria fails to
recover the optimum — a genuine open problem. We further contribute a scratch-convergence diagnostic that
prescribes protocol-adaptive transfer. We claim no absolute superiority; the contribution is a rigorously
validated caution and an external-evaluation methodology.

---

## Alternative shorter (~120 words, if length-limited)
Label-free checkpoint selection for 3D brain-MRI foundation models — e.g. maximizing effective rank (RankMe)
— can fail catastrophically. Sweeping the dense/global objective balance of a residual-encoder U-Net
pretrained on 226,793 volumes, we find rank *decouples* from transfer: it is maximal for the pure-dense
checkpoint, which transfers worst. Under a shortcut-controlled external protocol (scanner orthogonalization,
matched random baselines, BCa/Holm) on three disjoint cohorts (n>2000), the RankMe-selected checkpoint equals
a random encoder for brain age and is at chance for cross-continent dementia classification, while
balanced/global checkpoints transfer significantly. The failure holds against ViT and BrainIAC baselines, and
no pre-registered label-free criterion recovers the optimum (open problem). We contribute the finding, a
scratch-convergence transfer diagnostic, and a reusable shortcut-controlled evaluation protocol.

## Claims ledger (what each sentence rests on — for internal audit)
- "rank decouples / pure-dense worst": `external_analysis_v2.json` (post-A2 wg0 Δ 0.049 n.s.; wg≥0.25 Δ 0.23–0.29 p=0.005); external RankMe argmax=wg0.
- "indistinguishable from random / at chance cross-continent": `external_analysis_v2.json`, `adni_downstream.json` (ADNI→AJU 0.71, ADNI→AIBL 0.71; wg0 0.50–0.57).
- "persists against ViT/BrainIAC": `model_comparison.json`, `brainiac_comparison.json`.
- "no label-free criterion recovers optimum": `phase1_5point.json` (NO-GO).
- "scratch-convergence diagnostic / protocol-adaptive": TC1 (`ablation_registry.csv`, Δ+0.134/gap+0.101).
- "no absolute superiority": `h5_morphometry.json` (morphometry>foundation), `brainiac_comparison.json` (BrainIAC>ours on brain-age).
