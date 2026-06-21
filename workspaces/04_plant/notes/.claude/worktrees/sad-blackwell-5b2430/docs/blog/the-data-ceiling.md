# 7개 코호트로도 왜 막히나 — T1 뇌 MRI 알츠하이머 표현학습의 천장 해부

> microbrain 라인의 데이터·천장 종합. 모든 그림·수치는 `notebook/01–06`에서 데이터를 직접 열어 재현(`uv run`).
> 톤: 되길 바라는 방향이 아니라 데이터가 말하는 대로. null도 1차 결과.

---

## 0. 시작은 세 가지 걱정이었다

이 라인을 시작할 때 걱정은 분명했다 — **(1) 7개 코호트의 클래스 분포가 깨져 있다, (2) site·scanner·cohort bias가 있다, (3) 그래서 어떤 방법을 써도 3D 알츠하이머 표현학습이 안 된다.** 직관은 옳았다. 다만 *왜* 안 되는지를 측정으로 분해하니, 걱정의 인과가 생각과 달랐다. 막는 건 "방법이 약해서"가 아니라 **데이터/modality 자체의 천장**이었다.

이 글은 그 천장을 다섯 개의 문제로 해부하고, 무엇이 *완전히* 닫혔고 무엇이 아직 열렸는지를 정직하게 그린다.

---

## 문제 1 — 클래스 분포 × site = population 교란

7개 코호트를 모았지만, **진단이 코호트와 거의 1:1로 얽혀 있다.** AJU는 정상(CN)이 2.3%뿐이고 OASIS는 80%가 CN이다.

![코호트별 진단 분포](figures/01_cohort_class.png)

site와 진단의 얽힘 강도는 **Cramér's V = 0.421**(강한 연관). 그래서 여러 코호트를 그냥 합쳐 학습하면, 모델은 질병이 아니라 "AJU에서 찍었으니 MCI"를 외운다. 실제로 **구조(부피)만으로 어느 코호트인지 2.6×chance로 식별**된다(AJU는 0.905로 거의 완벽).

그런데 결정적 반전이 있다 — **site를 통제해도 질병 신호는 살아있다.** 코호트 *내부*에서 morphometry로 정상/환자를 가리면 평균 AUC 0.775다.

![bias vs decidability](figures/01_bias_vs_decidability.png)

> **함의:** bias는 *제거* 대상이 아니다(빼면 신호도 빠진다 — 문제 4·아래). **평가 설계로 비결정화**할 대상이다. 단일 코호트 bracket + leave-one-cohort-out이 정답이지, harmonization이 아니다(ComBat·GRL·MixStyle·N4 모두 측정으로 dead).

---

## 문제 2 — 라벨 품질·결측·누수

라벨 자체가 함정이다.

- **시변 진단 라벨이 없다.** `clin_dx_label`은 subject별 *정적*(baseline) 값이라, ADNI multi-visit subject에서 변하는 경우가 **0**이다. 깨끗한 MCI→AD 전환 라벨은 원본(DXSUM)을 따로 당겨야 한다. 시변 신호는 요동치는 CDR뿐이다.
- **결측 패턴이 코호트마다 달라서, 결측 자체가 site 지문이 된다.**

![결측 패턴](figures/02_missingness.png)

KDRC는 field-strength가 100% 결측, NACC는 MMSE가 84% 결측, AIBL은 APOE가 전무, OASIS는 라벨의 71%가 미매칭이다. 이런 결측을 입력 indicator로 쓰면 모델은 *질병이 아니라 결측 패턴(=기관)*을 학습한다.

- **누수 중복이 있다.** 동일한 텐서(같은 md5)가 *다른 subject_id*로 두 번 들어가 있어, subject-level split조차 샌다. split 전 collapse가 필수다.

---

## 문제 3 — 구조적 저주: 신호와 라벨이 서로 다른 코호트에 있다

"풍부한 modality(DWI·PET)로 T1 천장을 우회하면 되지 않나?" — 안 된다. **신호가 풍부한 축과 라벨·종단이 풍부한 축이 서로 다른 코호트에 격리**돼 있다.

![modality ⊥ label disjointness](figures/03_disjointness.png)

라벨·종단이 가장 강한 **ADNI**는 raw FLAIR/DWI/PET이 **0**(final T1 텐서만). 미세구조(DWI/PET)가 가장 풍부한 **KDRC**는 cross-sectional이고 field 결측에 Korean 단일 인구다. 한 subject가 *풍부한 modality + 라벨 + 종단*을 동시에 갖는 경우가 없다. → cross-site 멀티모달 종단 연구는 **구조적으로 불가능**하다.

---

## 문제 4 — morphometry 천장 (핵심)

이게 가장 깊은 벽이다. **어떤 표현·아키텍처를 써도, 단순 부피 + 공짜 임상정보(나이·성별·APOE·baseline 인지)를 넘는 신호가 측정되지 않는다.**

