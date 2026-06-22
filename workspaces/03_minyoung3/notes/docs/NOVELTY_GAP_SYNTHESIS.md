# Novelty-Gap Synthesis — Learned Claim-Safety Direction (2026-06-22)

Synthesis of 4 novelty-gap literature-scouts (L1 honesty/calibration tuning · L2 guardrail/controller distillation ·
L3 constrained/ordinal objectives · L4 biomedical claim-safety training). **My mandate (per Min): not to report, but
to locate the unoccupied gap our data+resources fill and deliver a defensible technical novelty + the minimal
experiments that prove it — or say plainly if none survives.** Honesty gate: this novelty is *contingent on empirical
results*; it is a research bet with a falsifiable kill condition, not a guaranteed win. No "first" — "within verified
literature, unoccupied."

---

## 1. The convergent meta-finding (all 4 clusters agree)
**Every primitive is already published**, peer-reviewed in most cases:
- auto-labeled preference DPO for truthfulness → **FactTune** (Tian et al., ICLR 2024, peer-reviewed).
- verifier→DPO in a clinical domain → **VERI-DPO** (2603.10494, 2026 preprint — method twin).
- "remove inference-time machinery by distilling it in" → **Distilling System 2 into System 1** (2407.06023).
- evidence-faithfulness DPO → **Context-DPO** (Bi et al., ACL 2025 Findings, peer-reviewed — binary).
- constrained RLHF → **Safe RLHF** (Dai et al., ICLR 2024 — scalar aggregate cost budget).
- ordinal reward modeling → **Liu et al. 2024**; over-claim *scoring* → **RIGOURATE** (2601.04350, detector).

