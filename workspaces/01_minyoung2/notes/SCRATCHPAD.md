# SCRATCHPAD — FOMO26 현재 상태 (매 게이트 업데이트)

> 최종 업데이트: 2026-06-15. 단계: **계획 완료, 데이터(downstream) 미확보 — 등록 대기.**

## 현재 단계
- ✅ 선행연구 3 deep-research + 에이전트 종합 → [[docs/01_prior_research]]
- ✅ 아키텍처·method 확정(ViT-3DINO) → [[docs/02_architecture_method]]
- ✅ 규칙 정리 → [[docs/00_challenge_rules]] | 무결성 → [[docs/03_data_integrity]] | 전략 → [[docs/04_strategy_timeline]]
- ✅ 전처리 파이프라인 검증(파일럿) → [[preprocessing/PREPROCESSING]]
- ✅ 모니터링 시스템 검증 → `pretrain/monitor.py`
- ⏳ **다음 게이트 = FOMO26 등록 → downstream 7 task 데이터 → Phase A pilot**

## Branch별 상세 status

### 전처리
| branch | status | 다음 |
|---|---|---|
| pretrain-prep | 스크립트(extract_arrange + 공식 preprocess) 검증완료(IXI 15scan) | subset 30~60K 선정·실행(데이터 시) |
| downstream-prep | 미착수 | 등록 후 run_preprocessing.py per task |

### method (Phase A에서 검정)
| branch | status | 검정할 가설 |
|---|---|---|
| 백본 ViT-DINO | 확정(3DINO 검증) | ⚠️ **최우선**: 우리 데이터서 수렴·probe·**120초 추론** |
| ① balancing (A~D) | 설계 완료 | *unvalidated* — well-tuned λ 넘나? (equal-λ 아님) |
| ② cross-seq recon | 설계 완료 | single-modal 넘나? (modality-inv는 금지) |
| ③ scanner-invariance | 설계 완료 | seg(50%) 안 깎고 Task7 올리나? |
| dense: iBOT vs MAE | ablation 설계 | head-to-head(선행 없음) |
| Gram anchoring | 강등 | ablation으로만(MedDINOv3 −0.04) |

### downstream task (셋업·명령은 [[docs/05_downstream_setup]])
| task | dataset ID | split | 다운로드 | 전처리 | baseline | novel |
|---|---|---|---|---|---|---|
| 1 infarct cls | CLS002 | 75_15_10 | ⬜ | ⬜ | ⬜ | ⬜ |
| 2 meningioma seg ⭐25% | SEG009 | 40_10_50 | ⬜ | ⬜ | ⬜ | ⬜ |
| 3 brain age reg | REGR002 | 75_15_10 | ⬜ | ⬜ | ⬜ | ⬜ |
| 4 trigeminal seg ⭐25% | SEG010 | 40_10_50 | ⬜ | ⬜ | ⬜ | ⬜ |
| 5 polymicrogyria cls | CLS003 | 75_15_10 | ⬜ | ⬜ | ⬜ | ⬜ |
| 6 linear probe (no-FT) | =Task1 | 75_15_10 | — | ⬜ | ⬜ | ⬜ |
| 7 fairness (no-FT) | =Task6 | 75_15_10 | — | ⬜ | ⬜ | ⬜ |
- 다운로드: erda `sid.erda.dk/sharelink/fmeuvo1EdF` (~6GB). split=config 기본(PDF 80/10/10 아님).
- ⚠️ **공식 baseline 모델=ResEnc U-Net(CNN)** → ViT 쓰려면 Asparagus custom model 등록(통합 마찰). Phase A 결정.

## 열린 결정 / 리스크
- novelty 무게중심: ① balancing(borderline) vs ③ fairness(가장 열림) — Phase A 결과로 확정.
- seg(2,4)=리더보드 50% → 인프라 최우선.
- 8/21 마감 ~9주 → 공저 안전판 먼저.

## 핸드오프 노트
- 환경: `.venv`(yucca2.2.6/torch2.2), 공식 코드 `baseline-codebase/`.
- git: AD 작업은 태그 `exploratory-v1/rtssl-v1/experiments-v1/fomo-planning-v1` 보존. 현재 working tree = FOMO only.
- 데이터: FOMO300K `/home/vlm/data/FOMO300K`(minyoung2 밖).
