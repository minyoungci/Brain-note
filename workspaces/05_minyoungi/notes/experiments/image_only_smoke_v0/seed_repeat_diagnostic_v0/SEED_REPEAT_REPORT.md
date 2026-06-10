# image-only seed repeat diagnostic v0

Compared three same-setting scale-up runs: original seed `20260521` plus repeat seeds `20260522`, `20260523`.

## Internal-test seed summary
```
                              run_id     seed  test_bal_acc  test_macro_f1  recall_CN  recall_MCI  recall_AD  pred_count_CN  pred_count_MCI  pred_count_AD  pred_rate_CN  pred_rate_MCI  pred_rate_AD                        confusion_matrix
image_only_smoke_v0_20260521T072243Z 20260521      0.387500       0.374260      0.225      0.6500     0.2875             40             164             36      0.166667       0.683333      0.150000 [[18, 58, 4], [19, 52, 9], [3, 54, 23]]
image_only_smoke_v0_20260521T075236Z 20260522      0.416667       0.330951      0.000      0.7500     0.5000              0             151             89      0.000000       0.629167      0.370833 [[0, 51, 29], [0, 60, 20], [0, 40, 40]]
image_only_smoke_v0_20260521T081446Z 20260523      0.404167       0.323599      0.000      0.5625     0.6500              0             122            118      0.000000       0.508333      0.491667 [[0, 49, 31], [0, 45, 35], [0, 28, 52]]
```

## Aggregate
```
                   mean       std       min       max
test_bal_acc   0.402778  0.014633  0.387500  0.416667
test_macro_f1  0.342937  0.027375  0.323599  0.374260
recall_CN      0.075000  0.129904  0.000000  0.225000
recall_MCI     0.654167  0.093819  0.562500  0.750000
recall_AD      0.479167  0.182146  0.287500  0.650000
pred_rate_CN   0.055556  0.096225  0.000000  0.166667
pred_rate_MCI  0.606944  0.089591  0.508333  0.683333
pred_rate_AD   0.337500  0.173255  0.150000  0.491667
```

## Interpretation

- MCI overprediction is stable across seeds: pred_rate_MCI ranges from 0.5083 to 0.6833, always the largest predicted class.
- CN recall collapses in both repeat seeds: 0.0 for seeds 20260522 and 20260523, while original seed had 0.225.
- The model does not merely trade MCI vs CN/AD randomly; it consistently fails to keep a reliable CN decision region under this tiny downsampled CNN setting.
- AD recall varies upward in repeat seeds, so the instability is mostly in where the model places the CN boundary and how much mass is assigned to MCI vs AD.
- This supports a structural representation/optimization problem for the current image-only tiny CNN, not only a one-off unlucky sample.
