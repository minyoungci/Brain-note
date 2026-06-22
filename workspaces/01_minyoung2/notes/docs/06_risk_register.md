# 06. 위험 레지스터 (W1~15) + 모니터링 spec

> 계획 단계 실패모드를 *학습 중 관찰 신호*(monitor.py)에 묶어 조기 발견. 구현체 = `pretrain/monitor.py`. 설계 [[03_architecture_method]], 데이터/무결성 [[02_data]], 규칙 [[00_challenge_rules]].
> 원칙: 자기평가 금지 — "괜찮아 보임"이 아니라 *이 metric이 이 임계를 넘으면 문제*로 판정.

## A. 연구/novelty 위험
| # | 경고 | 관찰 신호 | 트리거=문제 | fallback |
|---|---|---|---|---|
| **W1** | ① balancing 전이 미검증(핵심 novelty) | 사전학습 `grad_cos_dense_global`·`grad_conflict_streak`; Phase A probe(global+dense) vs well-tuned-λ baseline | ⓐ grad_cos 거의 항상 ≥0(충돌 없음=고칠 게 없음) ⓑ Phase A서 **well-tuned λ를 CI 넘게 못 이김** | novelty 무게 ③ fairness로 이동 |
| **W2** | ViT 흔들림 + 120초 추론 제약 | Phase A 추론시간/case 벤치(H100); 수렴은 loss·probe 추세 | 추론 **>120초**=실격 / probe가 baseline 미달 | 모델·patch 축소, sliding-window, 또는 ResEnc 백본 |
| **W3** | ② cross-seq 미검증 | Phase A: single-modal vs cross-seq probe | cross-seq가 single-modal 미달/seg 하락 | single-modal recon 강등 |
| **W4** | ③ fairness가 seg(50%) 깎을 risk | `probe_seg_drop_frac`(fairness ON), Task7 metric | fairness 켠 뒤 `probe_seg_drop_frac>0.15` | ablation-only, seg 깎이면 즉시 drop |

> reviewer-2 "known 조합" 공격 방어 = 오직 W1 실증(well-tuned λ 넘음) + ③·규모. training signal 아니라 *Phase A 결과로만* 막힘.

## B. SSL 학습 실패모드 (monitor.py 자동판정)
| # | 경고 | metric(alert key) | 임계 | 의미/조치 |
|---|---|---|---|---|
| **W5** | collapse(차원) | `emb_std_min` | **<0.01 STOP** | std→0 → 중단·KoLeo↑·LR↓ |
| **W6** | collapse(rank) | `rankme_drop_frac` | **>0.30 STOP** | 초기대비 rank 30%↓ |
| **W7** | teacher 붕괴 | `teacher_entropy_ratio` | **<0.05 or >0.98 WARN** | 과샤프닝/균등 → temp·centering·EMA 조정 |
| **W8** | 목적충돌 지속 | `grad_conflict_streak` | **≥200 WARN** | ∇dense·∇global cos<0 지속 → balancing 점검(W1 직결) |
| **W9** | dense 퇴화 | `gram_drift` | **>0.50 WARN** | Gram anchoring 강화 |
| **W10** | dense probe 하락 | `probe_seg_drop_frac` | **>0.15 WARN** | local-global tension 발현 |
| **W11** | bf16 발산 | `loss_nan`/`grad_nan_params` | **≥1 STOP** | NaN/Inf → LR↓·clip(fp16 금지) |

> `grad_conflict`(W8)=이중의미: 학습건강 경고 + *thesis 증거*(충돌 있어야 balancing 할 일 있음). 충돌 0이면 ① 정당성↓, 지속되는데 안 풀리면 ① 효과↓ — 양쪽 기록.

## C. 제약/인프라
| # | 경고 | 점검 |
|---|---|---|
| **W12** | 단일 체크포인트 강제 | 모든 선택 내부 subject-disjoint val + 3시드+CI([[02_data]] §5) |
| **W13** | pretrain↔downstream subject overlap | 결과 신뢰 *전에* overlap-check=0 강제(등록 후 downstream 데이터 시) |
| **W14** | 공유 gpfs | ✅ 전처리 완료(float16 full=3.2TB). 학습 중 ckpt/로그 누적 `df` 감시 + disk guard 100GB. (실측: 타 사용자 12h에 200GB↑ 잠식) |
| **W15** | 제출 컨테이너 형식(120초/case, 7 task I/O) | env 아닌 *형식*이 진짜 제약 → sanity-check로 최소 제출 조기 검증 |

