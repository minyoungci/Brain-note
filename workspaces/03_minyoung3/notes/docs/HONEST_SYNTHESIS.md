# Honest synthesis — rigor-control / LLM-agent exploration (2026-06-22)

Five experiments tested whether a rigor/safety-control LLM-agent contribution beats simple baselines on real data.
**It does not.** Recorded straight (CLAUDE.md: negative results kept; no spin). The exploration was cheap
(scouts + CPU stats + light GPU) and did its job — it ruled out a doomed full build before we committed to it.

## The five signals (consistent)
1. **ClaimTrap-AD** (claim-safety benchmark + controller): controller reaches 0/90 over-claim but does NOT beat a
   one-line checklist prompt on completeness (1.878 vs 2.622) — a trade-off, not a win.
2. **E1** (open-base over-claim): Llama/MedGemma over-claim on our artifacts (13–19/30) → the *problem* exists, but
   that only motivates; it is not a method win.
3. **D3** (LLM-as-rigor-decider): giving an LLM the rigor numbers makes it OVER-KILL (Qwen labels 29/29 artifact,
   incl. hippocampus); verifiers make it worse. LLMs are unreliable validity deciders in both directions.
4. **Sprint-2** (deterministic controller, 1022 findings): beats naive on PLANTED synthetic confounds
   (F1 0.93 vs 0.25) but TIES on REAL findings (0.83 vs 0.84) — disc-AUROC already predicts replication.
5. **Sprint-3 (final bet, models-as-findings)**: hypothesized overfit/site-shift decoupling DOES NOT occur — ROI
   models (incl. overfit RF, raw/head-size, small-n) generalize across 6 cohorts (within-CV ≈ cross-cohort ≈ GT,
   ~0.72–0.79); only 1/98 non-generalizing. Nothing for the controller to catch. **Pre-registered STOP met.**

## Two root causes (why the thesis fails)
- **LLMs are miscalibrated claim/validity deciders** (over-claim unguarded; over-kill when prompted skeptical).
- **The real neuroimaging substrate is "clean":** harmonized FreeSurfer ROI findings replicate and ROI models
  generalize cross-cohort, so naive significance / within-CV is already well-calibrated. The rigor machinery only
  has an edge against *adversarial/planted* confounds — which reviewers discount. (The leakage/reproducibility
  crisis lives in raw-voxel/connectome/high-dim spaces we did not use, not ROI volumes.)

## What is genuinely real here (salvageable)
- **ClaimTrap-AD paper** (`paper/main.tex` + figures + tables + bib): a dual-view claim-safety benchmark + an
  inference-time Claim Safety Controller with an honest safety–completeness trade-off. **Most complete, submission-
  ready artifact.** Honest venue: workshop / NeurIPS D&B / ACL-BioNLP / ML4H. ← the realistic deliverable.
- **Sprint-2 planted-control result**: a clean controlled demonstration that naive significance-thresholding fails
  on site-confounds (F1 0.25) while a replication+covariate rule catches them (F1 0.93) — a methods vignette.
- **Sprint-3 robustness finding**: ROI-volume AD/MCI models generalize across 6 dementia cohorts (a citable
  negative result vs the leakage-crisis narrative, for ROI-space specifically).

## Recommendation (honest)
**Consolidate the ClaimTrap-AD paper as the deliverable; treat the rigor-agent line as a recorded negative result.**
The "trendy top-tier agent paper that beats baselines" goal is not supported by our data — now shown with five
experiments, not opinion. Do not start another rigor-control experiment. If a neuroimaging-flavored paper is
wanted, the honest one is "ROI AD-models are cross-cohort robust; rigor-control helps only against adversarial
confounds" (Sprint-2 + Sprint-3) — modest, methods/clinical venue.

## Dead-ends recorded (do not re-walk)
LLM-as-rigor-decider (D3); deterministic controller vs naive on real ROI findings (Sprint-2); models-as-findings
decoupling on ROI features (Sprint-3). All negative; artifacts/scripts committed for provenance.
