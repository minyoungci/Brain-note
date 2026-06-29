# Supplementary File S1 — TRIPOD-LLM reporting checklist

**Manuscript:** ClaimTrap-AD: A Replication-Grounded Benchmark for Claim Calibration in Medical Research Agents
**Target:** *JAMIA — Research and Applications*
**Guideline:** Gallifant J, Afshar M, Ameen S, et al. The TRIPOD-LLM reporting guideline for studies using large language models. *Nat Med.* 2025;31(1):60–9. doi:10.1038/s41591-024-03425-5.
**Study type for TRIPOD-LLM purposes:** *evaluation/use* of existing large language models (no model development, fine-tuning, or preference optimization was performed). The modular development-specific items are therefore largely not applicable; the modular evaluation/use items apply.

---

> ## ⚠️ HOW TO READ THIS FILE — verification status (do not skip)
>
> | Element | Status |
> |---|---|
> | Citation, item numbering (1–19), and counts (**19 items / 50 subitems** = **14 core items / 32 core subitems** + **5 modular items / 18 modular subitems**) | **VERIFIED** (Crossref + two independent secondary sources, 2026-06-29) |
> | The per-item **topic descriptions** and all **subitem wording** in the "Item (paraphrased)" column | **NOT VERBATIM — every entry is `[VERIFY]`.** Paraphrased from secondary full-text extraction because the official PDF was not machine-parseable and the publisher HTML is paywalled. |
> | The **"Reported in"** column (manuscript location of each item) | Authors' mapping to *this* manuscript — the usable content of this file now. |
>
> **Before submission you MUST** download the official TRIPOD-LLM checklist (Word/PDF) and replace every paraphrased item/subitem description with its verbatim wording, then re-confirm the "Reported in" mapping against the final formatted manuscript. Official sources:
> - EQUATOR: https://www.equator-network.org/reporting-guidelines/the-tripod-llm-reporting-guideline-for-studies-using-large-language-models/
> - TRIPOD statement site: https://www.tripod-statement.org/
> - Open full text (read on screen for exact wording): https://pmc.ncbi.nlm.nih.gov/articles/PMC12104976/
>
> A **separate** "TRIPOD-LLM for Abstracts" checklist also exists (referenced by Item 2) and must be completed in its own file (S1b) before submission. `[VERIFY: obtain and complete the abstracts checklist.]`

---

## Checklist (C = core, applies to all; M = modular, design/task-specific)

### Title and Abstract

| # | Type | Item (paraphrased — `[VERIFY]`) | Reported in |
|---|---|---|---|
| 1 | C | Identify the study as developing, fine-tuning, or **evaluating** an LLM, and the clinical task. `[VERIFY wording]` | Title page (title); Abstract — Objective |
| 2 | C | Structured abstract (see separate TRIPOD-LLM-for-Abstracts checklist). `[VERIFY]` | Structured abstract (≤250 words); separate S1b to be completed |

### Introduction

| # | Type | Item (paraphrased — `[VERIFY]`) | Reported in |
|---|---|---|---|
| 3a | C | Healthcare context, intended use case, and rationale for using an LLM. `[VERIFY]` | Introduction ¶1–2 |
| 3b | M | Target population / setting and intended users of the task being evaluated. `[VERIFY]` | Introduction ¶3; Methods — Study design |
| 4 | C | Study objectives, including the development/validation stage (here: evaluation). `[VERIFY]` | Abstract — Objective; Introduction ¶3 |

### Methods

