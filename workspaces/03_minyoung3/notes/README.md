# minyoung3 — ClaimTrap-AD

**Claim-safety for medical research agents.** A dual-view benchmark (**ClaimTrap30**) and an inference-time
**Claim Safety Controller** that prevent LLM research agents from emitting unsupported biomarker over-claims
when they read structured analysis artifacts and write conclusions.

- **What it is NOT:** AD biomarker *discovery*. The contribution axis is claim-safety, not neuroimaging findings.
- **Status (2026-06-22):** Claim Safety Controller **v4 FROZEN** (over-claim 0/90, n=3 pilot). Paper drafts written.
  Related-work / "first"-claim verification **pending** (all novelty claims held at `[VERIFY]`).
- **Direction change:** code/artifacts/docs moved here from `minyoungi` (agent-only scope, 2026-06-22) after
  import + unit-test verification. Upstream data-feasibility audit and multi-cohort assets remain in `minyoungi`.

See `SCRATCHPAD.md` for full state, repo layout, frozen items, and forbidden claims.
Entry points: `src/controllers/claim_safety_controller.py`, `configs/claim_safety_controller.yaml`,
`outputs/agent_benchmark/runs/claimtrap30_controller_v4_n3/`, `docs/PAPER_DRAFT_METHODS_RESULTS.md`.

**Prior direction** (Korean AD–SVD generative/conversion, closed 2026-06-20) recoverable at git tags
`archive/generative-2026-06-20` and `archive/conversion-2026-06-20`.
