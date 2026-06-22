# ClaimTrap-AD — Related Work Scout (literature-scout output, 2026-06-22)

**Status: VERIFIED inventory.** Produced by 4 parallel `literature-scout` agents (WebSearch+WebFetch live;
all entries checked against arXiv / ACL Anthology / journal pages, NOT memory, unless tagged otherwise).
Source discipline (CLAUDE.md §2): peer-reviewed = load-bearing; arXiv/workshop preprint = supporting only,
never used to assert priority. Items needing a final check before camera-ready are tagged `[VERIFY]`.

> **Headline for the paper's novelty posture (read first):**
> 1. The **central formulation** ("claim safety = compute a ceiling `L*(e)` from the artifact's OWN evidence and
>    enforce `λ(c) ≤ L*(e)`") is **NOT first**. Two PRIOR preprints already calibrate a claim to its own evidence:
>    **RIGOURATE** (arXiv:2601.04350, Jan 2026) and **CSS / Huang et al.** (arXiv:2604.17487, Apr 2026). Both
>    pre-date this work (now 2026-06). "First/novel formulation" wording must be **removed**; differentiate concretely.
> 2. The **hybrid evaluator** (non-self judge + rule screen + human audit) is **assembled known practice**
>    (PoLL, Wang et al., G-Eval). Downgrade from "contribution" to "engineering + a documented failure mode."
> 3. The **benchmark** (claim-calibration as the *scored axis*, on *fixed structured artifacts with planted
>    confounds*, in the *AD-biomarker* domain) **survives as a combination gap** — strongest standalone claim.
> 4. The **controller** survives vs generic guardrails but is *mechanistically*, not categorically, distinct;
>    its remaining edge over CSS is discrete-ordered ceilings + ceiling-dependent block/rewrite routing.
> 5. The **dual-view / answer-key-leakage** contribution (scouted 2026-06-22, Cluster 5) is a **named confound +
>    fix within a KNOWN family**, not a clean novel pillar: eval-time gold leakage is occupied (BenchJack;
>    contamination line; judge-side reference bias). Claim ONLY the *verification-aware → answer-aware* channel +
>    the generation_view/scoring_view fix. ❌ never "first leakage-free benchmark / first info-separation."

---

## Cluster 1 — Medical / clinical LLM-agent benchmarks

**Verdict:** gap survives, but defend against *research-agent* cousins, not the EHR cluster.
EHR/clinical-task benchmarks score task execution / diagnosis / QA correctness — none score claim-calibration.

| paper | venue | id | peer-rev | what | closeness |
|---|---|---|---|---|---|
| MedAgentBench (Jiang et al.) | NEJM AI (DOI 10.1056/AIdbp2500144) | arXiv:2501.14654 | **yes** `[VERIFY DOI]` | 300 physician tasks in FHIR EHR sandbox; **task success** | adjacent |
| AgentClinic (Schmidgall et al.) | npj Digital Medicine (DOI 10.1038/s41746-026-02674-7) | arXiv:2405.07960 | **yes** | simulated doctor–patient; **diagnosis** under incomplete info | adjacent |
| MedAgentsBench (Tang et al.) | arXiv | 2503.07459 | preprint | hard multi-step medical **QA** | background |
| FHIR-AgentBench | arXiv | 2509.19319 | preprint `[VERIFY authors]` | EHR **QA** over real FHIR | background |
| **BixBench** (Mitchener et al.) | arXiv | 2503.00096 | preprint | agent explores bio data, interprets results; **binary correctness** (refusal noted, NOT a calibration metric) | **nearest (data-analysis)** |
| **BiomniBench** (Huang et al.) | bioRxiv (DOI 10.64898/2026.05.12.724604) | — | preprint | **PARTIAL_OVERLAP** (verified via Phylo/Sekbio blogs; full text 403) | process-trajectory scoring, 6 dims A/B/C rubrics; only 1 generic "avoids causal overclaims" check; NO claim ceiling, NO supplied-artifact→claim, NO E1–E8 | **nearest (process) — RESOLVED: not a direct threat** |
| GIScholarBench (Li et al.) | arXiv (→SIGSPATIAL'26) | 2606.08036 | preprint | LLM **overconfidence** in GIS research generation | nearest (concept) |
| ReplicatorBench (Nguyen et al.) | arXiv | 2602.11354 | preprint | replication fidelity, social science | adjacent |

**Differentiation required:** ClaimTrap-AD = (a) claim-calibration as the scored axis + (b) fixed structured
artifacts with planted confounds + (c) AD-biomarker domain. No single benchmark combines all three — but BixBench
covers (a-ish)+(b) and GIScholarBench covers the overclaim concept, so **contrast scored-axis-vs-accuracy and
artifact-grounding-vs-free-generation explicitly.** **BiomniBench (closest, resolved PARTIAL_OVERLAP):** grades the
agent's own end-to-end *trajectory* (data handling, method selection, stat rigor) with task-specific ordinal
rubrics + one generic "avoids causal overclaims" check — it holds NO discrete claim ceiling, NO supplied-artifact→
claim design, NO E1–E8 traps. Required sentence (see VERIFY_CLOSURE_REPORT §1): ClaimTrap-AD holds the analysis
*fixed* and scores the conclusion against a shared discrete ceiling (L0–L3) + E1–E8 taxonomy = claim–evidence
calibration, not process correctness. Off-target (do not cite as competitors): ADAgent, ADRD-Bench, TAP-GPT.

---

## Cluster 2 — LLM-as-a-judge & evaluation reliability

**Verdict:** bias *motivation* is rock-solid and peer-reviewed; the hybrid *pipeline* is largely folklore.
Cite PoLL + Wang up front to pre-empt "you reinvented juries + human-in-the-loop."

| paper | venue | id | peer-rev | role |
|---|---|---|---|---|
| MT-Bench (Zheng et al.) | NeurIPS 2023 D&B | arXiv:2306.05685 | **yes** | foundational LLM-judge + names position/verbosity/self-enhancement bias |
| LLMs are not Fair Evaluators (Wang et al.) | ACL 2024 | 2024.acl-long.511 | **yes** | position bias; **already pairs calibration with human-in-the-loop** |
| G-Eval (Liu et al.) | EMNLP 2023 | 2023.emnlp-main.153 | **yes** | reference-guided LLM scoring (ancestor of our judge) |
| Self-Preference Bias (Wataoka et al.) | NeurIPS'24 workshop | 2410.21819 | workshop | self-preference tracks low-perplexity/familiarity (caution: non-self ≠ bias-free) |
| Length-Controlled AlpacaEval (Dubois et al.) | **COLM 2024** | 2404.04475 | **peer-reviewed** ✓ | verbosity-bias correction |
| **PoLL — Replacing Judges with Juries (Verga et al.)** | arXiv | 2404.18796 | **preprint** (no venue) ✓ | **panel of diverse non-self judges = direct competitor framing to our non-self judge** |

**Differentiation required:** the contribution is the evaluation *target* (claim over-vs-correct-restriction
calibration) and the **documented evaluator failure mode** — the rule screen false-positively penalizing
calibrated negations ("this is *not* a robust biomarker"). Frame the hybrid pipeline as the engineering response,
not the novelty.

---

## Cluster 3 — Biomedical claim verification + over-claim/over-generalization  ⚠️ most consequential

**Verdict:** classic claim-verification (external-evidence binary entailment) poses no threat; but the
**self-evidence calibration** idea has two PRIOR preprints. "First to calibrate a claim to its own evidence" is
**not defensible** — must cite and distinguish both.

| paper | venue | id | peer-rev | what | closeness |
|---|---|---|---|---|---|
| **Peters & Chin-Yee 2025** | Royal Society Open Science (DOI 10.1098/rsos.241776) | — | **yes** | LLMs over-generalize science (26–73%, ~5× human) — *descriptive phenomenon* | **nearest (over-claim concept)** |
| **CSS — Huang et al. 2026** | arXiv | 2604.17487 | preprint (prior, Apr'26) | per-claim back-off to most-specific **admissible level** | **NEAREST (mechanism) — single biggest threat** |
| **RIGOURATE — James et al. 2026** | arXiv | 2601.04350 | preprint (prior, Jan'26) | continuous **overstatement score**: claim vs its OWN evidence | **adjacent (strong)** |
| CLAIM-BENCH (Javaji et al.) | IJCNLP-AACL 2025 | 2025.ijcnlp-long.127 | **yes** | claim↔evidence reasoning in AI papers (binary) | adjacent |
| SciFact (Wadden et al.) | EMNLP 2020 | 2020.emnlp-main.609 | **yes** | scientific claim verification SUPPORT/REFUTE/NEI | background (paradigm anchor) |
| HealthVer (Sarrouti et al.) | Findings EMNLP 2021 | 2021.findings-emnlp.297 | **yes** | health-claim fact-check vs literature | background |
| CliniFact | Nature Scientific Data (DOI 10.1038/s41597-025-04417-x) | — | **yes** `[VERIFY authors]` | 1,970 trial claims, LLM verification | background |
| MuSciClaims (Lal et al.) | IJCNLP-AACL 2025 | 2025.ijcnlp-long.175 | **yes** | multimodal claim verification | background |
| Biomedical Claim Verification (Liang & Sonntag) | BioNLP 2025 (ACL ws) | 2025.bionlp-1.14 | workshop | structured-prompting entailment method | background |

**Differentiation required vs CSS/RIGOURATE (write this verbatim in Related Work):** ClaimTrap-AD's levels are a
**domain-grounded, discrete, ordered evidence hierarchy** (L0 no-claim → L1 within-cohort → L1.5 incremental →
L2 predictive → L3 transportable/deployable) computed from a **biomedical analysis artifact's own statistical
evidence**, and used to **gate/route** an agent's output (block vs semantic-preserving rewrite) — vs CSS's generic
open-domain specificity back-off and RIGOURATE's continuous score over written paper claims.

---

## Cluster 4 — Guardrails / runtime controllers for LLM agents

**Verdict:** controller survives as distinct, but the difference is mechanistic. Lead with the specific delta;
do NOT say "first/only." Nearest peer-reviewed twin = **AgentSpec (ICSE 2026)**.

| paper | venue | id | peer-rev | what | closeness |
|---|---|---|---|---|---|
| **AgentSpec (Wang et al.)** | ICSE 2026 | arXiv:2503.18666 | **yes** `[VERIFY proc.]` | DSL trigger→predicate→enforcement on agent **actions** | **nearest (structural twin)** |
| NeMo Guardrails (Rebedea et al.) | EMNLP 2023 demo | 2310.10501 | **yes** | Colang dialogue/topic/format rails (block/canned) | nearest (rails framing) |
| SelfCheckGPT (Manakul et al.) | EMNLP 2023 | 2023.emnlp-main.557 | **yes** | sampling-consistency hallucination **detection** | background (a verifier, not a controller) |
| Self-Refine (Madaan et al.) | NeurIPS 2023 | 2303.17651 | **yes** | LLM self-feedback iterative rewrite (evidence-agnostic) | background (rewrite prior art) |
| VeriGuard (Miculicich et al.) | arXiv | 2510.05156 | preprint | verify agent policy code vs safety spec | adjacent (cite as preprint only) |
| Llama Guard (Inan et al.) | arXiv | 2312.06674 | preprint | I/O safety classifier | adjacent (cite as preprint only) |
| Guardrails AI | OSS repo | github:guardrails-ai | software | RAIL validators + reask/fix | adjacent (cite repo, no paper) |

**Differentiation required:** novelty rests entirely on the **evidence→ceiling→routing triple being
deterministic and per-claim**, binding the *rewrite target strength* to extracted evidence. Pre-empt: (a)
Self-Refine / Guardrails-AI "reask" already do evidence-*agnostic* rewrite; (b) AgentSpec reviewer may say "your
ceiling is just a predicate" → defense: `L*(e)` is a *computed graded value* driving *semantic-preserving
downgrade*, not a boolean trigger→fixed-action.

---

## Cluster 5 — Answer-key leakage / evaluation contamination (the dual-view contribution)

**Verdict:** the *phenomenon* (gold reaching the system under test → confound) is a known family; the *specific
channel* ClaimTrap-AD names (verification-aware → answer-aware via gold-in-the-self-verification-prompt) was not
found described anywhere. So: domain-specific instance of a known idea, applied to a previously-unnamed channel,
with a concrete fix. Category not new; the named confound + fix are.

| paper | venue | id | peer-rev | what | closeness |
|---|---|---|---|---|---|
| **BenchJack — Do Androids Dream of Breaking the Game?** (Wang et al.) | arXiv (UC Berkeley RDI) | 2605.12673 | preprint | agents read gold from config / manipulate grader because agent+evaluator **share an environment** (219 flaws across 8 benches) | **nearest (problem family) — different channel (infra/filesystem, not the verification prompt)** |
| Evaluating Scoring Bias in LLM-as-a-Judge (Li et al.) | DASFAA 2026 | arXiv:2506.22316 | **yes** | rubric-order / score-ID / **reference-answer** bias in the *judge's* prompt | adjacent (judge-side, not agent-side answer-awareness) |
| Time Travel in LLMs (Golchin & Surdeanu) | ICLR 2024 | arXiv:2308.08493 | **yes** | detect test data leaked into **pretraining** | background (training-corpus channel) |
| Investigating Data Contamination… (Deng et al.) | NAACL 2024 | 2024.naacl-long.482 | **yes** | TS-Guessing; ~29% MMLU/ARC contamination | background (training-corpus channel) |
| Self-Verification Limitations of LLMs (Kambhampati group) | arXiv | 2402.08115 | preprint | self-verification unreliable without an external oracle | adjacent `[VERIFY authors]` — never flags gold-in-prompt as the leak |
| Can Agent Benchmarks Support Their Scores? (Gao & Zhou) | arXiv | 2605.10448 | preprint | evidence-supported bounds on benchmark scores | adjacent |

**Strongest HONEST novelty wording (use ~verbatim):** *"While eval-time gold leakage is well documented for
training-corpus contamination (Golchin & Surdeanu 2024; Deng et al. 2024), shared agent/evaluator environments
(Wang et al. 2026, BenchJack), and judge-side reference bias (Li et al. 2026), we identify a previously-unnamed
channel specific to verification-aware agents: building the self-verification prompt from the per-case gold used
for scoring turns a verification-aware agent into an answer-aware one, confounding any measured benefit of
self-verification. We make this leak structurally impossible via a generation_view/scoring_view separation
verified by a zero-gold-token leakage scan."* ❌ Do NOT claim "first to identify evaluation leakage" or "first
generation/evaluator information separation" — both occupied.

---

## Open verification items — CLOSED 2026-06-22 (see VERIFY_CLOSURE_REPORT.md)
1. ✅ **BiomniBench** — verdict PARTIAL_OVERLAP (not a direct threat); C2 survives w/ differentiation sentence.
   Residual: full text + author list (403 → human browser read before submission). "resolved-but-verify."
2. ✅ Peer-review status: **Length-Controlled AlpacaEval = COLM 2024** (peer-reviewed); **PoLL = preprint**;
   **BenchJack = preprint** (concurrent, unvetted — anchor leakage-family claim on contamination line instead).
3. ✅ **MedAgentBench** = NEJM AI 2(9) 2025, DOI 10.1056/AIdbp2500144, title w/o "Realistic". **AgentSpec** =
   accepted ICSE 2026, proceedings not yet published (residual: page numbers after ICSE 2026).
4. ✅ Author lists filled: **CliniFact** (Zhang et al.), **FHIR-AgentBench** (Lee et al.); **2402.08115** =
   Stechly/Valmeekam/Kambhampati; **2506.08235 ≡ 2025.ijcnlp-long.127** (same work, cite ACL version).

### Residual (carry to camera-ready)
- BiomniBench full text + author list (browser read).
- AgentSpec final ICSE 2026 proceedings page numbers.
- PoLL/BenchJack: non-archival workshop cannot be 100% excluded (low risk).
5. ~~Dual-view / answer-key-leakage cluster~~ **DONE (Cluster 5, 2026-06-22).** Residual: confirm **BenchJack**
   (2605.12673) peer-review status & exact author list; confirm **self-verification-limitations** (2402.08115)
   authors/venue before citing.

## How this maps to the paper's `[VERIFY]` tags
- Removable now (peer-reviewed grounding exists): the *existence + positioning* citations for medical-agent
  benchmarks, LLM-judge bias, claim-verification paradigm, and guardrails (see `.bib`).
- **NOT removable — must be rewritten, not just un-tagged:** every "first/novel formulation" phrase (CSS/RIGOURATE
  prior); the hybrid-evaluator novelty (folklore); the dual-view novelty (unscouted).
See `NOVELTY_POSITIONING_MATRIX.md` for the per-claim verdict and `CLAIMTRAP_AD_CITATION_CANDIDATES.bib`.
