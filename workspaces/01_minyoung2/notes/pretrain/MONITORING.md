# SSL 사전학습 모니터링 시스템 (상세)

목적: foundation model 특유 실패를 **조기**에 잡아 비싼 재학습 방지. `monitor.py`의 `SSLMonitor`가 매 step/주기마다 metric 산출 + **WARN/STOP 자동판정** + wandb/jsonl 로깅. (smoke 검증 완료.)

## 1. 6대 모니터링 카테고리

| # | 카테고리 | metric | 무엇을 잡나 |
|---|---|---|---|
| 1 | **Collapse** | rankme(effective rank), emb_std(차원별), koleo, off-diag corr | 표현 붕괴(가장 흔한 SSL 실패) |
| 2 | **Local-global tension** (우리 thesis) | grad_cos(∇dense·∇global), mag_ratio, conflict_streak | 목적함수 충돌 → balancing이 대응하는지 |
| 3 | **Dense 퇴화** (Gram) | gram_drift(현재 vs Gram-teacher) | dense localization 무너짐(긴 학습의 함정) |
| 4 | **Teacher 건강** | softmax 엔트로피 ratio, max-prob | DINO 과샤프닝/균등붕괴 |
| 5 | **수치(bf16)** | loss_nan, grad_nan, grad_global_norm | 발산·NaN |
| 6 | **Downstream proxy** (조기경보) | linear-probe: cls AUROC, reg corr, **seg Dice** | 임베딩 품질 추세 — global·dense **둘 다** |

## 2. Alert 임계값 (자동 STOP/WARN)

| metric | 조건 | level | 조치 |
|---|---|---|---|
| emb_std_min | < 0.01 | **STOP** | 차원 collapse → 재시작/LR↓ |
| rankme_drop_frac | > 0.30 (초기 대비 30%↓) | **STOP** | rank collapse |
| loss_nan / grad_nan | ≥ 1 | **STOP** | bf16 발산 → LR/clip 점검 |
| teacher_entropy_ratio | < 0.05 or > 0.98 | WARN | teacher temp/centering 조정 |
| grad_conflict_streak | ≥ 200 step | WARN | **balancing(층1) 점검** — 목적충돌 지속 |
| gram_drift | > 0.50 | WARN | **Gram anchoring(층2) 강화** |
| probe_seg_drop_frac | > 0.15 | WARN | **local-global tension 발현** — dense probe 하락 |

→ STOP은 학습루프가 `m['_should_stop']`로 즉시 중단. WARN은 로그+대시보드 강조.

## 3. 핵심 설계 — "global과 dense를 *동시에* 추적"

우리 thesis가 local-global balance이므로, **단일 지표로 판단 금지.** 항상 쌍으로:
- **global probe**(cls AUROC / reg corr) ↑ 인데 **dense probe**(seg Dice) ↓ 이면 → *바로 그* tension이 발현 중 = balancing 실패. 이걸 `probe_seg_drop_frac`로 자동 경보.
- gram_drift ↑ 와 seg-probe ↓ 가 동반되면 dense 퇴화 확정 → Gram anchoring weight↑.

## 4. 주기 (cost 관리)

| 항목 | 주기 | 비용 |
|---|---|---|
| loss/collapse/teacher/수치 | 매 step | 싸다 |
| grad_conflict (2 backward) | K=50~100 step | 중간 → 주기적만 |
| gram_drift | 매 step (이미 forward됨) | 싸다 |
| **linear-probe (cls+reg+seg)** | probe_every=2000 step | 비쌈 → 주기적, held-out 소규모 |

## 5. Dashboard (wandb 패널 구성)
- **Panel A 손실**: total + dino/ibot/recon/gram/koleo (수렴·발산).
- **Panel B collapse**: rankme(추세 ↓ 감시), emb_std_min, koleo.
- **Panel C tension**: grad_cos(0 아래로 가나), mag_ratio, balance/σ_d·σ_g(균형 변화).
- **Panel D dense**: gram_drift(↑ 감시).
- **Panel E probe**: cls/reg/seg 동시 플롯(global↑ dense↓ 갈리는지 한눈에).
- **Panel F sys**: throughput, gpu_mem(병목·OOM).

## 6. de-risking 워크플로우와 연결
- **Phase A(소규모 설계검증)**: 모든 alert를 *민감하게* 켜고 balancing A~D·Gram on/off를 빠르게 비교. probe(global+dense)로 *어느 recipe가 둘 다 올리나* 직접 선택.
- **Phase B(스케일업)**: 검증된 recipe 1개만. STOP alert + probe 추세로 *학습 중* 조기 중단/조정 → 100ep 끝까지 안 기다림.
- warm-restart: balancing/Gram weight는 학습시간 component라 checkpoint에서 조정 후 resume 가능.

## 7. 사용 예 (pretrain 루프에 삽입)
```python
mon = SSLMonitor(run_dir, config=cfg, probe_every=2000)
for step, batch in loader:
    ...  # forward, loss
    grad_terms = (L_dense, L_global, model.encoder.parameters()) if step % 50 == 0 else None
    m = mon.log_step(step, losses={...}, batch_size=B, student_emb=cls_emb,
                     teacher_logits=t_logits, model=model, total_loss=L,
                     dense_feat=local_feat, gram_ref=gram_teacher_feat,
                     balance_state={"sigma_d":σd,"sigma_g":σg}, grad_terms=grad_terms)
    if m.get("_should_stop"): save_ckpt(); break
    if step % 2000 == 0:
        mon.log_probe(step, {"cls_age_auc":..., "reg_age_corr":..., "seg_dice":...})
```
