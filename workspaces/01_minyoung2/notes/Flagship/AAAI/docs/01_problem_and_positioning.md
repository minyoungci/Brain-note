# 01. Problem and Positioning

## 목표

AAAI target paper의 목표는 단일 dense-global 3D brain MRI foundation 체크포인트를 대상으로
**"무엇이 전이되고, 어떻게 배포해야 하는가"** 를 통제된 실험으로 규명하는 것이다.
새 사전학습 방법을 발명했다고 주장하지 않는다(아래 SparK positioning 참조).

Working title 후보:

```text
What Transfers from a Single-Checkpoint 3D Brain MRI Foundation Model?
A Controlled Study of Objective Balance and Protocol-Dependent Transfer
```

```text
Protocol-Adaptive Transfer for Single-Checkpoint Dense-Global 3D Brain MRI Foundation Models
```

## 풀어야 하는 문제 (실무자가 실제로 겪는 것)

3D brain MRI foundation 모델을 *실제로 쓸 때* 답이 없는 질문들이다.

1. **단일 체크포인트로 이질적 task(global 회귀·분류 + dense segmentation)를 동시에 감당할 때, dense/global 목적함수 가중치를 어떻게 잡아야 하는가?** 한쪽으로 치우치면 다른 축 전이가 약해진다.
2. **사전학습이 정말 도움이 되는가? 언제?** 흔히 full fine-tuning에서 pretrained ≈ scratch가 되어 "foundation 무용"처럼 보인다. 이것이 진짜인지, 평가 protocol의 아티팩트인지 구분이 안 된다.
3. **표현 품질을 어떻게 진단하는가?** CNN global SSL은 collapse/low-rank로 빠질 수 있고, 작은-n 내부 평가에서는 random encoder조차 위치/site shortcut으로 높은 점수를 낸다.

## 우리 방법의 위치 (정직한 SparK positioning)

현재 model:

```text
ResEnc backbone
+ skip-preserving dense branch (submanifold-masked conv, stage-wise re-mask)
+ global branch (InfoNCE / SimPool)
+ KoLeo
= single 3D brain MRI SSL checkpoint
```

dense branch에 대한 정직한 위치:

```text
우리의 stage-wise re-mask dense conv는 SparK(Tian et al., ICLR 2023)의 submanifold sparse-conv
masked image modeling과 개념적으로 동치이며(코드 주석도 "SparK식 submanifold-근사 MAE"로 명시),
ConvMAE/SimMIM 계열과도 가깝다.
따라서 우리는 이것을 novelty가 아니라 *구현 detail*로 처리하고, SparK/ConvMAE/SimMIM을 인용한다.
기여는 method가 아니라, 이 체크포인트가 3D brain MRI에서 무엇을·어떻게 전이하는지에 대한 분석과 배포 레시피다.
```

약한/강한 claim 구분:

- 약한(쓰지 않음): `we propose a new anti-leakage masked reconstruction loss`
- 강한(쓰는 것): `we characterize when and how a SparK-style single dense-global checkpoint transfers in 3D brain MRI, and give a protocol-adaptive deployment recipe validated across external multi-site cohorts`

## AAAI 기술적 기여 (TC1/TC2/TC3) — 증거 스트림 C1/C2/C3

> 기술적 novelty = backbone(SparK 인용)이 아니라 **TC1 scratch-convergence 진단·protocol-adaptive method /
> TC2 objective-balance·rank 기반 checkpoint 선택 / TC3 shortcut-통제 평가 framework**. 아래 Claim C1/C2/C3는
> 각 TC를 뒷받침하는 *증거 스트림*이다(TC1↔C1, TC2↔C2, TC3↔C3).

### Claim C1 (method-flavored). Protocol-Adaptive Transfer

```text
Foundation의 가치는 fine-tuning protocol에 의존한다.
full fine-tuning은 random-init도 encoder를 학습시켜 foundation 우위를 *가린다*.
frozen/low-LR는 그 우위를 드러낸다.
처방: tubular/anatomy = frozen/low-LR, lesion = full fine-tune.
```

