# ClaimTrap-AD SCALED benchmark — result note (2026-06-22)

Scaled the 30-case pilot to **2888 replication-grounded cases** (auto-gold via cross-cohort replication; no
human-labeling bottleneck). Honest outcome: a **credible benchmark** (D&B/BioNLP/ML4H tier), NOT top-tier novelty.

## Size & composition
- 2888 cases (1008 artifact / 1880 real); kinds: univar 2470, planted 228, model 190.
- difficulty strata: easy_real 1706 · easy_artifact 805 · **HARD_artifact 214 (over-claim traps)** · HARD_real 163.
- gold ceiling (auto, from GT replication): L0 1019 · L1 957 · L2 912.
- endpoints CN_AD/CN_MCI/MCI_AD/CN_Dem/CNMCI_AD × LOO over 6 cohorts; manifest read-only.

## Deterministic baselines (artifact detection)
| stratum | n | controller F1 | naive F1 |
|---|--:|--:|--:|
| ALL | 2888 | 0.841 | 0.812 |
| HARD_artifact (traps) | 214 | 0.831 (rec 0.72, prec 0.99) | **nan (rec 0.0)** |
| REAL findings | 2660 | 0.825 | 0.861 |
| PLANTED | 228 | 0.974 | 0.095 |

## The honest core
- HARD_artifact 214 = 116 planted + **98 REAL-derived** (~46% ecologically real; concentrated in MCI contrasts).
- On REAL-derived traps: **naive 0/98 (0%) — total failure**; controller **42/98 (43%)** — much better but misses 57%.
- On clean real findings, naive ≈ controller (real ROI findings replicate; naive significance adequate).

## What this is / isn't
- IS: a large, real, replication-grounded claim-calibration benchmark whose selling point is that naive
  significance catastrophically fails on cross-cohort over-claim traps (0%), a simple controller only partially
  helps (43% real), and the benchmark is **unsaturated** (headroom for future methods). Real D&B-tier contribution.
- ISN'T: top-tier *novel* (benchmark in a populated area: CSS/RIGOURATE/BiomniBench neighbors; "first" dead) and the
  controller does NOT "solve" it. Difficulty is partly planted (54%), partly real (46%) — state both.

## Next (if pursued as the benchmark paper)
- Run LLM agent arms (generic/checklist) as benchmark SUBJECTS on a stratified sample (GPU) — measure agent over-claim.
- Human-validate the 120-case subset (`human_validation_subset.json`) to certify the auto-gold.
- Frame as "claim-calibration benchmark for medical research agents, replication-grounded gold, unsaturated."
