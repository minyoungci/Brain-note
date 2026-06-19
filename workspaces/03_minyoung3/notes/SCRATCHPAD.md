# SCRATCHPAD — conditional 3D brain-MRI generation (current state)

## Direction
**Clinically-conditioned counterfactual 3D brain-MRI generation — Korean AD–SVD cohort (AJU).**
A conditional *latent* diffusion model (AutoencoderKL → conditional DiffusionModelUNet in latent space)
conditioned on a rich multimodal clinical vector; identity-preserving counterfactuals along clinically
meaningful axes (amyloid-PET status, WMH/Fazekas grade, SNSB executive-vs-memory, APOE, vascular subtype).
**Contribution = per-axis conditioning-fidelity READOUT** (which clinical axes are structurally encoded in
T1, measured generatively), not generator fidelity. Target ACCV/MICCAI-tier. Plan:
`/home/jovyan/.claude/plans/glistening-booping-meadow.md`.

## Data / assets (AJU, on disk, 192×224×192 1mm RAS z-score, same grid)
- Images: T1w 1001, FLAIR 985, T2, amyloid-PET 992. `/home/vlm/data/preprocessed_official/v2/AJU/subjects/<id>/<ses>/{t1w,flair,t2,pet_amyloid}/`
- Conditioning ~1000, ~97–100% cov: `korean_multimodal_manifest.csv` (consortium==AJU) + SNSB z from
  `raw/AJU/metadata/임상역학정보 분양_all.xlsx`. amyloid 656neg/344pos, WMH grade 628/312/61, vascular-spectrum ~261,
  dx MCI606/AD190/CN119/OtherDem86, SNSB domains all 1001. (DTI NOT on disk — dropped.)
- In-project AE-pretrain corpus (own assets only): T1 at 192³ — ADNI 10074/NACC 3752/OASIS 3230/AJU 2574/AIBL 1980
  t1w/final_tensor (~10k images). Exclude AJU val/test from AE pretrain.
- Assembled: `manifests/generation_manifest.csv` (N=1001, split 707/147/147 subject-level dx-strat, 48-col missingness mask).
  Built by `scripts/build_generation_manifest.py`.

## Model architecture
**Conditional LATENT diffusion** (two stages):
1. **AutoencoderKL** (conv-only — 3D attention OOMs): 192³ → latent (4,24,28,24). Unconditional.
2. **Conditional DiffusionModelUNet** in latent: the generator. Conditioning HERE via **CondEncoder**
   (per-variable embeddings: continuous MLP + categorical embed + learned MISSING tokens) → cross-attention,
   + classifier-free guidance. Latents precomputed (cached) → fast training.
- Backbone STANDARD (fancy generators lose at N≈707). Novelty goes into conditioning + counterfactual, not backbone.

## ✅ BREAKTHROUGH (2026-06-17): generation WORKS — the "noise" was a SAMPLING-STEPS bug, not the model
The whole noise saga was caused by `sample_m2_sanity.py` sampling with only **100 DDPM ancestral steps** →
divergence to blobs. With the **FULL 1000-step schedule, KL=1e-3 epsilon generates clear conditioned brains**
(cortex, ventricles, WM, gyri — `results/montage_kl1e3_1000step.png`). The KL-retrains (1e-3, 1e-2), v-prediction,
and min-SNR were all chasing the WRONG cause (the model/latent were fine; the prior-gap diagnosis was misleading because
the gate itself was mis-sampled). FIX: default `--steps` 100→1000 in sample_m2_sanity.py. Lesson: when the gate
(montage) is the judge, the gate's own config (sampler steps) must be validated FIRST. Re-evaluating all 4 sweep models
at 1000 steps (`experiments/*/montage_1000.png`) to pick the best. Next real work: conditioning FIDELITY (do AD show
atrophy, WMH3 show WMH?) — the per-axis readout — not "does it generate brains" (it does).

## Current state / open blocker
- **M1 AutoencoderKL DONE — G1 passed**: PSNR 28.33dB / SSIM 0.934. `runs/ae_pretrain/ae_step12000.pt`.
- **M2 conditional latent diffusion: BLOCKED — generates noise, root cause diagnosed.**
  - AE roundtrip = clear brain (L1 0.029); z_sigma tiny (H1 innocent); **partial-noise reconstruction t=200/500/800 = brains**
    → diffusion LEARNED the manifold; only from-pure-N(0,I) sampling fails → **PRIOR GAP**: latent is unit-moment (per-channel
    norm) but NOT Gaussian (KL=1e-6 = no regularization → far from N(0,I)). Textbook LDM failure.
  - Diagnostics: `scripts/diag_m2.py`, `diag_latent.py`, `diag_recon.py` (+ `results/diag_*.png`, `m2_sanity_montage.png`).
- **FIX (next): retrain AE with proper latent regularization** — Option A: KL weight 1e-6 → ~1e-3 (cheap, standard, try first);
  Option B: VQ-VAE/VQGAN latent (SOTA 3D-brain-CF choice). Then re-run M2 → montage must show real brains (the gate).

