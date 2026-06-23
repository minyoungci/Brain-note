# 04. 전략 · 계획 · 학습 인프라

> 규칙 [[00_challenge_rules]], 데이터 [[02_data]], 설계 [[03_architecture_method]], 위험/모니터 [[06_risk_register]], 현재 상태 [[SCRATCHPAD]].

## 1. 트랙 전략
- **Methods 트랙(주력)**: FOMO300K only. ① balancing(공저 게이트의 "의미있는 수정") + ③ fairness(Task6,7, first-author). 단일 백본이 7 task.
- **Open 트랙(최소)**: 한국 임상데이터 = *단일 ablation만*, 기본 포기(306K의 0.6%, 자원분산). 져도 "소규모 외부데이터 무효" negative 기여.

## 2. 논문 전략
- **공저(안전판, 반드시)**: 7 task에 *비-trivial* 제출(unmodified baseline=trivial 제외) → top저널(MedIA/TMI/Nat Methods/npj) 공저초청(≤5인).
- **first-author(도전)**: ① balancing / ③ fairness(미점유) 정조준. dense ablation(iBOT vs MAE)도 기여.

## 3. 가드레일 (AD 함정)
1. 백본 리스크 = ViT 채택으로 완화(3DINO 검증). Phase A서 수렴·probe·**120초 추론** 확인.
2. **baseline 먼저**(3DINO/S3D/well-tuned-λ 재현) → 못 넘으면 정직 보고.
3. 3+시드+CI. 4. falsifiable(①②③ 전부 ablation, 안 되면 negative=자산). 5. 큰 모델 금지(8×B200=병렬 iteration).

## 4. de-risking 워크플로 (Phase A → B)
- **Phase A(소규모)**: 작은 백본 + subset + 짧은 학습 → 후보 A/B/C·balancing A~D·dense iBOT vs MAE·②③ on/off·④ corpus를 **내부 subject-disjoint probe(global+dense)**로 비교 + ViT 작동·추론시간 검증 → 이긴 recipe 1개. *설계 틀림 다 걸러짐.*
- **Phase B(1회, 8×B200)**: 검증된 recipe만 full(226,793)·full epoch 스케일업.
- 조기경보: monitor.py STOP/WARN([[06_risk_register]])로 학습 *중* 중단/조정.

## 5. 학습 인프라 (Multi-day run 필수 — 전처리서 외부kill 경험) — ✅ 구현+실험검증(2026-06-22)
- 구현: `pretrain/train.py`(full-state ckpt·atomic·resume) + `pretrain/supervisor.py`(분류형) + `pretrain/test_resume.py`(실험). **검증 통과**: resume bit-exact(CPU)·B200 bf16 안정·GPU resume(cuda RNG)·NaN→STOP halt·crash→자동재개. 실험이 버그 2개 적발(torch2.12 `weights_only`·cuda RNG device).
- **분류형 복구**: 외부죽음(노드/OOM/세션) → **최신 ckpt 자동재개** / 발산·붕괴(monitor STOP) → **정지+근인분석**(무지성 재시작=crashloop 금지, "낙관적 재시작 금지").
- **전체상태 체크포인트**: model + **EMA teacher** + optimizer + scheduler + RNG + 데이터 샘플러 위치 + balancing 상태(σ_d/σ_g) + monitor baseline. (일부만 저장 = 사실상 처음부터.)
- **atomic write**(`*.tmp`→os.replace, last-N+best) · **setsid 세션독립**(PPID=1) · supervisor 래퍼(bounded retry).
- 체크포인트 주기 = 손실상한(예 20~30분), 공유 gpfs `df` 감시 + prune.
- ⚠️ **Phase A에서 resume를 먼저 검증**(일부러 kill→자동재개, NaN주입→STOP정지) 후 Phase B 의존.

## 6. 9주 일정 (8/21 마감)
| 주차 | 작업 |
|---|---|
| 1 | **인프라 올인** — 등록 → 7 task 제출 파이프라인 통과. seg 2·4(sliding-window/NSD) 최우선. 120초 검증. |
| 2-3 | baseline 재현(OpenMind 프로토콜) + Phase A ablation. |
| 3-6 | Phase B(balancing+cross-seq+fairness), 3시드+CI. |
| 4-7 | 7 task 비-trivial 제출(공저 확보). |
| 7-9 | ablation·polish·최종제출·논문. |

## 7. 다음 게이트 (Tier 0 — 학습 직전 선행)
1. **novelty prior-art pass**(literature-scout) — adaptive/uncertainty/GradNorm/PCGrad를 joint MIM+global SSL에 적용한 선행 유무 → firsthood 방어. (compute 0, 병렬)
2. **내부 평가 하네스** — subject-disjoint split + global-probe(메타 age/sex) + dense-probe(프록시 seg). 챌린지 검증 3회뿐 → 모든 결정 내부 eval로.
3. **학습 하네스** — §5 checkpoint/resume/supervisor 구현·검증.
4. (병행) FOMO26 등록 → downstream 7 task 데이터.
→ 그 다음 baseline 재현 → Phase A 후보 bake-off → Phase B.
