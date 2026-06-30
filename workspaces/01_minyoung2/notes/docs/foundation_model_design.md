# 우리 3D Brain MRI Foundation Model — 설계 해부 (gradient가 실제로 어디로 흐르는가)

> 대상: FOMO26 (MICCAI 2026) 단일 체크포인트 foundation model.
> 이 글은 "그림으로 보는 개요"가 아니라 **코드(`pretrain/models.py`, `pretrain/train.py`)에서 한 줄씩 검증한** 데이터·gradient 흐름 해설이다.
> 모든 수식·흐름은 실제 학습 루프와 일치한다. 그림은 `figures/modules/`.
>
> 📎 **이 문서는 foundation 모델 *자체*의 해부다.** 그 foundation을 7개 downstream 과제에 *어떻게 fine-tuning*했고 어떤 실험을 거쳤는지의 여정은 [`downstream_finetuning_journey.md`](downstream_finetuning_journey.md), Task2 men 저성능 원인 진단은 [`men_task2_diagnosis.ipynb`](men_task2_diagnosis.ipynb)에 있다.
> §10 downstream 결과는 **R3~Wave-I까지 반영된 최신 수치**다 (초기 full-FT 측정의 "seg=한계" 결론은 정정됨 — §10 이력 참조).

---

## 0. 한 문장 요약

> **하나의 ResEnc CNN U-Net 인코더가, 같은 뇌 볼륨에서 뜬 두 개의 랜덤 crop을 받아, (1) 가려진 복셀을 복원하는 dense 과제와 (2) EMA-teacher가 만든 표현을 대조로 맞히는 global 과제를 *동시에* 풀며 학습한다. dense loss는 인코더+디코더를, global loss는 인코더+풀링헤드를 학습시키고, teacher는 gradient 없이 student의 EMA로만 따라온다.**

핵심 설계 결정 3가지(뒤에서 각각 "왜"를 설명):
1. **백본 = ResEnc-L CNN U-Net** (ViT 아님) — 3D 의료 seg SOTA이고 우리 frozen-probe에서 encoder가 실제로 dense에 기여한 유일 백본.
2. **global 목적함수 = InfoNCE (대조학습)** — DINO/sinkhorn self-distillation은 CNN+SimPool에서 *붕괴(collapse)*했고, negative가 있는 InfoNCE만 살아남았다.
3. **dense 목적함수 = S3D식 submanifold masked-conv MAE** — skip을 켜고도 마스크 누수가 0이라, seg로 전이 가능한 고해상 디코더 feature를 사전학습한다.

---

## 1. 큰 그림: student–teacher 이중 과제

```
                       같은 볼륨에서 랜덤 crop 2개
                          ┌────────── v1 (마스킹) ──────────┐         ┌─ v2 (비마스킹) ─┐
                          ▼                                  │         ▼
   ┌──────────────────────────────────────────────┐         │   ┌────────────────────┐
   │  STUDENT (gradient O — 실제로 학습되는 쪽)        │         │   │ TEACHER (gradient X) │
   │  ResEnc encoder ─┬─► bottleneck ─► S3D decoder │         │   │  = student의 EMA      │
   │                  │                  │ recon     │         │   │  (decoder 제외)       │
   │                  └─► SimPool ─► proj head        │         │   │  SimPool ─► proj head │
   └──────────────────────────────────────────────┘         │   └────────────────────┘
            │ L_dense (복원 MSE)        │ L_global (InfoNCE 대조)        │
            ▼                           └──────────────┬───────────────┘
      encoder+decoder 학습                           encoder+SimPool+head 학습
                                                        │
                          teacher ◄── EMA(m=0.996) ── student (매 step)
```

- **student**: 모든 gradient를 받고 optimizer가 업데이트하는 "진짜" 모델. 우리가 마지막에 저장·배포하는 것은 student다.
- **teacher**: gradient를 *전혀* 받지 않는다. 매 step 끝에 student 파라미터의 지수이동평균(EMA, m=0.996)으로만 갱신된다. teacher의 역할은 global 과제의 *타깃*(맞혀야 할 정답 표현)을 제공하는 것.
- 두 과제는 한 번의 `backward()`로 합산되어 흐른다: `L = 1·L_dense + 0.5·L_global` (+ 0.1·KoLeo). 이 가중치가 우리가 고른 체크포인트 **wg0.5**의 값이다.

