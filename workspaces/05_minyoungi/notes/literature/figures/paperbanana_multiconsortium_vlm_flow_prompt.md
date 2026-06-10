# PaperBanana Prompt — Multi-consortium ROI-grounded MRI-Language VLM Study Flow

Draw a publication-ready academic methodology figure. Use a clean left-to-right block flowchart, not a decorative illustration. The figure should be suitable for a biomedical AI paper methods overview.

## Title
Multi-consortium ROI-grounded MRI–Language Representation Learning for Dementia

## Central idea
Seven heterogeneous dementia consortia have different CN/MCI/AD class distributions, scanner/site protocols, and PET/CSF/APOE biomarker availability. The study therefore uses a consortium-invariant common core for the main model: 3D T1-weighted MRI, harmonized ROI morphology, and leakage-controlled structured clinical/ROI language captions. Biomarkers are not universal inputs. PET/CSF/ATN biomarkers are used only as availability-aware held-out validation targets or optional masked auxiliary supervision. The model is evaluated as a stress test under severe cohort shift, class-prior shift, and biomarker-availability shift.

## Required layout
Create six vertical columns connected left-to-right with arrows. Each column must have a clear title and concise boxes. Use readable labels and muted journal colors.

### Column 1: Seven-consortium data lake
Show exactly these seven cohort boxes once each:
ADNI, AIBL, OASIS, NACC, Korean Dataset, KDRC, Local/Other cohort.
Add three warning badges: class-prior shift, biomarker availability shift, scanner/site shift.
Add a small red note: No pooled random scan split.

### Column 2: Common-core preprocessing and manifest
Show three streams: 3D T1w MRI, segmentation/ROI morphology, structured clinical table.
Show a manifest box with: subject_id, session_id, cohort, site, t1w_path, seg_path, roi_features, diagnosis, age, sex, visit_month, has_APOE, has_CSF, has_amyloidPET, has_tauPET, split_subject, split_cohort.
Add gate: subject-disjoint and cohort-aware split keys.

### Column 3: Leakage-controlled caption builder
Show structured variables converted into controlled language captions.
Caption views: demographic caption, ROI morphology caption, clinical-function caption, biomarker caption only for explicit privileged-supervision experiments.
Add policy box: allowed/forbidden fields by target.
Diagnosis target forbids diagnosis phrases. Amyloid target forbids amyloid PET, centiloid, CSF Aβ, ATN-A. Tau target forbids tau PET, p-tau, t-tau, ATN-T. Progression target forbids future diagnosis and future scores.

### Column 4: ROI-grounded MRI–Language VLM architecture
Show two parallel streams merging into shared latent space.
Visual stream: 3D T1w MRI → 3D MRI encoder → ROI grounding module → visual embedding z_img.
Text stream: controlled caption → Bio_ClinicalBERT or PubMedBERT → text embedding z_txt.
Alignment: shared latent space with bidirectional InfoNCE contrastive loss.
Add dashed optional module: MTKD warm-start using AD-vs-CN and MCI-vs-CN teacher models to initialize a DenseNet student MRI encoder.

### Column 5: Bias-aware training and ablations
Show training controls: cohort/class-balanced sampler, group-aware contrastive negatives, balanced batches.
Show shortcut baselines: text-only, clinical-only, ROI-only, cohort-only, missingness-only, scanner-only.
Show harmonization ablation: raw ROI vs ComBat ROI. Add note: ComBat is an ROI-level ablation, not assumed to erase bias. No universal full-image ComBat.
Optional ablation: cohort-adversarial loss.

### Column 6: Outputs and stress tests
Show outputs: MRI embedding, text embedding, image-to-text retrieval, text-to-image retrieval, zero-shot prompt matching.
Show probes: CN/MCI/AD diagnosis, MMSE, CDR-SB, MCI-to-AD conversion, longitudinal trajectory alignment.
Show conditional PET/ATN validation: amyloid, tau, ATN, SUVR/centiloid where available.
Show evaluations: within-cohort stratified evaluation, leave-one-consortium-out evaluation, balanced test subset, cohort-wise/class-wise reporting, macro-F1, balanced accuracy, AUROC/AUPRC, calibration.

## Final claim box
At the far right or bottom, include this exact claim:
Stress-tested common-core ROI-grounded MRI–language representation under severe consortium, class-prior, and biomarker-availability shift.

## Style constraints
Readable scientific block diagram. No cartoons. No glossy 3D brain art. No generic AI icons dominating the figure. No fake numbers. Do not show biomarkers as required universal inputs. Do not show ComBat as the main solution. Use compact labels, arrows, grouped boxes, and clear stage titles.
