# roi_to_image_distill_v0

ROI teacher → 3D T1w image encoder student distillation experiment scaffold.

Planning source:

```text
/home/vlm/minyoungi/notes/context/ROI_TO_IMAGE_DISTILLATION_V0_PLAN.md
```

Status: plan approved conceptually; implementation should start with schema/dataloader smoke before any full GPU run.

Key rule: distillation training uses image-derived ROI z/status targets only; diagnosis labels are reserved for downstream probes/evaluation.
