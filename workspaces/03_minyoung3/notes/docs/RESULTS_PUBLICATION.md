# ClaimTrap-AD (scaled) — Publication-grade Results

Replication-grounded benchmark for **claim-calibration of medical research agents**: given a discovery-cohort
analysis artifact, does an agent claim only what the evidence licenses? Gold = whether the finding actually
replicates out-of-cohort (auto-derived, validated). Honest tier: **NeurIPS D&B / ACL-BioNLP / ML4H benchmark
paper** (not top-tier-novel; "first" not claimed — CSS/RIGOURATE/BiomniBench are neighbors).

All numbers from committed artifacts (`outputs/agent_benchmark/claimtrap_scaled/`). No fabrication.

## 1. Benchmark (Table B1)
- **2,888 cases** (1,008 artifact / 1,880 real), from a 7-cohort manifest (13,022 sess / 7,231 subj), LOO over
  {ADNI, NACC, AIBL, KDRC, OASIS, AJU}; 5 endpoints (CN_AD, CN_MCI, MCI_AD, CN_Dem, CN+MCI_AD).
- kinds: univariate ROI features 2,470 · multivariate models 190 · planted controls 228.
- **difficulty strata**: easy_real 1,706 · easy_artifact 805 · **HARD_artifact (over-claim traps) 214** · HARD_real 163.
- auto-gold claim ceiling: L0 (no-claim) 1,019 · L1 (within-cohort) 957 · L2 (predictive) 912.
- Each case = neutral discovery artifact (agent-visible) + gold ceiling + replication evidence (scorer-only) — the
  dual-view discipline from the 30-case pilot, now at scale with auto-gold.

## 2. Auto-gold validation (Table B2) — Proposal 2 (DONE)
- **Threshold robustness:** 70.1% of real-derived labels invariant across REAL_T ∈ {0.55–0.65} (30% near-boundary).
- **Cross-cohort consistency:** of 280 findings judged under ≥2 held-out GT cohorts, **77.1% get a UNANIMOUS
  real/artifact label** (verdict does not depend on which cohort is held out).
- **Convergent validity:** gold=real has higher replication & covariate-incremental than gold=artifact
  (tool_repl 0.696 vs 0.551; cov_inc 0.080 vs 0.009; disc 0.699 vs 0.546).
- 120-case human-validation subset exported (`human_validation_subset.json`); planted controls are objective
  anchors. **Human sign-off = remaining certification step (TODO).**

## 3. Deterministic baselines (Table B3) — DONE
Artifact-detection (does the method flag a non-replicating finding?). Controller = covariate-incremental +
cross-cohort replication kill-rule; naive = trust discovery AUROC (significance-thresholding).
| stratum | n | controller F1 | naive F1 |
|---|--:|--:|--:|
| ALL | 2888 | 0.841 | 0.812 |
| **HARD_artifact (over-claim traps)** | 214 | **0.831** (rec 0.72, prec 0.99) | **— (rec 0.00)** |
| REAL findings only | 2660 | 0.825 | 0.861 |
| PLANTED | 228 | 0.974 | 0.095 |
**Key:** on over-claim traps, naive significance-thresholding has **0% recall** (it trusts high in-cohort AUROC);
the controller catches 72% overall and **43% of the REAL-derived traps** (98 real, MCI-concentrated) — far better
than naive but leaving substantial **headroom (benchmark is unsaturated)**.

## 4. LLM agents as subjects (Table B4) — Proposal 1 (DONE)
generic vs checklist agents (Qwen3-32B, MedGemma-27b) read the discovery artifact and answer "does this finding
generalize?" (yes/no/uncertain). Stratified sample 480 (120/stratum) × 2 arms × 2 models.
- **over-claim rate = 0/234 artifact cases for EVERY arm and model.** But this is **degenerate over-rejection, not
  calibration**: the agents answer "yes" (generalizes) to **ZERO** cases — real AND artifact alike (recognize-real =
  0/246 for all arms/models; MedGemma+checklist = 480/480 "no").
- Under a direct "does it generalize, given a single-cohort AUROC and no external result?" question, open LLMs
  collapse to **never affirming generalization → they do not discriminate**. The checklist makes them more
  conservative still.
- **Honest reading:** same framing-driven miscalibration as the rigor-controller D3 experiment (LLMs over-reject
  when the prompt foregrounds rigor). This is **NOT evidence that agents over-claim** — under direct questioning
  they over-reject. The benchmark's discriminative signal lives in the deterministic baselines (§3), not in LLM
  agents under this framing. (Contrast the 30-case pilot's open-ended generative framing, judged by GPT-5.5, which
  did surface over-claims — confirming the failure mode is framing- and judge-dependent.)

## 5. Headline findings (for abstract)
1. A 2,888-case replication-grounded benchmark for medical-research-agent claim calibration (auto-gold validated:
   70% threshold-robust, 77% cross-cohort-consistent).
2. **Naive significance-thresholding catastrophically fails on cross-cohort over-claim traps (0% recall)**; a
   deterministic replication+covariate controller helps (43% on real traps, 0.99 precision) but does not solve it
   — the benchmark is unsaturated.
3. Open LLM agents are **framing-dominated**: under a direct generalization question they collapse to
   non-discrimination (0% affirm generalization on BOTH real and artifact cases) — a calibration cautionary
   finding, not "agents over-claim". The failure mode is framing/judge-dependent (cf. 30-case pilot).

## 6. Honest limitations (state explicitly)
- Benchmark, not a new model/training; populated area (CSS/RIGOURATE/BiomniBench) → contribution is the
  large replication-grounded resource + the unsaturated over-claim-trap stratum, not a "first".
- Difficulty is 54% planted / 46% real-derived — both reported; real traps concentrate in MCI contrasts.
- Auto-gold has a near-boundary zone (30%); human sign-off of the subset pending.
- Single feature/region family (FreeSurfer ROI); ROI-volume models are otherwise cross-cohort robust (the
  reproducibility failure is concentrated, not pervasive, in this space).
- **LLM-agent result is a null/cautionary one** (framing-driven over-rejection), not a positive "agents over-claim"
  demonstration; the contribution rests on the benchmark + deterministic statistical-method baselines.

## 7. Honest contribution statement (for the paper)
ClaimTrap-AD (scaled) is a **2,888-case, replication-grounded, validated benchmark** for claim calibration on
biomedical analysis artifacts, whose value is: (i) it operationalizes "artifact" as cross-cohort non-replication
with auto-gold (70% threshold-robust, 77% cross-cohort-consistent); (ii) it shows **naive significance-thresholding
catastrophically fails on over-claim traps (0% recall)** while a deterministic replication+covariate controller
only partially recovers them (43% on real traps) — i.e., the benchmark is **unsaturated**, leaving clear headroom;
(iii) it documents that **open LLM agents are framing-dominated** (over-reject under direct questioning), a
cautionary calibration result. **Tier: D&B / ACL-BioNLP / ML4H benchmark contribution — honestly modest, not
top-tier-novel, no "first" claim.** A larger contribution requires a different problem/data (advisor decision).
