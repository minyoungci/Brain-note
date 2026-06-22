# D3 rigor-ablation — RESULT (negative, 2026-06-22)

**Pre-registered kill condition: "agent+verifiers (LLM shown rigor tools) beats naive LLM at artifact detection."
→ FAILED.** Recorded straight, no spin (CLAUDE.md: negative results kept).

## Result (GT = KDRC, unseen; 29 findings, 4 artifact / 25 real)
| model | arm | artifact-recall | accuracy | kills correct/wrong | decisions |
|---|---|--:|--:|--:|---|
| Qwen3-32B | naive | 1.00 | 0.14 | 4/25 | **artifact ×29** |
| Qwen3-32B | agent+verifiers | 1.00 | 0.14 | 4/25 | **artifact ×29** |
| MedGemma-27b | naive | 1.00 | 0.52 | 4/14 | real 11 / artifact 18 |
| MedGemma-27b | agent+verifiers | 1.00 | 0.14 | 4/25 | **artifact ×29** |

## Diagnosis (from per-case decisions)
- Qwen3-32B labels **everything artifact** (incl. hippocampus, the textbook AD biomarker) — pathologically skeptical
  under the "audit for artifacts" framing; verifiers change nothing (saturated).
- MedGemma-27b *naive* is balanced (correctly calls hippocampus/amygdala real); **adding the verifier numbers flips
  it to all-artifact** → the rigor tools made the LLM MORE miscalibrated (over-kill), not better.
- The deterministic kill-rule (Sprint-1 pilot) got the same controls **3/3 right**. The LLM free-text decider does not.

## Interpretation (consistent with all prior evidence)
LLMs are miscalibrated claim/validity DECIDERS in **both** directions: unguarded → over-claim (E1: 13–19/90);
prompted to be skeptical → over-kill (D3: kills real findings). Same over-claim↔over-suppression tension as the
ClaimTrap-AD controller. **The working component is the deterministic verifier; the LLM is not a reliable decider.**
⇒ "an LLM agent that *reasons about* rigor and decides" is NOT supported. What is supported: deterministic
verifier-driven decisions, with the LLM as a proposer/explainer component (the ClaimTrap-AD controller philosophy).

## Options (genuine fork — user decides)
- **A. Prompt-calibration re-run** (cheap): explicit thresholds + balanced framing. May rescue MedGemma's decider,
  but "we hand-tuned the prompt to stop over-rejection" is itself weak evidence the LLM is a reliable decider.
- **B. Re-architect → deterministic decision, LLM as component** (honest, evidence-aligned): the kill decision is
  the deterministic rule (works 3/3); the LLM proposes findings + writes the audit rationale. Shrinks the "LLM
  agent" novelty toward "automated rigor-control pipeline."
- **C. The miscalibration IS the finding** (empirical contribution): "LLMs over-reject when prompted for rigor and
  get worse when given the evidence numbers; only deterministic evidence-grounded control is reliable" — mirrors
  ClaimTrap-AD; argues for the deterministic-controller design. Publishable as an honest negative/empirical result,
  but not a "trendy LLM agent" paper.

## Honest bottom line
The data substrate + deterministic engine work (3/3). The **LLM-as-rigor-decider hypothesis does not.** This is the
third independent signal (ClaimTrap-AD trade-off, E1 over-claim, D3 over-kill) that the defensible contribution is
**deterministic evidence-grounded control with the LLM as a constrained component** — not an autonomous reasoning
agent. Decide whether to pursue B/C (honest, deterministic-centered) or accept that the "LLM agent" framing the
project keeps gravitating toward is not supported by our own results.
