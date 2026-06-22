# Research Plan — Scanner/Confound-Aware Rigor Agent + Verifier-Pruned Efficiency (2026-06-22)

Direction chosen (D1 + M-a). Built per CLAUDE.md §5 (claim-first), experiment-methodology (DoE, falsifiable,
pilot-first), and the novelty gate (no "first"; novelty contingent on the falsifiable demo). Evolves the prior
ClaimTrap-AD work (benchmark + E1–E8 traps + deterministic controller) — reuses, not restarts.

## 0. One-line
An LLM analysis agent that treats **cross-cohort/scanner confounding as a first-class object it reasons about and
acts on** — it **kills non-replicating leakage/scanner artifacts** that naive agents report (leaving
cross-cohort-validated findings), and does so **efficiently** by using deterministic verifiers to prune expensive
reasoning/vision calls **without losing rigor**.

## 1. Central claim (paper thesis — fix BEFORE results)
> On a real multi-cohort multimodal dementia manifest, a verifier-guided agent detects and removes findings that
> fail out-of-cohort replication (leakage/scanner/covariate artifacts) that an unguided agent reports as
> significant; and deterministic verifier-pruning achieves this at materially fewer LLM/vision calls than an
> always-reason agent, at equal artifact-detection quality.

Contributions (REVISED after Sprint-0 confirmation scouts, 2026-06-22):
- **C-A (THE contribution, data×task):** NOT "we built a scanner-aware agent" — ModelAuditor (arXiv:2507.05755,
  preprint) already occupies scanner-aware agents. The novelty is the **asset + verb**: out-of-cohort replication as
  the *ground-truth definition of "artifact"*, a **kill action with measured consequences**, and a **planted
  positive/negative control** proving the agent kills site-confounds while sparing real effects — on a real
  7-cohort manifest. (moat: multi-cohort + scanner; asset: E1–E8 verifiers as rigor tools.)
- **C-B → DEMOTED to a supporting *result*, NOT a named contribution (per S0b):** verifier-pruned efficiency is
  occupied at the mechanism level (FrugalGPT cascade; "deterministic-check-skips-LLM" guardrail pattern; ADP-MA
  zero-cost Monitor). Report ONLY as an empirical result — "X% fewer LLM+vision calls at unchanged
  artifact-detection F1 (efficiency *because of* rigor)" — never as novelty. If savings are trivial, drop silently.

## 2. Claim threat-model → Design of Experiments (each kills a reviewer objection)
| Reviewer objection | Experiment that kills it |
|---|---|
| "the problem isn't real" | **D2a**: a naive multimodal agent reports K "significant" findings on the manifest; many are confounded |
| "the agent doesn't actually kill artifacts" | **D2b (HEADLINE)**: artifact-detection precision/recall vs *out-of-cohort replication* ground truth (a finding = artifact iff it fails to replicate in a held-out cohort) |
| "replication-failure ≠ artifact (could be cohort-specific biology / underpowered)" — S0a falsifiability risk | **D2c (MAKE-OR-BREAK)**: inject **planted positive (real) + negative (site-confound) controls** into the manifest; agent MUST kill planted confounds, MUST spare planted real effects. This is the falsifiable core that converts exploration → Real novelty |
| "it's ComBat/stats, not the agent" | **D3 (rigor ablation)**: agent+verifiers vs agent−verifiers vs plain statistical pipeline (ComBat + covariate baseline) |
| "efficiency is fake / costs rigor" | **D4 (efficiency ablation)**: verifier-pruned vs always-reason — #LLM calls, #vision calls, tokens, wall-clock @ equal artifact-detection F1 |
| "single cohort / single model" | **D5**: multi-cohort hold-out + multi-base (Llama/MedGemma/Gemma/Qwen) |
| "thin wrapper / cosmetic" | the **capability ablation** in D3: a decision (kill/abstain) the non-agent baseline cannot make |

Experiments not mapped to an objection are not run (CLAUDE.md §3).

## 3. Falsifiable success criteria (pre-registered)
- **C-A is REAL iff:** the agent flags artifacts that fail out-of-cohort replication with precision/recall
  materially above the no-verifier baseline, AND survivors replicate out-of-cohort. **Kill:** if naive ≈ agent on
  artifact detection, or "killed" findings replicate as often as survivors → exploration, not contribution.
- **C-A REAL requires the D2c planted-control result** (pre-registered): agent kills ≥ (target, e.g. 80%) of
  planted site-confounds AND spares ≥ (target, e.g. 90%) of planted real effects. Without the control set,
  out-of-cohort non-replication conflates {true artifact / cohort-specific biology / underpowered} → NOT
  falsifiable → exploration, not contribution.
- **C-B is a RESULT, not a contribution** (S0b): report only if verifier-pruning cuts LLM+vision calls materially
  (≥30%) at equal artifact-detection F1; otherwise drop silently. Never the headline.
