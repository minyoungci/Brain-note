# 01. Problem and Positioning

## 목표

이 논문은 **대규모(FOMO300K, 전처리 후 226,793 volumes·36-source) 3D brain MRI foundation 사전학습
regime을 위한 두 가지 positive technical method**를 제안하고 외부 multi-site로 검증한다:

1. **TC2 (headline, 검증중) — 라벨-프리 objective-balance 선택**: dense+global 결합 SSL에선 effective rank가
   transfer와 *분리*(rank 단조↓ vs transfer inverted-U)되어 naive rank/RankMe 선택이 *실패*함을 보이고,
   이를 극복하는 라벨-프리 기준 C로 transfer-최적 가중치를 고르는 selection 절차(C 존재는 Phase 0이 GO/NO-GO).
2. **TC1 — budget-adaptive transfer protocol**: scratch-convergence 진단으로 task·라벨예산별
   fine-tuning protocol을 처방 → naive full-FT가 *가리는* foundation 우위를 회복(동급 이상·저비용,
   Δ-over-scratch +0.03→+0.134).

스케일은 *novelty 자체가 아니라 이 method가 필요·유효해지는 regime*이다: 226,793-volume 규모에선
체크포인트마다 라벨 튜닝이 불가능하므로 **라벨-프리 선택(TC2)이 필수**가 되고, 36-source multi-site이므로
**shortcut-통제 평가(TC3)가 검증 rigor**로 요구된다. 새 backbone/loss는 주장하지 않는다(SparK positioning 참조).

Working title 후보:

```text
Label-Free Objective-Balance Selection and Budget-Adaptive Transfer
for Large-Scale 3D Brain MRI Foundation Models
```

```text
What to Tune Without Labels: Rank-Guided Objective Balancing for
Single-Checkpoint Dense-Global 3D Brain MRI Foundation Pretraining
```

## 풀어야 하는 문제 (실무자가 실제로 겪는 것)

3D brain MRI foundation 모델을 *실제로 쓸 때* 답이 없는 질문들이다.

1. **단일 체크포인트로 이질적 task(global 회귀·분류 + dense segmentation)를 동시에 감당할 때, dense/global 목적함수 가중치를 어떻게 잡아야 하는가?** 한쪽으로 치우치면 다른 축 전이가 약해진다.
2. **사전학습이 정말 도움이 되는가? 언제?** 흔히 full fine-tuning에서 pretrained ≈ scratch가 되어 "foundation 무용"처럼 보인다. 이것이 진짜인지, 평가 protocol의 아티팩트인지 구분이 안 된다.
3. **표현 품질을 어떻게 진단하는가?** CNN global SSL은 collapse/low-rank로 빠질 수 있고, 작은-n 내부 평가에서는 random encoder조차 위치/site shortcut으로 높은 점수를 낸다.

## 우리 방법의 위치 (정직한 SparK positioning)

현재 model (FOMO300K로 사전학습 → 전처리 후 226,793 volumes·36 public sources):

```text
ResEnc backbone
+ skip-preserving dense branch (submanifold-masked conv, stage-wise re-mask)
+ global branch (InfoNCE / SimPool)
+ KoLeo
= single 3D brain MRI SSL checkpoint
  corpus: FOMO300K → 226,793 preprocessed volumes / 36 public sources
          (OpenNeuro 46%·HBN·HCP·BraTS·OASIS1·2·IXI… / ADNI 미포함 = 외부검증 disjoint)
```

dense branch에 대한 정직한 위치:

```text
우리의 dense branch는 dense conv + stage-wise re-mask로 SparK(Tian et al., ICLR 2023)의
submanifold sparse-conv masked image modeling을 *근사*한다.
★ 개념은 같으나 연산은 동일하지 않다(NOT equivalent, only approximate):
  - SparK = 진짜 submanifold sparse convolution(active site만 계산, active set 고정).
  - 우리 = sparse-conv 라이브러리 없이 dense conv를 돌린 뒤 매 stage masked 위치를 re-zero
           → normalization(BN/GN이 zero 포함)·경계에서 SparK와 비등가.
이 dense masked-conv 변형은 ConvMAE/MCMAE(Gao et al., 2022)·SimMIM 계열과 더 가깝다.
설계 의도(왜 이렇게 했나): skip을 보존해 누수 없이 dense decoder 전이를 3D U-Net foundation에
  사전학습하기 위함(skip-free MAE의 negative-transfer 회피). 이는 의도적 design choice다.
→ 정직한 위치: 이 연산 차이는 *분명히 존재하지만*(SparK와 동일하지 않음을 본문에 명시),
   "3D에 적용했다"만으로는 novelty가 되지 않는다(3D masked-CNN pretraining 자체가 선행연구).
   따라서 우리는 이것을 **primary method 기여로 주장하지 않고** minor design detail로 처리하며,
   정확한 prior art(SparK + ConvMAE/SimMIM)를 인용한다.
   기여는 method가 아니라, 이 체크포인트가 3D brain MRI에서 무엇을·어떻게 전이하는지에 대한
   분석과 배포 레시피(TC1/TC2/TC3)다.
```

