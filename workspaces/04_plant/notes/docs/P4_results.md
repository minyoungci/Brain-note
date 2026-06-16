# P4 RESULTS — cross-population AD 모델 전이 (서양 vs Korean)

> 2026-06-16. 통계 확정 결과. 설계=`docs/P4_crosspop_adlip_plan.md`. 코드=`experiments/P4/`, 산출=`data/derived/P4/`.
> 모든 수치 재현가능(parquet 직접·seed 고정). 정직 원칙: 점추정 아닌 CI 기준, 미확정은 미확정으로 표기.

## 0. 한 줄 결론 (strong-backbone 실험 후 정정 — 단순 "비가역" 주장 철회)
**From-scratch deep(3D CNN·ResNet·fusion)은 인구 간(서양↔Korean) 전이가 morphometry보다 양방향 유의하게 나쁘다.
그러나 *전이가능 사전학습(brain-age)* 은 이 결손을 비대칭으로 회복: **W→K는 morph와 *동등*(Δ−0.002, CI[−0.036,+0.032])까지 회복,
K→W는 여전히 morph 미달(Δ−0.053, CI[−0.093,−0.015])**. test-time BN-adapt는 둘 다 회복 못 함(0%).
→ 결손은 *test-time 비가역이나 전이가능 사전학습으로 비대칭 부분 회복*. 인구간 배포 위험은 **방향-의존적**,
**Korean-train→Western이 가장 취약**(사전학습으로도 안 메워짐). within-Korean에선 사전학습 deep이 morph 초과(Δ+0.075).**

## 1. 질문 / 설계
- task: **CN vs impaired(MCI+AD) 이진** (AD 단독은 표본 얇음 → 이진).
- 그룹: **서양 = ADNI+OASIS**, **Korean = AJU+KDRC**.
- 4 transfer 셀: within(W→W, K→K) + cross(W→K, K→W). 입력 = T1w 이미지(+morph는 baseline).
- 비교 = deep 이미지 표현 vs morphometry(FastSurfer fs_vol). "deep>morph"가 아니라 *전이 robustness* 가 질문.

## 2. 데이터 (matched cohort)
- age×sex×CDR-stage 매칭 → 그룹당 **CN 302 / MCI 717 / AD 124** (binary impaired 841), 총 **2,286** subj.
- age/sex 균형(서양 71/56%F, Korean 73/60%F). subject-level split, 누수 0.
- 산출: `data/derived/P4/matched_cohort.csv`, 2mm 캐시 `vols_2mm_f16.npy`.

## 3. 방법
- **deep:** 3D CNN(4-conv) + **3D ResNet10-style(+dropout·aug, weight-decay)**, 96³(2mm), bf16+channels_last_3d+torch.compile(B200), val-lock(held-out val로 checkpoint 선택), **5-seed**.
- **morph baseline:** fs_vol(head-size 정규화) + culture-invariant clinical(APOE/age/sex; **MMSE 제외** — §6), LogisticRegression.
- **평가(power):** within = source held-out test(n=173); **cross = FULL target(n=1,143, 전부 unseen)** → CI 강화. deep는 5-seed **ensemble** + per-seed 분포.
- **decomposition:** inductive **BN-adapt**(target 64–128 unlabeled로 BN 재계산→freeze→eval; cal/eval disjoint). 회복=acquisition, 무회복=population.
- **stats:** paired subject bootstrap(2000) ΔAUROC 95% CI; within=TOST(±0.05), cross=one-sided.

## 4. 결과 — transfer 매트릭스 (ResNet 5-seed ensemble vs morph) — morph **train-only**(M2 공정성 수정 후)

| cell | kind | n | deep | morph | Δ(deep−morph) | 95% CI | 판정 |
|---|---|---|---|---|---|---|---|
| W→W | within | 173 | 0.650 | 0.675 | −0.026 | [−0.114, +0.073] | 유의차 없음(inconcl) |
| **W→K** | cross | 1143 | 0.624 | 0.715 | **−0.091** | **[−0.129, −0.053]** | **deep < morph (유의)** |
| K→K | within | 173 | 0.893 | 0.834 | +0.058 | [−0.007, +0.123] | 유의차 없음(inconcl) |
| **K→W** | cross | 1143 | 0.625 | 0.680 | **−0.055** | **[−0.095, −0.015]** | **deep < morph (유의)** |

