# 02. Ablation Study Plan

## 목적

이 문서는 hybrid 기여 **C1(protocol-adaptive transfer)** 과 **C2(objective balance & rank mechanism)** 를
증명하는 ablation plan이다. dense branch 자체(SparK-style submanifold masked conv)는 novelty가 아니므로
ablation의 목표가 아니다 — 그것은 구현 detail로만 다룬다.

핵심 전환(이전 plan 대비): anti-leakage hidden-content probe는 동어반복(아래 Group S)이므로
**main ablation에서 내리고**, objective sweep(C2)과 protocol sweep(C1)을 **primary ablation**으로 둔다.

## Ablation Overview

| Group | 질문 | 비교군 | Primary evidence | 상태 |
|---|---|---|---|---|
| **P** (C1) | foundation 가치가 protocol에 의존하는가? | full-FT vs frozen vs low-LR vs scratch | seg Δ-over-scratch by protocol | ✅ 확보 |
| **B** (C2) | objective balance가 global 전이의 정점을 만드는가? | wg0 / wg0.5 / wg1 | provenance-clean global probe (inverted-U) | ✅ 확보 |
| **R** (C2) | rank가 trade-off 메커니즘을 설명하는가? | wg sweep × rankme/emb_std | rank vs transfer 관계 | ✅ 확보 |
| **X** (C3) | global 전이가 외부·multi-site에서 유지되는가? | 6코호트 leakage-safe | 외부 brain age + CN/MCI/AD | 🟡 준비중 |
| **E** | ResEnc가 dense 3D MRI에 적합한가? (보조) | ResEnc vs ViT | transfer + rank | △ 부분(vit_ibot collapse 참조) |
| **S** (detail) | re-mask가 hidden-content 누수를 막는가? | masked±re-mask | leakage probe (동어반복=detail) | ⬇️ sanity only |

## Group P. Protocol-Adaptive Transfer (C1 — primary)

### Hypothesis

Foundation의 dense 전이 가치는 fine-tuning protocol에 의존한다. full fine-tuning은 random-init 인코더도
학습시켜 scratch가 따라오게 만들어 foundation 우위를 *가린다*. frozen/low-LR는 그것을 드러낸다.

### Variants & 결과 (trigeminal Task4, n=40, dicecldice+EMA) — ⚠️ audit 교정본

| Protocol | pretrained Dice [CI] | matched scratch [CI] | Δ | 상태(audit) |
|---|---|---|---|---|
| frozen (**TC1 정량**) | 0.442 [0.408,0.474] | 0.308 [0.275,0.340] | **+0.134** | **SOLID, matched·CI-분리** |
| full-FT | 0.445 [0.411,0.479] | 0.409 [0.372,0.444] | +0.03 | SHAKY (CI 겹침) — *diagnostic 입력* |
| low-LR | 0.450 [0.412,0.486] | (low-LR-scratch ≈ frozen-scratch 0.308) | ~+0.14 | absolute-best(보조), 별도 정량주장 안 함 |

**TC1 정량 = frozen matched 비교(재실행 불필요, 기존 데이터로 SOLID):**
- foundation-frozen 0.442 [0.408,0.474] vs scratch-frozen 0.308 [0.275,0.340] → **Δ+0.134, CI-분리** (둘 다 frozen-mode=fresh decoder+encoder 동결 → 완전 matched).
- **scratch-convergence diagnostic**: `gap = Dice_scratch(full-FT) − Dice_scratch(frozen) = 0.409 − 0.308 = +0.101`.
  이 gap이 full-FT에서 scratch가 따라잡는 정도를 정량화 = "full-FT가 foundation 가치를 *가린다*"의 *측정값*.
- 정직 경계: frozen-foundation 0.442 ≈ **full-FT-scratch 0.409(CI 겹침)**. → 주장은 "값싼 frozen 단일-체크포인트 probe가
  full-FT-from-scratch *수준을 회복*(저비용)"이지 "foundation이 더 낫다"가 아니다.
- low-LR 0.450은 absolute-best로만 보조 보고(low-LR mode는 pretrained decoder 사용 → "matched low-LR scratch"는 frozen-scratch와 사실상 동일, 별도 +0.142 주장 안 함).
- meningioma Task2(n=23): 전부 <0.16, CI 겹침 → **방향성("frozen은 lesion 도움 안 됨")만**, 정량 Δ 안 씀.

→ TC1은 frozen matched(+0.134) + diagnostic(+0.101) + task-adaptive 방향성으로 **GPU 재실행 없이 paper-ready.**

### "scratch-convergence gap" 진단 (method-flavored)

```text
gap(task) = Dice_scratch(full-FT) - Dice_scratch(frozen)
gap이 클수록 = scratch가 full-FT에서 스스로 강해짐 = foundation 우위가 full-FT에서 가려짐
→ 이 task는 frozen/low-LR로 평가해야 foundation 가치가 보인다.
```

Paper figure: protocol(x) vs Δ-over-scratch(y), task별 곡선 + scratch-convergence 도식.

## Group B. Objective Balance (C2 — primary)

### Hypothesis

dense/global 가중치는 inverted-U를 그린다. global 가중을 너무 키우면 representation rank가 붕괴해
global linear-probe마저 손해본다. balanced(wg0.5)가 정점이다.

### Variants & 확보된 결과 (provenance-clean frozen probe, recipe=resenc_s3d, matched random)