필요 증거(audit 검증, paper-ready, GPU 재실행 불필요):

- **frozen matched(정량 핵심)**: trigeminal Task4(n=40) foundation-frozen 0.442[0.408,0.474] vs scratch-frozen
  0.308[0.275,0.340] → **Δ+0.134, CI-분리**(둘 다 frozen-mode=완전 matched).
- **scratch-convergence diagnostic(TC1 핵심)**: `gap = Dice_scratch(full-FT) − Dice_scratch(frozen) = 0.409 − 0.308 = +0.101`
  = full-FT가 scratch를 따라잡게 해 foundation 가치를 *가리는* 정도의 *측정값*. → 알고리즘적 진단 지표.
- 정직 경계: frozen-foundation 0.442 ≈ full-FT-scratch 0.409[0.372,0.444](CI 겹침) → "값싼 frozen 단일-체크포인트
  probe가 full-FT-from-scratch *수준을 회복*(저비용)"이지 "더 낫다"가 아니다. low-LR 0.450은 absolute-best 보조.
- meningioma Task2(n=23): 방향성("frozen은 lesion 도움 안 됨")만 — 전부 Dice<0.16, CI 겹침. 정량 Δ 안 씀.

### Claim C2 (empirical). Objective Balance & Rank Mechanism

```text
단일 체크포인트의 dense/global 가중치는 effective rank와 semantic linear-probe를 trade off 한다.
global 가중을 너무 키우면 rank가 붕괴해 global 선형분리마저 손해본다.
balanced(wg0.5)가 inverted-U 정점이다.
```

필요 증거(audit SOLID):

- brain age frozen probe(r, n494): random 0.137[0.042,0.222] → pure 0.599[0.540,0.656] → **wg0.5 0.792[0.762,0.819]**
  → full 0.683[0.632,0.722]. **wg0.5 정점이 양 이웃과 CI-분리** = 유일하게 견고한 정량 주장. (proj 무해함 코드로 증명.)
- rankme(tail): wg0 14.86 → wg0.5 12.93 → wg1 11.65 (단조감소). 단 rank는 **down-arm만** 설명(up-arm은 semantic 이득이 rank 손실 상쇄).
- polymicro는 Δ-over-random 보조로만(단조 + n48, random CI도 chance 포함). **infarct(n21)는 컷**(CI가 chance 포함). inverted-U는 brain age 1개 → **C3 외부 재현 필요**.

### Claim C3 (validation). External Multi-Site Transfer

```text
global 표현은 leakage-safe 외부 코호트·scanner·대륙을 넘어 유지된다.
```

필요 증거(준비중 — critical path):

- brain age 회귀: 6코호트 합 ~6,300 subject(전부 FOMO300K 사전학습과 disjoint)
- CN/MCI/AD 분류: ADNI(849/594/126)·KDRC(282/239/249 balanced)·NACC(935/309/131)
- site-disjoint(ADNI 16 scanner / NACC 11) + 대륙간(ADNI→KDRC/AJU)

### Implementation detail (claim 아님). Skip-Preserving Dense Pretraining

```text
SparK-style submanifold-masked conv로 skip을 보존하며 dense decoder 전이를 사전학습한다.
이전의 hidden-content "anti-leakage" probe는 마스킹+re-mask의 산술적 결과(동어반복)로 0이 되며,
*증거가 아니라* 아키텍처 sanity check로만 보고한다(상세 02, 06).
```

## 현재 약점과 논문 내 처리 (정직)

- 내부 seg/cls는 작은-n(task4 n=40, task2 n=23, infarct n=21, polymicro n=48). polymicro는
  random floor 0.608의 약한 site confound, infarct CI는 chance 포함. → C3 외부검증으로 보강.
- dense seg 전이는 modest·protocol-dependent. SOTA seg를 주장하지 않는다.
- Task2 meningioma 저성능은 central proof가 아니라 few-shot lesion decoder limitation 사례로만 쓴다.

```text
Task2 is a stress test exposing few-shot lesion decoder limits and the task-adaptive protocol need,
not the primary evidence. The central evidence is C1/C2 ablations and C3 external validation.
```