약한/강한 claim 구분:

- 약한(쓰지 않음): `we propose a new anti-leakage masked reconstruction loss`
- 강한(목표, 일부 검증중): `we show that effective rank decouples from transfer under joint dense+global objective balancing (so RankMe-style rank selection fails), and develop a label-free criterion that locates the transfer optimum, validated as a selection procedure (leave-one-task-out regret); plus a budget/protocol-adaptive transfer method — for large-scale (FOMO300K) single-checkpoint 3D brain MRI foundation models. (External multi-site validation: in progress, not yet claimed.)`

## AAAI 기술적 기여 (TC1/TC2/TC3) — 증거 스트림 C1/C2/C3

> **Positive technical novelty (headline)** = backbone(SparK 인용)이 아니라:
> - **TC2 (headline method, 검증중) — 라벨-프리 objective-balance 선택**: FINDING — dense+global 결합에선
>   effective rank가 transfer와 *분리*(rank 단조↓ vs transfer inverted-U)되어 naive rank/RankMe 선택이 *실패*.
>   METHOD — rank가 못 잡는 up-arm까지 따라가는 라벨-프리 기준 C로 transfer-최적 가중치를 고르고 selection 절차
>   (leave-one-task-out regret)로 검증(C 존재는 Phase 0 GO/NO-GO; 외부검증 [PENDING]). RankMe delta: 그들=label-free
>   *model 순위* / 우리=objective-balance에서 rank 실패를 보이고 이를 극복하는 C를 selection으로 검증.
> - **TC1 (method) — budget-adaptive transfer**: scratch-convergence 진단(gap)이 task·라벨예산별 protocol을
>   처방 → naive full-FT가 가리는 foundation 우위를 회복(동급 이상·저비용, Δ-over-scratch +0.03→+0.134).
> - **TC3 (validation rigor) — shortcut-통제 외부평가**: 헤드라인이 아니라, 위 두 method가 site/scanner/대륙을
>   넘어 작동함을 증명하는 *검증층*.
>
> 스케일(FOMO300K, 226,793 volumes·36-source)은 *novelty가 아니라 regime*: 이 규모에선 라벨 튜닝 불가→TC2 필수,
> 36-source multi-site→TC3 필수. 아래 Claim C1/C2/C3는 각 TC의 *증거 스트림*(TC1↔C1, TC2↔C2, TC3↔C3).

### Claim C1 (method). Budget/Protocol-Adaptive Transfer

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

### Claim C2 (headline method, UNDER CONSTRUCTION). Label-Free Objective-Balance Selection — overcoming rank–transfer decoupling

```text
FINDING (verified): dense+global 결합 SSL에선 effective rank가 transfer와 *분리(decouple)*된다.
  rank 단조↓(wg0 14.86→0.5 12.93→1 11.65) vs transfer inverted-U(0.599→0.792→0.683).
  → naive rank/RankMe 선택은 rank-max인 wg0(0.599)을 골라 *틀린다*. (RankMe에 대한 non-obvious 경고)
METHOD (목표, 검증중): rank가 못 잡는 up-arm까지 따라가 inverted-U 정점에서 extremum을 갖는
  *라벨-프리 기준 C*(후보: α-ReQ exponent · alignment/uniformity · cluster-quality)를 찾아,
  selection 절차로 검증한다 — leave-one-task-out에서 ŵ=argmax C가 default·midpoint 대비 regret↓.
주의(정직): up-arm을 설명하는 'semantic 주입'은 현재 linear-probe(=라벨)로만 측정됨
  → C 존재 여부는 *미확정*(Phase 0 후보지표 스크리닝이 GO/NO-GO). "rank로 최적 선택"은 주장 안 함.
delta vs RankMe/α-ReQ: 그들=label-free *model 순위* / 우리=objective-balance에서 rank가 실패함을
  보이고 이를 극복하는 C를 selection 절차로 검증(존재 시). 외부검증=[PENDING], 완료형 금지.
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
