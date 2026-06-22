# exp01 LOCO Segmentation Results

## Current Question

Can a stronger training method or architecture improve 4-channel whole-tumor segmentation
under leave-one-consortium-out evaluation?

Primary metric: subject-level held-out Dice, paired against the standard Dice+BCE 3D U-Net.

## Completed Runs

| run | method | mean Dice | delta vs standard | 95% CI | status |
|---|---|---:|---:|---:|---|
| `standard_dice_bce_loco_full_v1_sharedcache` | compact 3D U-Net, Dice+BCE | 0.884277 | 0 | - | baseline |
| `tail_source_loco_full_v3_sharedcache` | source-balanced focal Tversky+BCE, worst-source checkpoint | 0.878937 | -0.005340 | [-0.007761, -0.002890] | no-go |
| `source_balanced_dice_bce_loco_full_v1_sharedcache` | source-balanced Dice+BCE, worst-source checkpoint | 0.879252 | -0.005025 | [-0.008068, -0.002164] | no-go |
| `standard_dice_bce_tta_all_v1` | all-flip TTA on standard baseline | 0.886454 | +0.002177 | [+0.000459, +0.003924] | diagnostic positive |
| `resunet_ds_dice_bce_loco_full_v1_sharedcache` | residual SE 3D U-Net + deep supervision | 0.887385 | +0.003108 | [+0.000509, +0.005785] | current best training candidate |
| `resunet_ds_tta_all_v1` | all-flip TTA on ResUNet-DS | 0.889639 | +0.005362 | [+0.002599, +0.007976] | previous best performance artifact |
| `unet_flip_consistency_loco_full_v1_sharedcache` | compact 3D U-Net + train-time flip-consistency | 0.882868 | -0.001409 | [-0.004078, +0.001082] | no-go / neutral-negative |
| `resunet_ds_flip_consistency_loco_full_v1_sharedcache` | ResUNet-DS + train-time flip-consistency | 0.883842 | -0.000435 | [-0.003360, +0.002374] | no-go / neutral-negative |
| `resunet_ds_tta_distill_loco_full_v1_sharedcache` | ResUNet-DS + train-time TTA self-distillation | 0.885826 | +0.001549 | [-0.001405, +0.004473] | no-go / hard-fold positive |
| `resunet_ds_tta_distill_tta_all_v1` | all-flip TTA on TTA-distilled ResUNet-DS | 0.888930 | +0.004653 | [+0.001918, +0.007449] | positive, not best |
| `resunet_ds_tta_distill_ensemble_tta_all_v1` | probability ensemble of ResUNet-DS and TTA-distilled ResUNet-DS, all-flip TTA | 0.892775 | +0.008498 | [+0.005960, +0.011038] | new best performance artifact |
| `resunet_ds_ensemble_student_loco_full_v1_sharedcache` | single-pass ResUNet-DS student distilled from the complementary teacher ensemble | 0.885765 | +0.001488 | [-0.001390, +0.004324] | no-go compression |
| `resunet_ds_ensemble_student_tta_all_v1` | all-flip TTA on ensemble-distilled single student | 0.892077 | +0.007800 | [+0.005067, +0.010471] | strong 1-model TTA artifact |
| `resunet_ds_weighted_ensemble_tta_all_v1` | validation-selected weighted ensemble of ResUNet-DS and TTA-distilled ResUNet-DS, all-flip TTA | 0.891906 | +0.007629 | [+0.004949, +0.010257] | no-go vs fixed 50:50 ensemble |
| `resunet_ds_confidence_distill_loco_full_v1_sharedcache` | single-pass ResUNet-DS with confidence-weighted soft BCE+Dice teacher distillation | 0.887774 | +0.003497 | [+0.000801, +0.006272] | positive vs standard, no-go vs ResUNet-DS |
| `resunet_ds_confidence_distill_tta_all_v1` | all-flip TTA on confidence-distilled ResUNet-DS | 0.890254 | +0.005977 | [+0.003389, +0.008572] | positive, not best |
| `resunet_ds_three_model_ensemble_tta_all_v1` | probability ensemble of ResUNet-DS, TTA-distilled ResUNet-DS, and confidence-distilled ResUNet-DS, all-flip TTA | 0.892344 | +0.008067 | [+0.005448, +0.010681] | no-go vs 2-model ensemble |

## Active Runs

No active exp01 GPU runs.

## Best Candidate

`resunet_ds_tta_distill_ensemble_tta_all_v1` is the current best performance artifact.
It ensembles two complementary checkpoints: standard ResUNet-DS and TTA-distilled
ResUNet-DS, both evaluated with all-flip TTA. The TTA-distilled checkpoint alone is not
an overall winner, but it improves the harder MU and UCSD held-out folds; probability
averaging preserves those gains while recovering UTSW/UPENN stability.

