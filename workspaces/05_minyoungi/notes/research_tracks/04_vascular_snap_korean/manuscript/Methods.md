# Methods

_Draft — Alzheimer's Research & Therapy (clinical track + medical-AI implementation detail). Past tense; criteria here, counts in Results; 1:1 correspondence with Results. [VERIFY] = not confirmable from source files._

## Study design and participants

We performed a cross-sectional analysis of two independent Korean memory-clinic cohorts: the AJU cohort (primary) and the KDRC cohort (consistency). Each participant contributed a single baseline magnetic resonance imaging (MRI) session; when multiple sessions were available, the baseline session was retained to avoid repeated-measures dependence. Participants were stratified by amyloid status into amyloid-negative and amyloid-positive groups; the amyloid-negative group was the pre-specified analysis stratum.

## Inclusion and exclusion criteria

Participants were eligible if they had (1) a usable baseline T1-weighted MRI yielding hippocampal and intracranial volumes, (2) a FLAIR sequence suitable for WMH quantification, (3) a categorical amyloid status, and (4) complete covariate data (age, sex, APOE ε4 allele count, and, for the AJU cohort, years of education). Participants lacking any of these were excluded. Selection counts and the exclusion flow are reported in Results (Figure 1).

## Ethics

[VERIFY — institutional review board approval, protocol number, and informed-consent procedures for the AJU and KDRC cohorts were not available in the source files and must be supplied.]

## MRI acquisition and preprocessing

T1-weighted and FLAIR images were acquired on clinical scanners [VERIFY — scanner vendors, field strengths, and sequence parameters to be supplied from acquisition logs]. FLAIR images were acquired as two-dimensional sequences with anisotropic voxels (approximately 0.4 × 0.4 × 5 mm). For the primary analysis, each FLAIR image underwent N4 bias-field correction, rigid (6 degrees-of-freedom) co-registration into the participant's 1-mm T1-weighted space, brain extraction using the T1-derived mask, and robust intensity z-scoring, yielding a 1-mm isotropic FLAIR volume. For a sensitivity analysis (registration robustness), native FLAIR volumes were reconstructed directly from source DICOM using dcm2niix without bias correction, registration, or intensity normalization.

## Hippocampal and intracranial volumetry

T1-weighted images were processed with FastSurfer [VERIFY version], a deep-learning whole-brain segmentation pipeline based on a view-aggregation convolutional neural network (VINN). Bilateral hippocampal volumes were summed. Because the FastSurfer (VINN) output does not provide an estimated total intracranial volume (eTIV), the brain-mask volume (fs_MaskVol) was used as the eTIV proxy for head-size normalization; the whole-brain segmentation volume (fs_BrainSegVol) was retained for a sensitivity analysis. The primary outcome was the eTIV-normalized hippocampal volume, defined as (left + right hippocampal volume) / fs_MaskVol × 1000.

## Quantitative WMH segmentation (deep-learning method)

WMH were quantified with WMH-SynthSeg [VERIFY version; model file WMH-SynthSeg_v10_231110], a published deep-learning model for joint segmentation of brain anatomy and WMH; the model was used as released, without retraining or modification. The network is a three-dimensional U-Net with an encoder–decoder architecture and skip connections, comprising five resolution levels with feature maps following a geometric progression from 64 to 1024. Each convolutional block applied group normalization (8 groups), a 3 × 3 × 3 convolution, and a LeakyReLU activation; downsampling used 2 × 2 × 2 max-pooling. The network received a single-channel image and produced a 33-label segmentation (including WMH, label 77; bilateral hippocampus; cerebral cortex; and ventricular structures). The model was trained entirely on synthetic images generated from anatomical label maps with randomized contrast, resolution, orientation, bias field, and artifacts (the SynthSeg domain-randomization paradigm), rendering inference contrast- and resolution-agnostic; no real images were used in training. At inference, each FLAIR volume was internally resampled to 1 mm and the WMH label volume and tissue volumes were derived. Inference was run on an NVIDIA GPU. WMH-SynthSeg was selected because the cohorts comprised multiple scanners and anisotropic two-dimensional clinical FLAIR, for which acquisition-specific supervised segmenters are prone to out-of-distribution degradation; the domain-randomization design is robust to this heterogeneity. The WMH burden was expressed as a percentage of the WMH-SynthSeg intracranial volume; we note that the WMH normalizer (WMH-SynthSeg intracranial volume) and the hippocampal normalizer (FastSurfer fs_MaskVol) are derived from different tools and different images.

## Visual WMH rating

For comparison with the automated quantification, ordinal visual WMH ratings were available: a three-level visual grade in the AJU cohort and the Fazekas periventricular and deep ratings (summed, 0–6) in the KDRC cohort.

## Amyloid stratification

Amyloid status was defined categorically (negative/positive) from visual amyloid read in both cohorts; continuous amyloid positron-emission-tomography standardized uptake value ratios were additionally available in the KDRC cohort. Amyloid status was used as a stratifier and covariate, not as an analytic endpoint.

## Vascular risk factors

Hypertension, diabetes mellitus, and dyslipidemia were recorded as binary variables; a vascular-risk burden score was their sum (0–3). Continuous measures (blood pressure, fasting glucose, glycated hemoglobin, lipids) were available but contained physiologically implausible out-of-range entries and were therefore not used as covariates [VERIFY — data-cleaning of continuous vascular measures].

## Statistical analysis

The exposure was the within-cohort z-score of log-transformed WMH percentage of intracranial volume. The primary analysis was an ordinary-least-squares regression of eTIV-normalized hippocampal volume on WMH burden within the amyloid-negative stratum, adjusted for age, sex, APOE ε4 count, and education. A robustness battery sequentially added (i) a flexible natural cubic spline for age (4 degrees of freedom), (ii) a non-circular global-atrophy control (cerebral cortical grey-matter volume from WMH-SynthSeg, which excludes the hippocampus and shares no normalizer with the outcome), (iii) the vascular risk factors, and (iv) a registration-quality metric (normalized mutual information of FLAIR-to-T1 registration). A specification-curve analysis enumerated 32 model specifications crossing outcome normalization (eTIV vs whole-brain), WMH transform (log vs raw), age model (linear vs spline), global-atrophy control (present/absent), and vascular-risk adjustment (present/absent). Effect modification by APOE ε4 was assessed with a WMH × ε4 interaction term and ε4-stratified models. Concurrent validity of automated WMH against the visual grade was assessed with Spearman correlation, the Kruskal–Wallis test, and per-grade medians. Mediation analyses (age → WMH → hippocampus; vascular-risk burden → WMH → hippocampus) used the product-of-coefficients estimator with 2000 bootstrap resamples for the indirect-effect confidence interval. Hypertension and diabetes were tested as positive controls for the WMH measure (predicted greater WMH). A registration-robustness sensitivity analysis compared WMH quantified from native versus registered FLAIR in a subset, and additionally adjusted the primary model for registration quality. Analyses used Python (pandas, statsmodels, SciPy) [VERIFY versions]. Statistical significance was set at a two-sided α of 0.05; the primary association is reported without multiplicity correction and contextualized by the specification curve.

## Data and code availability

Analysis code is available at [VERIFY repository]. Cohort data are available under the cohorts' governance [VERIFY data-access pathway].
