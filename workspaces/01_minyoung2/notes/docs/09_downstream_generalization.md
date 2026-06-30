# 09. Downstream few-shot 일반화 — 내부 점수 ≠ hidden test (반드시 준수)

> **이 문서의 한 줄**: downstream task의 n이 너무 작아 **내부/Validator 점수가 hidden test를 예측하지 못한다.** 내부 최고점을 쫓지 말고 *일반화*를 우선하라.
> 관련: 위험 [[06_risk_register]] W17, 제출 [[fomo26-submission-container]], 평가 confound [[08_shortcut_and_confound_control]], 여정 [[downstream_finetuning_journey]] §4.2, 현재 상태 [[SCRATCHPAD]] 🎯.
> 작성 2026-06-30 (근거: Task1 실제 제출 결과).

---

## 1. 관찰된 사실 (근거)

- **Task1 infarct**: 로컬 FOMO Validator·내부 LOOCV에서 **AUROC ≈ 0.94로 매우 높게** 나왔으나, 실제 Synapse **hidden test = 0.658**으로 급락. = **전형적 few-shot 과적합** (내부 high → hidden 낮음).
- FOMO가 제공한 로컬 Validator는 **소수의 제공 샘플 위에서 돈다** → Validator 점수가 높아도 그건 *그 몇 case에 맞춰진* 점수일 수 있다. **로컬 Validator 통과 = 일반화 보장 아님.**

## 2. downstream n 실측 (왜 과적합하는가)

| task | type | n(평가) | 라벨 밀도 | 과적합 위험 |
|---|---|---|---|---|
| T1 infarct | cls | **21** (pos 13) | subject당 1 라벨 | 🔴🔴 최고 (입증됨: 0.94→0.658) |
| T5 polymicro | cls | **48** | subject당 1 라벨 | 🔴🔴 최고 (+ site confound) |
| T2 meningioma | seg | **23** | voxel 감독(조밀) | 🔴 높음 |
| T4 trigeminal | seg | **40** | voxel 감독(조밀) | 🟡 중간 |
| T3 brain age | reg | **494** | subject당 1 (n 큼) | 🟢 낮음 |
| T6/T7 | embedding | — | finetune 없음(frozen) | 🟢 안전 |

- **cls가 가장 위험**: subject당 라벨 1개 → 정보량이 가장 적고, n=21/48이면 1~2 case로 AUROC가 크게 출렁인다.
- **조밀-감독 seg**는 voxel마다 감독이 있어 cls보다 sample-efficient하나, n=23은 여전히 작다.
- **reg(n494)·embedding(frozen)**은 상대적으로 안전.

## 3. 근본 원인 (3겹) — 특히 ③을 잊지 말 것

1. **작은 n = 높은 분산**: n=21의 LOOCV는 case 1~2개로 0.05~0.15씩 출렁인다. 점추정 신뢰 불가, CI 필수.
2. **full-FT가 few-shot을 외운다**: encoder까지 21 case에 맞추면 그 case들을 외우고 hidden엔 일반화 못 한다. ([[downstream_finetuning_journey]] §4.2)
3. **선택 과적합 (selection / optimization overfitting) — 가장 교묘**: recipe·하이퍼파라미터·모달 조합을 *내부 CV 최대화로 골랐다면*, 그 내부 점수 자체가 **낙관적으로 편향**된다. C·fusion·modality를 내부 LOOCV로 튜닝해 0.942를 얻었다면, 그 0.942는 hidden 예측값이 아니라 *그 선택 절차의 상한*이다. **→ v2_frozen의 LOOCV 0.942도 hidden을 보장하지 않는다.**

> 핵심 함의: **n이 이 정도로 작으면 내부 지표는 hidden 성능을 *예측하지 못한다*.** 내부 점수로 모델을 고르는 행위 자체가 위험하다.

## 4. 처방 — 일반화 우선 체크리스트

내부 점수를 1점 더 올리는 것보다, *hidden에서 무너지지 않을 이유*가 강한 모델을 택한다.

**구조/학습 (trainable 파라미터·자유도 축소):**
1. **encoder frozen 또는 low-LR** — full-FT가 외우는 걸 막는 1순위 레버(우리가 입증). cls는 frozen-encoder + linear head가 기본.
2. **얕은 head** (linear/1×1) — 깊은 디코더·MLP는 few-shot서 외운다.
3. **모달 축소** — 노이즈 모달 제거(Task1서 t2star/swi 제거). 입력 차원↓ = 과적합↓.
4. **강한 정규화** — L2(작은 C, 예: 0.3)·weight decay·dropout·early stopping.
5. **공격적 augmentation** — scanner/site/해상도 shift를 학습 중 모사해 일반화 압력.

**평가/선택 (선택 과적합 차단):**
6. **내부 CV로 하이퍼파라미터를 사냥하지 말 것** — 합리적 기본값을 *사전에* 고정하라. 내부 CV로 고른 모든 선택은 낙관 편향을 더한다.
7. **CI를 항상 보고**, 점추정은 *상한*으로 취급(예측값 아님).
8. **fold/seed 앙상블** — 단일 모델보다 robust.

**제출 전략:**
9. **보수적 선택** — 내부가 약간 낮아도 *더 정규화된* 모델을 hidden에 낸다. best-of-all selection이면 frozen/정규화 변형 제출에 손해 없음.
10. **남은 test 1회**(2회 중 1회 사용=0.658)는 가장 일반화-안전한 번들로. 내부 peak를 쫓아 또 과적합 모델을 내지 말 것.

## 5. 즉시 적용 (현재 제출에)

- **Task1**: full-FT(0.658) → **v2_frozen**(frozen-enc + linear + dwi/adc/flair + L2 C=0.3)로 교체. 단 LOOCV 0.942도 hidden 미검증 → §3-③ 유의.
- **Task5**: Task1과 동형 위험(cls n48) → frozen-mitigation 점검 필수(아직 미수행).
- **Task2/4 seg**: 조밀 감독이라 cls보단 안전하나, 과한 finetune·해상도 튜닝은 절제.
- **원칙**: 모든 cls/소-n task는 "내부 점수 최대"가 아니라 "**자유도 최소 + 정규화 최대**"로 제출 변형을 고른다.

---

> **잊지 말 것**: 0.94 → 0.658은 우연이 아니라 **n=21의 구조적 결과**다. 내부 Validator가 아무리 높아도, few-shot에선 *일반화에 베팅*하는 모델이 이긴다.
