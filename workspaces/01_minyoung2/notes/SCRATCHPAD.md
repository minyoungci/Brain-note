# SCRATCHPAD — FOMO26 현재 상태 (단일 LIVE 상태, 매 게이트 갱신)

> 최종 업데이트: 2026-06-22. 단계: **전처리·학습env·monitor 완료. thesis=단일ckpt×이질 7-task(seg+cls+reg) Pareto 체계연구(II+III, 챌린지 제출=first-author) 확정 → 다음 = 내부 eval harness + 7-task 파이프라인.**

## ✅ 완료
- **전처리 완료**: 학습 코퍼스 **226,793 볼륨**(구조 anat 181,315 + DWI b800–1200 44,943 + orphan 535 미분류), 3.2TB float16, 36/36 파티션, error 2(정상격리). out=`/home/vlm/data/FOMO300K_preprocessed`. 전수정합·대량로드 검증 PASS. (DWI b1000 큐레이션 + 정량맵 650 삭제 완료.) → [[docs/02_data]]
- **학습 env**: `.venv-train`(torch 2.12.1+cu130, B200 sm_100 검증). 전처리 `.venv`(torch2.2)는 B200 학습 불가(numpy ABI+커널). → [[fomo-env-split]]
- **설계 골격 확정** + 후보 A/B/C 문서·figure(백본 3 + 사전학습 3 + 디코더 1). → [[docs/03_architecture_method]] · `docs/figures/`
- ✅ **실험별 구조·figure 매핑 확정(2026-06-22)**: 공통 코어 잠금 + Phase A arm(A/B/C)↔figure 매핑 단일출처화([[docs/03_architecture_method]] §8). figure 7종 실물 검증. *승자는 Phase A가 결정*(지금 못박지 않음). gap: ②③ figure 미반영, C는 native 디코더, Asparagus=CNN네이티브(C먼저).
- ⚠️ **thesis 2개 후보 탈락(2026-06-22) → 전략 재결정 중**: ① Conflict-Aware(cosine balancing) = conflict pilot서 **cos≈0·창발없음 자체 falsify**. ② SSL Decoder-Transfer(C) = **S3D(CVPR2025, DKFZ) 선점**(같은 brain MRI·full U-Net MAE·decoder 전이 ablation·저데이터 곡선; 마진 +0.42 작음). → [[docs/01_prior_research]] §F. method-novelty 공간 레드오션. **무게중심 미정.**
- **근거**: deep-research(2026-06-21)·research-critic·literature-scout 반영 → [[docs/01_prior_research]]
- ✅ **downstream 데이터 확보(2026-06-22)**: 7 task 전부 다운로드·추출·검증(크기 무결성 정확). subjects T1=21·T2=23·T3=494·T4=40·T5=48, 입력모달 확정(T3=t1w·T4=t2w). `/home/vlm/data/fomo26_downstream/raw/Task_N` + symlink `downstream/taskN/data`. → [[docs/05_downstream_setup]]
- **docs 정리 완료(2026-06-22)**: 31개 → 00~06 canonical + 인덱스(README). 주제별 단일 출처.

## 🔒 확정 vs ⏳ Phase A 미정 (요약 — 상세 [[docs/03_architecture_method]] §2)
- 🔒 (방향 무관 유효) 백본 family(ViT 주력+ResEnc 안전망)·단일채널·단일체크포인트 / SSL 골격(DINO+MAE+register/Gram/KoLeo+의료aug, **balancing=단순결합 novelty 아님**) / 디코더(conv-stem+UNETR, MAE사전학습→전이, 단 novelty 아님=S3D 선점) / 의료특화 scope / resume 인프라.
- ⏳ patch 16³vs8³ / dense MAE vs iBOT / ViT vs ResEnc / 백본크기 / aug / modality-embedding / 120초 / downstream specifics. (**thesis novelty 축은 전략 fork에서 결정**.)