---

## 2. 모듈 ① — 입력과 두 개의 view

![입력](figures/modules/mod_01_input_views.png)

**오프라인 전처리 (yucca 4-step, 사전학습·downstream 동일)**: 원본 MRI → `crop_to_nonzero`(배경 잘라냄) → `volume_wise_znorm`(클램프→z-norm→[0,1] 재스케일) → **1mm 등방 리샘플 + RAS 정렬** → float16 `.npy`. *두개골 제거(skull-strip)는 하지 않는다* — yucca 표준은 crop_to_nonzero까지다.

**온라인 (학습 중, `data.py::TwoCropDataset`)**:
- 한 볼륨에서 **랜덤 96³ crop을 2번** 뜬다 → `v1`, `v2`. 둘은 *같은 뇌의 다른 위치*다.
- 각 crop을 다시 z-norm(`_znorm`).
- **강도 증강·회전·플립은 없다.** 두 view의 유일한 차이는 *crop 위치*다. (이게 global 과제의 불변성 신호가 된다: "같은 뇌의 다른 부분도 같은 표현이어야 한다".)

> 코드: `(gl[0], gl[1])` 반환 = 두 글로벌 crop. `_rand_crop(v, 96, rng)`가 서로 다른 rng draw로 위치를 정한다.

학습 텐서 모양: `v1, v2 : (B, 1, 96, 96, 96)`. 단일 채널.

---

## 3. 모듈 ② — 블록 마스킹 (dense 과제의 입력 만들기)

![마스킹](figures/modules/mod_02_block_masking.png)

dense(MAE) 과제는 v1의 일부를 가리고 복원시키는 것이다.

- 96³를 **16³ 복셀 블록**으로 나눈다 → grid `6×6×6 = 216`개 블록.
- 그 중 **60%(=약 129개)를 무작위로 가린다**(`mask_ratio=0.6`, `mask_block=16`). step-keyed 결정적 RNG라 resume해도 같은 마스크.
- 마스크 텐서 `mvox : (B,1,96³)` (1=가림). `v1m = v1 * (1 - mvox)` = 가려진 입력.

> 코드: `block_mask(step,...)` → `mvox` → `v1m = v1*(1-mvox)`. 가려진 영역이 복원 타깃이 된다.

---

## 4. 모듈 ③ — ResEnc-L 인코더 + submanifold (여기서 표현이 만들어진다)

![인코더](figures/modules/mod_03_encoder_submanifold.png)

**구조** (`ResEncUNet`, `chans=(32,64,128,256,320)`, `blocks=(1,2,2,2,2)`):
- stem: `Conv3d(1→32, 3³)`.
- 5 stage, stage1만 stride1, 나머지 stride2 → 공간 `96³→48³→24³→12³→6³`, 채널 `32→64→128→256→320`.
- bottleneck = `320 × 6³` (=216 토큰 × 320차원).
- ResBlock = `Conv3³→InstanceNorm→GELU→Conv3³→IN→(+1³ skip)→GELU`.

**submanifold masked-conv (S3D식, 우리가 자체 구현 — `forward_masked`)**:
일반 conv로 마스크 영역을 처리하면 *인접한 보이는 복셀이 가려진 곳으로 새어 들어가* MAE가 trivial해진다(누수). 이를 막기 위해:
```
x = stem(x * vis) * m              # ① 입력을 먼저 마스킹(stem이 원본 못 봄) + stem 후 가린 곳 0으로
for i, stage in enumerate(enc):
    if i>0: m = max_pool3d(m, 2)    # ② 마스크도 같이 다운샘플(자식 중 보이는 게 있으면 visible)
    x = stage(x) * m                # ③ 매 stage 후 가린 위치 다시 0 (정보가 visible manifold에만 머묾)
```
→ **검증된 성질**: 가려진 영역의 입력값을 +100 바꿔도 복원 출력 차이 = `0.000` (누수 완벽 0). 그래서 skip을 켜고도(=고해상 디코더 feature) 누수 없이 사전학습할 수 있다.