| ID | w_global | brain age r [CI] (n494) | polymicro AUROC (n48) | ~~infarct~~ (n21) |
|---|---:|---|---:|---|
| random | — | 0.137 [0.042,0.222] | 0.608 | ~~컷~~ |
| wg0 (pure) | 0.0 | 0.599 [0.540,0.656] | 0.793 | ~~컷~~ |
| **wg0.5** | 0.5 | **0.792 [0.762,0.819]** | 0.957 | ~~컷~~ |
| wg1 (full) | 1.0 | 0.683 [0.632,0.722] | 0.984 | ~~컷~~ |

audit 교정:
- **brain age = primary·SOLID.** wg0.5 정점이 양 이웃과 **CI 분리**(0.762 > pure 0.656, 0.762 > full 0.722). random 0.137로 낮아 confound 아님. 이것이 유일하게 견고한 inverted-U 증거.
- **polymicro는 단조증가**(0.793→0.957→0.984) + n=48 → *정점 증거 아님*, **Δ-over-random 보조로만** (random 0.608의 CI [0.438,0.767]도 chance 포함 → 절대값 신뢰 불가).
- **infarct는 제거.** n=21, 모든 CI가 0.5 포함(예: wg0.5 [0.475,0.929]), 비단조 → balance/inverted-U 증거에서 완전 배제.
- inverted-U는 내부 brain age 1개뿐 → **C3 외부 brain age(대규모·cross-cohort)에서 재현**되어야 AAAI급.

Paper figure: global score(x) vs dense/seg score(y) Pareto, 점=wg0/0.5/1; brain age inverted-U.

## Group R. Rank Mechanism (C2 — primary)

### Hypothesis

global 가중↑ → effective rank↓. 이 rank 붕괴가 inverted-U의 하강 팔을 설명한다.

### 확보된 결과 (tail-window collapse diagnostics)

| run | rankme | emb_std_mean | teacher_entropy_ratio | collapse_flag |
|---|---:|---:|---:|---|
| wg0 | 14.86 | 0.134 | 0.852 | ok |
| wg0.5 | 12.93 | 0.146 | 0.392 | ok |
| wg1 | 11.65 | 0.228 | 0.413 | ok |
| vit_ibot (참조) | 14.07 | 0.444 | 0.020 | **collapse_risk** (uniform teacher) |

- ResEnc s3d 계열은 collapse 임계(rankme<4) 미접근 — "붕괴"가 아니라 *완만한 rank 압축*.
- **2-force 재서술(audit 강제)**: rank는 inverted-U의 **down-arm(wg0.5→wg1)만** 설명한다.
  up-arm(wg0→wg0.5)은 rank가 *떨어지는데* transfer가 *오르므로*(14.86→12.93, 0.599→0.792) rank만으로 설명 불가 —
  global objective가 주입하는 *semantic 정보 이득*이 rank 손실을 상쇄하기 때문. 정점은 두 힘이 균형하는 지점.
  → "rank가 inverted-U를 설명한다"고 쓰지 말고, "semantic 이득 vs rank 손실의 trade-off, rank는 하강 팔을 설명"으로 쓴다.
- vit_ibot의 uniform-teacher collapse는 *backbone 참조*로만(직접 ResEnc-DINO matched run 없음 → 과대해석 금지).

## Group X. External Multi-Site (C3 — validation, 준비중)

상세는 `03`. frozen global probe(brain age 회귀, CN/MCI/AD 분류)를 leakage-safe 6코호트에 적용.
matched random baseline + Δ + bootstrap CI + site-disjoint/대륙간 split.

## Group E. Backbone (보조)

ResEnc vs ViT(vit_ibot/vit_mae). transfer Δ + rank + locality. claim 경계:

```text
ViT가 일반적으로 열등하다고 주장하지 않는다.
우리 3D MRI dense decoder-transfer 세팅에서 ResEnc가 더 잘 맞는다고만 주장한다.
```

## Group S. Leakage Sanity (detail — 증거 아님)

### 정직한 처리

```text
hidden-content leakage probe는 입력 마스킹(x*vis)+stage re-mask로 인해, visible이 동일하면
encoder feature가 비트 단위로 동일 → masked-region 차이가 *산술적으로* 0이 된다(학습 무관, random-init도 0).
re-mask 유무 두 masked 변종이 모두 0이고, 유일한 비-0(0.69)은 *unmasked* 입력 control(실제 MAE에 없음).
따라서 이 probe는 anti-leakage를 증명하지 못한다 — architectural sanity check로만, detail 섹션에 보고한다.
```

(선택) 더 의미 있는 진단을 원하면 *boundary/receptive-field bleed*(visible→hidden RF 누출)를 측정하는
probe를 재설계한다. 학습 불필요. main claim은 아니다.

## Paper-Ready Tables and Figures

- Table 1. Objective balance — wg0/0.5/1 × {brain age r, polymicro, infarct, rankme}
- Table 2. Protocol-adaptive transfer — task × {full-FT, frozen, low-LR} Δ-over-scratch
- Table 3. External multi-site — cohort × {brain age r, CN/MCI/AD AUROC} Δ-over-random (C3)
- Figure 1. Architecture (single checkpoint → dense pyramid + global vector; re-mask는 detail로 표기)
- Figure 2. Objective-balance Pareto + brain age inverted-U + rankme overlay
- Figure 3. Protocol curve (Δ-over-scratch vs protocol, task별) + scratch-convergence 도식
- Figure 4. External site-disjoint / cross-continent transfer

## Execution Priority

1. C1/C2 결과 표/그림 확정(기존 자산 — D1/D2/collapse 통합) ✅ 데이터 확보
2. 외부 데이터 전처리 완료 후 C3 frozen probe 실행
3. (선택) boundary-bleed probe 재설계 — detail 섹션
4. ResEnc vs ViT 보조 표
5. 새 사전학습 run은 *필요 시에만* (촘촘한 wg sweep 등) — 데드라인 우선
