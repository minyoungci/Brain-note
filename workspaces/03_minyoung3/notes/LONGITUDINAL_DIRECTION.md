# Research direction assessment — Longitudinal 3D representation learning

Date: 2026-06-13. Critical-advisor assessment of "focus on a 3D-representation-learning method
based on longitudinal data" as the next direction, grounded in actual data checks.

## Verdict
**Viable and the strongest remaining axis — conditionally.** Single-timepoint structural T1 has
converged to a representation-robust null (see RESULTS_AMYLOID.md); within-subject CHANGE is the
only structural axis with literature-supported headroom (longitudinal CN amyloid ~0.87 vs single
~0.62). This is also a genuine *method* (representation-learning) contribution, not just another
prediction task. BUT this dataset has real limitations that must be resolved before committing GPU.

## Data feasibility (verified, not assumed)
- "18,868 longitudinal sessions" is MISLEADING. `scan_day` is populated ONLY for OASIS (100%);
  0% for A4/ADNI/AIBL/AJU/KDRC/NACC.
- Multi-scan IMAGES exist for **3,601 subjects** (≥2 distinct tensors): A4 1498, ADNI 870,
  OASIS 404, NACC 365, AJU 286, AIBL 178. All sessions have a usable 3D tensor.
- **Dates are recoverable from `session_id`**: ADNI 97% and AIBL 100% are YYYYMMDD; OASIS is
  `dNNNN` (days-from-baseline); A4 is `VISCODE_NNN` (orderable); AJU `V1/V2` (orderable).
  Recovered dated ≥1yr longitudinal pairs: **ADNI 858 + AIBL 175 (+ OASIS 404) ≈ 1,400+ subjects,
  3 cohorts** (more if A4/AJU visit-ordering is used).
- Two usable regimes:
  - **Date-agnostic SSL** (same-subject ≠ time): 3,601 subjects, ALL cohorts. Scale OK.
  - **Dated temporal / change modeling**: ~1,400+ subjects, 3 cohorts (after session_id date recovery).

## The gating reality (must respect)
Longitudinal MORPHOMETRY (ROI-volume change-rate) is a STRONG baseline on the subset where it is
computable (FreeSurfer-paired n=354): dx-conversion CV AUC **0.865**, CDR-SB progression **0.850**
(vs baseline-morphometry 0.64/0.71; change increment +0.18/+0.14). So a vision method cannot win
on a single accuracy number easily — the contribution must be the *representation/method*, not
oracle-beating. (Same morphometry-saturation lesson as the amyloid direction, one level up.)

## Proposed method (the actual direction)
**Longitudinal-consistency self-supervised 3D representation that disentangles subject-stable
anatomy from within-subject change.** Self-supervision signals (no FreeSurfer needed):
1. same-subject contrastive (a subject's own scans = positive; other subjects = negative) →
   subject-stable + nuisance(scanner/session)-invariant content.
2. where dated: interval / temporal-order prediction; change-field (baseline→follow-up
   deformation or feature-delta) prediction → a "change" factor.
3. content/change factorization (two heads): stable-content vs time-varying-change embeddings.

Evaluation (the contribution, NOT a single AUC):
- downstream conversion / CDR-SB progression / amyloid, single- vs paired-input;
- **data-efficiency** (does longitudinal SSL beat single-timepoint SSL and from-scratch at low
  label counts — the regime that matters here);
- **cross-cohort LOCO transfer** of the representation;
- vs the morphometry-change bar (0.85) honestly, with the framing "learned, FreeSurfer-free,
  generalizing representation" rather than "we beat morphometry."

## Why potentially novel
Subject-as-own-anchor longitudinal SSL with stable/change disentanglement for 3D brain MRI is
under-explored, directly targets the proven single-timepoint ceiling, and is multi-cohort. It is a
method contribution that can stand even against a strong morphometry baseline (via efficiency /
transfer / FreeSurfer-free operation).

## Honest risks / must-verify BEFORE GPU
1. **Registration→morphometry circularity**: if "change" is computed as a registration deformation,
   the representation just relearns morphometry-change. Mitigate: learn change in feature space, and
   ALWAYS report vs the morphometry-change bar; the win must be method/efficiency, not the number.
2. **Genuine follow-up vs same-visit rescan**: confirm A4/ADNI multi-scans are real longitudinal
   intervals (recover dates first), not repeat scans.
3. **Thin supervised labels** (conv n=354): the representation eval MUST lean on multiple
   downstream tasks + data-efficiency curves + transfer, never one task.
4. **Scanner-change confound**: small here (3.6% of multi-scan subjects change scanner) — control
   and report.
5. **Modality ceiling caveat carries over**: structural T1 representations top out near morphometry
   on these tasks; a flashy positive is unlikely. Expected honest outcome = a method that matches
   morphometry-change FreeSurfer-free and/or wins on data-efficiency/transfer.

## Staged next steps (CPU-first, then GPU on approval)
1. (CPU) Recover scan dates from `session_id` → build a dated longitudinal pair manifest; count
   genuine pairs/subjects/intervals per cohort.
2. (CPU) Establish the morphometry-change bar on the EXPANDED dated set (not just n=354); confirm
   headroom and the honest target.
3. (CPU/light) Build the 96^3 longitudinal-pair image cache.
4. (GPU, approval) Longitudinal-consistency SSL pretrain → downstream eval (efficiency + LOCO
   transfer + vs morphometry-change). Code-audit + research-critic before claiming anything.