## Interpretation

Loss weighting, source-balanced sampling, and train-time flip-consistency were not sufficient.
The first positive training result is architecture-level: residual SE blocks plus deep
supervision. TTA over ResUNet-DS is the current best performance artifact, but it uses extra
inference compute. The completed flip-consistency runs show that naive consistency
regularization does not transfer the TTA gain into a single-pass model; on ResUNet-DS it
significantly worsened performance versus ResUNet-DS alone (-0.003543, CI95
[-0.005933, -0.001208]).

The next test should not repeat plain consistency. It should test whether TTA behavior can
be distilled without forcing both augmented branches to receive equal consistency gradients.

TTA-distillation partially supports this: it improved MU (+0.006838 vs ResUNet-DS) and
UCSD (+0.005980) and reduced Dice <= 0.8 failures on those folds, but lost on UPENN
(-0.001597) and UTSW (-0.006396). This suggests the next useful direction is not stronger
global regularization; it is adaptive or source-risk-aware application of the TTA-derived
training signal, or a direct test-time/ensemble method if the paper claim tolerates extra
inference compute.

The direct ensemble test is positive. Averaging probabilities from the ResUNet-DS and
TTA-distilled ResUNet-DS checkpoints under all-flip TTA gives the current best result:
mean Dice 0.892775. It beats the previous best ResUNet-DS TTA artifact by +0.003136
(CI95 [+0.002044, +0.004342]) and reduces Dice <= 0.8 failures by -0.011750
(CI95 [-0.018553, -0.005566]). This is a performance artifact rather than a clean
single-pass method, but it is the strongest empirical signal so far and shows the
TTA-distilled model contributes complementary information.

Single-pass compression did not work in the first attempt. The ensemble-student model reached
mean Dice 0.885765, below ResUNet-DS alone (-0.001620, CI95 [-0.003487, +0.000300]) and far
below the two-model ensemble-TTA teacher (-0.007010, CI95 [-0.009016, -0.005096]). The result
suggests that the complementary signal is not captured by a simple MSE soft-probability
student objective with cycle-flip teacher views.

However, the ensemble-student checkpoint becomes useful with all-flip TTA: mean Dice
0.892077, beating ResUNet-DS TTA by +0.002438 (CI95 [+0.000792, +0.004210]). It remains
slightly below the two-model ensemble-TTA artifact (-0.000698, CI95 [-0.002478, +0.001103])
but is a cheaper 1-model TTA deployment option.

Validation-selected weighted ensembling did not improve the best artifact. The selected
weights varied by fold (MU 0.7/0.3, UCSD 0.4/0.6, UPENN 0.7/0.3, UTSW 0.5/0.5 for
ResUNet-DS/TTA-distill), but mean Dice was 0.891906. This is still positive against the
standard baseline (+0.007629, CI95 [+0.004949, +0.010257]) but significantly worse than
the fixed 50:50 two-model ensemble-TTA (-0.000869, CI95 [-0.001551, -0.000396]).
The practical read is that validation Dice is not a reliable enough router for fold-level
ensemble weighting; the fixed average remains the stronger and simpler performance artifact.

Confidence-weighted teacher distillation is also not enough as a single-pass method.
It reached mean Dice 0.887774 and is positive versus the standard U-Net baseline
(+0.003497, CI95 [+0.000801, +0.006272]), but it does not clearly beat ResUNet-DS alone
(+0.000389, CI95 [-0.001428, +0.002163]) and remains far below the fixed ensemble-TTA
artifact (-0.005001, CI95 [-0.006488, -0.003496]). Its fold pattern is useful
diagnostically: MU and UCSD improve over ResUNet-DS, while UPENN and UTSW slightly degrade.
All-flip TTA on this checkpoint gives mean Dice 0.890254. It is positive versus the standard
baseline (+0.005977, CI95 [+0.003389, +0.008572]) but does not clearly beat ResUNet-DS TTA
(+0.000616, CI95 [-0.000852, +0.002120]) and is significantly worse than the fixed
two-model ensemble-TTA (-0.002521, CI95 [-0.003665, -0.001373]). Single-pass/one-model
distillation should therefore be treated as a failed compression direction for now, with
the caveat that it improves UCSD relative to ResUNet-DS TTA.

Adding the confidence-distilled checkpoint as a third model in the ensemble also did not
beat the fixed two-model ensemble. The three-model all-flip ensemble reached mean Dice
0.892344, positive versus standard (+0.008067, CI95 [+0.005448, +0.010681]) but slightly
below the two-model ensemble-TTA (-0.000431, CI95 [-0.000940, +0.000089]). This supports
keeping the simpler two-model ensemble as the current best artifact and treating the
confidence-distilled checkpoint as diagnostic rather than a final component.
