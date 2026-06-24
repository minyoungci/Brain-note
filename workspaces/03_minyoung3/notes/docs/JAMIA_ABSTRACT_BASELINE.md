# JAMIA Abstract Baseline

Status: baseline v2 after research-critic blocker review.

Working manuscript and artifact name: **ClaimTrap-AD**.

Target journal framing: JAMIA-style biomedical informatics benchmark/evaluation protocol.

## Title

**ClaimTrap-AD: A Replication-Grounded Benchmark for Claim Calibration in Medical Research Agents**

## Structured Abstract

**Objective:** To benchmark whether medical research agents calibrate biomedical conclusions to evidence.

**Materials and Methods:** We developed ClaimTrap-AD, a dual-view framework: agents receive structured neuroimaging artifacts; evaluators receive held-out claim ceilings and replication evidence. A 30-case LLM-reviewed pilot with manual adjudication of one disagreement established the task and ordinal ceiling scheme. We scaled to 2,888 auto-gold cases from a 7-cohort source manifest (13,022 sessions; 7,231 subjects), using 6 cohorts for leave-one-cohort-out evaluation. Gold labels and replication-rule baselines used disjoint held-out cohort signals. We evaluated prompt-based agents, a pilot Claim Safety Controller, and scaled statistical baselines.

**Results:** In the pilot, generic agents over-claimed on 19/90 outputs; checklist prompting reduced this to 3/90. The controller rewrote fixed generic drafts, eliminating observed over-claims (rewrite-stability, 0/90) with lower completeness than checklist prompting (1.878 vs 2.622). In the scaled benchmark, non-planted labels were 70.1% threshold-robust, and 77.1% (216/280) of multi-cohort-judgeable findings received unanimous cross-cohort labels. Hard artifact traps (n=214) were defined as high discovery performance with failed replication; therefore, a discovery-threshold rule had 0% recall by construction. A replication-rule baseline achieved 0.72 recall at 0.99 precision and detected 43% of naturally occurring non-planted traps. Direct-questioned open LLM agents collapsed to near-uniform rejection, contrasting with pilot over-claiming under open-ended generation.

**Discussion:** Claim calibration was sensitive to framing and replication structure; checklist prompting improved but did not solve over-claim control.

**Conclusion:** ClaimTrap-AD exposes a claim-calibration gap: discovery-threshold rules are blind to replication traps, while replication-aware baselines and LLM agents handle them only partially.

## Body/Limitation Carry-Forward

- Define the completeness scale when reporting 1.878 vs 2.622.
- State that 70.1% threshold robustness implies a near-boundary zone; report the 30% threshold-sensitive region in limitations.
- Keep the E1-E8 taxonomy pilot-specific: the pilot taxonomy informed the 30-case pilot; scaled cases use replication-defined labels, ordinal ceilings, and difficulty strata.
- Disclose the pilot-vs-scaled model/judge/framing differences when interpreting over-claiming versus direct-question over-rejection.
- Preserve the controller caveat: pilot controller results are rewrite-stability on fixed generic drafts, not three independent controller generations.
- Treat discovery-threshold 0% recall as a by-construction property of the hard-trap stratum, not an empirical headline.
- Use "naturally occurring non-planted traps" for the n=98 denominator; avoid ambiguous real-* phrasing because "real" is also a benchmark label.
- State that the source manifest has 7 cohorts, while the scaled leave-one-cohort-out benchmark uses 6 diagnostic cohorts (A4 excluded).
- Report 77.1% cross-cohort consistency with denominator 216/280.
- In body results, disclose that replication-rule baseline and gold use correlated but disjoint held-out cohort signals.