**이 인코더가 받는 gradient**: dense loss(L_d)와 global loss(L_g) **둘 다**. 즉 인코더는 *공유 트렁크*로서 "복원에 필요한 국소 디테일"과 "대조에 필요한 전역 표현"을 동시에 배운다. (downstream에서 우리가 떼어 쓰는 게 바로 이 인코더다.)

---

## 5. 모듈 ④ — S3D 디코더 & dense 복원 손실 (L_dense)

![디코더](figures/modules/mod_04_s3d_decoder.png)

- bottleneck `320×6³` → `ConvTranspose3d + ResBlock` ×4, 각 단계에서 **인코더 skip을 concat** (Stage1~4: `256×12³ / 128×24³ / 64×48³ / 32×96³`) → recon head `Conv3d(32→1)` → 복원 `(B,1,96³)`.
- **손실**: 가려진 복셀에서만 MSE.
```python
rec = student.recon(s_out, v1m)            # = backbone의 디코더 출력(s3d masked recon)
L_d = ((rec - v1)**2 * mvox).sum() / (mvox.sum()+1e-6)   # 마스크 복셀만 평균
```
(타깃은 마스킹 *전*의 v1. mvox로 가린 곳만 센다.)

**gradient 흐름 (중요)**:
> `L_d` → **디코더(backbone.dec + backbone.head)** *그리고* → skip·bottleneck을 거쳐 **인코더(backbone.stem + backbone.enc)**.
>
> 즉 **dense loss는 인코더와 디코더를 둘 다 학습**시킨다. 디코더는 *오직* 이 loss에서만 gradient를 받는다(global·koleo는 디코더로 안 흐름).

> 설계 포인트: 이 디코더는 student 전용이다. teacher EMA 대상에서 **decoder를 제외**한다(아래 §7). 복원기는 "정답"이 필요 없는 부분이라 teacher에 둘 이유가 없고, 대조 타깃만 안정적으로 주면 된다.

---

## 6. 모듈 ⑤ — SimPool + projection head (global 벡터 만들기)

![SimPool](figures/modules/mod_05_simpool_head.png)

CNN은 ViT의 CLS 토큰이 없으므로, bottleneck feature map을 한 벡터로 모으는 학습형 풀링이 필요하다.

