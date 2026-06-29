# CLAUDE.md — FOMO26 프로젝트 로컬 규칙
# 위치: /home/vlm/minyoung2/CLAUDE.md
# 전역 ~/.claude/CLAUDE.md보다 **우선**한다.

## ⛔ GPU 실험 / 실제 훈련 전 — 필수 선행 (가정 기반 실행 절대 금지)
GPU 스크립트 실행, 사전학습(SSL)·finetune·평가 등 **실제 훈련/GPU 작업에 들어가기 전 반드시
아래 문서를 *정독*하고 최신 상태를 확인한다.** 문서와 어긋나는 실행 금지. 확정된 것만 그대로 쓰고,
"Phase A 미정" 항목은 반드시 실험(baseline-first·3시드+CI·내부 subject-disjoint)으로 결정한다.

정독 대상 (역할별 단일 출처):
1. **설계 of record** — 백본·목적함수(DINO+MAE+cross-seq)·적응적 balancing(novelty)·디코더·**확정 vs Phase A 미정** → `docs/03_architecture_method.md` (후보 상세 `docs/arch_candidates/`)
2. **데이터** — 전처리·코퍼스 실측·설계 함의·무결성(leakage) → `docs/02_data.md`
3. **규칙(실격조건)** — 단일 체크포인트·seg 50%·120초/case·외부데이터/외부supervision 금지 → `docs/00_challenge_rules.md`
4. **위험·모니터** — W1~15 + monitor.py(collapse/bf16/teacher STOP/WARN) → `docs/06_risk_register.md`
5. **전략·계획·학습인프라(resume)** → `docs/04_strategy_plan.md`
6. **현재 상태**(확정/미정·다음 게이트) → `SCRATCHPAD.md`
7. **Shortcut/confound 통제(필수)** — scanner/site/cohort/protocol/resolution/registration/age/label-acquisition shortcut 측정·통제 절차(측정→A2 orthogonalization→B held-out), Δ-over-random 강제, claim 전 체크리스트 → `docs/08_shortcut_and_confound_control.md`

> 핵심은 *경로*가 아니라 "**설계·데이터·규칙·위험·상태·shortcut통제를 실제 훈련/평가 전 반드시 읽고 확인**"이다.
> 특히 모든 transfer/probe/seg 결과는 §08 절차로 shortcut을 *먼저* 통제·검정한 뒤에만 증거로 쓴다.

## 환경 (틀리면 GPU 실험 즉시 실패)
- **학습/GPU = `.venv-train`** (torch 2.12.1+cu130, B200 sm_100 검증).
- **전처리 `.venv`(torch 2.2.2)는 B200 학습 불가** — numpy2 ABI 깨짐(`from_numpy` 불가) + sm_100 커널 없음("no kernel image"). **절대 학습에 쓰지 말 것.**
- **bf16 필수** (fp16 금지).
- 데이터: 전처리 산출물 `/home/vlm/data/FOMO300K_preprocessed`(학습 코퍼스 226,793), 원본 `/home/vlm/data/FOMO300K`.

## 참조
- 전역 행동원칙(비판적 조언자·검증의무·자기평가 편향 금지·커밋 컨벤션): `~/.claude/CLAUDE.md`
- 하네스 패턴: `~/.claude/rules/harness.md`
