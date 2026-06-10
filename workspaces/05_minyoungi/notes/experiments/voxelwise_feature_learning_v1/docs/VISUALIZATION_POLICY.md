# Visualization policy

For every baseline/model run, produce at most the final visualization files needed to interpret the run:

- class distribution
- cohort × class distribution
- confusion matrix, if supervised predictions exist
- class-wise recall/F1 bar plot, if supervised predictions exist
- optional ROI-level metric plot for ROI objectives

Do not save exploratory duplicates. If a figure is improved, overwrite the same stable filename and update `REPORT.md`.
