# ClaimTrap-AD — Figure & Table Final Spec (submission, 2026-06-22)

Production spec for the integrated draft (`PAPER_DRAFT_CLAIMTRAP_AD_FULL.md`). **The job of these visuals is to
*defend novelty*, not to show medical results:** Fig 2 = benchmark validity, Fig 3 = technical algorithm, Fig 4 =
empirical trade-off, Fig 5 = failure localization; Table 1 = taxonomy, Table 4 = controller evolution.

**Production rule (integrity):** statistical visuals (Fig 4 bars, Fig 5 heatmap) are rendered by a deterministic
matplotlib script from the committed score CSVs — **never a generative image** (no hallucinated bar heights).
Conceptual diagrams (Fig 1–3) are produced as designed diagrams (paperbanana). Tables are LaTeX `booktabs`.

**Single source of truth (re-confirmed from raw CSVs 2026-06-22):**
generic 19/90 OC · 14/90 HF · 1.678 | checklist 3/90 · 1/90 · 2.622 | controller v4 0/90 · 0/90 · 1.878.
Benchmark: 30 cases = 10 OASIS-derived + 20 constructed probes; levels L1.5:10/L1:17/L0:3; E1:4 E2:4 E3:4 E4:4
E5:4 E6:3 E7:5 E8:2. Controller v4 routing tally (n=3): soft_rewrite 39 / accept 31 / fallback 11 / l0_block 9.

---

## MAIN FIGURES

### Figure 1 — Problem setup: from artifact to unsupported claim
- **Purpose:** fix the problem definition; signal "claim safety, not biomarker discovery" on page 1.
- **Layout:** left→right flow (structured artifact → generic agent → unsupported claim); right column = calibrated
  contrast. Artifact box lists: small AUROC gain · temporal-window ambiguity · label-provenance uncertainty ·
  site/vendor negative control.
- **Data source:** conceptual (worked example: site-only AUROC 0.497 = chance).
- **Message:** weak artifacts get inflated into strong biomarker claims; the correct output is a *lower* claim.
- **Caption:** "ClaimTrap-AD evaluates whether medical research agents overstate what structured biomedical
  analysis artifacts support. The task is claim calibration, not biomarker discovery."
- **Placement:** MAIN. **Producer:** paperbanana (schematic). **Overclaim warning:** the "deployable biomarker"
  text must be shown as the *wrong* claim (red/struck), never as a result.

### Figure 2 — Dual-view benchmark & gold-leak correction  [NOVELTY: benchmark validity]
- **Purpose:** show the leakage-control contribution. **MUST stay in main (never appendix).**
- **Layout:** two panels. LEFT (deprecated, confounded): verification prompt + gold claim level + gold forbidden
  + gold required → answer-aware agent → confounded eval. RIGHT (ClaimTrap30): generation_view (neutral, no gold)
  → agent; scoring_view (gold allowed/forbidden/required/ceiling) → judge only. Bottom banner: "Zero-gold-token
  scan: PASS (0 gold tokens in any agent prompt)."
- **Data source:** conceptual + leakage scan = 0 (committed).
- **Message:** a verification-aware agent becomes answer-aware iff per-case gold enters its prompt; the dual-view
  split makes that structurally impossible.
- **Caption:** "Dual-view evaluation prevents verification-aware agents from becoming answer-aware. Agents see
  only generation_view; gold constraints are restricted to scoring_view (verified by a zero-gold-token scan)."
- **Placement:** MAIN. **Producer:** paperbanana. **Overclaim warning:** label the right path "leak-free
  baseline," NOT "first leakage-free benchmark."

### Figure 3 — Claim Safety Controller algorithm + trace  [NOVELTY: technical core]
- **Purpose:** the technical-novelty figure. **MUST stay in main.**
- **Layout:** vertical flow: artifact A → LLM propose c0 → deterministic evidence extraction → verifier modules
  E1–E8 → claim ceiling L*(e) → over-claim detect (λ(c0)>L*?) → ceiling-dependent routing {L0→hard block;
  L1+→semantic-preserving rewrite} → strict enforcement (multi-word, negation-aware) → final claim + trace.
  Shade the deterministic blocks (code) vs the LLM blocks (propose/rewrite) differently. Side inset = e2_03 trace
  (ΔAUROC +0.04, n=300, feat 40, nested CV no, paired ΔCI no → E2 fires → ceiling L1.5 → "positive increment"
  rejected).