## ⏭️ 다음 게이트
**⓪ CONFLICT PILOT GATE — 1차 실측 완료(2026-06-22, GPU4·ViT-S·2000subset·3000step·bf16)**
- 결과: cos(∇L_d,∇L_g) mean **+0.017**·median +0.018·**cos<0 43%**·std 0.108 (초기40%→후기44%). 손실 둘 다 감소(1.02→0.55 / 8.22→5.70)=정상학습, collapse/NaN 없음.
- 해석(비판적): **충돌 실재·빈번하나 aggregate는 near-orthogonal(약함)**. 강충돌(cos<−0.1) ~13%뿐.
- ⚠️ **aggregate가 전 encoder param을 뭉뚱그림 → thesis(conflict *map*)의 실제 검증 아님.** near-0+43%flip = 국소충돌 평균상쇄 형태일 수 있음.
- 부수: **data_fraction 71%/GPU 21% = I/O 바운드 실측확인**.
- **run02 per-layer conflict map(진짜 GATE, 완료)**: 🔴 **cosine 충돌 전 layer 평평(falsify, 이 regime)** — 강충돌 layer 0, 국소충돌 없음 → "conflict map" 동기 figure 부재. 🟢 **magnitude 불균형 깊이-구조적**: |∇dense|/|∇global| 입력 ~1.4 → 깊은층 ~0.16(global ~5.5× 우세), dense=얕은층·global=깊은층. → 메커니즘 PCGrad(cosine) 아니라 GradNorm/uncertainty(magnitude). ⚠️ ViT-S·3000step 초기 proxy → cosine 충돌 후반/대규모 창발 가능(완전사망 단정 전 재확인). → `experiments/conflict_pilot/run02_*/summary.md`
- **run03 장기 30k step(창발 검증, 완료)**: 후반에도 평평(aggregate cos<0 52%→42% **상승 없음**, 깊은층 L05~07 평평 유지) → **cosine 충돌 가설 결정적 기각**(3k·30k 2 regime + 창발 부재). magnitude 불균형은 robust·심화(|∇dense|/|∇global| 입력 ~0.8 → 깊은층 0.05~0.07, global 15~20× 우세). 잔여 캐비엇 ViT-S(ViT-L 아님)이나 평평궤적상 규모창발 저확률. → `experiments/conflict_pilot/run03_*/summary.md`
- ⏭️ **(C도 S3D 선점으로 탈락)** → 전략 fork 아래.

## ⏭️ 전략 확정: II+III (2026-06-22)
**thesis = "하나의 SSL ckpt+디코더가 seg(50%)·cls·reg 이질 task를 *동시* Pareto-good하게 만드는 recipe는 무엇·왜"** — 챌린지 제출 시스템 = first-author 체계연구(한 노력 두 산출). S3D=seg-only라 미점유, pilot 충돌부재=공존 positive 근거. fairness(I)=보조 ablation. decoder-transfer/balancing=상속(novelty 아님, S3D/표준 인용). → [[docs/03_architecture_method]] §1.
- (탈락: Conflict-Aware 자체 falsify, Decoder-transfer S3D 선점, IV negative-results는 fallback)

### 로드맵 (II+III)
1. ✅ **내부 eval harness 빌드+실측(2026-06-22)** — `pretrain/eval_harness.py`, cls/reg/seg(voxel proxy) subject-disjoint. 🔴 **run01(random encoder)이 confound 노출**: seg voxelAUROC 0.84~0.99(=위치 shortcut)·cls Task5 0.95(=site confound). → **모든 내부 eval은 random baseline 대비 Δ로** 측정(절대값 금지). 작은-n(task1·2·4 ≤40) 고분산 주의. W13: ID 네임스페이스 불일치 → ID-match N/A(provenance 의존). → `experiments/eval_harness/`. ⏳ v2: multi-seed·진짜 Dice·위치통제.
2. **학습 하네스** — monitor ✅ / 남음: checkpoint·resume·supervisor(Phase A서 kill/NaN 테스트).
3. **baseline 재현** — S3D/ResEnc-L MAE/OpenMind 프로토콜(= 우리가 넘을 바 + firsthood 인용).
4. **Phase A recipe bake-off** — A/B/C 백본 × dense형 × corpus 조성 → "7 이질 task Pareto 지배 recipe" 1개.
5. **7-task finetune 파이프라인** — 챌린지 제출(공저) = 동시에 체계연구 데이터.
- ✅ 자산: monitor·conflict pilot 프레임·experiments 구조·226K 코퍼스·downstream 7task·8×B200.

### Tier 0 (학습 직전 선행, [[docs/04_strategy_plan]] §7)
1. ✅ **novelty prior-art pass** 완료(2026-06-22) → Conflict-Aware 재정의. (남은 [VERIFY]: 3DINO 손실식·Galileo §3 원문 직독)
2. **내부 평가 하네스** — subject-disjoint + global/dense probe (챌린지 검증 3회뿐).
3. **학습 하네스** — ✅ 모니터(monitor.py+resources.py, 7대 카테고리·자동STOP/WARN·리소스/I/O진단/disk guard) **검증완료**(test_monitor.py 23 PASS, 2026-06-22) / ⏳ 남음: checkpoint·resume·supervisor 구현·검증(Phase A서 kill/NaN 테스트).
4. (병행) FOMO26 등록 → ✅ downstream 7 task 데이터 확보.
→ baseline 재현 → Phase A 후보 bake-off → Phase B full run.

## ⚠️ 학습 전 미해결 (등록/데이터 필요)
- Task1~5 full-backbone vs frozen finetune (Task6/7만 frozen 확정) → dilution/디코더 설계에 영향.
- Task4/5 입력 모달·제출 컨테이너 형식·few-shot N — 등록 후 확인. → [[docs/05_downstream_setup]]
- W13 pretrain↔downstream subject overlap=0 (downstream 데이터 시).

## 핸드오프 노트
- git: AD 작업은 태그 `exploratory-v1/rtssl-v1/experiments-v1/fomo-planning-v1` 보존. 현 tree = FOMO only.
- 실행: 학습/GPU는 `.venv-train/bin/python` (전처리만 `.venv`). bf16 필수.
- 위험/모니터는 [[docs/06_risk_register]](W1~15 + monitor.py).
