# ⚠️ Warning.md — 경고 레지스터 (학습 중 관찰·기록용)

> 목적: 계획 단계에서 식별한 **깨질 수 있는 지점**을, 학습 중 *관찰 가능한 신호*에 묶어 조기 발견·기록한다.
> 원칙: 각 경고 = (왜 위험 / **관찰 신호** = `monitor.py` 실측 metric / **트리거 임계** / 기록 위치 / fallback).
> 자기평가 금지 — "괜찮아 보임"이 아니라 *이 metric이 이 임계를 넘으면 문제*로 판정.
> 연관: [[docs/02_architecture_method]] [[docs/03_data_integrity]] [[pretrain/MONITORING]] · alert 구현체 = `pretrain/monitor.py` `ALERTS`.

---

## 사용법 (학습 루프에서)
- 매 step `SSLMonitor.log_step(...)` → `metrics.jsonl` + (wandb) 기록. 반환 `m`의 `m.get("_should_stop")==1` 이면 **즉시 중단**(STOP alert).
- 주기적 `log_probe(step, {...})` → GLOBAL(cls/reg) + DENSE(seg) probe *둘 다*. local-global balance를 직접 본다.
- alert는 console에 `⚠ [STOP|WARN] stepN key=val → 의미` 로 출력 + `alerts_fired`에 누적.

---

## A. 연구 / novelty 경고 (가설이 틀릴 수 있는 지점)

