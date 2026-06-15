# pretrain/ — SSL 사전학습 (FOMO300K)

FOMO300K(라벨없는 3D 뇌 MRI) → SSL foundation 사전학습. downstream과 분리(여긴 사전학습 전용).

> 모델·method 상세는 [[../docs/02_architecture_method]] (ViT-3DINO + ① balancing ② cross-seq ③ fairness). 전처리 [[../preprocessing/PREPROCESSING]] · 무결성 [[../docs/03_data_integrity]] · 현재 status [[../SCRATCHPAD]].

## 데이터 흐름
`/home/vlm/data/FOMO300K` zip → `preprocessing/extract_arrange.py` → 공식 `preprocess.py`(Yucca, npy) → SSL 사전학습 → **단일 체크포인트**(규칙: 모든 task 동일).
- 용량: subset 30~60K(full 6~9TB > 디스크). findings: scaling 무효.
- 메타데이터: demographic(age/sex 83%), scanner(86%) → ③ fairness/invariance 가능.

## 모니터링 ([[MONITORING]])
`monitor.py`(검증완료) — 6범주 자동 STOP/WARN: collapse / local-global tension / dense퇴화 / teacher / bf16 / downstream-proxy. 학습 *중* 조기경보 → 재학습 회피.
```python
mon = SSLMonitor(run_dir, probe_every=2000)
m = mon.log_step(step, losses=..., student_emb=..., grad_terms=(L_d, L_g, params), ...)
if m.get("_should_stop"): save_ckpt(); break
```

## status
설계·모니터 검증 완료. 사전학습 실행은 Phase A(데이터/등록 후) — [[../docs/04_strategy_timeline]].
`configs/` 설정 | `checkpoints/` 가중치.
