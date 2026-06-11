# SPEC — PET-Privileged De-Confounding for Site-Invariant 3D Brain-MRI Representations

> Living research spec. Updated through dialogue + after every experiment.
> Target venue: **CVPR / ICCV / ECCV (3D Vision)**. Constraint #1: leakage/overfitting 금지, honest metric.
> Plan of record: `~/.claude/plans/luminous-inventing-knuth.md` (approved 2026-06-11).

## 1. Research question / thesis

구조 MRI 픽셀은 site에 강하게 묶여 있다 (cohort-probe 0.75–0.95). **amyloid PET은 생물학적 신호**다.
*privileged*(train-only, 비싸고 sparse) PET teacher를 T1w student에 distill하면 표현이 site가 아닌
biology 쪽으로 당겨져 **미관측 코호트로 일반화(LOCO↑)**되고 **cohort 분리도↓** 되어야 한다.

**Headline A/B**: *구조* teacher(morphometry)는 site 교란을 **증폭**(0.948); *생물학* teacher(PET)는
**감소**시켜야 한다. 승리조건 = **절대 amyloid AUC 아님**(ceiling ~0) → **cohort-probe AUC↓ + LOCO 질병 AUC↑**.

## 2. Data contract (verified, defect-free)

Tree: `/home/vlm/data/preprocessed_official/v2/{cohort}/subjects/{sid}/{ses}/...` (192×224×192, 1mm RAS).

| modality | ADNI | OASIS | AJU | KDRC | path |
|---|--:|--:|--:|--:|---|
| T1w + FastSurfer seg | ✓ | ✓ | ✓ | ✓ | `t1w/final_tensor_n4/t1w_brain_1mm_RAS_192x224x192_n4_zscore.nii.gz` |
| FLAIR (processed) | ✗ | raw만 | ✓ | ✓ | `flair/flair_brain_1mm_RAS_192x224x192_zscore.nii.gz` |
| **PET amyloid (teacher)** | 669 | 343 | 993 | 891 | `pet_amyloid/pet_suvr_1mm_RAS_192x224x192.nii.gz` (>0 = brain) |

- PET teacher 합계 **2,896 subjects** (hard-defect 0; QC제외 3; 검증: `audits/.../VERIFICATION.md`).
- 라벨 `data/amyloid_label_table.csv`: amyloid binary 100%(4/4); centiloid ADNI/OASIS만; dx/cdr_sb/mmse/age/sex/apoe 대체로 완비(KDRC age/sex 74%).
- **Tracer**: ADNI=AV45, OASIS=AV45+PiB, AJU/KDRC=FBB/FMM(KDRC 개인별 미상). → teacher의 잠재 site 교란원(§4).

## 3. Honest constraints (measured — 재논쟁 금지)

- structure→amyloid ΔAUC ≈ **+0.01 (무용)**; structure→dementia **+0.13 (강함)**; PET→amyloid **0.97 (trivial 직접측정)**.
- **site == population** (traveling-subject 0): fs_vol→cohort **0.747**; learned-feature→cohort **0.92–0.95**.
- morphometry-distill (EXP-002 of Track01): dx 0.931 / **cohort 0.948** / LOCO dx 0.72–0.77.
- harmonization-distill (EXP-003): cohort 0.948→**0.921** only / LOCO +0.01 (타깃 harmonize 불충분 — 교란은 입력 픽셀에).

## 4. ⚠️ Phase-0 kill gate (the single biggest risk)

"PET = biology, not site"는 부분적 참. PET SUVR은 **tracer 신호**(AV45/FBB/FMM/PiB, cohort와 완전상관)를
실음 → teacher 자체가 site-separable이면 distill해도 de-confound 안 됨.
**P0.1에서 먼저 측정**(CPU, 수시간). 우회안: cortical-composite SUVR 비율(tracer-robust), single-tracer
{AJU,KDRC}=FBB/FMM subset, 또는 SUVR ComBat 후 distill.

## 5. Method

- **Student**: 3D DenseNet121 (`minyoungi/.../model.py` ModalityEncoder 재사용), T1w 입력. (ablation: +FLAIR 3코호트)
- **Teacher/objective (최단순부터)**: **regional-SUVR regression** — student가 T1w로 per-ROI amyloid SUVR 예측
  (생물학적 distill 타깃; morphometry-distill에서 fs_vol→regional-SUVR로 교체). `pretrain_morphometry.py` 거의 재사용.
  ablation: frozen PET encoder feature distillation.
- **De-confound**: implicit(생물학 타깃) + (ablation) explicit cohort-adversarial **GRL**.

## 6. Evaluation protocol

Frozen student → linear probe (`eval_distilled.py` 패턴 4코호트 확장): **cohort-probe AUC↓**, **LOCO dementia AUC↑**,
amyloid **ΔAUC-over-clinical**(정직 보고). Baseline ladder: random · supervised-T1w · morpho-distill(0.948/0.72–0.77) ·
harm-distill(0.921) · **PET-distill(ours)**. **모든 수치는 clinical-only(age/sex/mmse/apoe) baseline 대비 ΔAUC.**

**WIN GATE**: PET-distill cohort-probe **< 0.85** (vs 0.948) **AND** LOCO dementia ≥ 0.72–0.77.
cohort↓인데 LOCO도↓ → 신호파괴(정직 negative+분석). 둘 다 미개선 → 실패, Direction B로 pivot.

## 7. Artifact policy (산출물 누적 방지)

