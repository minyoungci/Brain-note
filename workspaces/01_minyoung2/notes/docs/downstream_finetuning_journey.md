# Foundation → Downstream: 7개 과제를 fine-tuning한 여정 (튜토리얼 노트)

> 대상: FOMO26 (MICCAI 2026) 단일 체크포인트 foundation model.
> 이 노트는 **"우리 foundation을 7개 downstream 과제에 어떻게 붙였고, 어떤 실험을 거쳐 지금 결과에 도달했는지"**를 튜토리얼처럼 풀어쓴 글이다.
> Foundation 모델 *자체*의 해부(아키텍처·gradient 흐름·설계 결정)는 자매 문서 [`foundation_model_design.md`](foundation_model_design.md)에 있다 — 이 노트는 그 *다음 이야기*다.
> 모든 수치는 `experiments/phase_b/downstream_runs/COMPARISON.md`와 실제 학습 로그에서 가져왔다. 미검증 외부 수치는 [VERIFY].

---

## Part 0. 두 문서의 분업 (먼저 읽는 법)

| 문서 | 다루는 것 |
|---|---|
| [`foundation_model_design.md`](foundation_model_design.md) | foundation 모델 **자체** — ResEnc U-Net + S3D MAE + InfoNCE-global이 *어떻게 생겼고 gradient가 어디로 흐르는가* |
| **이 노트** | 그 foundation을 **7개 과제에 적용**하는 fine-tuning — *무엇을 시도했고, 왜 실패/성공했고, 지금 결과는 무엇인가* |

> 주의: `foundation_model_design.md` §10의 downstream 결과 표는 초기(Jun 25) 수치다. **이 노트의 결과가 최신이며, 일부 결론(특히 "seg는 from-scratch를 못 넘는다")은 아래 Wave-E에서 뒤집혔다.**

---

## Part 1. Foundation 모델 30초 요약

자세한 건 design 문서로. 한 문장만:

> **하나의 ResEnc-L CNN U-Net 인코더**가 같은 뇌의 두 랜덤 crop으로 (1) 가린 복셀 복원(dense, S3D masked-conv MAE)과 (2) EMA-teacher 표현 대조(global, InfoNCE)를 *동시에* 풀며 학습했다. 코퍼스 ~22만 볼륨, 150k step, 체크포인트 = **wg0.5** (`L = 1·L_dense + 0.5·L_global + 0.1·KoLeo`).

downstream에서 우리가 떼어 쓰는 건 이 인코더(+필요시 디코더)다. 산출물:
- **global 벡터** (SimPool+head): cls/reg 과제용.
- **dense 디코더 feature** (S3D, 누수0): seg 과제용.

---

## Part 2. downstream의 본질 — 왜 데이터를 "적게" 줬나

FOMO26은 **foundation model challenge**다. 규칙에 명시돼 있다: *"few-shot generalization 평가가 핵심, fine-tuning 추가 데이터 금지."* 즉 데이터가 적은 건 *버그가 아니라 시험 문제*다.

| Task | 과제 | 유형 | n (subject) | few-shot? |
|---|---|---|---|---|
| 1 | infarct | cls | 42 | ✅ |
| 2 | meningioma | seg | 46 (멀티모달 완비 23) | ✅ |
| 3 | brain age | reg | **988** | ❌ (유일하게 많음) |
| 4 | trigeminal | seg | 80 | ✅ |
| 5 | polymicrogyria | cls | (별도) | ✅ |
| 6·7 | embedding/fairness | frozen | — | (학습 없음) |

> **핵심 프레임**: few-shot에서 가장 큰 레버는 "데이터를 늘리는 것"이 아니라 **pretraining 품질 + adaptation 전략**이다. 우리가 SSL pretraining을 한 이유가 바로 이것이고, 이 노트는 그 adaptation 전략을 task별로 어떻게 찾았는지의 기록이다.

---

## Part 3. 공통 fine-tuning 인프라 (모든 task가 공유)

본격적인 task별 이야기 전에, 7개가 공유하는 토대 3가지.

### 3.1 전처리 — pretraining과 *동일한* yucca 4-step
`crop_to_nonzero → volume_wise_znorm[0,1] → 1mm 등방 리샘플 + RAS → float16`. **pretraining 코퍼스와 downstream이 같은 전처리를 써야** 인코더가 본 적 있는 분포가 들어간다. (이 정합이 깨지면 어떻게 되는지는 Part 4.5 Wave-F에서 뼈저리게 배운다.)