- **cross 양방향 모두 deep < morph 유의**(CI 0 배제, n=1143). 단순 CNN에서도 동일 방향(robustness across arch); **강 backbone(ResNet)이 전이를 더 악화**(capacity↑→인구특이 feature↑).
- within은 양쪽 유의차 없음(deep≈morph). 단 n=173이라 **엄밀 동등성(TOST)은 미확정**.
- **[M2 공정성]** morph는 deep과 동일하게 source `train`-only(799)로 학습(이전 train+val 970은 morph 유리). 수정 후에도 cross 양방향 유의 유지(Δ 다소 축소: −0.106→−0.091, −0.062→−0.055).

### 4c. per-cohort 분해 (cross gap이 단일 코호트 driven인가 — 아님) — morph **train-only**(M2 일관)
| 방향 | target 코호트별 Δ(deep−morph) |
|---|---|
| W→K | AJU −0.039 (n588) · KDRC −0.126 (n555) |
| K→W | ADNI −0.065 (n846) · OASIS −0.076 (n297) |
→ **4개 target 코호트 전부 deep<morph** = 단일 코호트 artifact 아님. (AJU 마진은 −0.039로 작음 — 단 4/4 방향 일치.)

### 4d. M4 split-seed robustness (단일 매칭/split realization 아닌가 — 아님)
cross 평가셋(full target 1143)은 split 불변; split은 *source 학습 subset*만 변경. 3 split-seed:
| 방향 | orig | sp1 | sp2 |
|---|---|---|---|
| W→K Δ | −0.091 | −0.085 | −0.202 |
| K→W Δ | −0.055 | −0.097 | −0.080 |
→ **3 split 전부 양방향 deep<morph**(borderline K→W 포함). 효과크기 −0.05~−0.20 변동, **방향 불변**.

### 4e. ★ Strong/pretrained backbone (brain-age 사전학습) — 헤드라인 정정
brain-age(전이가능 pretext)로 **source-only 사전학습 → CN-vs-impaired finetune**(3-seed). cross(n=1143):

| cell | agepre | image(scratch) | morph | Δ(agepre−morph) | CI | 판정 |
|---|---|---|---|---|---|---|
| **W→K** | **0.713** | 0.624 | 0.715 | −0.002 | [−0.036,+0.032] | **morph와 동등** (사전학습이 회복) |
| **K→W** | 0.627 | 0.625 | 0.680 | −0.053 | [−0.093,−0.015] | **여전히 deep<morph 유의** (회복 안 됨) |
| K→K(within) | 0.909 | 0.893 | 0.834 | +0.075 | [+0.015,+0.137] | **deep>morph 유의** |

→ **비대칭·부분 회복:** 전이가능 사전학습이 **W→K 결손은 morph 동등까지 회복**하나 **K→W는 못 함**. within-Korean에선 사전학습 deep이 morph 초과. **"deep<morph 비가역 population"은 과한 결론 → 정정**: test-time(BN) 비가역 + 사전학습으로 비대칭 회복. **Korean-train→Western이 가장 취약**(data-resource/분포 비대칭 시사). 코드 `train_agepre.py`, 비교 `agepre_compare.py`.

### 4b. Fusion arm (ADLIP式 image+clinical late-fusion)
backbone feature ⊕ culture-invariant clinical(APOE/age/sex) → head (5-seed). image-only / fusion / morph:

| cell | image | fusion | morph | fusion Δ vs morph (CI) |
|---|---|---|---|---|
| W→W | 0.650 | 0.608 | 0.673 | −0.066 [−0.164,+0.033] inconcl |
| W→K | 0.624 | 0.623 | 0.730 | **−0.106 [−0.143,−0.070] deep<morph** |
| K→K | 0.893 | 0.894 | 0.837 | +0.056 inconcl |
| K→W | 0.625 | 0.619 | 0.687 | **−0.068 [−0.107,−0.028] deep<morph** |

→ **fusion cross ≈ image-only cross** (변화 없음), 여전히 morph보다 유의 낮음. BN-adapt 회복 ~0%(population). **clinical 융합이 cross-pop 결손을 못 메운다** = image 표현의 population-특이성이 binding liability, 약한 culture-invariant clinical로는 구제 불가. "fusion이면 다르지 않나" 반론 차단. 코드 `train_fusion.py`, 산출 `stats_summary_fusion.json`.

## 5. DECOMPOSITION — acquisition vs population
| 방향 | raw(test) | BN-adapt | Δ | 판정 |
|---|---|---|---|---|
| W→K | 0.634 | 0.635 | +0.001 | **회복 0% → population** |
| K→W | 0.568 | 0.568 | +0.000 | **회복 0% → population** |