- **SimPool** (ICCV'23): bottleneck `(B,320,6,6,6)` → flatten `(B,216,320)` → LayerNorm → 학습형 query 1개로 MultiheadAttention 풀링 → `(B,320)` global 벡터 `s_gvec`.
- **projection head** (`DINOHead`, MLP `320→2048→2048→256` → L2-norm → weight-norm prototype `1024`):
```python
x = F.normalize(self.mlp(x), dim=-1)         # 256-d L2 정규화 bottleneck
w = F.normalize(self.proto.weight, dim=1)    # prototype 행도 L2 정규화 → 입력 magnitude 불변
return F.linear(x, w)                         # cosine logits (B,1024)
```
→ `s_gproj : (B, 1024)`.

**gradient 흐름**: `L_g`(+koleo) → **DINOHead → SimPool → 인코더**. 디코더로는 안 흐른다. 즉 SimPool과 head는 *오직 global 과제*에서만 학습된다.

> 왜 magnitude-불변 head인가: CNN+SimPool의 출력 크기가 작아 일반 head는 부트스트랩이 어려웠다. L2-norm + weight-norm prototype이 입력 크기에 불변이라 collapse 저항에 *필요*했다(충분조건은 아니었고 — 그게 다음 모듈의 InfoNCE 이유다).

---

## 7. 모듈 ⑥ — InfoNCE 대조 + EMA teacher (global 손실 L_global)

![InfoNCE](figures/modules/mod_06_infonce_ema.png)

global 과제: "student가 v1에서 만든 표현이, teacher가 v2에서 만든 *같은 뇌의* 표현과 맞아야 한다."

```python
with torch.no_grad():                          # teacher는 gradient 없음
    t_out  = teacher.forward_backbone(v2)
    t_gproj = teacher.global_proj(t_out)        # (B,1024)
sn = F.normalize(s_gproj, dim=-1)               # student(v1)
tn = F.normalize(t_gproj, dim=-1)               # teacher(v2)
L_g = F.cross_entropy(sn @ tn.t() / 0.1, arange(B))   # 대각=positive, 나머지=negative, temp 0.1
```
- 유사도 행렬 `sn @ tn.T` (B×B): **대각선 = positive**(같은 볼륨의 v1↔v2), **나머지 = negative**(배치 내 다른 볼륨). temperature 0.1.
- cross-entropy로 "내 짝(대각)을 골라라"를 학습 → student 인코더+SimPool+head가 *배치 내에서 구별되는* 표현을 만들도록 압박.

**왜 DINO가 아니라 InfoNCE인가 (핵심 발견):**
> ResEnc+SimPool에서 **DINO·sinkhorn·high-koleo·w_global×5·격리(global-only)를 5연속 시도했는데 전부 붕괴**했다 (L_g가 ln(1024)=uniform에 고정, teacher entropy 1.0, student가 모두 같은 표현). EMA-teacher self-distillation이 CNN-SimPool에서 부트스트랩에 실패한 것.
> **negative가 있는 대조(InfoNCE)로 바꾸니 살아났다** (L_g 2.75→1.27, teacher가 판별적으로). negative가 "모두 같은 표현으로 뭉개기"를 *원천 차단*한다. → 이것이 우리 global 과제가 InfoNCE인 이유다.

**teacher 갱신 (EMA, gradient 아님)**:
```python
ema_update(teacher, student, ema_names, m=0.996)   # 매 step
```
`ema_names` = **인코더 + global(SimPool+head)** 만. **decoder(backbone.dec/head)는 제외** → teacher는 복원기를 갖지 않는다(불필요). teacher = student의 느린 평균이라, student가 따라갈 안정적·일관적 타깃을 제공한다.

---

## 8. 전체 gradient 흐름 — 한눈에 (이 글의 핵심)

한 step에서 `(L + 0.1·KoLeo).backward()` 한 번으로 모든 gradient가 흐른다. `L = 1·L_dense + 0.5·L_global`.

| 파라미터 그룹 | L_dense (복원 MSE) | L_global (InfoNCE) | KoLeo | 어떻게 갱신되나 |
|---|:---:|:---:|:---:|---|
| **인코더** stem+enc | ✅ | ✅ | ✅(간접) | optimizer (student) |
| **디코더** dec+head (복원) | ✅ | ✗ | ✗ | optimizer (student) |
| **SimPool** 풀링 | ✗ | ✅ | ✅ | optimizer (student) |
| **proj head** (DINOHead) | ✗ | ✅ | ✗ | optimizer (student) |
| **teacher 전체** | ✗ | ✗ | ✗ | **EMA(m=0.996), gradient 0** (decoder 제외) |

읽는 법:
- **인코더는 두 과제의 교차점**이다 — 복원이 요구하는 국소 텍스처와, 대조가 요구하는 전역 판별성을 *동시에* 흡수한다. downstream에서 떼어 쓰는 게 이 부분.
- **디코더는 복원 전용**(L_dense만). S3D 누수0 덕분에 이 디코더 feature가 seg로 전이 가능한 형태로 학습된다.
- **SimPool+head는 global 전용**(L_global+KoLeo). cls/reg downstream에서 쓰는 global 벡터의 출처.
- **teacher는 학습되지 않는다.** 오직 global 타깃 공급기. backward가 teacher로 흐르지 않도록 teacher forward는 전부 `torch.no_grad()`.

**KoLeo 정규화** (`koleo_w=0.1`): `koleo_loss(s_gvec)` = 배치 내 각 임베딩의 *최근접 이웃 거리*를 키우는 미분가능 항. 임베딩이 서로 퍼지게 해 collapse에 추가 저항. SimPool+인코더로 흐른다.

```python
opt.zero_grad()
(args.w_dense*L_d + args.w_global*L_g + args.koleo_w*koleo_loss(s_gvec)).backward()  # wg0.5: 1·L_d + 0.5·L_g + 0.1·koleo
opt.step()                                   # student 전 파라미터 갱신
ema_update(teacher, student, ema_names, 0.996)   # teacher = student의 EMA(decoder 제외)
```

> 부가 안정장치: `center`(DINO 모드의 centering), `dcenter`(iBOT 모드)는 우리의 InfoNCE/S3D recipe에서는 *사용하지 않는다*(코드에는 다른 recipe 대비 남아있음). `monitor`가 매 step embedding std·rankme·teacher entropy를 보고 붕괴 조짐이면 STOP.

---

## 9. 체크포인트 선택 — 왜 wg0.5인가

w_global을 0/0.5/1.0으로 셋 학습(각 150k step, 코퍼스 221,376) 뒤 downstream으로 비교:
- **w_global=0 (pure, dense만)**: global 표현이 약함(brainage·infarct 최악).
- **w_global=1 (full)**: global 압력 과해 일부 과제 저하.
- **w_global=0.5 (wg0.5)**: 검정력 있는 brainage·infarct에서 최고, 어느 축도 무너지지 않는 **Pareto sweet spot** → 단일 제출 체크포인트로 채택.

---

## 10. 이 모델이 *실제로* 배운 것 — downstream 검증 (Δ-over-random/scratch)

설계를 아는 것과, 그 설계가 *무엇을 학습했는지*는 다르다. proper 전처리(yucca)로 정직하게 측정한 **최신 결과(R3~Wave-I 반영)**:

| downstream | 지표 | 사전학습 | 베이스라인 | Δ | 해석 |
|---|---|---|---|---|---|
| **brain age** (reg, n=494) | pearson | **0.867** | random 0.541 | **+0.326** (CI분리) | ✅ **강한 진짜 신호** (global morphometry) |
| **infarct** (cls, n=21) | AUROC | **0.942** ⚠️ | scratch 0.596 | **+0.346** | ✅ 내부선 강하나 ⚠️ **실제 hidden=0.658**(아래) |
| **trigeminal** (seg, n=40) | Dice | **0.450** | scratch(frozen) 0.308 | **+0.142** | ✅ **encoder 보존시 명백** (full-FT의 +0.011은 아티팩트) |
| meningioma (seg, n=23) | Dice | 0.159 | scratch 0.107 | +0.052 | 🟡 **데이터 한계**(thick-slice 6.5mm·n23, 모델 아님 — `men_task2_diagnosis.ipynb`) |
| polymicrogyria (cls, n=48) | AUROC | 0.946 | random 0.868 | +0.078 | 🔴 대부분 site confound |

**무엇을 말하나:**
- **세 축에서 foundation 가치가 명확하다**: ① global morphometry(brain age, InfoNCE-global이 전역 구조 학습) ② few-shot cls(infarct, scratch가 실패하는 저데이터서 강함) ③ tubular/anatomy seg(trigeminal, encoder 보존시 Δ+0.14). → **"1개만 되는 모델"이 아니다.** 구조가 결함이면 이 셋부터 random 수준이어야 한다.
- **정밀 법칙: foundation 가치 = from-scratch가 *실패*하는 곳에서 크다.** few-shot(infarct)·encoder-보존 미세구조 seg(trigeminal). 데이터 충분 reg(brain age도 finetune시 Δ붕괴)·confound(polymicro)에선 작아 보인다.
- **"안 되는" task는 구조 결함이 아니라 task별 다른 원인**이다 — meningioma=데이터 한계(thick-slice·few-shot, ipynb로 인과 진단), polymicro=site confound(random도 0.87). 구조가 원인이면 *모든* task가 같은 방식으로 실패해야 하나, 그렇지 않다. **같은 구조가 trig 0.45 vs men 0.159 = 차이는 데이터, 모델 아님.**
- **task-adaptive 처방**: tubular/anatomy seg는 frozen/lowlr(foundation prior 보존), lesion seg는 full-FT. 만능 단일 레시피는 없다.
- 방법 교훈: **전처리·random/scratch 베이스라인·encoder 보존 여부가 결론을 바꾼다.** ① 구 resize 전처리의 trigeminal "+0.047"은 scratch를 망가뜨린 아티팩트. ② full-FT의 seg Δ≈0도 아티팩트(scratch가 encoder까지 학습해 따라옴) — frozen하면 진짜 Δ가 드러난다.
- ⚠️ **내부 지표 ≠ hidden 지표 (제출 전 필독)**: infarct(T1) 내부 LOOCV는 0.942지만 **실제 Synapse hidden validation AUROC = 0.658**(n21 full-FT 과적합). v2_frozen 경로(frozen-encoder + linear, dwi+adc+flair mean, C=0.3)도 LOOCV 0.942이나 **hidden 미검증**. n이 작은 cls(T1 n21·T5 n48)는 내부 점수를 hidden 성능의 증거로 쓰지 말 것. → `Challenge_Submission/Submission.md`, [[fomo26-submission-container]].
- ℹ️ **frozen-probe 수치 갱신(2026-06-29, `Flagship/AAAI/results/d2_probe`)**: 위 표 brainage/polymicro 행은 06-25 `downstream_feat` probe 기준이다. 최신 d2_probe(동일 n)는 random floor가 더 낮아 Δ가 더 크다 — **brainage wg0.5 0.792 vs random 0.137 (Δ+0.656)**, **polymicro 0.957 vs random 0.608 (Δ+0.349, w_global 단조증가 → confound 재확인)**. 결론(brainage=강한 신호, polymicro=confound)은 불변, 마진만 갱신.

> ### 이력 (정정 경위)
> 이 표의 **초기 버전**(2026-06-25)은 full-finetune 기준이라 trigeminal Δ+0.011·meningioma Δ+0.005로 "seg는 from-scratch 못 넘음 → global유용/dense한계 Pareto"로 결론했었다. **그 프레임은 폐기됐다**: Wave-E(encoder 보존)에서 trigeminal scratch가 0.421→0.308로 주저앉아 Δ+0.14가 드러났고(full-FT는 scratch도 encoder 학습해 Δ를 가렸음), meningioma는 Wave-I controlled ablation으로 데이터 한계임이 규명됐다. 전체 여정·수치는 [`downstream_finetuning_journey.md`](downstream_finetuning_journey.md), men 진단은 [`men_task2_diagnosis.ipynb`](men_task2_diagnosis.ipynb).

---

## 11. 설계 결정 요약 (왜 이렇게 만들었나)

| 결정 | 이유 (검증 근거) |
|---|---|
| ResEnc CNN U-Net 백본 | 3D 의료 seg SOTA(nnU-Net Revisited·S3D·OpenMind) + frozen-probe서 encoder가 seg에 기여한 유일 백본(Δrand+0.022) |
| global=InfoNCE | DINO/sinkhorn 등 self-distill 5연속 붕괴 → negative 대조만 부트스트랩 성공 |
| dense=S3D submanifold masked-conv | skip 켜고 누수0(검증: recon 차 0.000) → seg-전이 가능한 디코더 feature 사전학습 |
| teacher EMA서 decoder 제외 | 복원기는 student 전용, teacher는 global 타깃만 안정 공급 |
| L2-norm/weight-norm head | CNN+SimPool 저-magnitude 출력서 collapse 저항(필요조건) |
| w_global=0.5 | brainage·infarct 최고 + 전 축 안정 = Pareto sweet spot |

---

*재현: 아키텍처 `pretrain/models.py`(`ResEncUNet`·`SimPool`·`DINOHead`·`build_models`), 학습 루프 `pretrain/train.py`(loss·backward·`ema_update`), 전처리 `preprocessing/preprocess_fomo300k.py`(yucca 4-step). 모듈 그림 `figures/modules/`. downstream 검증 `downstream/eval_global.py`·`eval_seg.py`.*
