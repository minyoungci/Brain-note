# FOMO26 — 3D Brain MRI SSL Foundation

MICCAI 2026 Foundation Model Challenge for Brain MRI. FOMO300K(306K 라벨없는 3D 뇌 MRI)로 SSL foundation 사전학습 → few-shot 임상 OOD 7 task.

**핵심 thesis**: principled local-global balancing for joint dense+global 3D self-distillation (ViT 백본), FOMO300K 규모로 처음 입증. novelty 축 = ① balancing + ② cross-seq recon + ③ fairness.

## 문서 (주제별 통합)
| | |
|---|---|
| [SCRATCHPAD.md](SCRATCHPAD.md) | **현재 상태·branch별 status** (매 업데이트) |
| [Warning.md](Warning.md) | ⚠️ **경고 레지스터** — 가설·실패모드를 학습 중 관찰신호(monitor.py)에 묶어 기록 |
| [docs/00_challenge_rules.md](docs/00_challenge_rules.md) | FOMO26 공식 규칙 + 설계 함의 (단일 체크포인트/seg 50%/120초/3회) |
| [docs/01_prior_research.md](docs/01_prior_research.md) | 선행 연구 통합 (3 deep-research + 에이전트) |
| [docs/02_architecture_method.md](docs/02_architecture_method.md) | 모델 계획 — ViT 백본 + 학습법(①②③) |
| [docs/03_data_integrity.md](docs/03_data_integrity.md) | leakage/overfitting 설계 (비타협) |
| [docs/04_strategy_timeline.md](docs/04_strategy_timeline.md) | 트랙/논문/Phase A·B/9주 일정 |
| [docs/05_downstream_setup.md](docs/05_downstream_setup.md) | ⭐ **공식** downstream 데이터 셋업 & finetuning (Asparagus, erda 다운로드, config 기본값) |
| [preprocessing/PREPROCESSING.md](preprocessing/PREPROCESSING.md) | 전처리 파이프라인 상세 (branch별) |
| [pretrain/MONITORING.md](pretrain/MONITORING.md) | SSL 사전학습 모니터링 spec |

## 구조
- `preprocessing/` — 전처리 드라이버 `preprocess_fomo300k.py`(프로덕션) + PREPROCESSING.md (구 extract_arrange.py=파일럿)
- `pretrain/` — SSL 사전학습 (monitor.py)
- `downstream/task1~7/` — 각 downstream task
- `baseline-codebase/` — 공식 FOMO 코드 (gitignored)
- `.venv/` — 전처리 env (yucca2.2.6/torch2.2, **완료**) · `.venv-train/` — 학습 env (torch 2.12.1+cu130, B200)

## 환경
```
.venv/bin/python -c "import yucca"          # 전처리 env (완료)
.venv-train/bin/python -c "import torch"    # 학습 env (B200 sm_100)
# 원본 데이터: /home/vlm/data/FOMO300K  ·  전처리 산출물: /home/vlm/data/FOMO300K_preprocessed (227,443볼륨/3.2TB)
```

## 다음 게이트
✅ 전처리 완료(227,443볼륨) · ✅ 학습 env(.venv-train, B200) → **SSL 사전학습 코드 셋업 → Phase A pilot.** (FOMO26 등록·downstream 데이터는 병행) ([[SCRATCHPAD]] 참조)

---
*이전 AD/7-코호트 연구는 git 태그 `exploratory-v1`/`rtssl-v1`/`experiments-v1`로 보존(현 tree는 FOMO 전용).*
