# pretrain/ — SSL 사전학습 (FOMO300K)

FOMO300K(라벨없는 3D 뇌 MRI) → SSL foundation 사전학습. downstream과 분리(여긴 사전학습 전용).

> 모델·method 상세는 [[../docs/02_architecture_method]] (ViT-3DINO + ① balancing ② cross-seq ③ fairness). 전처리 [[../preprocessing/PREPROCESSING]] · 무결성 [[../docs/03_data_integrity]] · 현재 status [[../SCRATCHPAD]].

## 데이터 흐름 (전처리 완료 2026-06-21)
`/home/vlm/data/FOMO300K` zip → **`preprocessing/preprocess_fomo300k.py`**(스트리밍 드라이버: os.walk 임의깊이 + 공식 Yucca 4단계 + float16 + manifest CSV) → `/home/vlm/data/FOMO300K_preprocessed/npy/<PT>/*.npy` → SSL 사전학습 → **단일 체크포인트**(규칙: 모든 task 동일).
- **학습 코퍼스: 227,443 볼륨 = anat 181,965 + DWI b1000대역 45,478** (~3.2TB float16). full 처리(subset 아님). DWI는 b800~1200만 큐레이션(b0/고b drop). 전수 정합·대량로드 검증 PASS.
- 산출물 추적: `FOMO300K_preprocessed/manifest.csv`(스캔별 status/dtype/shape/range). error 2(PT030 상수볼륨 정상격리).
- 메타데이터: demographic(age/sex 83%), scanner(86%) → ③ fairness/invariance 가능.
- ⚠️ **env 분리**: 전처리=`.venv`(torch2.2, 완료) / **학습=`.venv-train`(torch 2.12.1+cu130, B200 sm_100 검증)**. monitor.py·학습코드는 `.venv-train`에서 실행. [[../SCRATCHPAD]] 참조.

## 모니터링 ([[MONITORING]])
`monitor.py`(검증완료) — 6범주 자동 STOP/WARN: collapse / local-global tension / dense퇴화 / teacher / bf16 / downstream-proxy. 학습 *중* 조기경보 → 재학습 회피.
```python
mon = SSLMonitor(run_dir, probe_every=2000)
m = mon.log_step(step, losses=..., student_emb=..., grad_terms=(L_d, L_g, params), ...)
if m.get("_should_stop"): save_ckpt(); break
```

## status (2026-06-21)
✅ 전처리 완료(227,443볼륨/3.2TB) · ✅ 학습 env(.venv-train, B200 검증) · 설계·모니터 검증 완료.
→ **다음 = SSL 사전학습 코드 셋업**(ViT-3DINO + ①②③, monitor.py 배선). Phase A pilot.
`configs/` 설정 | `checkpoints/` 가중치. 상세 status [[../SCRATCHPAD]].
