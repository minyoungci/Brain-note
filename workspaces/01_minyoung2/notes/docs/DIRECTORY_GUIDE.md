# 디렉토리 가이드 — FOMO26 프로젝트 (v1 official + v2 탐색)

> 2026-06-27. v1=확정 official, v2=대안 패러다임(JEPA 등) 탐색. v1 자산은 보존, v2는 별도.

## 루트 구조
```
minyoung2/
  CLAUDE.md  README.md  SCRATCHPAD.md       ← 규칙·개요·LIVE 상태
  pretrain/        ← v1 SSL 학습 (models.py·train.py·data.py·monitor.py …) [확정]
  downstream/      ← downstream 7-task 파이프라인 (core·eval_*·seg_v2/v3) [v1·v2 공용]
  pretrain_v2/     ← v2 대안 패러다임(JEPA) 학습 [신규, 탐색]  → README.md
  experiments/     ← v1 실험 결과 (phase_a 탐색 / phase_b 본학습)
  experiments_v2/  ← v2 실험 결과 [신규]
  docs/            ← 설계·데이터·규칙 문서 (00~07 canonical + v2/)
  preprocessing/   ← 전처리 (yucca 4-step, 완료)
  Challenge_Submission/ ← 제출 컨테이너(Apptainer) [별도, gitignore]
  baseline-codebase/ data/ ← 참조·데이터(읽기전용)
```

## ⭐ v1 핵심 자산 (확정 — 절대 보존)
| 자산 | 경로 |
|---|---|
| **단일 제출 ckpt = wg0.5** | `experiments/phase_b/resenc_s3d_wg0.5/latest.pt` (530MB) |
| 모델 정의 | `pretrain/models.py` (ResEncUNet·SSLModel·build_models) |
| SSL 학습 루프 | `pretrain/train.py` |
| downstream 추론/평가 | `downstream/core.py`(load_backbone) ·eval_finetune·eval_global·seg_v3 |
| 비교분석 | `experiments/phase_b/downstream_runs/COMPARISON.md` |
| 설계 해설 | `docs/foundation_model_design.md` |

## v2 (탐색 — pretrain_v2/README.md 참조)
JEPA 등 대안 패러다임. 공용(data.py·monitor·downstream eval) 재사용, v1 무영향.

## 🧹 experiments/phase_b 정리 계획 (boundary 실험 종료 후 실행)
**원칙**: official(resenc_s3d_*·downstream_*·s3d_*) 보존, 구 탐색 실험은 `experiments/phase_b/_archive/`로.
- **archive 대상(~14GB 회수)**: `resenc_infonce_{full,wg0.5,wg2.0}`(6.1G), `vit_ibot_full`(6.3G), `resenc_mae_full`(1.9G) — InfoNCE 탐색기·ViT-iBOT 비교 arm(역할 종료, 결론은 SCRATCHPAD/메모리에 기록됨).
- **삭제 후보(빈/smoke)**: `seg_150ep`·`seg_c128`·`segtest_*`(수 KB, 구 smoke).
- **흩어진 26개 driver.log·run_*.sh** → `experiments/phase_b/_scripts/`·`_logs/`로 묶기.
- ⚠️ ckpt 이동은 **data-manager 불필요**(data/ 아님, experiments/는 일반 작업영역)이나, 진행중 실험·waiter 경로 의존 없는지 확인 후.
- 실행: `R3_WAVEB_DONE` + men(Wave-C) 등 모든 실험 종료 확인 → archive 이동 → SCRATCHPAD 갱신.
