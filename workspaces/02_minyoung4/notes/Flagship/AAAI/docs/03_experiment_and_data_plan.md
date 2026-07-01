# 03. Experiment and Data Plan

## 목표

C3(외부 multi-site 전이)를 위해, 우리가 보유한 컨소시엄 코호트를 **사전학습과 동일한 전처리**로
정리한 뒤, global 표현 전이를 leakage-safe·site-disjoint·대륙간으로 검증한다.

```text
pretraining corpus: FOMO300K (PT001–036), unlabeled, 226,793 ok-files
external downstream: ADNI/NACC/A4/AIBL/AJU/KDRC (라벨 보유, 사전학습과 disjoint)
evaluation: subject-disjoint by construction + site/scanner-disjoint + cross-continent
```

## 전처리 원칙 — 사전학습과 *동일* Yucca 4-step (검증됨)

`preprocessing/preprocess_fomo300k.py`가 적용하는 official Yucca 4-step을 외부 코호트에 **그대로** 적용한다.

```text
1. crop_to_nonzero
2. volume_wise_znorm  ([0,1])
3. 1mm-isotropic resample + RAS orientation
4. save (.npy)
```

주의(검증된 사실):

- **HD-BET / N4 bias correction / skull-strip / QC / modality-tagging 없음.** (그것들은 옛 AD
  `official` v3.5 파이프라인 것 — FOMO와 무관. 전역 `preprocessing.md` 규칙도 그 옛 파이프라인 기준이므로 적용 금지.)
- CPU-only(nibabel/scipy + multiprocessing) → **GPU 안 씀**. 모델 작업과 자원 충돌 없음.
- 동일 전처리 적용의 *목적*: 전처리-유발 domain shift 제거 → 전이 격차를 모델에 정확히 귀속.
- 정직한 caveat: N4/skull-strip 미적용 → 외부 multi-site intensity 비균일·두개골 신호가 남는다.
  이는 foundation이 학습된 *native* 조건이므로 올바른 테스트이며, site-disjoint split이 그 영향을 드러낸다.

## 외부 코호트 인벤토리 (실측, leakage-safe 검증)

`build_filelist()`(`pretrain/data.py`)가 FOMO300K_preprocessed/manifest.csv만 읽고, 모든 experiment
filelist가 `FOMO300K_preprocessed/npy/PT0xx/`만 포함함을 확인. 아래 6코호트는 그 filelist에 **0건** →
**구조적으로 subject·dataset disjoint(leakage-safe)**. 라벨은 `official_manifest_full_n4_real_final.csv` 보유.

| 코호트 | 모달 | n(subj) | age | CN/MCI/AD (subj) | 사전학습 중복 | site metadata |
|---|---|---:|:--:|---|:--:|---|
| ADNI | T1w | 1580 | ✓ | 849 / 594 / 126 | **0** | 3T, 4 vendor, 16 model |
| NACC | T1w | 1414 | ✓ | 935 / 309 / 131(Dementia) | **0** | 3T, 11 model |
| A4 | T1w* | 992 | ✓ | all CN_preclinical(+amyloid) | **0** | 3T, vendor only |
| AIBL | T1w | 617 | ✓ | 452 / 95 / 70 | **0** | 3T, 1 scanner |
| AJU(Korean) | T1w | 955 | ✓ | 22 / 752 / 212 | **0** | 3T, 3 vendor |
| KDRC(Korean) | T1w | 770 | ✓ | 282 / 239 / 249 (balanced) | **0** | 4 model |

*A4는 downstream용 T1; FLAIR/DWI도 보유. 현재 디스크엔 raw 재전처리 진행 중.

**제외: OASIS-3** — OASIS-1/2(566 subj)가 사전학습에 포함되고 ID 재익명화로 disjoint 증명 불가.
sensitivity check 외엔 leakage-safe claim에 쓰지 않는다.

## Data Split 원칙 (C3의 생명선)

### Subject-level
코호트 disjoint 구조로 자동 충족(외부 코호트 subject가 사전학습에 0건).

### Site/scanner-disjoint
- **within-cohort**: ADNI(16 model)/NACC(11 model) → scanner-disjoint train/test 가능.
- **cross-cohort(가장 강함)**: train ADNI → test KDRC/AJU(한국) = 대륙·scanner·subject 모두 disjoint 외부 일반화.

### Pretraining/downstream leakage
- 검증 완료: 외부 코호트 = FOMO300K filelist와 0건. 재전처리 후에도 동일 disjoint 유지.

## Recommended Downstream Suite (C3)

| Axis | Task | Metric | 데이터 | 검정력 |
|---|---|---|---|---|
| Global anatomy | brain age 회귀 | MAE, Pearson r | 6코호트 합 ~6,300 | 🟢 강함 |
| Disease semantics | CN/MCI/AD 분류 | AUROC, balanced acc | ADNI/KDRC/NACC | 🟢 3클래스>100 |
| Robustness | site/scanner-disjoint, cross-continent | Δ, CI | ADNI→KDRC/AJU | 🟢 가능 |
| Frozen representation | linear/MLP probe | r/AUROC | 전부 | 🟢 (eval_harness) |
| (보조) dense seg | 내부 task4/task2 | Dice/NSD | n40/n23 | 🟡 작은-n(C1용) |

## Evaluation Protocols

### Frozen probe (C2/C3 표현 품질)
```text
encoder frozen → global_vec 추출 → linear/shallow MLP head
matched random baseline(recipe=resenc_s3d) 대비 Δ + bootstrap CI
subject-disjoint(코호트 구조) + site-disjoint/cross-continent
```
인프라: `pretrain/eval_harness.py`(--ckpt/--baseline/--tasks). 외부 코호트를 새 task로 배선 예정.

### Low-LR / full fine-tune (C1 실무 전이)
```text
low-LR: encoder_lr 1e-5, head/decoder_lr 1e-3, AdamW, cosine, (seg) EMA
full: all weights — scratch 대조군과 함께(scratch-convergence 진단)
protocol별로 보고 (C1 핵심)
```

## Baselines (claim 직격)

| Baseline | 왜 |
|---|---|
| matched random encoder (recipe=resenc_s3d) | Δ-over-random 분모(confound 통제) |
| scratch (full-FT) | C1 scratch-convergence 진단 |
| wg0 / wg0.5 / wg1 | C2 objective sweep(150k matched) |
| ViT-MAE / iBOT (보조) | backbone 참조·collapse 대조 |

## Risk Management

| Risk | 의미 | 완화 |
|---|---|---|
| 외부 전처리 미완 | C3 지연(critical path) | 코호트별 순차 완료, n≥300 첫 코호트로 brain age anchor 선행 |
| 작은-n 내부 seg/cls | 약한 검정력 | C3 외부 large-n + bootstrap CI + Δ-over-random |
| polymicro/infarct confound | site/위치 shortcut | Δ-over-random, 외부 CN/MCI/AD로 대체·보강 |
| OASIS-3 leakage | disjoint 증명 불가 | 제외(또는 sensitivity only) |
| SparK 중복 지적 | novelty 공격 | detail로 인용, 기여는 C1/C2/C3로 |

## Data Table Required for Paper

```text
Dataset | Modality | n subj | labels(age/dx) | spacing | site/scanner | in-pretraining? | used-for
```

## Result Table Required for Paper

```text
Task | Metric | Random | wg0 | wg0.5 | wg1 | Δ(wg0.5 vs random) | (external) cross-site Δ
```