### 3.2 late-fusion — 1채널 backbone 고정
backbone은 1채널 입력으로 pretrain됐다. 멀티모달 task는 **모달별로 backbone을 따로 통과시킨 뒤 head/fusion에서 합친다**. 이게 finetune(seg)·frozen(Task6/7) 양쪽에서 일관되게 쓸 수 있는 유일한 구조다.

### 3.3 평가 프로토콜 — 결론을 좌우하는 부분
- **k-fold subject-disjoint CV + 3 seed + per-subject bootstrap CI**: n이 작아 단일 split의 분산이 크다. CV+CI 없이는 어떤 결론도 신뢰 불가.
- **`Δ-over-scratch` (또는 random)**: "사전학습이 *실제로* 도움이 되는가"는 동일 프로토콜의 from-scratch와 비교해야만 답할 수 있다. 절대 점수는 confound(위치·site)로 부풀 수 있다.
- seg는 **sliding-window 추론 + NSD(surface Dice)**로 전체 볼륨에서 정직하게 측정.

> ⚠️ 이 프로토콜이 왜 중요한지: 구 resize 전처리에서 trigeminal이 "+0.047 positive transfer"로 *보였지만*, 그건 scratch를 망가뜨려 생긴 아티팩트였다. proper 전처리로 scratch가 따라오자 사라졌다. **평가가 결론을 만든다.**

---

## Part 4. Task별 여정

### 4.1 brain age (reg, n=988→평가 494) — "손대지 않아도 되는 강한 신호"

- **결과**: finetune Pearson r **0.947** (frozen probe r 0.867, Δ-over-random **+0.326**, CI 완전 분리).
- **해석**: 우리 foundation의 **가장 명백한 가치**. InfoNCE-global이 전역 형태(morphometry) 표현을 진짜로 학습했다는 직접 증거. brain age는 뇌 전체의 위축·구조 변화를 읽는 과제라 global 벡터가 곧바로 통한다.
- **fine-tuning**: 특별한 트릭 불필요. 데이터가 충분(988)해서 from-scratch도 따라오지만(finetune Δ는 +0.037로 줄어듦), frozen probe에서 Δ+0.33이 나오는 것 = "표현이 좋다"는 증거.
- **교훈**: 데이터가 충분한 과제에서는 foundation의 *절대* 이득이 작아 보인다. 진가는 few-shot에서 드러난다(→ 4.2).

### 4.2 infarct (cls, n=42→21) — "few-shot에서 foundation의 진가"

- **결과**: finetune AUROC **0.942**, scratch 0.519 → **Δ +0.346**.
- **해석**: from-scratch가 *실패*하는(0.52, 거의 랜덤) 저데이터 영역에서 foundation이 0.94로 끌어올린다. **이게 foundation의 핵심 가치 = scratch가 못 하는 걸 해낸다.**
- **주의**: n=21이라 검정력이 부족하다(CI 넓음). 방향은 확실히 양수지만 절대치는 신뢰구간을 함께 봐야 한다.

### 4.3 polymicrogyria (cls, n=48) — "confound를 조심하라"

- **결과**: finetune AUROC 0.986 — *높아 보이지만* random encoder도 0.868.
- **해석**: 🔴 **대부분 site confound**. 표현의 질이 아니라 스캐너/사이트 신호를 읽고 있을 가능성이 크다. Δ-over-random이 +0.078로 작은 게 그 증거.
- **교훈**: 절대 AUROC는 거짓말을 한다. random 베이스라인이 confound를 드러낸다.

### 4.4 trigeminal (seg, n=80→40) — "clDice + frozen, 두 번의 도약"

가장 교훈이 많은 seg 여정. trigeminal nerve는 **얇은 관(tubular)** 구조다.

| 라운드 | 설정 | Dice | NSD | 비고 |
|---|---|---|---|---|
| R1 | tversky+bce, full-FT, 1mm | 0.413 | 0.786 | 기준 |
| R2 | 0.5mm 고해상 시도 | **0.000** | 0.000 | 🔴 crop128@0.5mm=64mm FOV로 축소 → localization 실패 |
| R3 | EMA+LLRD+**clDice** | **0.445** | **0.804** | ✅ clDice(연결성 loss)가 tubular에 적중 |
| Wave-E | **lowlr (encoder 보존)** | **0.450** | 0.796 | ✅ 절대 미세↑ + **Δ 폭발** |

