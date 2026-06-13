# F04 ROI Evidence Trainability Review

Updated: 2026-06-01

## Question

Can a direct image model learn ROI-derived anatomical evidence from the current 2.5D T1w slab inputs?

## Active Input

- Dataset: `results/f04_roi_evidence_encoder/20260531_235859_roi_evidence_dataset`
- Training manifest: `slab_roi_evidence_manifest.csv`
- Model input: 5-slice axial T1w slab, downsampled to 96x112
- Evaluation unit: session-level mean over selected slabs

## Smoke Experiment

- Run: `results/f04_roi_evidence_encoder/20260601_030701_roi_evidence_regression_smoke_512s`
- Train: 512 sessions / 1,536 slabs
- Validation: 128 sessions / 384 slabs
- Test: 128 sessions / 384 slabs
- Model: small 2.5D CNN
- Targets: 6 ROI evidence targets
- Best validation checkpoint selected by mean session RMSE

## Medium Experiment

- Run: `results/f04_roi_evidence_encoder/20260601_064349_roi_evidence_regression_medium_1024s_ep3`
- Train: 1,024 sessions / 3,072 slabs
- Validation: 256 sessions / 768 slabs
- Test: 256 sessions / 768 slabs
- Model: small 2.5D CNN
- Epochs: 3
- Validation session RMSE mean: 0.1657 -> 0.1595 -> 0.1578

Note: an attempted 4,096-session run at `results/f04_roi_evidence_encoder/20260601_041131_roi_evidence_regression_medium_4096s` terminated before final artifacts were written. It is not treated as a completed result.

## Test Session Results

### 1,024-Session Medium Run

| target | R2 | Pearson | MAE gain vs mean | interpretation |
|---|---:|---:|---:|---|
| `log1p_roi_ventricle_sum_vol` | 0.293 | 0.642 | +0.0630 | clearly learnable |
| `roi_ventricle_to_brain_proxy` | 0.278 | 0.661 | +0.0052 | clearly learnable |
| `roi_hippocampus_to_ventricle` | 0.273 | 0.549 | +0.0188 | learnable, likely ventricle-driven |
| `log1p_roi_mtl_sum_vol` | 0.035 | 0.238 | +0.0005 | weak |
| `roi_mtl_to_brain_proxy` | 0.028 | 0.270 | +0.0001 | weak |
| `log1p_roi_hippocampus_vol` | 0.014 | 0.218 | -0.0006 | not convincing |

### 512-Session Smoke Run

| target | R2 | Pearson | MAE gain vs mean | interpretation |
|---|---:|---:|---:|---|
| `log1p_roi_ventricle_sum_vol` | 0.238 | 0.506 | +0.0420 | clearly learnable |
| `roi_ventricle_to_brain_proxy` | 0.195 | 0.518 | +0.0044 | learnable |
| `roi_hippocampus_to_ventricle` | 0.196 | 0.448 | +0.0111 | learnable, likely driven by ventricle signal |
| `log1p_roi_mtl_sum_vol` | 0.096 | 0.328 | +0.0052 | weak but positive |
| `log1p_roi_hippocampus_vol` | 0.044 | 0.265 | -0.0001 | weak; not yet convincing |
| `roi_mtl_to_brain_proxy` | -0.033 | 0.099 | -0.0000 | failed in this smoke |

## Verdict

ROI evidence training is feasible, but the learnable signal is not uniformly anatomical.

The strongest learnable signal is ventricular enlargement. The result improved when moving from 512 to 1,024 training sessions, especially for ventricle-related targets. Medial temporal and hippocampal evidence remains weak with the current tiny CNN and axial slab-only input. This supports the next experiment, but the target design should not rely on hippocampus-only supervision.

## Next Experimental Decision

Proceed with a larger ROI evidence encoder only if it includes:

- multi-target ROI supervision, not a single hippocampus target
- explicit session-level aggregation in validation
- target-wise metrics and failure reporting
- comparison against a mean baseline
- shortcut audit after representation extraction

Recommended next target set:

- Primary: `log1p_roi_ventricle_sum_vol`, `roi_ventricle_to_brain_proxy`, `roi_hippocampus_to_ventricle`
- Secondary: `log1p_roi_mtl_sum_vol`, `log1p_roi_hippocampus_vol`
- Hold-out/diagnostic: `roi_mtl_to_brain_proxy`


## Full Cache-Backed Multi-Target Run

- Run: `results/f04_roi_evidence_encoder/20260601_125527_roi_evidence_cached_full_v1`
- Cache: `results/f04_roi_evidence_encoder/20260601_114226_roi_evidence_slab_cache_full_v1`
- Train: 13,221 sessions / 39,663 slabs
- Validation: 2,737 sessions / 8,211 slabs
- Test: 2,855 sessions / 8,565 slabs
- Model: cache-backed 2.5D CNN encoder with 128-dim embedding
- Target weights: primary 1.0, auxiliary 0.4
- Best epoch: 4

### Test Session Results

| target | R2 | Pearson | MAE gain vs mean | interpretation |
|---|---:|---:|---:|---|
| `roi_ventricle_to_brain_proxy` | 0.643 | 0.809 | +0.0133 | strong |
| `log1p_roi_ventricle_sum_vol` | 0.618 | 0.802 | +0.1826 | strong |
| `roi_hippocampus_to_ventricle` | 0.417 | 0.734 | +0.0461 | strong enough for primary evidence |
| `log1p_roi_mtl_sum_vol` | 0.195 | 0.472 | +0.0112 | now learnable, still secondary |
| `log1p_roi_hippocampus_vol` | 0.190 | 0.482 | +0.0098 | now learnable, still secondary |
| `roi_mtl_to_brain_proxy` | 0.109 | 0.344 | +0.0002 | weak but positive |

This full cache-backed run materially strengthens the evidence: multi-target ROI supervision is not merely a small-subset artifact. The representation should now be exported to downstream shortcut/progression audits.


## AEB Downstream Probe

- Run: `results/f04_roi_evidence_encoder/20260601_131409_aeb_downstream_probe_full_v1`
- Input model: `results/f04_roi_evidence_encoder/20260601_125527_roi_evidence_cached_full_v1`
- Exported features: `aeb_features_session.csv`, `aeb_features_slab.csv`
- Pair table: 10,562 pairs with AEB features available

### Raw Split Test Results

| target | best AEB-related model | macro F1 | balanced accuracy | positive recall | clinical macro F1 | interpretation |
|---|---|---:|---:|---:|---:|---|
| `cdrsb_progression_ge05` | `aeb_pred_plus_clinical` | 0.671 | 0.667 | 0.466 | 0.677 | does not beat clinical |
| `diagnosis_worsening` | `aeb_pred_plus_clinical` | 0.662 | 0.687 | 0.453 | 0.663 | similar F1, better balanced accuracy/positive recall |
| `future_ad_from_nonad` | `aeb_pred_plus_clinical` | 0.750 | 0.770 | 0.567 | 0.750 | similar F1, lower balanced accuracy than clinical |

### Interpretation

The AEB encoder clearly learns ROI evidence, but raw split downstream progression is still dominated by clinical context. The most promising downstream signal is `diagnosis_worsening`, where adding AEB evidence to clinical context improves balanced accuracy and positive recall while preserving macro F1.

This is not yet enough for a final novelty claim. The next required test is clinical-matched and within-cohort evaluation of AEB evidence, because raw split performance can still be dominated by baseline clinical variables and cohort composition.