## M3 conditioning novelty — MEDCOND (RUNNING 2026-06-18) — "make conditioning work + domain novelty"
PROBLEM found: cross-attention-only conditioning on the 15-var clinical vector is WEAK — model ignores it vs the strong
prior (dx→atrophy +0.016 CSF, no CFG amplification, amyloid>dx backwards). FIX = stronger + medically-biased conditioning.
**`scripts/train_ldm_medcond.py` — conditioning = adaLN/FiLM + clinical-token Transformer MIXER + MEDICAL-PRIOR GATES + cross-attn:**
- **adaLN/FiLM**: pooled clinical emb → UNet timestep-emb (via `class_embedding`→`nn.Linear` trick) → modulates EVERY block (strong).
- **clinical-token Transformer mixer** [novel]: self-attention over the 15 correlated clinical vars (models interactions).
- **medical-prior per-axis GATES** [the "medical bias/weight"]: learnable sigmoid gate per var, INIT to T1-structural-relevance
  priors (dx/age/CDR/memory 0.7–0.9; amyloid/APOE/labs 0.2–0.25 = T1-blind; WMH 0.6; exec 0.5). Biases conditioning to
  medically-plausible axes AND the **learned gates = the structural-encoding READOUT** (paper contribution).
- + per-sample CFG dropout on BOTH paths. Trained on best AE (kl1e2). Eval: `scripts/counterfactual_med.py` (gates readout +
  CFG counterfactual fidelity). Orchestrator `run_medcond_pipeline.sh` (detached) auto-evals when training done (~1.75h).
What injected (current): 15 clinical vars = 10 cont (age/edu/MMSE/CDR-SB/amyloid-SUVR/GDS/SNSB-mem/SNSB-exec/HbA1c/LDL)
+ 5 cat (sex/dx/amyloid-vis/WMH-grade/APOE-e4), per-variable embed + missing tokens.

## M3 RESULT (2026-06-18) — medcond conditioning fidelity: MODEL WORKS, single-axis weak by COLLINEARITY
medcond (adaLN+mixer+medgate+xattn) trained 50k (loss 0.40). Fidelity diagnosed in 4 steps:
1. **from-noise CFG CF** (`counterfactual_med.py`): dx ΔCSF +0.020 @s1 but REVERSES @s3/s5; amyloid≈dx; gates static
   (dx .90→.88, amyloid .20→.23). Montage: CN/AD indistinguishable. → looked like failure.
2. **cond-strength diag** (`diag_condstrength.py`): null↔base=0.142 but EVERY axis change (dx/age/cdr/amyloid)=0.11–0.15
   same band → conditioning is received but NON-SPECIFIC/non-structural. Montage: 9 conditions ≈ identical brain.
3. **SDEdit identity-preserving paired CF** (`cf_inversion.py`, real subject→t0 noise→edit dx, same noise): single-axis
   dx ΔCSF +0.0055±0.0070 (signal<noise) → NOT a measurement artifact; conditioning genuinely weak on single axis.
4. **DATA sanity** (real T1 proxy by dx): CN .286/MCI .304/AD .307, **real CN→AD ΔCSF +0.021, Cohen-d=1.33** → signal
   IS in the data; proxy works. ⇒ model-learning issue, not data/proxy.