**두 도약의 의미:**
1. **clDice (R3)**: 얇은 관은 일반 Dice로는 끊긴 예측을 벌하지 못한다. clDice는 **연결성(centerline)**을 직접 최적화 → tubular에 특화. (단 이건 pre·scratch 둘 다 올리는 *레시피* 개선.)
2. **frozen/lowlr (Wave-E) — 가장 중요한 발견**:
   - full-FT: Dice 0.445, scratch 0.41 → **Δ+0.03** (작아 보임)
   - **frozen: Dice 0.442, scratch 0.308 → Δ+0.134** / **lowlr: 0.450, scratch 0.308 → Δ+0.142**
   - 즉 **"Δ가 작다 = foundation이 seg엔 쓸모없다"는 full-FT 아티팩트였다.** full-FT에선 scratch도 encoder를 학습해 0.41까지 따라왔지만, **encoder를 보존(frozen)하면 scratch는 random encoder에 갇혀 0.308**. 우리 foundation prior가 **0.13만큼의 진짜 가치**를 한다. (VISTA3D가 1-shot에서 pre 0.795 vs scratch 0.185로 보인 패턴과 동일.)

> **이 발견이 design 문서 §10의 결론("dense/seg는 from-scratch 못 넘는다")을 뒤집는다.** 못 넘는 게 아니라, full-FT가 prior를 덮고 있었을 뿐이다.

### 4.5 meningioma (seg, n=46→23) — "가장 험난한 길, 그리고 데이터의 한계"

meningioma는 **경막 기반(extra-axial) blob** 종양. 가장 많은 실험을 쏟았고, 가장 많은 *부정적* 교훈을 얻었다.

| 라운드 | 설정 | Dice | 결론 |
|---|---|---|---|
| R1 | tversky+bce(β0.7), flair, 1mm | 0.127 | 기준 |
| R2 | 멀티모달 mean-fusion | 0.054 | 🔴 mean이 flair(정보 모달)를 dwi/t2s로 희석 |
| Wave-C | **고recall Tversky β0.8 + EMA** | **0.159** | ✅ best (+25%). 검출 누락이 병목 → FN 페널티↑ |
| Wave-D | learned-fusion (concat+1×1conv) | 0.121~0.129 | mean보단↑(0.05→0.13)이나 단일 flair 못 넘음 |
| Wave-E | frozen / lowlr | 0.086 / 0.078 | 🔴 full-FT보다 나쁨, Δ 소멸 |
| Wave-F | anisotropic z=3mm | 0.148 (Δ+0.078) | foundation 살아남으나 1mm-iso 못 넘음 |
| Wave-F | anisotropic z=5mm(~native) | 0.098 (Δ−0.018) | 🔴 domain shift로 pre<scratch |

**단계별로 무엇을 배웠나:**
1. **멀티모달은 men에 무익** (R2·Wave-D): 정보가 FLAIR에 집중(label/brain 밝기비 4.47로 실측). dwi/t2s는 노이즈만 추가. mean-fusion은 특히 해롭다. learned-fusion으로 살려도 단일 flair를 못 넘었다.
2. **고recall이 답** (Wave-C): median lesion 1205복셀인데 검출 자체를 놓치는 게 병목 → Tversky β0.8로 FN을 강하게 벌해 0.159 달성.
3. **frozen은 men엔 실패** (Wave-E): trigeminal과 정반대. lesion-detection은 형태학 prior로 풀리지 않아 **encoder를 task에 맞춰 풀어야(full-FT)** 한다. → **task-adaptive 처방**: tubular/anatomy=frozen, lesion=full-FT.
4. **anisotropic의 함정** (Wave-F): men은 native **z축 6.5mm thick-slice (8.2배 anisotropic)**. 기존 1mm-iso는 z를 5.2배 *가짜 upsampling*(label 복셀 3047→12867로 부풀림)하고 있었다 — 진단은 옳았다. 하지만 anisotropic으로 고치자 **domain shift의 정도가 결과를 갈랐다**:
   - **z=5mm (완전 native)**: foundation의 1mm-iso pretrain과 너무 멀어 prior가 죽음 → **pre 0.098 < scratch 0.116 (Δ−0.018)**.
   - **z=3mm (중간)**: shift가 덜해 foundation이 살아남음 → **Δ+0.078**. 그러나 절대값(0.148)이 1mm-iso(0.159)를 못 넘는다.
   - **→ anisotropic은 men에 순이득이 없다.** 가짜 z 제거의 득과 domain shift의 실이 상쇄. **교훈: downstream 전처리는 pretraining과 정합해야 한다 — "데이터에 최적인 전처리"와 "모델이 본 적 있는 분포"가 충돌할 수 있고, foundation을 쓰려면 후자가 이긴다.**

