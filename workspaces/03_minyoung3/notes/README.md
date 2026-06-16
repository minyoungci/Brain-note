# minyoung3 — multi-cohort 3D brain-MRI

Self-contained project. Use ONLY this directory's own assets — do not borrow corpora/code from
sibling projects (`minyoung2` = FOMO/ACCV, `minyoung4`, etc.). `/home/vlm/data` is read-only shared
data; physical presence there does not make a thing this project's asset.

## Current direction (locked 2026-06-16)
**Clinically-conditioned counterfactual 3D brain-MRI generation — Korean AD–SVD cohort (AJU).**
A conditional *latent* diffusion model (AutoencoderKL → conditional DiffusionModelUNet in latent space)
conditioned on a rich multimodal clinical vector; identity-preserving counterfactuals along clinically
meaningful axes (amyloid-PET status, WMH/Fazekas grade, SNSB executive-vs-memory, APOE, vascular subtype),
validated by a per-axis conditioning-fidelity battery. The contribution is the **per-axis structural-encoding
readout**, not the generator. Target MICCAI/MIDL.

- Current state + milestones: **`SCRATCHPAD.md`**
- Full plan: `/home/jovyan/.claude/plans/glistening-booping-meadow.md`

## Why this direction (the record)
11 prior supervised directions all hit the **morphometry-oracle ceiling** (learned reps never beat
engineered morphometry+clinical; targets are saturated or T1-blind), and the negative "ceiling-law"
meta-paper is literature-pre-empted (Schulz/Bzdok, Bron). The generative pivot is the one route that
uses the rich Korean multimodal cohort without competing on a prediction metric. Full per-experiment
failure record: **`insights/`** (I01–I12, indexed in `insights/README.md`). Always log new
failures/insights there.

## Layout
- `insights/` — distilled per-experiment knowledge archive (I01–I12). The knowledge layer.
- `scripts/` — analysis gates + generation smokes (reproducible code).
- `manifests/` — assembled generation manifest (conditioning table + image index + splits). [gitignored]
- `results/` — gating-experiment outputs. [gitignored]

## Discipline
bf16 only (no fp16); GPU runs need prior approval + smoke-subset first; subject-level splits (no leakage);
multi-seed + subject-bootstrap CIs; report FID but do NOT claim generator superiority; memorization audit;
NO "synthetic augmentation improves diagnosis" claim (information-capped). 3D AE must be conv-only
(attention OOMs at these resolutions). GPU0/6/7 often shared/busy — prefer GPU3–5.
