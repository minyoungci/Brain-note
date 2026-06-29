# 08. Shortcut & Confound Control — 모델 실험 필수 참조

> ⛔ **모든 모델/다운스트림/평가 실험 전 반드시 정독.** transfer/probe/seg 결과를 "foundation의 표현 품질"로
> 해석하기 *전에*, 그 결과가 shortcut(scanner/site/cohort/protocol/resolution/registration/age/label-acquisition)로
> 설명되지 않음을 이 문서의 절차로 *먼저* 통제·검정해야 한다. 통제 안 된 절대 점수는 증거로 쓰지 않는다.

작성일: 2026-06-29. 근거: 코드·manifest 실측(아래 §3) + 메모리 `eval-probe-confounds`.

## §1. 왜 이 문서가 필수인가

3D brain MRI foundation 평가에서 가장 흔한 reviewer-kill·자기기만은 **shortcut**이다.
검증된 사례(메모리 `eval-probe-confounds`): **random encoder**가 cls에서 site 약 0.95, seg에서 위치 shortcut으로 0.84~0.99.
즉 "높은 점수"가 표현 품질이 아니라 confound 누설일 수 있다. 따라서 **Δ-over-random**과 **held-out 통제**가 *기본*이다.

## §2. 통제 대상 shortcut 7종 (brain MRI)

| # | shortcut | 어떻게 새는가 | 대표 위험 task |
|---|---|---|---|
| 1 | scanner/site | 스캐너별 intensity/noise 시그니처 | 모든 global probe |
| 2 | cohort | "어느 코호트인가"가 라벨과 상관 | cross-cohort cls/reg |
| 3 | sequence/protocol | TR/TE·시퀀스 파라미터 시그니처 | dx classification |
| 4 | resolution/FOV | 해상도·시야 차이 | global probe, seg |
| 5 | registration/template | 정합/템플릿이 주는 위치 단서 | seg(위치), reg |
| 6 | age distribution | 코호트별 나이 분포 → "분포 추정" | **brain age** (cross-cohort) |
| 7 | diagnosis-label acquisition | dx가 특정 스캐너/획득과 얽힘 | CN/MCI/AD |

## §3. FOMO foundation 학습의 shortcut 대비 — **사실상 0개** (코드 실측)

| 대비책 | 현황 | 근거(파일) |
|---|---|---|
| metadata audit | **없음** | `FOMO300K_preprocessed/manifest.csv`에 scanner/site 컬럼 없음(pt=source proxy만) |
| group-balanced sampling | **없음** | `pretrain/data.py build_filelist` = composition 필터만, source/site 균형 없음 |
| adversarial site/scanner head | **없음** | `pretrain/train.py`·`models.py`에 site/domain/GRL/adversarial 전무 |
| resolution/FOV·intensity augmentation | **없음(심각)** | `pretrain/data.py NpyMultiCrop.__getitem__` = **random crop + znorm *그게 전부*** |
| site-held-out 학습 | 없음 | (평가에서만 가능 — §5) |

**가장 중요**: InfoNCE의 두 view(v1,v2)는 *같은 볼륨의 다른 공간 crop*일 뿐 **photometric 차이가 없다.**
→ global vector는 "crop 위치 불변"만 학습, **scanner/intensity/resolution 불변 압력은 0** → site를 자유롭게 인코딩 가능.

**부분 방어(검증된 좋은 소식)**: brain age는 random floor가 **0.137로 낮음** → site shortcut으로 안 풀림(상대적 robust).
반면 **polymicro는 random 0.608 = site-confounded** → Δ-only로 강등. (출처: `Flagship/AAAI/results/d2_probe/`)

**메타데이터 가용성**: FOMO300K엔 scanner 없음. **외부 라벨 manifest `official_manifest_full_n4_real_final.csv`엔
`acq_scanner_raw` + FreeSurfer `fs_*` 부피(covariate) 존재** → 외부 평가에서 site 통제·audit 가능.

## §4. 통제는 세 곳에서 — 각기 다른 것을 증명

