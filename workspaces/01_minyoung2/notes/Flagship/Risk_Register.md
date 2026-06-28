# Risk Register

## R1: Task2 Weakness Undermines Generality

Status: active.

Risk:

- Task2 meningioma remains low despite foundation pretraining.
- Reviewers may conclude the model is not useful for lesion segmentation.

Mitigation:

- run R4 frozen/low-LR protocol
- per-case failure analysis
- separate Task2-specific limitation from general segmentation capability
- show Task4 improvement clearly

## R2: Challenge Internal Metrics Do Not Generalize

Status: active.

Risk:

- Task1 internal AUROC was much higher than official validation.

Mitigation:

- use external consortium validation
- repeated subject/site splits
- calibration and uncertainty
- avoid overclaiming n=21 internal results

## R3: Novelty May Be Seen as Combination of Known Components

Status: active.

Risk:

- ResEnc, MAE, InfoNCE, KoLeo, SimPool are individually known.

Mitigation:

- frame novelty as anti-leakage dense decoder transfer + dense-global balance
- provide ablation showing why each component was necessary
- emphasize failure modes solved: skip leakage, skip-free negative transfer, global collapse

## R4: Baseline Insufficient

Status: open.

Risk:

- Without nnU-Net/MedicalNet/SwinUNETR comparison, results may look weak.

Mitigation:

- include at least scratch same-architecture and nnU-Net-style segmentation baseline
- add external baselines where feasible

## R5: Data Independence

Status: must audit.

Risk:

- External consortium data may overlap with pretraining sources.

Mitigation:

- subject/site/date overlap audit
- document all exclusion rules
- store audit outputs with immutable paths
