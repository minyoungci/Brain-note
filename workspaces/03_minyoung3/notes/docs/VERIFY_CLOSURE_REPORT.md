# ClaimTrap-AD — [VERIFY] Closure Report (2026-06-22)

Closes the residual `[VERIFY]` items from `RELATED_WORK_SCOUT.md` via 4 parallel `literature-scout` runs
(WebSearch/WebFetch live). Source discipline: peer-reviewed = load-bearing; preprint/workshop = supporting only;
unconfirmed fields marked UNVERIFIED, never fabricated.

## TL;DR
- **BiomniBench is NOT a direct threat** → C2 (benchmark) survives, **with a mandatory differentiation sentence**.
  Verdict PARTIAL_OVERLAP (~80% confidence; full text 403-blocked → resolved-but-verify, see below).
- Peer-review statuses fixed: **Length-Controlled AlpacaEval = COLM 2024 (peer-reviewed)**; **PoLL & BenchJack =
  preprint**. → BenchJack must NOT be the sole basis for "leakage family is known"; lean on the peer-reviewed
  contamination line (ICLR'24/NAACL'24) instead.
- All citation metadata confirmed (MedAgentBench DOI, AgentSpec status, CliniFact/FHIR-AgentBench authors,
  2402.08115, 2506.08235=2025.ijcnlp-long.127 same work).
- AAAI-26 reproducibility checklist located → §6 must split *deterministic-reproducible* from
  *LLM-replicable*, report runs/variation, and mark N/A items explicitly.

---

## 1. BiomniBench (gating — P1)
**Verdict: PARTIAL_OVERLAP.** BiomniBench (bioRxiv, DOI 10.64898/2026.05.12.724604, 2026; Phylo/Stanford/Harvard;
"Process-level Evaluation of LLM Agents for Real-world Biomedical Research") scores an agent's **own end-to-end
analytical trajectory** over 100 real tasks via task-specific **A/B/C ordinal rubrics** across 6 dimensions (data
handling · tool/method selection · statistical rigor · biological interpretation · reasoning chain · source
reliability). The single overlap point: the *reasoning-chain* dimension lists "avoids causal overclaims" and
"survival-associated vs predictive" framing.

| Probe | BiomniBench | ClaimTrap-AD C2 |
|---|---|---|
| (a) scores over-claims? | partial — 1 sub-criterion ("avoids causal overclaims") | yes — the central scored axis |
| (b) supplied-artifact → claim validity? | **no** — scores the agent's own trajectory | yes — fixed artifact → conclusion |
| (c) discrete ordered claim ceiling (L0–L3)? | **no** — A/B/C per-criterion quality grade | yes |
| (d) E1–E8 traps (provenance/temporal/covariate/transport/neg-control)? | **no** (faint temporal/transport adjacency only) | yes |

**→ C2 survives.** Required differentiation sentence (add to Related Work + matrix):
> "Unlike process-level agent benchmarks such as BiomniBench (Huang et al. 2026), which grade an agent's own
> end-to-end analytical trajectory with task-specific ordinal rubrics and include only a single generic
> 'avoids causal overclaims' check, ClaimTrap-AD holds the analysis *fixed* — supplying a structured artifact
> and scoring the written conclusion against a shared discrete claim ceiling (L0–L3) and a formal E1–E8 trap
> taxonomy — i.e. claim–evidence calibration rather than analytical-process correctness."

**Residual (NOT fully closed):** per-task rubric files (HF `tests/`, gated) and the bioRxiv full text (403) were
not directly read; author list UNVERIFIED (Kexin Huang confirmed as an author). Confidence ~80%. **Before
submission, a human should open the bioRxiv full text in a browser to (i) confirm no shared claim-ceiling scheme
and (ii) get the author list.** The differentiation sentence is written to hold even if a per-task rubric is
closer than the summary suggests (it distinguishes on fixed-artifact + discrete ceiling + named traps, not merely
on "we check over-claims").

## 2. Peer-review status (P2)
| paper | status | action |
|---|---|---|
| **Length-Controlled AlpacaEval** (Dubois et al.) | **peer-reviewed @ COLM 2024** (OpenReview CybBmzWBX0 + arXiv Comments) | upgrade .bib to @inproceedings; keep author Galambosi |
| **PoLL** (Verga et al., 2404.18796) | **preprint** (DBLP CoRR only; no venue) | cite as "the PoLL preprint (Verga et al. 2024)"; not "published" |
| **BenchJack** (Wang et al., 2605.12673) | **preprint** (CoRR 2026, "in preparation"; ~concurrent, unvetted) | cite as concurrent preprint; do NOT lean on its quantitative claims |

