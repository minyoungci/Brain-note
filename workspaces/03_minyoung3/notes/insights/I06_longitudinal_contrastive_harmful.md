# I06 — longitudinal same-subject contrastive는 진행 task에 해롭다 (invariance-to-progression)

## 무엇을 시도했나
소데이터 종단 3D 표현학습: same-subject contrastive SSL(한 피험자의 두 시점 스캔 = positive) +
tabular privileged-info fusion. frozen-probe로 amyloid/전환/진행 평가.

## 어디서/왜 (실패 지점 + 결정적 control)
- **M1 control (augmentation-only single-timepoint contrastive vs longitudinal-pair)**: aug-only가
  **세 task 모두에서 longitudinal-pair를 능가**(amyloid 0.620>0.587, conv 0.530>0.459, prog
  0.580>0.531). 즉 longitudinal pairing이 표현을 **악화**.
- **원인**: 같은 피험자의 건강↔진행 스캔을 positive로 끌어당기면 인코더가 **진행 변화에 invariance**를
  학습 → 정작 검출하려는 신호(atrophy/진행)를 파괴. 이전 I01의 "contrastive scale/cutout aug가
  atrophy 신호 해침"과 동일 메커니즘.
- **F5 permutation**: conv의 amyloid-fusion 이득(+0.101 유의)이 permuted-aux에서 +0.054(미유의)로
  반감 → 절반은 distributional regularization, 절반만 생물학. proper baseline(aug-only) 대비 잔여
  이득 ~+0.030(미유의).
- **천장**: 어떤 SSL/fusion 표현도 matched-morphometry(amyloid 0.673/conv 0.571/prog 0.656) 못 넘음.
- **평가 설계 결함**: pair로 학습하고 **baseline 단일 스캔으로 probe** → 종단 신호를 평가에서 버림.

## 재사용 가능한 인사이트
1. **진행/변화를 검출하려는 task에 same-subject contrastive(invariance) SSL을 쓰지 마라.** 그건
   변화에 invariance를 학습해 신호를 지운다. → 올바른 종단 SSL은 **변화/궤적을 모델링**(LSSL/LNE식
   progression-direction), invariance가 아님.
2. **종단으로 학습했으면 평가도 종단 입력을 써라**(baseline 단일 스캔 probe는 종단 이점을 버림).
3. **control 없이는 "X가 도움"을 주장하지 마라**: aug-only(proper baseline) + permutation(F5)이
   "fusion 이득"의 대부분을 noise/regularization으로 환원시켰다. baseline이 sub-chance면 그 위의
   "이득"은 baseline 복구일 뿐.
4. **모든 paired delta는 subject-bootstrap CI로.** 2-seed std는 optimization noise만 재고
   test-sampling noise(n_pos가 지배)를 놓쳐 ~2배 과소추정.

## 증거/포인터
- `results/fusion_ssl/RESULTS_FUSION.md`, `results/fusion_ssl/REANALYSIS.md`(bootstrap/F5/M1),
  `scripts/run_fusion_ssl.py`(--single_view/--permute_aux), `scripts/reanalyze_fusion.py`.

## 후속 — 올바른 종단(change-direction LSSL) 실행 결과
LSSL(AE recon + Δz를 학습된 progression-direction τ에 정렬; +APOE-conditioned τ novelty) 실행:
- conv: contrastive 0.459 → **LSSL 0.508 / cond 0.524** (change-direction가 invariance를 넘음 ✓, I06 확증)
- 단 **aug-only(generic SSL) 0.530과 동급**, 모두 morphometry 바(conv 0.571) 아래 (CI 소데이터로 0 포함).
- covariate-conditioned가 prog 0.580(plain 0.526)으로 hint(novelty), 미유의.
→ 교훈: 올바른 종단(change-modeling)은 틀린 종단(invariance)보다 낫지만, 이 소데이터·구조-T1에선
generic SSL/morphometry를 못 넘음. 종단 이점을 보려면 더 큰 N + 종단 입력 평가 필요.
