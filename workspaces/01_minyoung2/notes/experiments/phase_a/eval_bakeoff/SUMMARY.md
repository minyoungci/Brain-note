# Phase A 4-arm bake-off — 결과 요약 (2026-06-23)

OAT, 동일 예산: ViT-S(dim384/depth8) 또는 ResEnc-L, 동일 4000 anat subset, 8000 step, crop96.
frozen-encoder probe(eval v2): cls/reg=global linear probe(AUROC/pearson, Δ-over-recipe별-random),
seg=1×1-conv 선형 probe 진짜 Dice(Δfloor, floor=position-only). **bootstrap 95% CI 전 task.**

## 결과 (trained [CI]; reg/cls는 Δ-over-random, seg는 Δfloor)
| arm | infarct cls (n21) | brainage reg (n200) | polymicro cls (n48) | meningioma seg (n23) | trigeminal seg (n40) |
|---|---|---|---|---|---|
| vit_mae(R0) | 0.404 [.134,.663] | 0.498 [.368,.599] | 0.927 [.844,.985] | Δf+0.053 [.011,.109] | 0 |
| vit_ibot | 0.462 [.194,.731] | 0.566 [.448,.664] | 0.958 [.897,.997] | Δf+0.045 [.008,.093] | 0 |
| vit8_mae | 0.510 [.224,.769] | **0.640 [.549,.722]** | 0.965 [.912,.998] | Δf+0.040 [.006,.082] | 0 |
| resenc_mae | 0.423 [.153,.714] | 0.368 [.239,.489] | 0.943 [.872,.990] | Δf+0.001 [0,.004] | 0 |
| (random ViT 참고) | ~0.27–0.57 | ~0.25–0.36 | **~0.97** | 0.000 | 0 |
| resenc crop128 | — | — | — | Δf+0.003 | 0 |

## 판정 (CI 적용, research-critic 검증 반영)
- **infarct cls**: 전 arm CI가 chance(0.5) 포함 → **신호 없음**(n=21 underpowered). vit8 "승리"는 허상(F1).
- **polymicro cls**: random ViT도 0.97(site/intensity confound 지배) → recipe 구별 0. **제외**(M4).
- **brainage reg (유일 검정력)**: vit8 0.640 ≈ vit_ibot 0.566 > vit_mae 0.498 > resenc 0.368. vit8·ibot·resenc 자기-random과 비겹침(유의); **vit8 > resenc 유의**. vit8 vs ibot/vit_mae는 CI 겹침(무구별).
- **meningioma seg**: ViT 3종 Δf+0.04~0.05(CI>0 실질, 상호 무구별). resenc ≈0 — **단 broken run이라 무효**.
- **trigeminal**: 전 arm·crop128 0 → frozen+선형 probe 측정 불가(해상도/probe 한계).

## 핵심 결론
- **확립**: 건강한 ViT-MAE-family arm이 reg(실질)+meningioma-seg(소량 실질)를 학습. reg서 vit8/ibot 선두, resenc보다 유의 우위.
- **미확립(=Phase B 전 필수)**: ① cls 전부 무정보(underpowered/confound) ② trigeminal 측정 불가 ③ **CNN-seg 미검증**(resenc broken: t_ent 1.0 global 미engage + MAE loss 8.2→7.13 거의 정지; ViT는 같은 DINO로 정상; seg probe도 coarse bottleneck만 씀, skip 미추출).
- **vit8_mae = reg-주도 선두 후보일 뿐, 검증된 3-type Pareto 승자 아님.** 어떤 arm도 Phase B 커밋 불가(critic).

## Phase B 전 보완 (critic 권고, 우선순위)
1. ✅ cls/reg bootstrap CI (구현·재평가 완료).
2. resenc 학습 실패 진단·수정(lr/scale/recon) → 수렴 재학습 (CNN-seg 검증 전제).
3. eval가 ResEnc 고해상 skip feature 추출 → CNN의 진짜 seg 능력 측정.
4. 고해상/shallow-nonlinear seg probe → trigeminal 측정가능성 + arm 판별력.
5. probe↔finetune 상관 측정 → frozen probe가 리더보드(finetune)를 예측하나.