- Sprint-0 scouts DONE: C-A PARTIALLY OCCUPIED (cell open, reframe to asset+verb; ModelAuditor nearest); C-B
  OCCUPIED at mechanism → demoted. No "first"; "within verified literature, no system does X" only.

## 4. Data & splits (leakage-free by construction)
- Source: `/home/vlm/data/.../official_manifest_full_n4_real_final.parquet` (7 cohorts, 13k sessions; usable amyloid
  pool ~3.1k: OASIS immediate; AJU/KDRC after PHI/temporal audit; A4 single-class excluded as a task).
- **Primary endpoint = dx / CDR (LOCKED 2026-06-22, data-verified):** dx(`clin_dx_label`: CN 5769 / MCI 3980 /
  AD 804) and `cdr_global` have **full 7-cohort coverage** (feature-core + label: ADNI 1569, NACC 1414, A4 992,
  KDRC 770, AIBL 617, OASIS 507/718, AJU 955/1001) → the artifact-kill demo runs NOW on structured ROI+clinical
  with NO PHI/temporal audit needed. **Amyloid = secondary endpoint** (4 cohorts only; A4 single-class; AJU/KDRC
  audit-gated) — added after audit.
- **Out-of-cohort replication split** (the ground-truth engine): discover candidate "ROI feature → dx/CDR"
  findings on a discovery set (e.g., ADNI+NACC, US, largest), test replication on a **site/population-distinct**
  held-out set (OASIS US-other / AIBL Australia / AJU+KDRC Korea). Real US↔AUS↔Korea shift by design → a finding
  that fails to replicate = confound/leakage artifact (the ground-truth label for the agent's kill decisions).
- ClaimTrap30 (30 cases) stays **held-out / untouched** (separate eval, not training).

## 5. Models & tools
- Open bases on B200 (no closed model needed): Llama-3-8B, MedGemma-4b/27b (vision), Gemma-3-27b, Qwen3-32B.
- Agent tools (reuse ClaimTrap-AD assets): load-cohort, fit covariate-baseline, compute incremental value, the
  **E1–E8 deterministic verifiers** (covariate omission / incremental / temporal / label-provenance /
  transportability / causal / site-shortcut / unsupported), harmonization (ComBat) tool, cross-cohort evaluator,
  MedGemma vision for image-level checks. Verifiers are cheap (no LLM) → they drive C-B pruning.

## 6. Sprints (pilot-first; GPU only from Sprint 1)
- **Sprint 0 (now, no GPU):** (a) **confirmation scout** — last collision check on "verifier-guided / cost-efficient
  agents" (C-B) and "scanner/harmonization/leakage-aware LLM agents" (C-A); (b) design the out-of-cohort
  replication protocol + the "naive findings" generator concretely; (c) lock the cohort split.
- **Sprint 1 (pilot):** minimal agent loop on OASIS + 1 held-out cohort; reproduce "naive reports artifacts" +
  agent kills a handful; prototype verifier-pruning. Cheap sanity (1-batch-scale).
- **Sprint 2:** full D2 artifact-killing demo + D3 rigor ablation.
- **Sprint 3:** D4 efficiency ablation + D5 multi-base/multi-cohort.
- **Sprint 4:** write-up (figures: artifact-kill PR curve, efficiency frontier, per-cohort).

## 7. Venue (honest fork, CLAUDE.md §2) — REVISED post-scout
- **Honest lean: MICCAI / IPMI / NeuroImage / Alzheimer's & Dementia.** The surviving novelty is *asset + verb*
  (replication-as-ground-truth + kill-with-consequences + planted controls), which reviewers read as a
  methods/clinical-validation contribution — ModelAuditor already occupies the scanner-aware-agent *mechanism*, and
  C-B efficiency is demoted. **AI top-tier (NeurIPS D&B / ICLR) ONLY if** the capability ablation (D3) shows the
  agent-that-kills recovers a true-artifact-rejection capability that no static harmonization pipeline achieves.
  Do NOT repackage the application as ML-novelty.

## 8. Risks / kill conditions (carry from scouts)
- Thin-wrapper ("agent calls ComBat"): mitigated only by the D3 capability ablation. Biggest risk.
- BiomniBench collision: we are a *generative system* with neuroimaging-specific verifiers + multi-cohort, not a
  benchmark. Time-sensitive (~6–12 mo).
- Efficiency-on-any-benchmark: C-B is grounded in the rigor verifiers (domain), not generic — keep it that way.
- "first" forbidden; AD-imaging-agent (ADAgent) and longitudinal-AD (CARE-AD) framings forbidden.

## 9. Immediate next action
Sprint 0 confirmation scout (this commit's trigger). No GPU until Sprint 1, on explicit approval.
