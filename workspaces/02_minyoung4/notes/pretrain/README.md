# pretrain/ — SSL 사전학습 (FOMO300K)

FOMO300K → SSL foundation 사전학습(단일 체크포인트). 설계·method는 [[../docs/03_architecture_method]], 데이터는 [[../docs/02_data]], 위험·모니터 spec은 [[../docs/06_risk_register]], 현재 상태는 [[../SCRATCHPAD]].

## 데이터 흐름
`/home/vlm/data/FOMO300K_preprocessed/npy/<PT>/*.npy`(226,793 볼륨, float16) → SSL 사전학습 → 단일 체크포인트 → downstream 7 task.
- ⚠️ 학습/GPU = `.venv-train`(B200). 전처리 `.venv`(torch2.2)는 학습 불가.

## monitor.py + resources.py — SSL 모니터 (✅ 검증완료: `test_monitor.py` 23 checks PASS)
`SSLMonitor`가 매 step/주기 metric + 자동 STOP/WARN — **7대 카테고리**: collapse·local-global tension·dense퇴화(Gram)·teacher·수치(bf16)·downstream proxy(torch-native probe)·**리소스/속도/진행**(throughput·data_fraction·ETA·GPU/CPU/RAM·disk guard W14·hang). 의존성 0(torch+stdlib). **임계·카테고리·사용법 = [[../docs/06_risk_register]] §D.**
```python
mon = SSLMonitor(run_dir, probe_every=2000, total_steps=N, disk_path=ckpt_dir, is_main=(rank==0))
m = mon.log_step(step, losses=..., batch_size=B, student_emb=..., total_loss=L,
                 data_s=t_data, compute_s=t_compute, grad_terms=(L_d,L_g,params))  # grad_terms는 K step마다
if m.get("_should_stop"): save_ckpt(); break
```
- `resources.py`(ResourceTracker) 분리 — 독립 테스트 가능. 검증: `.venv-train/bin/python pretrain/test_monitor.py`.
- ⚠️ I/O 바운드 진단: 루프가 `data_s`/`compute_s` 넘기면 `data_fraction`(>0.5=I/O 바운드)·`eta_h` 산출 → Phase A에서 Phase B 학습시간 실측 근거.

## status
✅ 전처리·학습env 완료 → **다음 = SSL 사전학습 코드 셋업**(ViT-3DINO + ①②③, monitor 배선). `configs/`·`checkpoints/`. 상세 [[../SCRATCHPAD]].
