# F04/F05 2.5D + ROI research plan

## 연구 방향 고정

이 프로젝트는 이제 3D volumetric classifier/PET-transfer 방향을 버리고, **2.5D center-slice SSL + ROI-informed representation**으로 간다.

## 핵심 hypothesis

검증된 masked reconstruction pretext task 자체가 novelty가 아니다. Novelty는 다음 조합이다.

1. multi-consortium T1w MRI에서 strict subject/session split을 유지한 2.5D SSL corpus;
2. 중앙 slice masked reconstruction으로 2.5D anatomical context를 학습;
3. ROI를 anatomical prompt/token/crop auxiliary pathway로 통제적으로 주입;
4. official CDR/CDR-SB label authority를 이용한 clinical probe;
5. cohort-only / ROI-volume-only / clinical-only shortcut controls로 false claim 차단.

## Model families

### F04-A: 2D center-slice MAE baseline

- input: center slice only `[1,H,W]`
- target: masked center-slice brain patches
- purpose: 2.5D context benefit 검증용 baseline

### F04-B: 2.5D center-slice MAE main baseline

- input: 5-slice slab `[5,H,W]`
- target: masked center-slice brain patches
- backbone: ViT/MAE-style patch Transformer
- current status: scaffold/pilot PASS

### F05-A: 2.5D + ROI crop auxiliary reconstruction

- input: 5-slice slab + ROI crop/prompt where source contract passes
- ROI use: auxiliary local reconstruction or ROI-token conditioning
- risk: ROI cache alignment imperfection; Visual-QC PASS means usable, not perfect

### F05-B: 2.5D + ROI token/prompt model

- input: slab patch tokens + ROI identity/location tokens
- target: center-slice masked reconstruction and optional ROI-local masked loss
- novelty: anatomical priors without full 3D volume classifier

### F05-controls

- ROI-volume-only probe
- cohort-only forbidden shortcut probe
- 2.5D no-ROI probe
- clinical-only allowed baseline if age/sex coverage is sufficient

## Immediate gates

### Gate 1 — official-label-enriched F04 slab manifest

Build:

```text
manifests/f04_25d/f04_25d_axial_slab_manifest_v0_official_labels.csv
```

Join key:

```text
final_tensor_path
```

Required added fields:

```text
official_label_available
official_cdr_global
official_cdrsb
official_cdr_source
official_cdr_source_table
official_cdrsb_available
```

### Gate 2 — ROI source-contract join

Verify ROI cache rows join to F04 sessions without identity leakage or split mismatch.

Required checks:

- subject/session/path identity join
- PASS-only policy layer
- ROI cache split vs F04 split
- ROI crop tensor shape/range/NaN
- ROI-volume-only shortcut baseline plan

### Gate 3 — F05 dataset smoke

- one F04 slab item + matched ROI item
- tensor shape/range/NaN
- mask/loss semantics
- one forward/backward step

### Gate 4 — downstream probe contract

Before claims:

- session-level embedding extraction
- subject-level aggregation rule
- train/val/test subject overlap check
- official CDR/CDR-SB missingness by cohort
- AIBL excluded from CDR-SB unless explicitly marked missing-label cohort

## Claim boundary

Allowed if evidence supports:

> ROI-informed 2.5D SSL representations improve official-label clinical probes over no-ROI 2.5D and shortcut controls under strict subject-level/cohort-aware evaluation.

Not allowed:

- “ROI causes biological interpretability” without separate validation
- “masked reconstruction is novel”
- “single run proves clinical utility”
- “3D volumetric model result”

## Next action

Implement Gate 1 now: build and test official-label-enriched F04 slab manifest.
