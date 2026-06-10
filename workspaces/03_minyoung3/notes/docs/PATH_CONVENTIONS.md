# Path conventions

## Workspace layout

```text
/home/vlm/minyoung3/
  README.md
  docs/
    STUDY_DECISION.md
    PATH_CONVENTIONS.md
    plans/
    context/
  configs/
  scripts/
  tests/
  manifests/
    f04_25d/
  reports/
  results/
  runs/
```

## Active family IDs

- `f04_25d`: axial 2.5D slab construction and smoke gates.
- `f04_ssl_center_slice_mae`: 2.5D center-slice masked reconstruction SSL.
- `f04_official_labels`: official-label-enriched slab/session manifests for downstream probes.
- `f05_2p5d_roi`: planned ROI-informed 2.5D SSL/probe variants.

## Artifact policy

- Raw/shared data under `/home/vlm/data` are read-only.
- Derived manifests for this project go under `/home/vlm/minyoung3/manifests/`.
- Human-readable audits go under `/home/vlm/minyoung3/reports/`.
- Machine-readable result bundles go under `/home/vlm/minyoung3/results/`.
- Training runs go under `/home/vlm/minyoung3/runs/<family_id>/<run_id>/`.
- Korean official notes go under `/home/vlm/minyoung/Official/potato/`.

## Deletion/reset policy

Old 3D/PET/longitudinal voxel remnants were removed on 2026-05-27. Pre-delete inventory and delete log are kept under:

```text
/home/vlm/minyoung/Official/potato/Reset_Audits/
```

Do not recreate 3D/PET-transfer artifacts unless Min explicitly reverses the study decision.

## GPU/long-run gate

Before any GPU training, long inference, or large preprocessing, run and report:

```bash
nvidia-smi
pwd
git status --short --untracked-files=all
 git branch --show-current
```

Then obtain explicit Min approval for long jobs. Short scaffold/pilot smokes must be labeled non-evidential.