## seg-finetune 결과 (2026-06-23) — frozen encoder + fresh skip-decoder few-shot, 진짜 Dice
n_seed=3, epochs40, bs2, k4. Δrand = Dice(trained) − Dice(random encoder, 같은 decoder).
| arm | meningioma Dice[CI] | random_enc | Δrand | trigeminal Dice | trig Δrand |
|---|---|---|---|---|---|
| vit_mae | 0.053[.011,.111] | 0.065 | -0.012 | 0.004 | -0.006 |
| vit_ibot | 0.036[.003,.084] | 0.065 | -0.029 | 0.011[.004,.018] | +0.001 |
| vit8_mae | 0.062[.012,.131] | 0.056 | +0.006 | 0.004 | +0.004 |
| resenc | 0.034[.017,.053] | 0.012 | +0.022 | 0.000 | 0.000 |

### 판정 (리뷰어② gate: dice_random_enc 함께)
- **ViT encoder seg 기여 ≈ 0 (C1 실측 확정)**: ViT random_enc(0.056~0.065) ≥ trained → conv-stem raw-input skip이 seg를 수행, pretrained ViT 토큰 기여 없음(Δrand ≤ 0). ViT seg = decoder+영상skip 아티팩트.
- **resenc만 encoder가 seg에 실제 기여**: random_enc 0.012(낮음, ResEnc random skip 무정보) → trained 0.034, Δrand +0.022(최대), CI 최협. CNN-seg 가설 첫 긍정 증거.
- **trigeminal 전 arm 측정불가**(skip-decoder로도; ViT 0.011도 skip-주도 Δrand+0.001).
- 절대 Dice는 ViT(raw-skip) vs ResEnc(encoder-skip) decoder 비대칭이라 직접 비교 불가(C2).

### thesis 함의
ViT=global(reg 최고)·dense(seg) 기여0 / resenc=dense(seg) 기여양수·global 사망 →
**단일 encoder가 global+dense 동시 Pareto-good인 arm 이 스케일서 없음** = II+III thesis의 task-type trade-off 실증.

### ⚠️ 미검증 (Phase B 전 필수, 리뷰어② W3): frozen-encoder Dice가 full-finetune 리더보드 랭킹 예측하나.
"ViT seg 기여 0"이 *frozen* 한정인지(full-finetune서 encoder 적응하면 바뀔 수도) 상위 arm full-finetune로 확인 필요.

## W3 full-finetune 결과 (2026-06-23) — pretrained vs from-scratch, meningioma n=23
encoder+decoder full-finetune(enc_lr1e-4/dec1e-3, epochs40, k4, n_seed2). Δ = Dice(pretrained) − Dice(scratch=random-init full-FT).
| arm | pretrained Dice[CI] | scratch Dice[CI] | Δ(pre−scratch) | frozen Dice(참고) |
|---|---|---|---|---|
| vit_mae | 0.030[.002,.077] | 0.055[.006,.133] | -0.025 | 0.053 |
| vit8_mae | 0.080[.000,.188] | 0.069[.000,.156] | +0.011 | 0.062 |
| resenc | 0.035[.008,.069] | 0.087[.024,.165] | -0.051 | 0.034 |

### 판정
- **사전학습이 seg full-finetune서 scratch를 못 이김**(2/3 음수, vit8 +0.011은 CI가 0 포함=노이즈). scratch resenc 0.087이 최고.
- "ViT-seg 기여 0"은 frozen 아티팩트가 아님 — full-FT서도 pretrained≤scratch (frozen+finetune 두 방법 일치).
- ⚠️ n=23 few-shot CI 거대(전부 ~0 걸침) → 작은 seg 이득은 원리적 검출 불가 + 사전학습 약함(스크리닝 스케일). "이득 0"인지 "검출 불가"인지 단정 못 함.
- **공통**: 현재 SSL은 reg엔 이득(frozen Δ+0.2)·seg엔 입증 불가/음수. **내부 seg eval은 n=23로 검정력 부족 → seg recipe 선택을 내부지표로 신뢰 불가.**

### 함의
seg-50% 축에서 사전학습 가치 미입증 → ① 구조(Swin 계층=dense feature) ② dense SSL 강화 ③ 스케일(Phase B) 검증 중 택. seg 결정은 원리·문헌·챌린지 3회 검증에 의존.