| # | 경고 | 왜 위험 | 학습 중 관찰 신호 (monitor.py) | 트리거 = 문제 | 기록 | fallback |
|---|---|---|---|---|---|---|
| **W1** | **① balancing 전이가 미검증** (핵심 novelty, borderline) | SSL split-head 전이는 선행 0. *well-tuned λ*를 못 넘으면 incremental | **사전학습 중**: `tension/grad_cos_dense_global`, `grad_conflict_streak`. **Phase A**: balancing run의 `probe/*`(global+dense) vs well-tuned-λ baseline run | ⓐ 사전학습서 `grad_cos_dense_global`가 *거의 항상 ≥0*(충돌 없음) → balancing이 *고칠 게 없음* = 전제 붕괴 조기경보. ⓑ Phase A서 balancing이 **well-tuned λ를 CI 넘게 못 이김**(equal-λ만 이김) | `metrics.jsonl`(tension/*, balance/*) + Phase A 결과표(SCRATCHPAD) | novelty 무게를 **③ fairness로 이동** |
| **W2** | 백본 ViT 확정이나 흔들림 + **120초/case 추론 제약** | 공식 baseline=ResEnc U-Net(CNN) → ViT custom 등록 마찰. 큰 ViT가 120초 초과 시 **실격** | 별도 Phase A 벤치(H100): inference time/case. 수렴은 `loss/total`·`probe/*` 추세 | 추론 **>120초/case** = 실격 리스크. 또는 probe가 baseline(morphometry/ResEnc) 미달 | Phase A 벤치 로그 + SCRATCHPAD | 모델/patch 축소, sliding-window 최적화, 또는 **ResEnc 백본** |
| **W3** | ② cross-seq recon 미검증 | BrainFM은 MAE-only. 조합이 single-modal을 못 넘으면 기여 0 | Phase A ablation: single-modal vs cross-seq `probe/*` | cross-seq가 single-modal **미달**, 또는 **seg 하락** | ablation 표 | single-modal recon으로 강등 |
| **W4** | **③ fairness가 seg(리더보드 50%)를 깎을 risk** | scanner-invariance 압력이 dense/seg 표현 손상 가능 | `probe/seg_dice` + `probe_seg_drop_frac` (fairness loss ON일 때), Task7 fairness metric | `probe_seg_drop_frac > 0.15`(WARN) 가 fairness 켠 뒤 발생 = seg 희생 | metrics.jsonl + ablation 표 | **ablation-only**, seg 깎이면 즉시 drop (seg 절대 희생 금지) |

> ⚠️ **reviewer-2 incremental 공격**: 부품이 전부 검증된 선행이라 "known 조합 아니냐" 공격에 노출. 방어는 *오직 W1의 실증*(well-tuned λ를 넘음) + ③·규모. 이건 training signal이 아니라 *Phase A 결과로만* 막힘.

---

## B. SSL 학습 실패모드 (monitor.py가 자동 판정)

| # | 경고 | 관찰 신호 (alert key) | 임계 (level) | 의미 | fallback |
|---|---|---|---|---|---|
| **W5** | representation collapse (차원) | `emb_std_min` | **< 0.01 (STOP)** | 차원 std→0 = collapse | 즉시 중단. KoLeo β↑, temp/centering 점검, LR↓ |
| **W6** | collapse (effective rank) | `rankme_drop_frac` | **> 0.30 (STOP)** | 초기 대비 rank 30%↓ | 위와 동일 + multi-crop/aug 점검 |
| **W7** | teacher 붕괴 | `teacher_entropy_ratio` | **<0.05 or >0.98 (WARN)** | 과샤프닝(단일모드) / 균등(collapse) | teacher temp·centering·EMA momentum 조정 |
| **W8** | 목적함수 충돌 지속 | `grad_conflict_streak` | **≥ 200 (WARN)** | ∇L_dense·∇L_global cos<0 지속 → balancing이 대응 못 함 | **W1과 직결** — balancing 동작 점검. 충돌 있는데 balancing이 못 풀면 thesis 위험 |
| **W9** | dense feature 퇴화 | `gram_drift` | **> 0.50 (WARN)** | local feature Gram drift = dense localization 손상 | (Gram은 강등 상태) γ·Gram anchoring 일시 강화 검토 — ablation으로만 |
| **W10** | dense probe 하락 | `probe_seg_drop_frac` | **> 0.15 (WARN)** | seg proxy 하락 = local-global tension 발현 | balance state 점검, dense 경로 가중 |
| **W11** | bf16 수치 발산 | `loss_nan` / `grad_nan_params` | **≥ 1 (STOP)** | NaN/Inf (fp16 금지, bf16 필수) | LR↓, grad clip, fp16 누수 점검 |

> `grad_conflict`(W8)는 **이중 의미**: 학습 건강 경고이자 *우리 thesis의 증거*. 충돌이 존재해야 balancing이 할 일이 있음(W1 전제). 충돌이 0이면 ①의 정당성↓, 충돌이 지속되는데 안 풀리면 ①의 효과↓ — 양쪽 다 기록.

---

## C. 제약 / 프로세스 / 인프라 경고

| # | 경고 | 왜 위험 | 점검/기록 |
|---|---|---|---|
| **W12** | **단일 체크포인트 강제**(규칙) | task별 튜닝 불가 → 리더보드 과적합 위험 | 모든 선택을 **내부 subject-disjoint val**로, 3시드+CI ([[docs/03_data_integrity]]) |
| **W13** | **pretrain ↔ downstream subject overlap** | 누수 시 전 결과 무효 | 결과 신뢰 *전에* overlap-check 스크립트 = **0 중복** 강제 ([[docs/03_data_integrity]]) |
| **W14** | **공유 디스크** (gpfs, 타 사용자/프로젝트 공유) | 대용량이 공유 풀 채워 타 작업 손상; 타 사용자도 우리 공간 잠식(실측: 12h에 200GB↑) | ✅전처리 완료(float16으로 full anat+dwi=3.2TB, 6~9TB는 float32 추정이었음). 학습 중 체크포인트/로그 누적 `df` 감시. disk guard 100GB. AD 잔존 정리 완료 |
| **W15** | **제출 컨테이너 형식**(120초/case, 7 task I/O) | env가 아니라 *형식*이 진짜 제약 — 형식 불일치 시 좋은 모델도 제출 실패 | sanity-check 파이프라인으로 **최소 제출 조기 검증** ([[docs/00_challenge_rules]]) |

---

## 기록 프로토콜 (어떻게 남기나)
1. **자동**: `monitor.py` → `<run_dir>/metrics.jsonl` (step별 전 metric) + wandb(있으면). STOP/WARN은 console.
2. **게이트별**: alert 발생·Phase A 결과 → `SCRATCHPAD.md` branch status 갱신 (CLAUDE.md: 실험 게이트마다 커밋과 함께).
3. **일일**: 이상 거동·판단 → `research_notes/daily/YYYY-MM-DD.md` (한국어).
4. **STOP 발생 시**: 즉시 중단 + 원인(어떤 alert, 직전 metric 추세) 기록 → 재시작 전 근인 분석 (낙관적 재시작 금지).

## 학습 시작 전 pre-flight (W와 연결)
- [x] **env**: 학습은 `.venv-train`(torch 2.12.1+cu130, B200 sm_100 검증). 전처리 .venv(torch2.2)는 B200 학습 불가(numpy ABI + sm_100 커널 없음) — 절대 학습에 쓰지 말 것. [[fomo-env-split]]
- [x] **전처리**: 227,443볼륨(anat 181,965+dwi 45,478) 전수정합·대량로드·DataLoader 검증 PASS.
- [ ] W13: pretrain↔downstream subject overlap = 0 확인 (등록 후 downstream 데이터 시)
- [ ] W11: bf16 설정, fp16 없음 확인 (.venv-train, bf16 B200 검증됨)
- [ ] W14: `df -h /home/vlm` 여유 감시 (체크포인트 누적 + 공유디스크 잠식 주의)
- [ ] W5/W6: baseline rankme 첫 기록(이후 drop_frac 기준)
- [ ] W8: `grad_conflict`를 K step마다 호출하도록 grad_terms 배선
- [ ] W2: 120초 추론 벤치 1회 (대표 case)
- [ ] monitor.py: `.venv-train`에서 import 확인(import torch/numpy)

## 학습 중 일일 점검 루틴
- STOP alert 0 인지 (있으면 이미 중단됐어야 함).
- WARN 누적 추세: `teacher_entropy_ratio`, `grad_conflict_streak`, `gram_drift`, `probe_seg_drop_frac`.
- `probe/*` GLOBAL vs DENSE 둘 다 우상향인지 (한쪽만 = local-global tension 발현, W1/W10).
- `balance/sigma_d, sigma_g`(또는 λ) 추이 — balancing이 실제로 움직이는지.