**Framing consequence:** the dual-view (C3) argument "eval-time leakage is a known family" must be anchored on
the **peer-reviewed** contamination works (Golchin & Surdeanu 2024 ICLR; Deng et al. 2024 NAACL) and judge-side
bias (Li et al. 2026 DASFAA); BenchJack is supporting/concurrent only.

## 3. Citation metadata (P3)
- **MedAgentBench**: peer-reviewed **NEJM AI 2(9) 2025**, title **without "Realistic"** ("MedAgentBench: A Virtual
  EHR Environment to Benchmark Medical LLM Agents"), **DOI 10.1056/AIdbp2500144** confirmed, authors Jiang, Black,
  Geng, Park, Zou, Ng, Chen. (arXiv:2501.14654 preprint keeps "Realistic".)
- **AgentSpec**: **accepted ICSE 2026, not yet published** → keep @misc with eprint 2503.18666; no page numbers.
- **CliniFact**: article title = "A dataset for evaluating clinical research claims in large language models"
  (CliniFact = dataset name, not title); authors Zhang, Bornet, Yazdani, Khlebnikov, Milutinovic, Rouhizadeh,
  Amini, Teodoro; Nature Sci Data 12, 86, 2025; DOI 10.1038/s41597-025-04417-x.
- **FHIR-AgentBench**: authors Lee, Bach, Yang, Pollard, Johnson, Choi, Jia, Lee; arXiv:2509.19319, preprint.
- **2402.08115**: Stechly, Valmeekam, Kambhampati, "On the Self-Verification Limitations…", arXiv 2024, no
  confirmed venue → cite as preprint.
- **"Can AI Validate Science?"**: arXiv:2506.08235 and **2025.ijcnlp-long.127 are the SAME work** (6 authors:
  Javaji, Cao, Li, Yu, Muralidhar, Zhu) → cite the ACL peer-reviewed version; arXiv = "preprint of …". No double-cite.

## 4. AAAI-26 reproducibility checklist (P4)
Located (AAAI-26, current; item text stable AAAI-23→26): https://aaai.org/conference/aaai/aaai-26/reproducibility-checklist/
Goes after references, off page-limit, shared with reviewers. §6 must state (concise):
- **Split reproducibility:** controller/verifiers/scoring are *deterministic & reproducible*; generation (Sonnet
  4.6) + judge (GPT-5.5) are *replicable conditioned on recorded model IDs/API dates* (closed hosted models drift).
- **Runs/variation (D-runs/D-variation):** n=3 per case; report per-repeat variation, not just the mean.
- **Significance (D-sig):** N/A — pilot scale, descriptive; no significance tests claimed.
- **No training (D-hp):** N/A — rule-based controller, fixed config released verbatim; no hyperparameter search.
- **Infra (D-infra):** report model IDs, API dates, token usage/cost, Python/lib versions, CPU/OS (no GPU).
- **Release:** benchmark JSONL + controller code + verifiers + judge prompts + per-case traces, free-research license.

---

## Cleared vs Unresolved
**Cleared (10):** BiomniBench verdict (PARTIAL_OVERLAP); LC-AlpacaEval=COLM'24; PoLL=preprint; BenchJack=preprint;
MedAgentBench DOI/title; AgentSpec status; CliniFact authors/title; FHIR-AgentBench authors; 2402.08115 metadata;
2506.08235≡2025.ijcnlp-long.127; AAAI checklist located.
**Unresolved / residual (3):** BiomniBench full-text + author list (403 → human browser read before submission);
AgentSpec final proceedings page numbers (ICSE 2026 not yet held); PoLL/BenchJack non-archival-workshop cannot be
100% excluded (low risk).

## Required paper changes
1. **Related Work + matrix C2**: add the BiomniBench differentiation sentence (above).
2. **.bib**: upgrade LC-AlpacaEval→COLM'24; MedAgentBench→NEJM AI title/DOI; AgentSpec→accepted-not-published;
   fill CliniFact/FHIR-AgentBench authors; add 2402.08115; mark 2506.08235 as preprint-of-2025.ijcnlp-long.127;
   add BiomniBench entry (authors UNVERIFIED).
3. **§6 reproducibility**: replace the `[VERIFY]` stub with the split-reproducibility statement (P4).
4. **No change to abstract or the 4-item contribution list** — C2/C3/C5 framing all hold.
5. **Citations to weaken**: PoLL, BenchJack → "preprint/concurrent"; do not present as peer-reviewed.