**정직한 결론**: men의 천장은 **n=23 few-shot + extra-axial blob + 8.2배 thick-slice**의 삼중고로 낮다(현실 상한 ~0.2-0.3 [VERIFY]). 0.159는 우리 foundation/레시피의 결함이 아니라 **challenge가 준 데이터의 본질적 한계**에 가깝다. trigeminal(0.5mm isotropic)이 0.45인데 men(6.5mm)이 0.16인 격차는 상당 부분 *해상도*가 가른다.

---

## Part 5. 누적 법칙 (이 여정이 증명한 것)

1. **Foundation 가치 = from-scratch가 *실패*하는 곳에서 가장 크다.**
   - few-shot cls(infarct Δ+0.35), encoder-보존 seg(trigeminal frozen Δ+0.14). 데이터 충분 reg(brainage)·confound(polymicro)에선 작다.
2. **"Δ가 작다 ≠ foundation 무용"** — full-FT는 scratch가 encoder를 학습해 따라오게 만들어 Δ를 가린다. **encoder를 보존(frozen/lowlr)하면 진짜 Δ가 드러난다.**
3. **task-adaptive 처방** — 만능 레시피는 없다.
   - tubular/anatomy(trigeminal) → frozen/lowlr + clDice
   - lesion/blob(meningioma) → full-FT + 고recall Tversky
4. **평가가 결론을 만든다** — 전처리·random/scratch 베이스라인·realistic 추론(sliding-window)이 바뀌면 결론이 뒤집힌다.
5. **전처리는 pretraining과 정합해야** — 데이터에 최적인 전처리(anisotropic)가 모델 분포와 어긋나면 foundation을 못 쓴다.
6. **멀티모달·고해상이 항상 좋은 게 아니다** — 0.5mm(FOV 축소)·멀티모달 mean(정보 희석)은 오히려 해로웠다.

---

## Part 6. 방법론 메타 (어떻게 신뢰를 쌓았나)

- **code-auditor를 매 라운드 호출** — silent no-op clDice 버그, EMA bias, learned-fusion의 EMA 누락, anisotropic의 데이터 가정(thick축 검증)·cross-spacing 비교 무효 등 **결과를 무효화할 버그를 실행 *전*에 다수 적발**. "코드가 안 깨진다"와 "결과가 맞다"는 별개.
- **ablation은 한 번에 하나씩** — R3 초기 5개를 한꺼번에 바꿨다가 men이 붕괴하고 원인 귀속이 불가능했다. 이후 one-at-a-time으로 전환.
- **끊김 생존(setsid+nohup)** — 모든 장기 실험을 detach 실행해 ssh/세션과 무관하게 진행. waiter로 완료 감지.
- **생성과 검증의 분리** — 자기평가 편향을 피하려 결과 판정에 독립 에이전트(code-auditor)와 동일-프로토콜 scratch 대조를 강제.

---

## Part 7. 현재 최종 결과 + 다음

### seg 최종 (리더보드 50% 비중)
| task | best 레시피 | Dice | NSD |
|---|---|---|---|
| trigeminal | **lowlr + clDice + EMA** | **0.450** | 0.796 |
| meningioma | **full-FT + Tversky β0.8 + EMA** | **0.159** | 0.137 |

### cls/reg
| task | best | Δ-over-scratch |
|---|---|---|
| brain age | r 0.947 | +0.037 (frozen Δ+0.33) |
| infarct | AUROC 0.942 | +0.346 |
| polymicro | 0.986 | confound (Δ+0.08) |

### 남은 작업
- **S5**: Task6/7 embedding 컨테이너 + fairness
- **S6**: 제출 컨테이너 (Apptainer, torch2.11/cuda12.6)
- **S7**: 내부 CV 최종 선정

> **한 줄 요약**: 우리 foundation은 **형태학(brain age)과 few-shot(infarct), 그리고 encoder를 보존한 tubular seg(trigeminal)**에서 명백한 가치를 증명했다. lesion-detection(meningioma)은 데이터 자체의 한계(few-shot + thick-slice)가 천장을 결정한다 — 이건 모델이 아니라 시험 문제의 성질이다.

---

*재현: downstream 코드 `downstream/`(core.py·eval_finetune.py·eval_global.py·seg_v2.py·seg_v3.py·eval_seg.py), 실험 오케스트레이션 `downstream/run_r3_wave*.sh`, 전체 비교 `experiments/phase_b/downstream_runs/COMPARISON.md`. foundation 해부는 `docs/foundation_model_design.md`.*