## D. monitor.py — 7대 카테고리 + 사용 (✅ 검증완료 `pretrain/test_monitor.py` 30 checks PASS + code-auditor HIGH/MED 수정 반영: C1 dedup·C2 disk fail-open·C3 grad_conflict·W1 probe누수·W2 AUROC tie·W3 NaN가드·W4 rankme baseline윈도·W8 teacher_temp, 2026-06-22)
| 카테고리 | metric | 잡는 것 |
|---|---|---|
| Collapse | rankme·emb_std·koleo·off-diag | 표현붕괴(최빈 실패) |
| **Local-global tension**(thesis) | grad_cos·mag_ratio·conflict_streak | 목적충돌 → balancing 대응 여부 |
| Dense 퇴화 | gram_drift | dense localization 무너짐(긴 학습 함정) |
| Teacher 건강 | entropy ratio·max-prob | 과샤프닝/균등붕괴 |
| 수치(bf16) | loss_nan·grad_nan·grad_norm | 발산 |
| Downstream proxy | linear-probe cls AUROC·reg corr·**seg Dice** (torch-native, sklearn 불필요) | 임베딩 품질 추세(global·dense 둘 다) |
| **리소스/속도/진행** | throughput_sps(순간)·data_fraction·eta_h·gpu/cpu/ram·disk_free·stall_ratio·sched/* | **I/O 바운드 진단**·ETA·**W14 disk guard 구현**·hang 탐지·스케줄 가시화 |

**핵심 설계**: thesis가 local-global balance라 *단일 지표 금지* — global probe↑인데 dense(seg) probe↓ = tension 발현(`probe_seg_drop_frac` 자동경보, **best-so-far 대비** 하락으로 판정 → 개선 중 오경보 없음). 주기: loss/collapse/teacher 매 step, grad_conflict K=50~100, probe every 2000. STOP은 `m['_should_stop']`로 즉시 중단.
- **오경보 방지(검증됨)**: rankme baseline은 `baseline_warmup`(기본 500 step) *후* 고정 — 랜덤 init의 인위적 고-rank로 W6 false STOP 안 냄.
- **속도/진행**: 루프가 `data_s`(배치대기)·`compute_s`(연산) 측정해 넘기면 `data_fraction`(>0.5=I/O 바운드)·`eta_h` 산출 → Phase A throughput 실측 = Phase B 시간 확정 근거. 미제공 시 wall-clock fallback.
- ⚠️ **disk guard(W14)**: `disk_path`를 **gpfs ckpt 디렉토리**로 줘야 함(기본=run_dir). free<`disk_min_gb`(기본100)면 STOP.
- 의존성 0(torch+stdlib): `.venv-train`에 sklearn/pynvml/psutil/wandb 없음 → 전부 native 구현. `resources.py` 분리(독립 테스트).
```python
mon = SSLMonitor(run_dir, config=cfg, probe_every=2000,
                 total_steps=N, disk_path=ckpt_dir, baseline_warmup=500, is_main=(rank==0))
m = mon.log_step(step, losses={...}, batch_size=B, student_emb=cls_emb, teacher_logits=t_logits,
                 model=model, total_loss=L, dense_feat=local_feat, gram_ref=gram_teacher,
                 balance_state={"sigma_d":σd,"sigma_g":σg}, schedules={"lr":lr,"teacher_temp":τ,"mask_ratio":mr},
                 data_s=t_data, compute_s=t_compute, grad_terms=(L_d,L_g,params) if step%50==0 else None)
if m.get("_should_stop"): save_ckpt(); break
```

## 학습 시작 전 pre-flight
- [x] env: 학습=`.venv-train`(B200 검증). 전처리 `.venv`(torch2.2)는 B200 학습 불가 — 쓰지 말 것. [[fomo-env-split]]
- [x] 전처리: 226,793 전수정합·대량로드 PASS.
- [x] monitor.py `.venv-train` import + 자동 STOP/WARN·리소스 검증(`test_monitor.py` 23 checks PASS).
- [ ] W13 subject overlap=0(등록 후) · [ ] W11 bf16/fp16없음 · [ ] W14 `disk_path`=gpfs ckpt 디렉토리 배선 · [ ] W5/6 baseline_warmup 후 rankme 기록 · [ ] W8 grad_conflict 배선 · [ ] W2 120초 벤치.

## 기록 프로토콜
monitor → `metrics.jsonl`+wandb(STOP/WARN console). 게이트별 → [[SCRATCHPAD]] 갱신+커밋. 일일 이상거동 → `research_notes/daily/YYYY-MM-DD.md`. **STOP 시 즉시중단+근인분석 후 재시작**(낙관적 재시작 금지).
