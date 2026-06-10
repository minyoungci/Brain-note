# Master Index — Official v2 Dataset, Manifest & Site-Bias Work

_Navigation hub, ordered by importance. Updated 2026-06-03._
_Scope: building/verifying the final integrated manifest, N4 harmonization, site-bias
analysis, and the figures/docs around them. Experiments live in `/home/vlm/minyoung4`._

---

## ⭐ TIER 0 — THE deliverable (start here)

| What | Path | Status |
|---|---|---|
| **Final manifest** (13,022 × 101) | `/home/vlm/data/preprocessed_official/official_manifest_full_n4.{parquet,csv}` | ✅ canonical, use for all downstream |
| **Official data dictionary** | `/home/vlm/data/preprocessed_official/official_manifest_full_n4.README.md` | ✅ authoritative reference |
| N4 model-input tensors | `…/v2/{C}/subjects/*/t1w/final_tensor_n4/` (per-session) | ✅ scanner-bias-reduced, ROI-aligned |

> Load `final_tensor_n4_path` (not the original), subject-level + leave-one-consortium-out
> splits, watch residual site bias. Originals (`official_manifest.csv`, `…_full`) are unchanged.

> 🧭 **다음 연구 주제를 정하려면 → [`research_topic/README.md`](../research_topic/README.md)** — 문헌+우리 실험 적부 판정. 직답: 정확도 SOTA는 죽음, 살아있는 베팅 = cross-population shortcut-audit(CPU 즉시) + biology-guided foundation linear-probe(GPU 조건).

---

## TIER 1 — Core analysis & state (the "why")

| Doc | Path | Contents |
|---|---|---|
| **Full analysis log** | `research_notes/daily/2026-06-02.md` | site-bias quantification, N4 (chosen) vs WhiteStripe/Nyúl/blur (rejected), voxel/scanner backfill, clinical backfill |
| **Harmonization 실험 폴더** | `roi_qc/experiments/harmonization/README.md` | scanner/site bias 측정·완화 실험 모음(우산). 01 bias check, 02 ComBat. `research_notes/daily/2026-06-04.md` |
| ├ 01 site bias check | `…/harmonization/01_scanner_site_bias_check/RESULTS.md` | 7-컨소시엄 식별: **metadata 0.761 > appearance 0.556 > N4 0.517 ≫ biology 0.151≈chance**. site는 픽셀보다 vendor/voxel에 더 박힘. A4/KDRC/AJU/AIBL 지문 수준 |
| └ 02 ComBat (fs_vol) | `…/harmonization/02_combat_fsvol/RESULTS.md` | fs_vol에 ComBat → site 0.238→0.175, biology 비순환 보존(within-ADNI AUC 0.885 불변)+null통과. feature-level만 해결. 문헌(Fortin/Dinsdale/Saponaro) |
| **Handoff state** | `roi_qc/SCRATCHPAD.md` | current status, task ledger, next steps |
| Memory (persistent facts) | `/home/jovyan/.claude/projects/-home-vlm-minyoungi/memory/` | `v2-no-n4-bias-correction`, `manifest-acq-voxel-site`, `clinical-manifest-join`, `fastsurfer-vinn-no-etiv`, `roi-blocked-provisional`, `aju-sex-coding` |

**Key findings (one line each):** v2 had no N4 → scanner shortcut (image→cohort 0.565, chance
0.143); N4 halves pure scanner bias (within-ADNI 0.84→0.66), preserves population; resolution
is an independent, image-irremovable site axis; site==population confound; clinical backfilled
to ≥97% except genuine source gaps (KDRC scanner, KDRC/OASIS/AJU clinical residuals).

---

## TIER 2 — Figures (PaperBanana, `docs/figures/`)

| Figure | Path |
|---|---|
| Why brain-MRI representation learning is hard | `docs/figures/research_challenges/why_brain_rl_is_hard.png` |
| Dataset overview (7 consortiums) | `docs/figures/dataset_overview/dataset_overview.png` |
| Preprocessing & N4 pipeline | `docs/figures/preprocessing_pipeline/preprocessing_pipeline.png` |
| minyoung4 research (shortcut-aware CN/AD) | `docs/figures/minyoung4_research/minyoung4_research.png` |

