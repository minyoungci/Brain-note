# Teacher Latent Distillation v1 Result

Run:

```text
/home/vlm/minyoungi/experiments/roi_to_image_distill_v0/runs/teacher_latent_distill_v1_20260521T122659Z
```

## Goal shift

Changed objective from ROI value prediction to teacher-latent/logit distillation.

Teacher input:

```text
ROI z/status + age + sex
```

Student input:

```text
T1w image + brain mask only
```

Student loss:

```text
cosine(image_emb, teacher_emb)
+ KL(student_logits, teacher_logits)
+ 0.25 * SmoothL1(pred_roi_z, true_roi_z)
```

## Teacher ceiling on same 80/class split

```text
teacher internal_test balanced_accuracy = 0.5292
teacher internal_test macro_f1          = 0.5199
CN/MCI/AD recall                        = 0.6500 / 0.2750 / 0.6625
```

## Student results

Direct distilled student logits, internal_test:

```text
balanced_accuracy = 0.4000
macro_f1          = 0.3802
CN/MCI/AD recall  = 0.6750 / 0.3125 / 0.2125
```

Frozen embedding logistic probe, internal_test:

```text
balanced_accuracy = 0.4208
macro_f1          = 0.4226
CN/MCI/AD recall  = 0.5125 / 0.3375 / 0.4125
confusion          = [[41,26,13],[37,27,16],[13,34,33]]
```

## Comparison

```text
Image-only tiny CNN mean:
  bal_acc=0.4028, macro_f1=0.3429, recall CN/MCI/AD=0.0750/0.6542/0.4792

CNN ROI-distill v0:
  bal_acc=0.4458, macro_f1=0.4432, recall CN/MCI/AD=0.4000/0.3625/0.5750

ViT ROI-distill v1:
  bal_acc=0.3917, macro_f1=0.3913, recall CN/MCI/AD=0.4875/0.3625/0.3250

Teacher-latent ViT v1:
  bal_acc=0.4208, macro_f1=0.4226, recall CN/MCI/AD=0.5125/0.3375/0.4125
```

## Interpretation

Teacher-latent objective improves over pure ViT ROI-distill v1 for frozen-probe diagnosis metrics, especially AD recall. It also preserves CN recall better than CNN ROI-distill v0. However, it still does not beat CNN ROI-distill v0 overall.

Most likely conclusion:

```text
Teacher-latent/logit distillation is directionally useful,
but the current small ViT student and 80/class regime still cannot fully absorb
teacher geometry. The remaining gap to teacher ceiling is large:
teacher bal_acc 0.5292 vs student frozen probe 0.4208.
```

Next best ablation:

```text
CNN or hybrid Conv-stem student
+ same teacher-latent/logit loss
+ same 80/class split
```

This isolates whether the bottleneck is ViT architecture/data regime rather than the new objective.