⇒ The novelty **cannot** be a primitive ("we use a verifier for DPO" / "we distill the controller" / "auto-labeled
pairs"). All are occupied. The novelty must be **composition + formulation level, and it survives review ONLY if a
specific empirical result holds.** This is the unanimous verdict across L1/L2/L4.

## 2. The gap (one cell, unoccupied across all 4 clusters)
> Training a generative agent under a **per-instance, ordinal, asymmetric evidence-ceiling constraint** — the ceiling
> `L*(e)` computed by a *deterministic controller from a structured analysis artifact* — so the learned policy keeps
> claim **strength** ≤ ceiling (safety) **and recovers the completeness the inference-time controller sacrifices**,
> via ordinal/asymmetric structure that binary faithfulness (Context-DPO/VERI-DPO) and scalar-budget constrained-RLHF
> (Safe RLHF) structurally cannot reproduce.

Two axes the field keeps separate and nobody verified joins: (i) constrained-RLHF = *scalar aggregate* cost budget
(trades violations across instances); (ii) ordinal structure lives in *reward prediction*, not in a *policy
constraint on output level*. Our cell binds an **input-conditioned ordinal ceiling** into the objective.

## 3. The technical novelty we deliver — CC-OPO
**Ceiling-Constrained Ordinal Preference Optimization (CC-OPO)** — a DPO variant where, for each artifact `e` with a
controller-computed ordinal ceiling `L*(e)` on the lattice `L0<L1<L1.5<L2<L3`:
- **asymmetric about the ceiling**: a claim with `λ(c) > L*(e)` is a **hard violation**, penalized by *ordinal distance
  above* the ceiling; a claim at-or-below the ceiling is ranked by **completeness** (closeness to the ceiling from
  below). Under-claiming is only an incompleteness loss, never a violation.
- **per-instance**, not an aggregate cost budget (no cross-instance trading of over-claims, unlike Safe RLHF).
- **graded/ordinal**, not binary supported/unsupported (unlike Context-DPO / VERI-DPO).

Narrative wrapper (the application): **controller distillation** — CC-OPO distills our deterministic claim-safety
controller into the weights, removing the inference-time machinery and (the contribution) **closing the controller's
own safety–completeness trade-off**. The benchmark (ClaimTrap-AD) + controller become the *substrate*; CC-OPO + the
trade-off-recovery result become the *technical core*.

**Why this is the load-bearing choice:** L1 said the objective (not the label source) must carry novelty or it's "new
verifier, old recipe." L3 said the ordinal-asymmetric structure must buy a capability binary/scalar baselines can't.
L2/L4 said the trade-off recovery must be empirically real or it collapses to VERI-DPO. CC-OPO is exactly the object
those three constraints point at.

## 4. Named threats to differentiate (cite + contrast, never "first")
| threat | venue | what they do | our differentiation |
|---|---|---|---|
| FactTune (Tian et al.) | ICLR 2024 ✓ | auto-labeled DPO for factuality vs corpus | label = artifact-derived ordinal *ceiling*, not corpus factuality; target = claim *strength* |
| VERI-DPO (Liu et al.) | 2026 preprint | RAG-verifier→DPO, clinical, supported/unsupported | binary faithfulness vs **graded ceiling + routing + trade-off recovery** |
| Context-DPO (Bi et al.) | ACL 2025 Findings ✓ | binary evidence-faithful vs stubborn | **asymmetric ordinal** (under-claim ok, over-claim graded violation) |
| Safe RLHF (Dai et al.) | ICLR 2024 ✓ | scalar aggregate cost budget E[cost]≤d | **per-instance hard** ordinal ceiling (different feasibility region) |
| Distilling System 2 (Meta) | 2407.06023 | distill reasoning to drop machinery (quality) | distilled object = *safety controller*; objective = close safety↔completeness, not quality |
| RIGOURATE (James et al.) | 2026 preprint | *scores* over-claim on ordinal evidence levels | we *generate* under a ceiling, not score existing prose |

## 5. Minimal experiment set (each maps to a reviewer-collapse it prevents)
| # | experiment | proves / prevents |
|---|---|---|
| E1 | open-base baseline (Llama/MedGemma + 1) over-claim on ClaimTrap30 (inference only) | problem exists on open bases (not a Sonnet artifact); pick base |
| E2 | 4-arm: generic / checklist / inference-controller / **CC-OPO** | **trade-off recovery** = CC-OPO matches controller safety (≈0 over-claim) AND completeness > controller's 1.878 → kills "VERI-DPO with a verifier" (L2) |
| E3 | objective ablation: CC-OPO vs vanilla-DPO vs binary-faithfulness-DPO vs Safe-RLHF-budget (**same controller labels**) | the **objective** (not the label) carries it → kills "new verifier, old recipe" (L1) and "Context-DPO/Safe-RLHF variant" (L3) |
| E4 | graded-vs-binary ceiling ablation (collapse L*→supported/unsupported) | the **graded** ceiling is load-bearing, esp. on intermediate L1.5 cases → kills "reframe as VERI-DPO binary verifier" (L4 conjunct-b) |
| E5 | multi-base transfer (Llama + MedGemma + 1) | generality → kills "single model" reviewer attack |

**Held-out discipline (non-negotiable):** train on ClaimTrap30-disjoint manifest pool (auto-labeled by controller);
eval on held-out ClaimTrap30, dual-view, non-self GPT judge.

## 6. Falsifiable kill condition (pre-registered — honesty gate)
The novelty is **Real** only if, on held-out ClaimTrap30:
1. CC-OPO reaches controller-level safety (≈0 over-claim) **AND completeness strictly above the inference controller
   (>1.878)** — i.e., the trade-off is *measurably closed*; and
2. CC-OPO beats vanilla/binary/scalar baselines **specifically on intermediate-evidence (L1.5) cases** (calibrated
   partial-claiming where binary objectives go all-or-nothing).
**If completeness does NOT recover, OR the ordinal structure does not beat binary → reclassify as exploration, not a
contribution.** Do not publish CC-OPO as novel absent both.

## 7. Verdict & venue implication
- This is the **strongest defensible novelty constructible from the gap**: a per-instance ordinal-asymmetric
  evidence-ceiling objective + the controller-distillation trade-off-recovery result. It is **formulation-level
  (composition), contingent on E2–E4 landing** — not a primitive, not guaranteed.
- If E2–E4 land, this becomes a genuine ML contribution (new objective + empirical trade-off result) → **materially
  strengthens the AAAI-main case** (the earlier "pilot benchmark = stretch" problem is replaced by a method+result).
- If they don't land, the honest outcome is the benchmark+controller paper at D&B/BioNLP/ML4H, with CC-OPO as negative/exploration.

## 8. Gates (no GPU until E1 done)
**E1 (open-base baseline, inference only)** first — cheapest decisive check + base selection. Then a **small CC-OPO
vs DPO pilot (E2/E3 at small scale)** to test the kill condition *before* full scale. Only then scale + E4/E5.
Controller v4 frozen; ClaimTrap30 held-out throughout. Needs explicit approval (GPU training from the pilot on).