Each folder keeps its `pb_*_input.md` prompt + `run_*/` artifacts for re-generation.
(Prior figures: `docs/figures/paperbanana/*`.)

---

## TIER 2.5 — Study / tutorial notebooks (`Clinical/studies/`)

> 🧭 **데이터 이해 노트북을 인사이트 축으로 찾으려면 → [`Clinical/INSIGHTS.md`](../Clinical/INSIGHTS.md)** (인사이트→노트북+섹션 지도, 모델링은 harmonization PLAYBOOK으로 브릿지).

| Notebook | 용도 |
|---|---|
| **`research_tutorial/notebooks/research_data_tutorial.ipynb`** | **종합 연구 튜토리얼** (8섹션, 수치+MRI 시각화): manifest·전처리·ROI 신뢰도·해부학·FastSurfer 부피·임상·site bias·연구 체크리스트. 89셀, 0 에러. |
| `qc_scanner_render/notebooks/data_quant_study.ipynb` | 수치 ↔ 이미지 데이터 점검 |
| `qc_scanner_render/notebooks/roi_anatomy_tutorial.ipynb` | 부위 해부 학습 |
| `qc_scanner_render/notebooks/dkt_cortex_extraction.ipynb` | 재처리 없이 DKT 피질 추출 + 신뢰도 |
| `qc_scanner_render/notebooks/qc_scanner_render_study.ipynb` | 컨소시엄/스캐너별 스캔 (A)(B) |

각 폴더는 `notebooks/`(ipynb) · `scripts/`(빌더·헬퍼) 로 분리. 커널: `Python (minyoungi · /opt/conda)`.
공유 헬퍼: `Clinical/common/{mri_io(n4 manifest+N4 loader), roi_tools, render3d}`.

## TIER 3 — Build & verification scripts (`roi_qc/scripts/`, 37 files)

| Stage | Scripts |
|---|---|
| Integrate (→75 col) | `merge_full_manifest.py`, `verify_full_manifest.py` |
| ROI QC | `run_autoqc_full.py`, `auto_anatomical_qc.py`, `merge_verdict_finalize.py` |
| Site-bias probes | `extract_image_features.py`, `probe_site.py`, `probe_robust.py`, `probe_compare4.py`, `probe_resolution7.py` |
| Harmonization tests | `n4_extract_features.py`, `n4_ws_extract_features.py`, `n4_nyul_extract_features.py`, `blur_reprobe.py` |
| **N4 production** | `n4_reprocess_full.py`, `n4_reprocess_verify.py`, `n4_prod_reprobe.py` |
| Manifest enrichment | `extract_acq_voxel.py`, `merge_voxel_into_n4_manifest.py`, `extract_scanner_meta.py`, `backfill_sex.py`, `backfill_clinical.py` |

All merges enforce row-invariance (13,022), original-column immutability, re-read integrity.

---

## TIER 4 — Understanding workspaces (validation/education)

| Area | Path | Purpose |
|---|---|---|
| ROI QC pipeline | `roi_qc/README.md` | numeric+visual ROI QC, fail-closed gates |
| Clinical/source understanding | `Clinical/README.md` | per-consortium raw data, "why RL is hard" insight |
| Voxel-level analysis plan | `Clinical/VOXEL_ANALYSIS_PLAN.md` | ROI-cube dataset design, harmonization notes |
| Manifest lineage (75-col) | `/home/vlm/data/preprocessed_official/official_manifest_full.README.md` | intermediate doc (points to TIER 0) |

---

## TIER 5 — Tooling

| Tool | Path | Notes |
|---|---|---|
| PaperBanana (figure gen) | `tools/paperbanana/` (gitignored) | Gemini backend; CLI `~/.local/bin/paperbanana` |
| `/paperbanana` skill | `/home/jovyan/.claude/skills/paperbanana/SKILL.md` | user-invocable |
| API key | `tools/paperbanana/.env` | gitignored — ⚠️ rotate if exposed |

---

## Maintenance
- Update this index when a TIER-0/1 artifact changes.
- Keep originals immutable; new manifest versions accumulate (never overwrite `official_manifest.csv`).
- Genuine missing data (KDRC scanner, clinical residuals) is documented, not fabricated.