ADNI에서 계층적으로 쌓아 보면 — baseline 인지(cdrsb)가 들어가는 순간, morphometry가 그 위에 더하는 증분의 95% 신뢰구간이 **0을 포함**한다(전환·미래 인지 둘 다).

![baseline bar](figures/04_baseline_bar.png)

이건 우리만의 결과가 아니다. 단면 AD/CN에서 deep(BN-adapt 0.910)은 morph(0.931)에 지고, 외부검증 표준인 **Bron 2021**도 deep ≤ SVM을 보인다. 4개 독립 라인이 같은 null로 수렴한다.

> **핵심:** R2 천장은 *모델 용량* 천장이 아니라 **modality 정보량** 천장이다. 부피가 T1 진단신호의 거의-충분한 요약이므로, 더 큰 transformer도 없는 headroom을 만들지 못한다. **아키텍처는 레버가 아니다.**

---

## 문제 5 — 종단마저 우회로가 아니었다

단일시점 부피가 *구조적으로* 못 담는 것 = 변화율. 종단(진행 예측)이 천장을 우회할 마지막 후보였다. 측정했다.

![change-rate kill-test](figures/05_changerate_killtest.png)

ADNI에서 종단 변화율(Δmorph)을 static 부피+인지에 더해보면, 증분 ΔR²가 **−0.103 [−0.194, −0.038]** — CI가 전부 음수다. 변화율 feature가 *돕는 게 아니라 해친다*. cross-site(ADNI→OASIS) transport도 파탄(미래 저하가 인구 간 분포가 달라 R²<0). 게다가 전환자 수(24개월 ~26명)는 문헌 권장(150~400)에 크게 못 미쳐 검정력도 부족하다.

---

## 그래서 — 완전히 닫힌 건 4개뿐이다

13개 주장을 적대적으로 검증(각각 *열려있다고 반증 시도*)한 결과, measurement-clean하게 **완전히 닫힌 건 4개**다:

1. deep이 단면 T1 AD/CN을 **정확도로** morph보다 잘함 — 가장 우호적 deep도 패배.
2. **naive 변화율(Δmorph)**이 static 부피+인지를 넘음 — CI 전부 음수.
3. scale로 foundation model과 경쟁 — 12,978 ≪ 49–60k, 산술 불가.
4. **AJU 단독** 진단 분류 — CN 2.3%, 통계적으로 불가능.

나머지 "닫힘"의 절반은 사실 *강하게 음성이나 미검정*이고, 단 하나의 측정 — **`image→fs_vol R²`(GATE-3)** — 에 걸려 있다. 이 한 번이 닫힘의 절반을 확정한다.

그리고 위안이 되는 사실: **우리 천장이 학계 전체의 천장이다.** 그 결과 2024–2026 top-venue 기준이 *정확도 → label-efficiency·external/LOCO 검증·leakage-clean·deployability*로 옮겨갔다. 우리의 "약점"이 field 합의가 됐고, 우리 rigor가 새 기준이다.

---

## 진행 가능한 연구 — 정확도가 아닌 축으로

정확도로 morph를 넘는 길은 닫혔다(아키텍처·종단·multimodal 전부). 살아있는 건 *정확도가 아닌 축*이다. 데이터 근거는 `notebook/06_feasible_directions.ipynb`에 있다.

- **Lane B (권장)** — *label-efficiency × LOCO*: SSL 표현이 **적은 라벨 × held-out site**에서 morphometry를 이기나. positive 방법론 claim(benchmark 아님). foundation model들이 morph와 비교를 안 한 *빈 칸*이 우리 자리. kill-test가 싸서 빨리 판정된다.
- **Lane A (pivot)** — *T1→미세구조 합성*: T1에서 FA/MD를 합성해 morphometry 너머 신호를 만드나. **구조적 저주가 ASSET이 된다**(KDRC/OASIS DWI=train 타깃 → ADNI 적용). risk: 합성이 atrophy 재인코딩이면 illusory.
- **GATE-3 먼저** — `image→fs_vol R²`를 cortical ROI별로. 이게 "Lane들이 애초에 가능한지"를 GPU 전에 가른다.

> 정직한 prior는 여전히 **null**이다(R2 천장이 모든 lane에서 morph를 못 넘김을 예측). 양성 결과는 *놀라운* 것으로 취급하고, 나오면 누수부터 의심한다. 그래도 — 이 라인은 처음으로 "막다른 길"이 아니라 *정직하게 좁혀진 한 자리*에 서 있다.

---

**더 읽기:** 데이터·bias 설계 `../analysis/01_data-and-bias.md` · 천장·닫힘 ledger `../analysis/02_ceiling-and-baselines.md` · novelty·방향 `../analysis/03_novelty-and-direction.md` · 음성 결과 `../ledgers/` · 결정 이력 `../DECISION_LOG.md`.
