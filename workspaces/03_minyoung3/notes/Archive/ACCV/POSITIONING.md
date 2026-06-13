# Positioning — Grounded 3D MRI ROI-VQA (vs M3D / AutoRG-Brain)

Updated: 2026-06-11. Reframes the project after reading the reference works.

## Correction to earlier framing

Earlier we judged the work against "beat the morphometry oracle on a single binary AUC"
and concluded there is no headroom (ceiling ~0.91). That is the WRONG bar. The relevant
3D medical VQA literature does NOT contribute via oracle-beating accuracy:

- **M3D (Bai 2024)**: VQA pairs are LLM-generated (Qwen-72B) from crawled web image-text;
  contribution = large-scale auto-generated dataset + multi-task MLLM (retrieval, report,
  VQA, positioning, segmentation) + M3D-Bench. Pseudo-labels are standard.
- **AutoRG-Brain (Lei 2024)**: grounded report generation with pixel-level region grounding;
  contribution = dataset (anomaly masks + manual reports) + grounded system + grounding eval.

So FreeSurfer-percentile labels are a legitimate pseudo-label, and the contribution axis is
dataset / grounding / system / cross-site generalization — not oracle accuracy.

## Our positioning

A **grounded, multi-cohort, shortcut-controlled 3D MRI ROI-VQA benchmark + system** where a
model must ANSWER an anatomical-evidence question AND GROUND it (localize the ROI evidence),
evaluated under strict leave-one-cohort/vendor-out (LOCO).

## Differentiators (our data + 3D advantage)

| axis | M3D / AutoRG | ours |
|---|---|---|
| labels | LLM-generated (M3D) / manual reports (AutoRG) | FreeSurfer normative-reference pseudo-labels, shortcut-controlled (clinical-context AUC ~ chance) |
| generalization | not emphasized | strict cross-site / cross-vendor LOCO (7 cohorts, 3 vendors) |
| grounding | manual anomaly masks (AutoRG) | ROI masks -> grounding WITHOUT radiologist reports |
| 3D | general 3D | dedicated high-resolution ROI crops + conditioning study |

## Contributions (target)

- C1 Benchmark: shortcut-controlled, multi-cohort/vendor, subject-level LOCO ROI-grounded
  3D MRI VQA (answer + ground), with normative pseudo-labels.
- C2 Grounding: models evaluated not only on answering but on whether attention/localization
  aligns with the true ROI region (pointing-game / IoU / attention-mass-in-ROI) — an axis
  morphometry cannot address.
- C3 Conditioning study: when does explicit 3D ROI conditioning help (representation- and
  capacity-gated; parameter/data efficiency) — the analysis already completed.
- C4 (optional) lightweight system: a single 3D model that answers + grounds across questions.

## Why this is not ceiling-limited

The morphometry oracle returns a number; it cannot ground (localize) or generalize across
unseen scanners as a benchmark. Our value is the grounded multi-cohort benchmark + the
grounding evaluation + the conditioning analysis — none capped by the 0.91 accuracy ceiling.

## Next experiments

1. Grounding evaluation: build per-question ROI ground-truth at the feature grid; measure
   whether B_loc attention / routing align with it (pointing-game, attention-mass-in-ROI),
   per question, under LOCO. New result axis.
2. Frame answering results (existing) as part of the grounded benchmark, not as an
   oracle-beating claim.
3. Honest caveats: no manual reports (no free-text generation); pseudo-label grounding is
   anatomical-region, not radiologist-verified pathology.
