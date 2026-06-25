# FOMO26 — 3D Brain MRI SSL Foundation

MICCAI 2026 Foundation Model Challenge. FOMO300K(라벨없는 3D 뇌 MRI)로 SSL foundation 사전학습 → few-shot 임상 OOD 7 task. **thesis**: principled (non-additive) local-global balancing for joint dense+global 3D self-distillation, FOMO300K 규모로 처음 입증.

> 📍 **현재 상태는 [SCRATCHPAD.md](SCRATCHPAD.md)** (단일 LIVE 상태). ⛔ GPU/훈련 전 정독 규칙은 [CLAUDE.md](CLAUDE.md).

## 📚 문서 맵 (주제 → 단일 출처)
| 주제 | 파일 |
|---|---|
| 현재 상태·다음 게이트 | [SCRATCHPAD.md](SCRATCHPAD.md) |
| 챌린지 규칙·실격조건 | [docs/00_challenge_rules.md](docs/00_challenge_rules.md) |
| 선행연구·deep-research | [docs/01_prior_research.md](docs/01_prior_research.md) |
| **데이터**(전처리·코퍼스실측·무결성) | [docs/02_data.md](docs/02_data.md) |
| **설계 of record**(아키텍처·method·후보·확정/미정) | [docs/03_architecture_method.md](docs/03_architecture_method.md) |
| 전략·일정·학습인프라(resume) | [docs/04_strategy_plan.md](docs/04_strategy_plan.md) |
| downstream 셋업·finetuning | [docs/05_downstream_setup.md](docs/05_downstream_setup.md) |
| **위험 레지스터**(W1~15)·모니터 spec | [docs/06_risk_register.md](docs/06_risk_register.md) |
| foundation↔downstream 불일치·해결전략 | [docs/07_downstream_integration_mismatch.md](docs/07_downstream_integration_mismatch.md) |
| 후보 상세 A/B/C·구조 figure | [docs/arch_candidates/](docs/arch_candidates/) · [docs/figures/](docs/figures/) |

## 구조
```
docs/            00~06 canonical + arch_candidates/(후보 A/B/C) + figures/(백본·사전학습·디코더 PNG)
preprocessing/   preprocess_fomo300k.py(프로덕션 드라이버) · analyze_corpus.py · PREPROCESSING.md(실행 노트)
pretrain/        monitor.py(SSL 모니터) · README.md
downstream/      task1~7/
baseline-codebase/  공식 FOMO 코드(gitignored)
.venv/           전처리 env(yucca2.2.6/torch2.2, 완료)   ·   .venv-train/  학습 env(torch2.12+cu130, B200)
```

## 환경 / 데이터
```
.venv-train/bin/python -c "import torch"   # 학습 env (B200 sm_100). 전처리는 .venv
# 학습 코퍼스: /home/vlm/data/FOMO300K_preprocessed (226,793 볼륨 / 3.2TB float16) · 원본: /home/vlm/data/FOMO300K
```

---
*이전 AD/7-코호트 연구는 git 태그 `exploratory-v1`/`rtssl-v1`/`experiments-v1`로 보존(현 tree=FOMO 전용).*
