# Medical LLM-Agent Direction — Trend Map Synthesis & Recommendation (2026-06-22)

Synthesis of 4 trend-mapping literature-scouts (M1 overall landscape · M2 multimodal/imaging agents · M3 agentic
data-analysis · M4 longitudinal/AD). Mandate (per Min): map the current LLM-agent trend, cross with OUR data moat,
and recommend a direction with genuine, defensible novelty headroom — grounded, not asserted-from-memory.
Honesty gate: headroom is rated per scout evidence; "first" is forbidden where an occupant exists.

## Convergent finding (all 4 scouts)
- **SATURATED / peer-reviewed (avoid):** text/EHR/QA medical agents — MedAgents (ACL'24), MDAgents (NeurIPS'24
  Oral), AgentClinic (npj Digital Medicine'26), MedAgentBench (NEJM AI'25).
- **"first" already taken:** AD imaging agent → ADAgent (MICCAI'25 wksp, raw MRI+PET, ADNI, single-shot).
  Longitudinal AD trajectory → CARE-AD (npj'25, text-only) + Cerebra (arXiv'26, multimodal) → crowding fast (M4).
- **The same white space named by M1-WS2, M2, and M3 from three angles:** an agent that treats
  **scanner/site/cohort confounding + methodological rigor as a first-class object it reasons about and tools
  against**, on **multi-cohort multimodal neuroimaging**. Harmonization literature is entirely non-agentic
  (ComBat family); agent literature is entirely single-cohort. The two have not met.

## Our moat (what occupants lack — verified)
- **7 cohorts / 13k sessions + scanner/site metadata** → every occupant is single-cohort (mostly ADNI).
- **Structured multimodal** (MRI tensors + FreeSurfer ROI + clinical + amyloid + scanner) → ADAgent uses raw
  images only; TAP-GPT tabular only; ADLIP T1+clinical static; none fuse all + scanner.
- **Our ClaimTrap-AD E1–E8 trap catalog + deterministic controller** → ready-made rigor checks (covariate
  baseline, incremental value, label provenance, transportability, site-shortcut) = the agent's guardrails.
- **MedGemma (multimodal) + B200 + FOMO300K** → image reasoning + compute.
This is an *evolution* of the prior 8-turn work (benchmark + controller + traps), not a restart.

## Ranked candidate directions
### ★ RECOMMENDED — D1: Multi-cohort, scanner/confound-aware "rigor" neuroimaging agent
A generative agent that runs a neuroimaging cohort analysis and whose **objective is methodological validity +
cross-site generalization**: it detects leakage/scanner/covariate confounds, invokes harmonization/validation as
tools, reports calibrated per-cohort confidence, and **kills findings that are artifacts** — leaving a
falsifiable, out-of-cohort-validated signal.
- **Why now / why us:** convergently named open by M1-WS2 + M2 + M3; uniquely fits our 7-cohort+scanner moat;
  reuses ClaimTrap-AD traps as the agent's checks.
- **Headroom: MED-HIGH** (HIGH if framed as a *generative system* with rigor-as-objective + scanner-as-signal;
  LOW if framed as a benchmark/catalog — BiomniBench owns that).
- **Nearest occupants to beat:** BiomniBench (rigor *benchmark*, bioRxiv — we are a *system*, neuroimaging-specific);
  ADAgent (single-cohort raw-image dx — we are multi-cohort, rigor-objective, structured); ComBat family
  (non-agentic — we make harmonization an agentic decision).
- **Falsifiable demo (pre-registered kill condition):** a naive multimodal agent reports K "significant"
  amyloid/dx findings on the manifest; our agent flags F of them as leakage/scanner/covariate artifacts; the
  flags are statistically/human-confirmed; killed findings fail to replicate out-of-cohort while surviving ones
  replicate. **If the agent cannot measurably kill artifacts a naive agent reports → collapses to "ADAgent + more
  data" = LOW novelty.** Rigor must be shown as a *capability*, not error-avoidance (CLAUDE.md §1).
- **Venue fork:** method (scanner-aware rigor agent mechanism) → AI top-tier (NeurIPS D&B / ICLR), benchmarked
  vs Biomni/BiomniBench; the validated cross-cohort finding → MICCAI/IPMI or Alzheimer's & Dementia.

### D2 (strong but crowding) — Longitudinal multimodal AD-trajectory agent
Per-visit image-grounded progression reasoning (AJU). **Headroom HIGH on data fit but LOW-MED on concept** —
CARE-AD (npj'25) + Cerebra (arXiv'26) + AD-LLaVA-3D occupy the headline. Survivable only as a sharply re-scoped
slice (structured per-visit *amyloid/biomarker-transition* reasoning + cross-cohort) and likely a clinical-venue
contribution. Collision risk high; AJU needs PHI/temporal audit first.

### D3 (safest, lowest headroom) — Missing-modality / value-of-information multimodal agent
When-to-order-PET / predict-amyloid-from-MRI+APOE decision agent. **Headroom MED** — closest to ADAgent; defend
via VOI/decision framing. Lowest novelty of the three.

## Recommendation
**Pursue D1.** It is the one direction (a) convergently confirmed open by three independent scouts, (b) uniquely
enabled by our multi-cohort + scanner moat that occupants lack, (c) that reuses (not discards) the ClaimTrap-AD
trap catalog + controller, and (d) carries a clean falsifiable kill condition. D2 is the fallback if D1's
artifact-killing demo proves infeasible; D3 is the conservative floor.

## Honest risks (do not skip)
- "Agent = thin wrapper over ComBat/classifiers" → must show the agent *changes a decision* (abstain/recalibrate/
  kill) that a non-agent cannot, as an ablation.
- Time-sensitive: BiomniBench-DA (2026-05) explicitly invites rigor systems; window ~6–12 months.
- Do NOT claim "first AD imaging agent" (ADAgent) or "first longitudinal AD agent" (CARE-AD).
- E1 (open-base over-claim baseline, running) is supporting evidence: open models over-claim on our artifacts →
  motivates a rigor-enforcing agent. It is not the contribution.

## Next gate (no GPU training yet)
1. Confirm D1 with a focused novelty-scout on "scanner/site-aware OR harmonization-aware LLM agents" +
   "leakage-detecting analysis agents" (close the last collision check).
2. Design the falsifiable artifact-killing demo on the 7-cohort manifest (define K findings, F artifacts, the
   out-of-cohort replication test).
3. Then build: agent loop reusing ClaimTrap-AD verifiers as rigor tools + MedGemma for image reasoning.