| 레벨 | 무엇 | 재학습 | 증명하는 것 | 비용 |
|---|---|---|---|---|
| **A1 source 재학습** | adversarial site head·source-balanced·resolution aug | **필요** | "표현이 site-불변" | 高·불안정·FOMO300K scanner메타 없음 |
| **A2 post-hoc orthogonalization** | frozen vector에서 site subspace 선형 제거 후 probe | 불필요 | "site와 *직교*하는 신호 존재" | 低 |
| **B downstream 평가 설계** | site/cohort-held-out + 공변량 보정 + within-cohort | 불필요 | "전이가 site-암기로 설명 안 됨" | 低 |

**핵심**: B(held-out)는 "*보고된 전이가 shortcut으로 설명 안 됨*"을 증명하지, "*표현이 site-free*"를 증명하지 않는다.
→ claim이 **"무엇이 전이되는가"**면 **B + A2로 충분**. "표현이 site-불변"을 주장할 때만 A1(재학습) 필요 — 그 주장은 하지 않는다.

## §5. 필수 pre-registered audit 절차 (측정 → A2 → B)

**모든 transfer/probe claim 전에 아래를 *순서대로*, falsification 기준을 *결과 보기 전에* 고정하고 실행.**

```text
1. 측정(shortcut 크기): frozen global vector로 site/scanner/cohort 예측 probe
   - 지표: balanced accuracy vs chance. 높으면 = 표현에 confound 강하게 인코딩(기록).
2. A2(직교성): site subspace(선형) 제거 후 target(age/dx) probe
   - 통과: orthogonalized Δ-over-random의 CI가 0 제외. 실패 = 신호가 site와 얽힘.
3. B(held-out 일반화):
   - cross-cohort: probe를 코호트 A에서 fit → 코호트 B(다른 site/대륙) test. Δ-over-random CI>0.
   - within-cohort(age 전용, #6 통제): 코호트 고정 brain age. 분포 추정 불가 → 해부에서만.
   - 공변량 보정: site/age covariate adjusted Δ.
```

**falsification(사전 고정)**:
- A2 또는 B에서 target Δ-over-random의 CI가 0을 포함 → **그 전이는 shortcut으로 설명됨 → claim 기각/하향.**
- cross-cohort에서 점수 붕괴 → site-암기였음.

## §6. task별 필수 통제

- **brain age (#6 핵심)**: 반드시 **within-cohort**(분포 고정) + **cross-cohort**(일반화) 둘 다. cross-cohort만으로는
  "코호트 나이 분포 추정" shortcut 못 배제.
- **CN/MCI/AD (#7)**: **cross-cohort**(ADNI fit → KDRC/AJU test) 필수. 같은 코호트 내 dx는 acquisition shortcut 잔존.
- **seg (위치/registration #5)**: random-encoder floor 반드시 보고(위치 shortcut). Δ-over-scratch + frozen/lowlr protocol(08 외 `COMPARISON.md` 참조).

## §7. Δ-over-random은 기본값, 절대점수 금지

모든 probe/transfer는 **matched random encoder(동일 recipe·crop·proj·subject) 대비 Δ + bootstrap CI**로 보고.
random floor가 높은 task(polymicro 0.608 등)는 confound로 간주하고 정점/우월 증거로 쓰지 않는다.

## §8. 실험 전 체크리스트 (claim 선언 전 필수)

```text
[ ] matched random baseline을 같은 protocol로 돌렸는가? (Δ-over-random)
[ ] site/scanner/cohort 예측 probe로 shortcut 크기를 측정했는가?
[ ] (global claim) A2 직교화 후에도 신호가 살아남는가?
[ ] (외부 claim) cross-cohort/site-held-out에서 Δ CI>0인가?
[ ] (brain age) within-cohort에서도 성립하는가? (#6)
[ ] 작은 n(<50)·CI가 chance 포함 → 증거에서 제외/강등했는가?
[ ] falsification 기준을 결과 보기 *전에* 고정했는가?
```

## §9. 재학습(A1) 정당화 규칙

```text
A1(de-confounding 재학습)은 §5의 A2·B에서 target 전이가 *붕괴할 때만* 정당화된다.
A2/B에서 전이가 살아남으면 = shortcut이 load-bearing 아님 = 재학습 불필요(B+A2로 claim 방어 완료).
"일단 재학습"은 금지 — 데이터(측정 결과)가 재학습 필요 여부를 결정한다.
```

관련: 메모리 `eval-probe-confounds`, `fomo-preprocessing-pipeline`, `aaai-novelty-reality`; AAAI 적용은 `Flagship/AAAI/docs/03·06`.