- **Data source:** Algorithm 1 + committed e2_03 trace.
- **Message:** the LLM only proposes/rewrites; the safety decision is deterministic, auditable code.
- **Caption:** "Claim Safety Controller. The LLM proposes and rewrites; deterministic modules extract evidence,
  estimate a claim ceiling, and route the claim through hard blocking or semantic-preserving rewriting."
- **Placement:** MAIN. **Producer:** paperbanana. **Overclaim warning:** do not imply universal coverage
  (≈22/30 cases trigger ≥1 verifier).

### Figure 4 — Main results: safety vs completeness  [empirical result]
- **Purpose:** show the headline numbers AS a trade-off, not a clean win.
- **Layout:** 3 grouped-bar panels (A over-claim/90: 19/3/0; B hard-fail/90: 14/1/0; C completeness mean:
  1.678/2.622/1.878) over arms {Generic, Checklist, Controller v4}. Panel C must visibly show checklist > controller.
- **Data source:** committed `llm_judge_scores.csv` (both runs) — rendered by matplotlib (exact).
- **Message:** controller maximizes safety (A,B) but does NOT dominate completeness (C).
- **Caption:** "Safety–completeness trade-off in the blinded ClaimTrap30 pilot. The controller removes observed
  over-claims but does not dominate checklist prompting on completeness." + footnote: controller arm = fixed
  generic-n1 propose + 3 rewrite resamples (rewrite-stability, not 3 independent draws).
- **Placement:** MAIN. **Producer:** matplotlib. **Overclaim warning:** no "outperforms"; keep the mismatch
  footnote on the figure.

### Figure 5 — Failure-mode heatmap  [failure localization]
- **Purpose:** show results are localized to specific traps, not random.
- **Layout:** rows = key cases/E-types; cols = Generic / Checklist / Controller v4; cells {white=safe,
  yellow=completeness-gap, orange=over-claim, red=hard-fail}. Highlight e2_03 (over/over/safe), e7_01·e7_02
  (hard-fail/safe/safe), e4_04 (v3 over → v4 safe via L0 block).
- **Data source:** per-case recurrence (committed human-corrected + controller per-case CSVs) — matplotlib.
- **Message:** the controller closes the e2_03 residual checklist misses and the e4_04 L0 hole, but leaves
  completeness gaps where conservative routing suppresses caveats.
- **Caption:** "Failure localization across claim-trap categories. The controller removes observed over-claims but
  leaves completeness gaps, particularly where conservative routing suppresses informative caveats."
- **Placement:** MAIN if space, else APPENDIX. **Producer:** matplotlib.

---

## MAIN TABLES (LaTeX booktabs → docs/tables/claimtrap_tables.tex)

### Table 1 — E1–E8 taxonomy & L0–L3 ceilings
- **Cols:** Type | Trap | Wrong-claim example | Required restriction | Typical ceiling.
- **Source:** CLAIM_SCHEMA / VERIFIER_SPEC. **Placement:** MAIN (benchmark section). **Warning:** examples are
  *wrong* claims, not findings.

### Table 2 — Benchmark construction & review pipeline
- **Cols:** Stage | Output | Why it matters. Rows: endpoint feasibility → amyloid label audit → draft generation
  → quality-critic QC → blind 2-reviewer review → human adjudication (30/30 locked) → self-authored gold
  correction (6/30, self-bias ≈79%) → dual-view adapter → zero-gold-token scan (0).
- **Source:** CLAIMTRAP30_FORMAL_REVIEW_REPORT. **Placement:** MAIN if space else APPENDIX.