- 트리: `minyoung4/experiments/` — **method/objective당 1 디렉토리**, **timestamp 복사 금지**, 체크포인트 **이름고정·in-place 갱신**,
  `BASELINE_INDEX.json` 레지스트리 + `LATEST.json`. 캐시는 gitignore `cache/`(재생성가능). 리포트=작은 `.md`+`.csv`.

## 8. Experiment log (append)

| EXP | date | hypothesis | result | next |
|---|---|---|---|---|
| P0.2 | 2026-06-11 | 4코호트 subject-level + LOCO splits | ✅ 3180 subj (has_pet 2527), random+4 LOCO, subject-disjoint 검증 | splits/ |
| P0.3 | 2026-06-11 | clinical-only ΔAUC baseline | ✅ amyloid 0.78(mmse 포함); dementia **비인지** baseline 0.64–0.78(헤드룸有). ⚠️ MMSE는 cdr_sb와 순환→dementia서 제외. **KDRC dementia 케이스 거의 0**(probe 3코호트만) | reports/P0_3 |
| P0.1 | 2026-06-11 | PET teacher가 cohort-separable인가? (KILL GATE) | ⚠️ **YELLOW**: SUVR분포→cohort **0.829** (구조 0.747보다 *높음*). same-tracer{AJU,KDRC} 0.78 | P0.1b/c |
| P0.1b | 2026-06-11 | 분리도가 절대 scale(tracer)인가 shape인가 | scale-norm해도 0.829→**0.776**뿐 — shape에도 cohort 신호. raw SUVR은 깨끗한 teacher 아님 | P0.1c |
| P0.1c | 2026-06-11 | amyloid 통제 후 잔여 cohort 분리 = 교란 vs 진짜 biology | ❌ **CONFOUND**: amyloid-음성만에서도 cohort **0.855** (전체 0.829) → tracer/scanner 교란이 dominant, amyloid biology 아님 | **GATE 발화** |

## 🚩 Phase-0 GO/NO-GO (2026-06-11)

**Direction A (PET-privileged de-confounding) 전제 반증됨:**
1. 구조→amyloid ΔAUC≈0 (P0.3/문헌); 2. PET teacher 자체가 site-confound (P0.1c, 음성 stratum 0.855 = tracer/scanner);
3. ⟹ 양끝 붕괴 — teacher가 site를 실어나르고(morphometry 0.948 증폭처럼), target(amyloid)은 구조로 학습불가.
→ naive raw-SUVR distill로 "clean de-confounding 표현"은 **비현실적**. **사용자 방향 재결정 필요** (pivot B / reframe A-negative / salvage with tracer-robust target).
*긍정 부산물*: "privileged biological modality조차 site-confound된다"는 측정은 그 자체로 강한 분석적 발견.

## Pivot → Direction B (사용자 결정 2026-06-11): 표현-레벨 de-siting

대상=강한 신호(dementia/atrophy, ΔAUC+0.13), 4코호트 LOCO. method=adversarial/style 표현 de-siting(타깃-harmonize는 EXP-003서 불충분 확인).
⚠️ **선결 위험**: minyoung2가 이미 "debiasing-for-transfer 반증"(site≈severity 얽힘; 선형 erasure는 MLP가 복원; LOCO 개선 0). → **B-P0 gate 먼저**: fs_vol에서 cohort-erasure 후 dementia가 살아남고 cohort가 떨어지는지(feature-level de-siting feasibility) 측정. 죽으면 B도 위협 → controlled-task pivot 재고.

| EXP | date | hypothesis | result | next |
|---|---|---|---|---|
| B-P0 | 2026-06-11 | feature-level de-siting feasible? | ⚠️→✅ cohort 0.92→0.78(lin)/0.89→0.75(MLP), dementia 0.95→0.89(−0.06 entangle). MLP가 완전 복원 안 함 | B-P0b |
| B-P0b | 2026-06-11 | **de-siting이 LOCO transfer 개선?** (진짜 go/no-go) | ✅ **mean Δ +0.015** (AJU +0.041, ADNI/OASIS≈0). minyoung2 부정 미반복 | **B GO** |

## 🟢 B GO (2026-06-11) — feasible, 단 headroom modest
feature-level de-siting이 cohort↓ + LOCO 질병↑(특히 AJU +0.041)을 보임 → 원리 성립. **pixel-level 학습 method**가 이 fs_vol-erasure baseline을 의미있게 넘어야 CVPR 기여.
다음: P0.4(4코호트 96³ T1w 캐시) → Phase-1 pixel de-siting(adversarial/conditional, label-aware) 학습 + LOCO eval. 경계: 이득 작을 수 있음(단일 run); method가 robust·larger gain + cohort→chance 근접 못 하면 재고.

### disease probe 주의 (확정)
dementia=CN(cdr_sb=0) vs Dem(cdr_sb≥4.5); KDRC는 Dem≈0이라 **3코호트(ADNI/OASIS/AJU) LOCO만 평가**. clinical baseline=비인지(age/sex/apoe).

**Phase-0 누적 인사이트**: amyloid는 clinical 0.78이라 imaging 타깃 부적합(재확인). **disease probe = dementia(cdr_sb, 비인지 baseline)**, 단 KDRC는 저-CDR이라 dementia 평가 불가 → disease-transfer는 ADNI/OASIS/AJU 3-fold. 라벨 N: CN 1012 / Dem(cdr_sb≥4.5) 255 / MCI-excl 1913.