| # | Type | Item (paraphrased — `[VERIFY]`) | Reported in |
|---|---|---|---|
| 5a–5e | C | Data: sources, description, eligibility, dates, preprocessing, and missing-data handling. `[VERIFY subitem split]` | Methods — Data sources; Scaled replication-grounded benchmark construction (one session/subject; non-missing age, sex, segmentation volume; cohort-viability filter) |
| 6a–6e | C | LLM identity: name, version/snapshot, access, and any development/configuration. `[VERIFY]` | Methods — Pilot agents and judging (`claude-sonnet-4-6`; judge GPT-5.5); Statistical baselines and direct-question LLM evaluation (`Qwen/Qwen3-32B`, `google/medgemma-27b-it`); "No model training, preference optimization, or fine-tuning was performed" |
| 7a–7e | C | Outcome/output definition; how output quality and relevance were assessed; human evaluation. `[VERIFY]` | Methods — Study design (over-claim/completeness definitions; ordinal ceilings); Pilot agents and judging (0–3 rubric; over-claim/hard-fail; human-review packs); Supplement S2.1 |
| 8a–8c | C | Annotation/labeling process and annotators (expertise, number, agreement). `[VERIFY]` | Methods — Pilot benchmark and dual-view protocol (two LLM reviewer agents; adjudication of one case); Auto-gold reliability checks; human-validation by MD co-author (underway); Supplement S2.2 |
| 9a–9b | C | Prompting strategy and the data/inputs provided to the model. `[VERIFY]` | Methods — Pilot agents and judging (generic vs checklist prompts); dual-view generation/scoring split; direct-question prompt arms; Supplement S2.1, S2.3 |
| 10 | M | Preprocessing specific to summarization tasks. `[VERIFY]` | **Not applicable** — task is claim conversion/calibration, not document summarization |
| 11 | M | Instruction tuning / alignment / RLHF performed by the authors. `[VERIFY]` | **Not applicable** — no fine-tuning, alignment, or preference optimization (Methods — Study design) |
| 12 | M | Compute resources / inference configuration. `[VERIFY]` | Methods — decoding settings (temperatures, token budgets); Supplement S2.1 (controller rewrite cost), S2.3 (direct-question decoding) |
| 13 | C | Ethical approval / data-governance statement. `[VERIFY]` | Declarations — Ethics |
| 14a–14f | C | Funding, competing interests, protocol/registration, data and code availability. `[VERIFY]` | Declarations — Data availability; Code availability; Use of AI; Funding; Competing interests; Author contributions |
| 15 | M | Patient and public involvement. `[VERIFY]` | **Not applicable** — secondary analysis of de-identified structured cohort data and constructed fixtures; no PPI |

### Results

| # | Type | Item (paraphrased — `[VERIFY]`) | Reported in |
|---|---|---|---|
| 16a–16d | M | Participant/data flow, characteristics, key variables, and sample sizes. `[VERIFY]` | Methods — Data sources (13,022 sessions / 7,231 subjects / 7 cohorts); Results — Scaled benchmark composition (Table 2). `[VERIFY: add post-filter subjects-per-cohort entering the benchmark — not derivable from the released JSONL]` |
| 17 | C | LLM/system performance, reported per prespecified metric and subgroup. `[VERIFY]` | Results — Tables 1 (pilot arms), 3 (baselines by stratum), 4 (direct-question stances); Wilson CIs |
| 18 | C | Model updating/version changes during the study. `[VERIFY]` | **Not applicable** — fixed model snapshots; no updating during evaluation (state explicitly in final text) |

### Discussion

| # | Type | Item (paraphrased — `[VERIFY]`) | Reported in |
|---|---|---|---|
| 19a | C | Interpretation of results, including fairness/equity considerations. `[VERIFY]` | Discussion — Principal findings; Relation to prior work |
| 19b | C | Limitations and potential biases. `[VERIFY]` | Discussion — Limitations (six items); "Why a discovery-threshold '0% recall' is not a straw-man" |
| 19c–19g | M | Usability, intended use, input handling, required user expertise, and future research. `[VERIFY]` | Discussion — Implications; Limitations (generalization scope); Conclusion |

---

## Pre-submission actions for this file

1. Replace every `[VERIFY]` paraphrased item/subitem description with verbatim wording from the official TRIPOD-LLM checklist (EQUATOR/TRIPOD links above).
2. Complete the separate **TRIPOD-LLM for Abstracts** checklist as S1b.
3. Re-map the "Reported in" column to final page/line numbers after formatting.
4. Confirm each **Not applicable** item is acceptable to mark NA under the official guidance (record a one-line justification per the checklist's instructions), especially Items 10, 11, 15, 18 and the development-specific modular subitems.
5. Add the completed-checklist citation/attribution line required by the guideline.

*End of Supplementary File S1.*