### Table 3 — Main results
- **Cols:** Arm | Prompt/control | Over-claim | Hard-fail | Completeness | Interpretation.
  Generic 19/90·14/90·1.678 | Checklist 3/90·1/90·2.622 | Controller v4 0/90·0/90·1.878.
- **Title:** "Main results" / "Safety and completeness outcomes" — NEVER "Controller outperforms…". Footnotes:
  safety prioritized; completeness below checklist; generation-base mismatch. **Placement:** MAIN.

### Table 4 — Controller evolution v1–v4  [NOVELTY: algorithmic evolution]
- **Cols:** Version | Policy | n | Over-claim | Completeness | Failure discovered | Lesson.
  v1 hard fallback n=1 0/30 1.633 (over-suppression) | v2 soft rewrite n=1 0/30 1.80 (strict-enforce negation
  bug) | v3 bugfix n=1 0/30 1.833 → n=3 2/90 1.878 (L0 soft-rewrite breach, e4_04) | v4 L0 hard-block + L1+
  rewrite n=3 0/90 1.878 (ceiling-dependent routing, final).
- **Source:** controller_v4_n3_analysis + SCRATCHPAD evolution table. **Placement:** MAIN if space else APPENDIX.
  **Warning:** keep the explicit `n` column (mixed-n is a development narrative, not constant-n head-to-head).

---

## APPENDIX
- **Fig A1** — case distribution bars (E1:4…E8:2; OASIS 10 / probes 20). matplotlib.
- **Fig A2** — dual-view leakage scan report (gold-token leakage 0/0/0 across arms).
- **Fig A3** — 3 controller traces side-by-side (e2_03 incremental, e4_04 L0, e7_01 negative-control).
- **Table A1** — human spot-check summary (over-claim flags adjudicated, all ACCEPT in v4 spot-check).
- **Table A2** — limitations & non-claims (biomarker discovery / clinical deployment / benchmark completeness /
  model superiority / DPO applied / free-text generalization — each with "why not claimed"). Pre-empts over-claim.

---

## PRIORITY PLAN

**Minimum AAAI-main set (tight on space):** Fig 1, **Fig 2, Fig 3**, Fig 4 · Table 1, Table 3.
(Fig 2 = leakage-control, Fig 3 = algorithm — never demote these.)

**Full main set:** Fig 1–5 · Table 1–4.

**Appendix:** Fig 5 + Table 2, Table 4 (if space-constrained) + Fig A1–A3 + Table A1–A2.

**Rule:** if cutting, cut Fig 5 / Table 2 / Table 4 to appendix FIRST; Fig 2 and Fig 3 stay in main regardless.

---

## Produced artifacts (2026-06-22)
All under `docs/figures/` and `docs/tables/`; tracked via `.gitignore` negations (global `*.png/*.pdf` excludes).
- **Fig 1** `fig1_problem_overview.png` — paperbanana (schematic; wrong claims struck-through/red).
- **Fig 2** `fig2_dualview.png` — paperbanana (deprecated vs dual-view; "leak-free", not "first").
- **Fig 3** `fig3_controller_algorithm.png` — paperbanana (LLM blue / deterministic grey; e2_03 trace inset).
- **Fig 4** `fig4_main_results.{pdf,png}` — **matplotlib** from committed CSVs (exact 19/3/0, 14/1/0, 1.678/2.622/1.878).
- **Fig 5** `fig5_failure_heatmap.{pdf,png}` — **matplotlib** per-case status (30×3); controller column has 0 over/hard-fail.
- **Fig A1** `figA1_case_distribution.{pdf,png}` — **matplotlib** (E1:4…E8:2; OASIS 10 / probes 20).
- **Tables 1–4 + A1–A2** `docs/tables/claimtrap_tables.tex` — LaTeX booktabs (pdflatex compile-verified).
- Reproducible figure script: `scripts/make_paper_figures.py` (no LLM). Diagram prompts: `paperbanana_fig{1,2,3}_prompt.md`.
- **Integrity note:** statistical figures (4/5/A1) are rendered from data by code (exact numbers); only conceptual
  diagrams (1/2/3) are generative. Each generative figure was visually verified for text/label correctness.