**RESOLUTION — full-profile CF** (align ALL atrophy-correlated axes: dx=AD + age↑ cdr↑ mmse↓ memory↓): **ΔCSF +0.0160±0.0068,
6/6 subjects positive, = 77% of real**. Montage: CF_AD visibly more ventricle/sulci than CF_CN.
**FINDING (paper-grade): conditioning works as a JOINT clinical syndrome; single-axis CF is diluted by clinical-vector
COLLINEARITY** (changing dx alone while holding age/CDR/MMSE at mean = contradictory "AD-but-cognitively-normal" condition).
→ This is exactly what DECOUPLED CFG (the locked novelty) must solve: recover each axis's UNIQUE structural contribution.
Scripts: `diag_condstrength.py`, `cf_inversion.py` (--t0 sweep, full-profile). Records: `results/{diag_condstrength,cf_profile_t700}.png`.
NEXT: per-axis decoupled-CFG readout (each axis's unique ΔCSF holding correlated axes fixed) — the contribution table;
if all single axes collapse to collinearity, decorrelated retraining (independent per-variable conditioning dropout) to
disentangle. medcond best ckpt: `runs/ldm_medcond/ldm_step50000.pt` (AE `runs/ae_kl1e2/ae_step12000.pt`).

## M3 per-axis READOUT (2026-06-18, `cf_readout.py`, N=8 real subj, single-axis SDEdit t0=700)
ΔCSF per axis (others held at baseline) — sorted:
  age +0.0127±0.0043 (8/8) | dx +0.0063±0.0096 (6/8) | cdr_sb +0.0036±0.0040 (6/8) | mmse -0.001 (3/8) |
  executive -0.001 (4/8) | apoe -0.002 (4/8) | memory -0.004 (3/8) | amyloid -0.004 (2/8) | wmh -0.006 (1/8)
**Only `age` is a clean signal (8/8).** Model funneled atrophy almost entirely into the age token (collinear SHORTCUT:
age always observed in training → it absorbs all atrophy; other axes starved). Two readings: (1) biologically valid —
age is the dominant atrophy driver, dx age-independent increment small, amyloid/exec/wmh ~0 = T1-blind (matches
morphometry-oracle); (2) CONFOUND — amyloid~0 may be "hidden by age" not "truly T1-blind"; indistinguishable now.
→ MUST disentangle before the readout is publishable (reviewer: "age explains everything").
**NEXT (needs GPU ~2h, approval): decorrelated retrain** — INDEPENDENT per-variable conditioning dropout (age dropped
often too) forces each axis to learn its own structural signal → removes age-confound from the readout. If reading (1)
holds after decorrelation = strong paper. Script TODO: `train_ldm_decorr.py` (= medcond + per-var dropout in train loop).

## DECORR SWEEP — RUNNING (2026-06-18 ~07:50, ETA ~1.8h) — break age-shortcut, 4-GPU parallel
`train_ldm_decorr.py` = medcond arch + INDEPENDENT per-variable dropout (each clinical var -> MISSING w.p. pdrop)
to stop the model funneling all atrophy into the always-observed `age` token. AE kl1e2 + shared latent cache reused.
4 strengths in parallel (sweet-spot: too low=shortcut survives, too high=conditioning starved):
  pdrop=0.3 GPU2 (pid 1049358) | 0.4 GPU3 (1049352) | 0.5 GPU4 (1049356) | 0.6 GPU5 (1049357) — all step200 loss0.545 0.13s/it.
Outputs runs/ldm_decorr_p{0.3,0.4,0.5,0.6}/ldm_step50000.pt; logs runs_ldm_decorr_p*.log.
Orchestrator `run_decorr_sweep.sh` (setsid pid 1105948) auto-runs `cf_readout.py` on each when done ->
experiments/decorr_p*/readout.log + experiments/decorr_SUMMARY.md. DISCONNECT-SAFE.
**Judge when done**: did age lose its monopoly (age ΔCSF down, dx/cdr up = collinearity broken)? does amyloid/exec/wmh
stay ~0 (TRUE T1-blind confirmed) or appear (was hidden)? pick best pdrop = cleanest per-axis separation. Baseline to beat:
medcond readout {age +0.0127(8/8) dominant; dx +0.006(6/8); amyloid -0.004(2/8); all others ~0}.

## DECORR SWEEP RESULT (2026-06-18 09:51) — age-shortcut PARTIALLY broken; single-axis fundamentally weak
4 pdrop done (`experiments/decorr_SUMMARY.md`). Per-axis single-axis ΔCSF (vs medcond baseline age+0.0127/8·8 monopoly):
  p0.3: age+.0071(6/8) dx+.0038 rest~.001 (flat, std>mean) | **p0.4 BEST: age+.0039(7/8)≈dx+.0028(6/8)≈cdr+.0027(7/8),
  amyloid+.0013 mem-.002 (age monopoly broken, atrophy-syndrome trio separates from T1-blind axes)** | p0.5: age+.0047,
  rest~0 (over-dropped) | p0.6: all +.002–.003 @4/8 = noise (conditioning starved).
**TRADE-OFF (critical): decorrelation broke age's monopoly but WEAKENED everything** — best single-axis now ~0.003
(15% of real 0.021, signal≈noise). ROOT: single-axis CF is inherently weak even after decorrelation — most atrophy
variance is SHARED across age/dx/cdr; each axis's UNIQUE contribution is small (real data collinearity, not a model bug).
**Two honest readings**: (A) per-axis readout direction holds (atrophy-syndrome>T1-blind) but absolute signal too weak for
strong stats; (B) the publishable result is SYNDROME-LEVEL CF (full-profile = real 75%) + the finding "single clinical
axes are structurally non-separable in T1 by collinearity; amyloid/executive stay ~0 = T1-blind (generative restatement
of morphometry-oracle)". Best model `runs/ldm_decorr_p0.4/ldm_step50000.pt`.
NEXT options: (1) decoupled-CFG guidance (s>1) + N↑(30) on p0.4 to amplify/stat-strengthen per-axis readout [novelty,
not yet tried]; (2) lock syndrome-level frame. Guidance risk: from-noise CFG reversed at s>1 earlier — SDEdit may differ.

## DECOUPLED-CFG RESULT (2026-06-18) — NOVELTY WORKS: guidance amplifies atrophy axes, NOT T1-blind axes
`cf_dcfg.py` on p0.4 (eps = eps_base + s*(eps_axisK - eps_base) per SDEdit step), N=6, t0=700:
  age:     s1 +0.0031(3/6) -> s3 +0.0113(5/6) -> s5 +0.0112  (3.6x, =54% of real 0.021)
  dx:      s1 +0.0021(3/6) -> s3 +0.0035 -> s5 +0.0079(4/6)  (3.8x, monotone)
  amyloid: s1 -0.0012 -> s3 +0.0001 -> s5 +0.0008(2/6)       (FLAT — cannot be amplified)
**Decoupled CFG recovers per-axis fidelity that single-axis(s=1) lost**: structurally-encoded axes (age/dx) grow with s;
T1-blind axis (amyloid) stays ~0 at any s. Stable under SDEdit (NOT the from-noise CFG reversal). This IS the paper's
core demonstration: per-axis structural-encoding readout via decoupled guidance — atrophy >> amyloid(null) = generative
restatement of morphometry-oracle. Best model `runs/ldm_decorr_p0.4/ldm_step50000.pt`, s=3 sweet spot.
LIMITS: N=6 (consistency 5/6,4/6, large sd — NEED N>=24 for stats); dx weaker than age (residual collinearity).
NEXT: scale readout — N>=24, ALL axes (age/dx/cdr/mmse/memory/executive/amyloid/wmh/apoe) x s={1,3} with paired stats
(mean±CI, % positive) -> final contribution table. Optionally identity/minimality (non-target region unchanged).

## FINAL per-axis readout (2026-06-18, `experiments/dcfg_FULL.md`, p0.4, N=18, s1->s3, decoupled-CFG)
ΔCSF (s=1 -> s=3, %pos@s3): age +.0067->+.0161 16/18 | dx +.0034->+.0087 16/18 | cdr +.0028->+.0050 13/18 |
memory +.0016->+.0037 12/18 | amyloid +.0018->+.0032 12/18 | executive +.0015->+.0026 11/18 |
wmh +.0024->+.0029 11/18 | mmse +.0015->+.0017 9/18 | apoe +.0016->+.0008 9/18.
**READOUT**: STRONG age,dx (s3 0.009-0.016, 89% consistent, 1.8-2.6x amplified by guidance) > MID cdr > WEAK/null
memory/amyloid/executive/wmh/mmse/apoe (<=0.004, 50-67% consistent). Decoupled CFG amplifies atrophy axes, not
molecular/cognitive/vascular/genetic — generative restatement of morphometry-oracle (amyloid/executive ~T1-blind).
HONEST CAVEATS: continuous spectrum (not clean dichotomy; amyloid+.0032 != exactly 0); sd large (±.007-.011) so weak-axis
separation not yet statistically firm. NEXT for paper: bootstrap CIs + grouped paired test (atrophy vs blind);
minimality (non-target region unchanged) + identity preservation; then writeup. Pipeline END-TO-END WORKS.

## STATISTICS (2026-06-18, `experiments/STAT_SUMMARY.md`, N=30, bootstrap B=10000) — claims hold
Per-axis s=3 bootstrap 95% CI: **age +0.0112 [+.0076,+.0148] CI>0 ✓ | dx +0.0069 [+.0043,+.0097] ✓** | cdr +0.0030
[-.0000,+.0060] borderline | memory/amyloid/executive/wmh/mmse/apoe ALL CI include 0 (null = T1-blind, stat-confirmed).
**GROUP paired-permutation**: atrophy(age,dx,cdr) +0.0070 vs T1-blind(6 axes) +0.0018, diff +0.0052, **p<0.0001 SIGNIF**.
**Guidance growth s1->s3 (decoupled CFG works)**: age +0.0074 [+.0044,+.0105] | dx +0.0041 [+.0020,+.0062] |
cdr +0.0026 [+.0008,+.0046] — ALL amplified (CI>0). → decoupled CFG significantly amplifies atrophy axes; atrophy >>
T1-blind (p<1e-4); amyloid/executive/etc statistically null = morphometry-oracle confirmed generatively.
Caveat: strong individual signal narrows to age,dx (cdr borderline); weak axes correctly null. PIPELINE+CLAIMS COMPLETE.
NEXT: minimality (non-target region unchanged under CF) + identity preservation → finish fidelity battery → writeup.

## ===== PIVOT: COLLINEARITY-CEILING FINDING (literature-scout #6, 2026-06-18) — strongest direction so far =====
literature: "controllability diagnostic FRAMEWORK" = WEAK (Eval-3D DGM4MICCAI'25 owns per-axis effectiveness/minimality,
same domain/motivation; Melistas, GenCtrl). Clinical-axis extension = data work, not novelty. BUT "collinearity index =
Δ_single/Δ_joint" has 0 explicit prior. **WINNING REFRAME = impossibility/NEGATIVE finding, not a framework:**
**"Clinical-vector COLLINEARITY imposes a ceiling on per-axis controllability in conditional 3D generation that NEITHER
inference-time decoupled guidance NOR training-time decorrelation can surpass."**
WHY STRONG: Eval-3D(metrics)/Causal-Adapter(method) did NOT do this; OUR experiments already evidence it (single-axis weak,
decoupled guidance partial+residual amyloid leak +0.0025, decorrelation trade-off = HFS-predicted age-monopoly-broken-but-
signal-weakened). Venue MICCAI/MIDL (finding); ML venue if impossibility framed rigorously.
MUST-PROVE (else collapses): (1) collinearity index VALIDITY = matches data VIF/condition-number. (2) index ⟂ minimality
(non-redundant info). (3) mitigation CEILING: guidance/decorrelation can't separate collinear axes (= the finding). (4)
synthetic positive control (inject corr -> index monotone). Risk: Eval-3D adjacent; single metric thin -> MUST be the
NEGATIVE/ceiling finding, not "another metric". STATUS: starting (1) VIF on clinical conditioning vector.

## ===== FRAMEWORK LOCK (2026-06-18) — superseded by collinearity-ceiling pivot above; kept for pipeline ref =====
**"Generative per-axis structural-encoding readout"** — a FRAMEWORK that generatively measures WHICH clinical axes are
structurally encoded in brain MRI. Contribution = framework(tool) + finding, NOT generator novelty (all components borrowed
& cited). Venue MICCAI/MIDL/IPMI. Pipeline:
1. Clinical conditioning: multimodal vector — molecular(amyloid-PET) / cognitive(SNSB exec,mem) / vascular(WMH/Fazekas) /
   genetic(APOE) + age/dx/cdr. **The NON-OBVIOUS axes = our white space** (prior work: regional-volume/age/dx only — Peng,
   Eval-3D confirmed).
2. Conditional latent diffusion: AE runs/ae_kl1e2 + cond UNet runs/ldm_decorr_p0.4. [borrowed backbone, cited]
3. Identity-preserving counterfactual: SDEdit invert (cf_inversion.py) + decoupled per-axis guidance (cf_dcfg.py).
   [SEGA-style, cited — NOT claimed novel]
4. Per-axis fidelity battery: effectiveness(ΔCSF) + MINIMALITY + IDENTITY + realism(FID), per axis, subject-bootstrap CI +
   atrophy-vs-blind group test (stat_readout.py). [Eval-3D/Melistas-style, cited]
5. Structural-encoding MAP: which axis, how strongly, (optionally where via spatial attribution).
**FINDING (real contribution)**: age/dx/cdr STRONG (p<1e-4) >> amyloid/executive/WMH/APOE statistically NULL = generative
restatement & multi-axis extension of the morphometry-oracle (no prior work measured molecular/cognitive/vascular/genetic
axes generatively). HONEST: single-axis CF limited by clinical collinearity (HFS-predicted trade-off).
**REVIEWER DEFENSE**: novelty = MEASURED AXES (non-obvious clinical) + finding, not the borrowed pipeline. Cite SEGA(guidance)
+ Eval-3D/Melistas(battery) + Peng(competitor, volume-only) UP FRONT.
**STATUS**: effectiveness + stats done. Fidelity battery (fidelity_battery.py, p0.4 t0=700 N=12): eff ΔCSF +0.0097±0.009
(9/12+), **identity=0.403 (LOW, ~0.9 expected — SDEdit t0=700 loses subject)**, **minimality=0.174 < chance 0.246 (change
is GLOBAL, not localized to ventricular target)**. ⚠️ FIDELITY WEAK = reviewer attack ("CF keeps neither identity nor
locality, why trust readout?"). Trying t0 sweep {400,500,600} for identity↔effectiveness trade-off. If irreducibly weak:
the readout's RELATIVE pattern (amyloid<atrophy) may still hold even if ABSOLUTE fidelity is weak — but must report honestly.
Possible fixes: lower t0 (identity↑), single-axis (locality↑ but eff↓), SynthSeg region metric (replace crude central-box).
**KILLED method directions kept below for record (decoupled CFG/decorrelation/spatial/causal-selective all preempted or
high-risk). Generator novelty = NONE; framework+finding = the paper.**

## CAUSAL-SELECTIVE CONDITIONING — NARROW GAP EXISTS (literature-scout #5, 2026-06-18) — first survivor, GATED
Unlike the 3 prior (fully preempted), TRAINING-TIME causal-graph-informed SELECTIVE decorrelation for conditional
diffusion (graph preserves causal edges, removes spurious edges DURING TRAINING) appears UNOCCUPIED (within search).
Surrounded by strong work:
- **DCFG (Glocker 2506.14399) = TOP THREAT**: same skeleton (graph splits intervened/invariant, group-wise guidance) but
  INFERENCE-TIME only ("no changes to model or loss"). We target TRAINING-TIME shortcut baked into weights. Same group →
  training-time is their natural next step (SCOOP RISK). venue ICML'26 [VERIFY].
- Causal-Adapter (2509.24798): ADNI + "reduce spurious correlation" BUT CTC loss is graph-AGNOSTIC per-attribute disent.
  (not selective); graph only propagates intervention. venue [VERIFY].
- DSCM (ICML'23): graph=true generative process, NO spurious-edge concept. CausalVAE/C-Disent/CausalDiff = independence-
  oriented, not selective preservation.
**SURVIVAL HINGES ON "why inference(DCFG) fails & training is needed"** — show a failure case where the shortcut is baked
into WEIGHTS and inference guidance can't separate it. Without it → "DCFG incremental" reject.
**WE ALREADY HAVE A CLUE**: our cf_dcfg (inference decoupled guidance) left residual amyloid leak +0.0025 @p0.4. If
causal-selective TRAINING reduces it further → gap is real.
**GO/NO-GO GATE (before any commitment)**: toy SCM with LABELED causal/spurious correlations → reproduce "inference(DCFG)
fails + training-selective succeeds". If not reproducible → no gap (4th death). Then research-critic for DCFG/DSCM formal
separation. NOTE: this gap is a THEORETICAL method question (training vs inference), NOT data richness — our data is the
testbed, not the gap's essence. HFS cite tone: "sidesteps causal/spurious by preserving all correlations", not "stated".

## research-critic verdict on causal-selective (2026-06-18) — gap REAL but ONE experiment decides it
FCFG(=DCFG) is **ICML'26 ACCEPTED** and EXPLICITLY scopes out training-time (= our gap is competitor-declared, good).
BUT "shortcut baked in weights → inference can't fix" BROAD claim is FALSE (FCFG queries score at group-masked configs =
uses all weight info). DEFENSIBLE = finite-sample OFF-SUPPORT disentanglement-identifiability: at high ρ the off-support
region (size-intervened, position-fixed) is unpopulated → score mis-estimated there; inference only reweights a wrong
function, training adds gradient pressure off-manifold. Claim the NARROW version, never the broad one.
**MAKE-OR-BREAK (gate): FCFG's FULL 2D weight-grid Pareto frontier must be DOMINATED — no (wc,ws) reaches the oracle
operating point (size preserved AND leak~0). If FCFG reaches it → NO PAPER. Run this BEFORE committing.**
MUST-HAVES (else reject): ① DSCM-edge-deleted baseline (spurious edge removed, refit — strongest objection: "isn't that
just DSCM?"; defense = spurious corr contaminates learned p(x|cond) image mechanism, not just graph edges DSCM deletes).
② ρ-sweep 0→1: gap monotone↑ in ρ, →0 at ρ=0 (else toy is circular). ③ independent probe for leakage (not same render
knob = circular). ④ wrong-graph sensitivity + placebo edge. ⑤ N=707 = plausibility only; PROOF on synthetic; semi-synthetic
bridge (real imgs + injected known corr) for real-image claim (raw clinical causal labels = circular per Point 4).
NARRATIVE: FCFG(sampling-time) ⊥ ours(training-time) = ORTHOGONAL & COMPOSABLE, not "we beat FCFG".
1st-pass toy running: toy_scm.py (std vs selective-oracle) + toy_eval.py (FCFG 2D grid vs oracle) → experiments/toy_gonogo.log.

## SPATIAL CONDITIONING method — DEAD (literature-scout #4, 2026-06-18) — 3rd preemption, pattern is STRUCTURAL
3rd method attempt (anatomically-grounded spatial conditioning) also preempted:
- SPADE-style spatial FiLM = SPADE (CVPR'19) + 3D brain (Karimaghaloo'26). anatomy-grounded 3D brain diffusion =
  AG-LDM/Cor2Vox/VCM (2025-26 red ocean). scalar-attr→spatial counterfactual = **Glocker MICCAI'25 Segmentor-Guided CF**.
- Residual gap (scalar clinical → atlas spatially-varying injection → 3D brain, all three) is REAL but NARROW, weak for
  ACCV/CVPR method (all building blocks off-the-shelf), high Glocker-scoop risk. Candidate 2 (2.5D-3D hybrid) = preempted
  (Choo MICCAI'24). 
**STRUCTURAL PATTERN (3/3 preempted)**: decoupled-CFG→SEGA, decorrelation→BarlowTwins/HFS, spatial→SPADE/Glocker. All were
"global→X" intuitions already owned. Generative-method space is a hyper-competitive red ocean; our off-the-cuff methods are
already done. We are NOT method researchers — our edge is UNIQUE DATA (Korean AD-SVD: amyloid-PET/SNSB exec-mem/WMH/APOE),
not method invention. ACCV(method-required) vs our asset(data+finding) MISMATCH is now triple-confirmed.
**DECISION: stop chasing method novelty (diminishing returns, 4th will also be preempted). Lock MICCAI/DGM4MICCAI FINDING.**
Spatial conditioning SURVIVES as a finding-tool: "which axis changes WHICH anatomical region" = SPATIAL ATTRIBUTION readout
(upgrades per-axis finding from "which axis" to "which axis, where"), NO method-novelty claim. That deepens data+finding.

## WHITE SPACE CONFIRMED (literature-scout #3, 2026-06-18) — FINDING paper is viable
Verified Peng et al. (2409.05585) & Eval-3D (2508.02880) FULL TEXT variable lists:
- Peng: 5 vars = age, diagnosis(**AUD alcohol, NOT AD** — helps us), frontal/insula/parietal VOLUME. No molecular/cognitive/
  vascular/genetic axis. Per-variable single-axis intervention NOT explicitly stated ("unclear" — don't claim they did multi).
- Eval-3D: 7 vars = ventricle + 6 lobe VOLUMES only. Demographics collected but NOT intervention vars. BUT it DID publish
  per-axis single-attribute intervention + effectiveness/minimality framing → the READOUT METHOD is prior art, cite it.
**OUR white space = the AXES, not the method**: no prior 3D brain-CF work uses amyloid-PET / SNSB exec-vs-mem / WMH-Fazekas /
APOE as intervention vars. Positioning (lock): "prior 3D brain CF validates per-axis intervention only for axes TRIVIALLY
encoded in structure (regional volume, age, coarse dx); we measure whether clinical axes whose structural encoding is
NON-OBVIOUS — molecular(amyloid), cognitive-domain dissociation(exec vs mem), vascular(WMH), genetic(APOE) — are readable
from T1." Novelty = WHICH axes + the scientific question; readout framework cited from Eval-3D/Melistas (NOT claimed new).
CAVEAT: both ★★ (arXiv preprint + workshop); verify Peng Springer camera-ready var list before "peer-reviewed" claim [VERIFY].
NEXT: minimality+identity via Eval-3D's effectiveness/minimality framing applied to OUR clinical axes; then writeup.

## DECORRELATION-LOSS method — DEAD for AI venue (literature-scout #2, 2026-06-18)
Tried "collinearity-aware training via conditioning-token decorrelation loss" (train_ldm_orth.py, lam sweep running).
Literature verdict: TRIPLE-occupied + theoretically refuted.
- Mechanism = Barlow Twins (ICML'21) + VICReg (ICLR'22) — our off-diagonal penalty IS their loss.
- Objective = β-TCVAE (NeurIPS'18) / FactorVAE total-correlation — ours is the weak 2nd-order approximation.
- Problem+domain = FCFG (ICML'26, Glocker lab; ~= our cf_dcfg) + Causal-Adapter (CTC loss, ADNI brain-MRI).
- **KILLER: HFS (ICLR'23)** proves forcing independence on CORRELATED factors fails by design → our dropout/decorr
  trade-off (signal weakens) is a PREDICTED failure, not a bug. age↔atrophy is a real biological correlation; cutting it
  destroys signal. No λ fixes this. ⇒ decorrelation loss CANNOT be an AI-venue method contribution.
- orth sweep value now = NEGATIVE ablation only (empirically confirm HFS in medical data: decorrelation doesn't solve the
  trade-off), supports an honest MICCAI finding paper. NOT a method.
- HFS opens the ONLY theoretical gap: distinguish SHARED structural variance (preserve) from SPURIOUS shortcut variance
  (penalize). Our edge if pursued: clinical causal priors could make that distinction (HFS had no causal knowledge). But
  this = a theory paper, high risk, not our strength. Best ckpt of the method line stays runs/ldm_decorr_p0.4.
CONCLUSION: AI-venue METHOD is twice-preempted (decoupled CFG, decorrelation loss). Realistic = MICCAI/MIDL FINDING paper.

## Method positioning (REVISED 2026-06-18 after literature-scout — METHOD NOVELTY IS OCCUPIED)
**HONEST: decoupled CFG is NOT novel.** SEGA (Brack NeurIPS'23) + Composable Diffusion (Liu ECCV'22) already own
"per-concept guidance with independent scales, isolate one axis / hold others" — SEGA's motivation ("global CFG leaks →
guide per-concept") preempts ours verbatim. Brain-MRI per-axis CF + leakage already done: Peng et al. (latent SCM,
DGM4MICCAI'24/25), Eval-3D (DGM4MICCAI'25, minimality = leakage), Melistas (NeurIPS'24 = the fidelity battery itself).
Decorrelated per-var dropout = standard multi-condition CFG practice. ⇒ CANNOT claim a new guidance method (reviewers cite
SEGA+Peng to reject). The std-vs-decoupled benchmark = domain evidence only, NOT a method contribution.
**WHITE SPACE = FINDING, not method**: (1) structural-encoding readout of MOLECULAR/COGNITIVE/VASCULAR axes (amyloid-PET,
SNSB exec/mem, WMH, APOE) — prior work covers only anatomical-volume / dx / age; our stat (atrophy +0.0070 vs T1-blind
6 axes +0.0018, p<1e-4; amyloid/executive statistically null) is a NEW clinically-surprising finding = generative
restatement of morphometry-oracle. (2) Korean AD–SVD + vascular spectrum (not ADNI). (3) collinearity makes single-axis
CF structurally non-separable (honest negative trade-off). POSITIONING: "structural-encoding readout / negative-result
study" using SEGA/Composable-style guidance as a TOOL (cite up front), NOT "we propose decoupled CFG".
**MUST verify next**: Peng et al. full PDF — did they cover molecular(amyloid) axes? if NOT, our white space widens. [VERIFY]
Prior framing (kept for record): per-axis fidelity battery (composition/effectiveness/minimality/realism) per clinical axis.
- Anchors: Melistas et al. NeurIPS 2024 (CF benchmark) + 3D ext DGM4MICCAI 2025; competitor Peng et al. DGM4MICCAI 2025
  (VQ-VAE latent SCM). White space = vascular + cognitive-domain axes (competitors do ADNI age/amyloid). Scoop risk — move fast.
- Add-ons (ROI-ranked): adaLN/FiLM conditioning (data-efficient N≈707); SynthSeg anatomy-consistency for minimality.
- AVOID (hype/kitchen-sink at N≈707): flow-matching-as-contribution, consistency distillation, SSL/foundation conditioning, pure DiT.

## Sweep RESULT (2026-06-18) — BEST model found
Generation works at FULL 1000-step DDPM (100-step/DDIM-200 diverge to noise — that was the whole "noise" saga).
4 configs trained + gen-metric'd (`scripts/eval_gen_metrics.py`: 2.5D-Inception FID, MS-SSIM diversity, NN-SSIM memorization):
| model | FID↓ | div gen/real | mem max |
|---|---|---|---|
| kl1e3_eps | 75.3 | 0.76/0.78 | 0.83 |
| kl1e3_vpred_minsnr | 63.5 | 0.77/0.78 | 0.88 |
| **kl1e2_eps ⭐ BEST** | **53.0** | 0.78/0.78 | 0.87 |
| kl1e2_vpred_minsnr | 54.8 | 0.78/0.78 | ~ |
All: healthy diversity (no collapse), no memorization. **KL=1e-2 > KL=1e-3**; v-pred+min-SNR helps low-KL only.
**BEST = `runs/ldm_kl1e2/ldm_step50000.pt` (kl1e2_eps), AE `runs/ae_kl1e2/ae_step12000.pt`, FID 53, sample at 1000 DDPM steps.**
Records: `experiments/<name>/{montage_1000.png,gensamples.png,genmetrics.log}` + `experiments/SUMMARY.md`.
NEXT: FID = unconditional quality only; the paper's contribution = per-axis conditioning FIDELITY (AD→atrophy,
WMH3→WMH via SynthSeg/WMH-seg). Further FID gains (longer training, larger UNet) have diminishing returns vs the readout.

## Autonomous sweep — (completed; see RESULT above)
`scripts/run_sweep.sh` (setsid, disconnect-safe) runs a diagnosis-ordered experiment queue; each =
train M2 (50k) → montage → record under `experiments/<name>/{montage.png,metrics.log}` + `experiments/SUMMARY.md`.
The montage is the gate (brain vs noise) — human reviews SUMMARY to pick best (brain-vs-noise can't be auto-judged).
Diagnosis: from-pure-noise fails / partial-noise→brain ⇒ high-noise regime under-trained (NOT "latent non-Gaussian"
fundamentally — diffusion handles non-Gaussian data). So v-prediction + min-SNR-γ (rebalance timesteps) is the targeted fix.
Queue:
- **E0 kl1e3_eps** (KL=1e-3 AE, epsilon) — baseline, currently training → runs/ldm_kl1e3.
- **E1 kl1e3_vpred_minsnr** (KL=1e-3 AE, `--pred v --min_snr 5`) — diagnosis-targeted fix, highest priority.
- **E2 kl1e2_eps** (train AE KL=1e-2 → M2 epsilon) — more-Gaussian-latent alternative.
- **E3 kl1e2_vpred_minsnr** (KL=1e-2 AE, v-pred+min-SNR) — combine.
New diffusion knobs (verified by smoke): `train_latent_diffusion.py --pred {epsilon,v} --min_snr <γ>`; ckpt stores `pred`
so `sample_m2_sanity.py` auto-matches the sampler. ETA ~11h total (E2 includes a 3.7h AE retrain). VQ-VAE = last fallback
(bigger detour, data-hungry at N=707, doesn't address the high-noise symptom).

## Roadmap
1. **GATE: fix AE latent (KL↑/VQ) → M2 → montage = real brains?** (whole direction hinges on this.)
2. + Decoupled CFG + FiLM conditioning (the method novelty).
3. T1+FLAIR 2-channel (FLAIR needed for the vascular counterfactual).
4. M3 — per-axis counterfactual fidelity battery (DDIM-inversion CF + SynthSeg/WMH-seg) = the readout.
5. M4 — writeup.

## Discipline
bf16 only; GPU runs need approval + smoke-subset first; `/home/vlm/data` read-only; use ONLY minyoung3 own assets
([[project-isolation-rule]]); subject-level splits; 3D AE conv-only (attention OOMs); GPU0/6/7 often shared — prefer free ones
(check nvidia-smi); detached runs via `nohup`/`setsid` (kill by PID, never `pkill -f <scriptname>` → self-kills shell);
report FID but DON'T claim generator superiority; memorization audit; ALWAYS verify generation visually (loss ≠ working —
montage is the truth). Long runs: `python -u` (block-buffering hides progress).
