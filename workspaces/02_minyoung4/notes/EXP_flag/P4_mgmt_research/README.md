# P4 — MGMT autonomous research track

Created 2026-06-20. Target pivoted to **MGMT methylation** because the IDH ceiling was an
age-confound (age predicts IDH at 0.89). MGMT is NOT age/clinical-predictable — verified clinical
LOCO floor **0.519** (≈ chance) — so imaging has a LOW bar to beat. Goal: imaging technical novelty
that beats the clinical floor / prior MGMT work (BraTS-MGMT ≈ chance 0.5-0.6; some report 0.6-0.7).

## Why this is NOT "the same ceiling"
- IDH: clinical floor (age) = 0.89 → imaging cannot beat it (proven).
- MGMT: clinical floor = 0.519 → imaging beating clinical is structurally possible (open question).
- Risk: MGMT-from-MRI may be no-signal (imaging ≈ 0.5) — a DIFFERENT failure than the age ceiling.

## Directory layout (organized by experiment)
```
P4_mgmt_research/
  README.md                       # this plan + status
  scripts/                        # MGMT-specific: clinical OOF, eval, orchestrator
    orchestrator.sh               # SSH-resilient autonomous runner (setsid nohup)
    mgmt_clinical_oof.py          # MGMT clinical (age/sex/scanner) LOCO OOF for fusion
    mgmt_eval.py                  # image vs clinical floor vs fusion/ensemble; GO/NO-GO
  runs/
    mgmt_clinical_oof.csv         # clinical LOCO predictions
    dann/                         # DANN (DG) fold runs
  reports/                        # baseline_eval.json, ensemble_eval.json
  logs/orchestrator.log           # autonomous run log
```
Baseline image folds run under `../P3_idh_strong/runs/mgmt_{UTSW,UPENN,MU,UCSD}_v1/` (reuse the
audited training pipeline `../P3_idh_strong/scripts/train_idh_strong.py --target mgmt`); referenced
by the orchestrator. Training scripts shared with P3 (`train_idh_strong.py`, `train_idh_dg.py`).

## Autonomous plan (orchestrator phases)
0. MGMT clinical LOCO OOF (for fusion).
1. **Baseline**: strong DenseNet121 MGMT LOCO (4 folds) → eval vs clinical floor.
   GO iff imaging mean AUC > clinical mean + 0.03 (imaging genuinely beats the floor).
2. (if GO) **DG (DANN)** MGMT LOCO (4 folds) + image+clinical fusion + ERM+DANN ensemble → eval.
3. Compare to prior MGMT work; report upgraded result + the technical pipeline.
If NO-GO at Phase 1 (imaging ≈ chance), stop honestly (MGMT no-signal — a different, valid finding).

## SSH resilience
`orchestrator.sh` is launched with `setsid nohup` → a detached OS process that survives session
disconnect. Trainings are launched as its background children (also nohup-detached). Monitor via
`tail -f EXP_flag/P4_mgmt_research/logs/orchestrator.log` and the `reports/*.json`.

## Status
- MGMT baseline UTSW/UPENN/MU training (verified target=mgmt: UTSW test=281, pos186). UCSD launched
  by the orchestrator. Clinical floor 0.519 verified.
