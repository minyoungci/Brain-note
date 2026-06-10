# Task: modality_amyloid_pet_inventory

Audit of amyloid-PET (and modality) data readiness for the **4 planned cohorts**
(ADNI, OASIS, AJU, KDRC) used by `minyoung4`.

## Goal (locked 2026-06-10)

**Task**: binary amyloid positivity classification across the 4 consortia
(ADNI, OASIS, AJU, KDRC).

- **Target (y)**: binary amyloid positive/negative — the only label common &
  defined for all 4 cohorts.
- **Test-time input**: **T1w** (universal) **+ FLAIR** (present in OASIS/AJU/KDRC;
  ADNI lacks it → handled by an input-modality **adapter** that absorbs the
  missing/heterogeneous-resolution modality).
- **Train-only privileged signal**: **PET-amyloid** (teacher for distillation; not
  used at inference). Voxel-aligned to T1w, so usable as a co-registered teacher.

Direct consequences to verify before modelling (see Open actions):
1. **Label harmonization** (verified) — ADNI & OASIS both cut at **Centiloid ≈ 20**
   (neg max ~19, pos min ~18–20) → mutually harmonized. AJU/KDRC use a nuclear-
   medicine **visual read** with no Centiloid → **cannot be verified against CL20**
   (residual confound). Mitigation: treat cohort as a domain (domain-aware
   training) and always report per-cohort metrics.
2. **Class balance** (verified) — positive rate: ADNI 39.7%, OASIS 33.6%,
   AJU 34.4%, **KDRC 67.8%** (outlier, ~2×). Pooled training risks a "KDRC ⇒
   positive" shortcut → cohort-aware stratification / balanced sampling needed.
3. **PET teacher coverage** — distillation only possible where PET exists
   (ADNI 669/1203, OASIS 347/443 once wired, AJU 992/994, KDRC 530/534).
4. **FLAIR-missing at test for ADNI** — the adapter must run T1w-only for ADNI.

## 핵심 요약 (verified 2026-06-10)

- `minyoung4/data/preprocessed_mm/` 는 **레거시 스냅샷**이다. 권위 트리는
  `/home/vlm/data/preprocessed_official/v2` 이며, `multimodal_manifest.csv` 의
  `final_tensor_n4_path` 가 이미 그쪽(official v2)을 가리킨다.
- **amyloid 라벨(target y)** 은 4개 코호트 모두 100% 존재.
- **amyloid PET 영상(input)** 은 4개 코호트 모두 raw 에 존재하지만, 공식 전처리
  트리에는 **AJU/KDRC 만** 들어와 있다. **ADNI/OASIS 는 0** (raw 는 있으나 미배선).
- 공식 PET 출력은 레거시 FLAIR 와 **voxel 단위로 정렬**(affine 동일, 8/8 표본) →
  채널로 stack 가능.
- **4개 코호트 공통 모달리티 = T1w + PET-amyloid 둘뿐.** 단 PET-amyloid 는 amyloid
  target 그 자체라 input 으로 쓰면 누수 → **공통 비누수 INPUT 은 T1w 단 하나**,
  PET-amyloid 는 train-only privileged 신호. (FLAIR 은 ADNI 결손으로 3/4.)

## Why this task exists

선행 대화에서 "OASIS 는 amyloid PET 영상이 없다"는 잘못된 단정이 있었다(SPEC.md 의
`✗(scalar)` 표기와 AJU/KDRC-only 인벤토리에만 의존). raw 를 직접 확인하니 OASIS·ADNI
모두 amyloid PET raw 가 실재한다. 이 task 는 **추측이 아니라 디스크 실측으로** 코호트별
라벨 / raw 영상 / 전처리 출력의 정합을 확정하고, "처리 가능하지만 아직 안 된" 격차를
정량화한다.

## Layout

```
audits/modality_amyloid_pet_inventory/
├── README.md              # this file — task definition + verified findings
├── config.py              # single source of truth: tree roots, raw layouts, cohorts
├── audit_amyloid_pet.py   # runnable audit (stdlib only; optional nibabel spot-check)
└── reports/               # generated artifacts (re-created on each run)
    ├── per_cohort_amyloid_pet.csv   # per-cohort label/raw/official/legacy counts
    ├── oasis_session_match.csv      # OASIS label-session <-> raw-PET-session per subject
    └── SUMMARY.md                   # machine-generated results snapshot
```

## Data sources (read-only)

| source | path | used for |
|---|---|---|
| labels | `data/amyloid_label_table.csv` | label count, T1w session per subject |
| AJU/KDRC raw | `…/minyoungi/preprocessing/reports/pet_amyloid_inventory.csv` | `gate=READY` = raw present |
| ADNI raw | `/home/vlm/data/raw/ADNI/PET/extracted/ADNI/<sid>/` | extracted AV45 (baseline) |
| OASIS raw | `/home/vlm/data/raw/oasis3/pet_bids_v7_exact_pet_only` | BIDS PIB/AV45 |
| official outputs | `/home/vlm/data/preprocessed_official/v2` | preprocessed pet_amyloid |
| legacy outputs | `data/preprocessed_mm` | old minyoung2-derived snapshot |

## How to run

```bash
cd audits/modality_amyloid_pet_inventory
python3 audit_amyloid_pet.py          # writes reports/, prints SUMMARY
```