→ cross-pop deep 결손은 **BN-adapt(test-time)로 회복 불가**, acquisition(스캐너 통계) 아님.
대조: AD/CN 라인 C4에서 **scanner shift는 BN-adapt로 +0.06 회복**. → *"site shift는 test-time 회복가능 / population gap은 test-time 비가역"*.
**[정정·§4e]** 단 "비가역=영구 population"은 아님: **전이가능 사전학습(brain-age)은 W→K 결손을 morph 동등까지 회복**(K→W는 못 함). → 정확히는 *test-time 비가역 + 표현학습(pretraining)으론 비대칭 부분 회복*.

## 6. 보조 발견 (Stage-1) — clinical scale 인구-비등가
age×sex×CDR-stage 매칭 후에도 Korean MMSE가 체계적으로 낮음(중증도 깊을수록↑):
CN Δ+1.1 / MCI +2.4 / **AD +4.7**(서양−Korean). → 같은 CDR=AD인데 MMSE ~5점차 = **MMSE는 문화·언어·교육 의존으로 인구간 비등가** → fusion feature에서 제외(넣으면 인구 지름길 학습). "강한 임상 feature가 곧 비전이 feature"라는 equity 메시지.

## 7. 정직한 caveats
- **within(n=173) underpowered** → "within 동등"은 *유의차 없음*까지만(TOST 미확정). 강화하려면 k-fold(full-group test).
- **2mm 해상도**: CN-vs-impaired는 주로 subcortical/global atrophy라 영향 작을 것이나 thin-cortex 신호 손실 가능(T5). morph는 full FastSurfer.
- **단일 매칭 split** → **§4d M4로 해소**(3 split-seed 전부 양방향 deep<morph; 방향 robust, 효과크기만 변동).
- **2 코호트/group** → cohort-cluster bootstrap degenerate, subject-level bootstrap 사용. §4c per-cohort로 4개 코호트 일관 확인.
- **deep = compact CNN/ResNet10/Fusion(from-scratch) + brain-age 사전학습(agepre, §4e).** 사전학습이 W→K를 morph 동등까지 회복 → "약한/미사전학습 모델 탓"을 *부분* 인정(W→K 한정). **남은 한계: 대규모 외부 SSL/published foundation backbone(brain FM)은 미검** — agepre는 source-내부 pretext라 진짜 large-scale FM과 다름. K→W가 FM으로도 안 메워지는지는 별도 검증 필요(향후).
- **코드 감사(독립 code-auditor)**: 치명적 누수 0 확인 — val⊂train 수정 반영·cross=full-target leak-free·BN-adapt cal/eval disjoint·morph scaler/impute train-only·deep/morph 동일 subject 정렬. (M1 깨진 aggregate_transfer 삭제, M2 train-only 수정 완료.)
- amyloid(분자) 자산은 비대칭(서양 22%)이라 비교축 미사용(Korean 내부 보조로만, 미실행).

## 8. 결론 / venue
- **claim(정정):** from-scratch deep은 인구간 전이가 morph보다 양방향 나쁘나, **전이가능 사전학습으로 W→K는 morph 동등 회복·K→W는 비회복 = 비대칭**. cross-population 배포 위험은 방향-의존적이고 **Korean-train→Western이 가장 취약**(사전학습으로도 비회복). test-time(BN) 적응은 무효. (성능 SOTA 아님, equity/cautionary measurement.)
- **venue:** NeuroImage:Clinical / Imaging Neuroscience(현실적), 형평성 강조 시 Alzheimer's & Dementia / npj Digital Medicine 상방. top method 저널(MedIA/TMI)은 novelty 부족.

## 9. 재현 (artifacts)
- 매칭/캐시: `experiments/P4/build_matched_set.py`, `build_cache_2mm.py` → `matched_cohort.csv`, `vols_2mm_f16.npy`.
- morph baseline: `baseline_morph_clinical.py`, `baseline_preds.py` → `baseline_results.csv`, `preds_morph_*.npz`.
- deep: `train_image_cnn.py`(--arch cnn|resnet, --aug, --split_seed) → `{arch}_{group}_s*.json`, `preds_{arch}_*_s*.npz`.
- fusion: `train_fusion.py`. strong/pretrained: `train_agepre.py`(brain-age pretrain→finetune) → `agepre_*`. 비교: `agepre_compare.py`.
- stats: `stats_robust.py [resnet|fusion]` → `stats_summary_{arch}.json`. robustness: `per_cohort.py`(코호트별), `m4_robust.py`(split-seed). (구 `aggregate_transfer.py`는 삭제 — stats_robust가 정본.)
