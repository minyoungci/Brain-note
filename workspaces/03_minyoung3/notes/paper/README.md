# ClaimTrap-AD — AAAI-2026 submission build

Assembled full draft for the AAAI-2026 main track (target chosen by the author; scout flags it as a stretch —
see `../docs/NOVELTY_POSITIONING_MATRIX.md`). Self-contained: prose + Algorithm 1 + figures + tables + bibliography.

## Files
- `main.tex` — the full paper (abstract → conclusion + appendix). Figures referenced from `../docs/figures/`
  (via `\graphicspath`); bibliography from `claimtrap.bib`.
- `claimtrap.bib` — **clean, BibTeX-safe** citation set (cited keys only; no `%` comments, no editorial `note`
  fields). The annotated superset with provenance/notes is `../docs/CLAIMTRAP_AD_CITATION_CANDIDATES.bib` (planning
  artifact — do NOT feed that one to BibTeX; its `%` headers and `note` fields break it).

## Build (one prerequisite)
The AAAI author kit is **not** included. Download `aaai2026.sty` and `aaai2026.bst` from
<https://aaai.org/authorkit26> into this directory, then from `paper/`:
```
pdflatex main && bibtex main && pdflatex main && pdflatex main
```

## Verification status (2026-06-22)
- The **body + citations** compile cleanly: validated by swapping the AAAI preamble for `article + natbib`
  (`\bibliographystyle{plainnat}`) — 0 LaTeX errors, 0 undefined citations, 0 BibTeX errors (~13 pp at 1in
  margins; expect ~7–9 pp in the AAAI two-column style).
- Algorithm 1 is typeset as a **portable framed box** (no `algorithm.sty` dependency), so it compiles even on
  minimal TeX installs. Swap to a proper `algorithm`/`algorithmic` float if your AAAI environment provides it.
- All numbers verified from committed runs: generic 19/90·14/90·1.678 | checklist 3/90·1/90·2.622 |
  controller v4 0/90·0/90·1.878. Honesty footnotes (generation-base mismatch, mixed-$n$) retained.

## Layout
- **Main**: Fig 1 (problem), Fig 2 (dual-view), Fig 3 (controller algorithm), Fig 4 (results); Table (main results).
- **Appendix**: Tables (taxonomy, construction, controller evolution), Fig 5 (failure heatmap), Fig A1 (case dist).
  If page-constrained, the priority order to cut to appendix is in `../docs/FIGURE_TABLE_FINAL_SPEC.md`
  (Fig 2 and Fig 3 stay in main regardless).

## Residual TODO (camera-ready)
- Add `aaai2026.sty/.bst`; confirm AAAI-26 page limit and move the reproducibility checklist after references.
- Residual `[VERIFY]`: BiomniBench full-text/author list (browser read); AgentSpec ICSE-2026 proceedings page nos.
- Convert the framed Algorithm 1 to a numbered `algorithm` float if desired.