Expected normal output: a per-cohort table, AJU/KDRC gate tallies, OASIS
session-gap buckets, and an affine spot-check reporting `aligned == checked`.

## Findings (verified, subject-level)

| cohort | label | raw PET | label∩raw | official v2 | legacy | unprocessed(official) |
|---|--:|--:|--:|--:|--:|--:|
| ADNI | 1203 | 1537 | 669 | 0 | 656 | 669 |
| OASIS | 443 | 412 | 347 | 0 | 3 | 347 |
| AJU | 1000 | 994 | 994 | 992 | 0 | 2 |
| KDRC | 534 | 903 | 530 | 890 | 0 | 9 |

Interpretation / risks:

1. **AJU / KDRC** — official v2 PET nearly complete (being generated now). Only a
   handful unprocessed; `BLOCKED_NO_RAW` (AJU 291, KDRC 6) can never be filled.
2. **ADNI** — only **669 / 1203** labelled subjects have an *extracted* raw PET
   (AV45 *Baseline* zips only). The other 534 labelled subjects have a label
   (UCBerkeley status, which includes FBB / non-baseline AV45) but no extracted
   image → coverage is recoverable by extracting more ADNI PET, not a hard limit.
   **0 are in official v2** (ADNI not wired into the official pipeline).
3. **OASIS** — 347 / 443 labelled subjects have raw amyloid PET. Of those, the
   nearest scan to the labelled **T1w** session is within 180 d for **257**, but
   **86 are > 730 d away** → temporal label↔image mismatch risk (the PET that
   produced the Centiloid label may differ from the scan nearest the T1w). **0 in
   official v2.** See `reports/oasis_session_match.csv` for per-subject gaps.
4. **Geometry** — official pet_amyloid sits on the same 192×224×192 grid with an
   identical affine to the legacy FLAIR (spot-check 8/8 aligned) → official PET is
   drop-in stackable as an extra channel.

## Modality scope across the 4 cohorts (raw availability, disk-verified 2026-06-10)

| modality | ADNI | OASIS | AJU | KDRC | common to 4? |
|---|:--:|:--:|:--:|:--:|:--:|
| **T1w** | ✓ | ✓ | ✓ 954 | ✓ 534 | **YES** |
| **PET-amyloid** | ✓ AV45 | ✓ AV45/PiB | ✓ 950 FBB/FMM | ✓ 530 FBB/FMM | **YES** (raw) |
| FLAIR | ✗ (1 subj only) | ✓ 677 | ✓ 954 | ✓ 532 | no — ADNI |
| fMRI | ✓ 349 | ✓ ~1020 | ✓ 807 | ✗ 0 | no — KDRC |
| T2 | ✗ | ✗ | ~480 | ~441 | no — ADNI/OASIS |
| DTI | (unchecked) | (unchecked) | 905 | 323 | unknown |
| DWI / MRA / CT | (unchecked) | (unchecked) | partial | ✗ 0 | no — KDRC |

Sources: AJU/KDRC from `multimodal_manifest.csv` modality columns; ADNI/OASIS from
direct raw inspection (`/home/vlm/data/raw/ADNI/{ADNI_3_4_T1w,PET,fMRI}`,
`/home/vlm/data/raw/oasis3/{OAS*_MR_d*,pet_bids_v7_exact_pet_only}`).

**Decision implication.** The only modality common to all 4 cohorts that is a
*non-leaky input* is **T1w**. PET-amyloid is common in raw but is the amyloid
target itself → train-only privileged signal, not a test-time input. FLAIR is a
3/4 modality (missing in ADNI) → handled as an optional input-modality adapter.

→ Working scope: **T1w universal backbone (+ optional FLAIR adapter) → amyloid;
PET-amyloid as train-only privileged teacher.**

### Tracer domains (per-subject where known)
- {AJU, KDRC} = **FBB / FMM** pool (KDRC per-subject tracer unknown — no source DICOM)
- {ADNI} = AV45
- {OASIS} = AV45 + PiB

Raw SUVR is self-consistent **within** a tracer domain (AJU≈KDRC medians) but is
not cross-domain comparable; Centiloid conversion is blocked for FBB/FMM
(equation differs + KDRC per-subject tracer missing).

## Open actions (not done by this audit)

- [ ] Wire **ADNI** + **OASIS** amyloid PET into the official pipeline: add raw
      resolvers to `…/minyoungi/preprocessing/shared/paths.py`, extend the
      inventory builder beyond AJU/KDRC, then run `run_full --modality pet_amyloid`.
- [ ] **Tracer harmonization** decision: AV45 (ADNI/OASIS) vs PiB (OASIS) vs
      FBB/FMM (AJU + KDRC) have different SUVR ranges → Centiloid or tracer-aware
      adapter. Centiloid currently blocked (FBB/FMM equation differs + KDRC
      per-subject tracer unknown); within-cohort whole-cerebellum / cortical-
      composite SUVR is self-consistent and usable as-is.
- [ ] **OASIS session rule**: nearest-to-T1w vs label(Centiloid)-session; resolve
      the 86 large-gap subjects.
- [ ] **ADNI extraction**: extract remaining PET (FBB / non-baseline) to lift the
      56% labelled-coverage.

## Notes

- This audit only **reads**. It never writes under raw or preprocessed trees.
- Numbers reflect a live tree; AJU/KDRC official counts move while the pipeline
  runs. Re-run to refresh.
