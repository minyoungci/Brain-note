# 06. AAAI Execution Runbook (Hybrid)

작성일: 2026-06-29 (hybrid framing 갱신)

이 문서는 AAAI 제출용 증거(C1 protocol-adaptive / C2 objective balance+rank / C3 external)를
실행·추적하는 운영 계획이다. dense branch(SparK-style)는 detail이며 증명 대상이 아니다.

## ★ 활성 워크스트림: TC2 라벨-프리 selection (2026-06-30)

> headline 후보 = "라벨 없이 effective-rank류 지표로 objective-balance 최적점 선택". 단일출처 로그·산출물 =
> `results/tc2_labelfree_selection/`(그 안 README.md), 전체 결과 맵 = `results/RESULTS_INDEX.md`.

- **critic F1(검증됨)**: rank(RankMe)는 단조↓(14.86→12.93→11.65) vs transfer inverted-U(0.599→**0.792**→0.683)
  = **decoupling** → rank 기반 선택은 wg0(틀림) 선택. "rank로 최적선택"은 **거짓, 주장 금지**.
- **Phase 0+0.5 (완료, GPU)** — `scripts/phase0_labelfree_screen.py`. frozen feature에 라벨-프리 지표 스크리닝.
  **α-ReQ = peak@wg0.5(2.41→4.08→3.00), 4/4 fit-range robust(R²≈0.99) = 유일 강후보**(rank류·silhouette=단조).
  DECISION=GO(잠정, 3점). 결과 `tc2_labelfree_selection/phase0_screen.json`.
- **Phase 1 (진행 중)** — wg0.25(GPU2)/wg0.75(GPU3) 재학습 → 5-grid. 재현 config는 기존 `.log`에서 복구
  (★`--global_mode infonce` = 기본 dino 아닌 trap). 완료 시 `scripts/phase0_labelfree_screen.py` 재실행 →
  `phase1_5point.json`. **결정적 검정 = α-ReQ argmax == transfer argmax(5점)?** → GO(selector)/NO-GO(decoupling).
  - **내성(SSH·크래시)**: 학습은 tty-detached. `scripts/resume_phase1.sh watch`(detached watchdog, 10분마다
    checkpoint서 자동 재개, 둘 다 DONE이면 자동 종료). 수동 재개도 동일 스크립트.
- **Phase 2 (대기, 외부 데이터 후)** — leave-one-task-out regret로 selection *절차* 검증.

## 현재 상태 (DONE vs TODO)

### DONE (추가 GPU 불필요)

- **C2 provenance-clean global probe** — `pretrain/eval_harness.py`로 진짜 `resenc_s3d` pure/wg0.5/full을
  matched random baseline 대비 측정. 결과: `Flagship/AAAI/results/d2_probe/{s3d_random,resenc_s3d_pure,resenc_s3d_wg0.5,resenc_s3d_full}/eval_results.json`.
  - brain age r: random 0.137 → pure 0.599 → **wg0.5 0.792** → full 0.683 (inverted-U).
  - polymicro/infarct: 03/02 표 참조(작은-n caveat).
- **C2 rank mechanism** — `scripts/collapse_diagnostics.py` tail-window aggregate.
  rankme wg0 14.86 → wg0.5 12.93 → wg1 11.65. `results/collapse_diagnostics.{csv,json}`.
- **TC1 protocol-adaptive transfer — paper-ready (GPU 재실행 불필요)**: frozen matched +0.134
  (trig 0.442[0.408,0.474] vs frozen-scratch 0.308[0.275,0.340], CI-분리) + scratch-convergence
  diagnostic gap=0.409−0.308=+0.101. 정직 경계: frozen-foundation 0.442 ≈ full-FT-scratch 0.409(CI 겹침)
  → "값싼 frozen probe가 full-FT-scratch 수준 회복". low-LR 0.450은 absolute-best 보조(별도 +0.142 주장 안 함).
  men은 방향성만. 출처: `experiments/phase_b/downstream_runs/R3_candidates/{A,B,C,E}_trig*.log`, `..._men*.log`.
- **leakage probe = 동어반복 확인** — `scripts/leakage_probe.py` → `results/leakage_probe.json`.
  s3d/skip±re-mask 모두 0.0, unmasked control만 0.69. **증거 아님(detail/sanity only)**.

### TODO

- (선택, optional — TC1은 이미 ready) C1 추가 protocol 포인트(low-LR matched·men full-FT scratch): absolute 수치 보강용일 뿐,
  TC1 정량 주장에는 불필요. 시간/GPU 여유 시에만.
- **C3 외부 전처리**(사용자, CPU, 진행중): 6코호트 Yucca 4-step. n≥300 첫 코호트 우선.
- **C3 외부 eval 배선**(나, GPU 불필요 prep): eval_harness에 외부 task 등록(전처리 산출물 포맷 확인 후).
- **C2 paper 표/그림 생성**(나, GPU 불필요): 아래 Stage 1 — **brain-age inverted-U만 SOLID로**, infarct 제외·polymicro Δ-only.
- (선택) boundary-bleed leakage probe 재설계(detail 섹션).

## Stage 1. C1/C2 Paper-Ready Aggregation (지금)

기존 자산을 통합해 표/그림 생성. 새 GPU 불필요.

```bash
# objective balance + rank (C2)
python Flagship/AAAI/scripts/collapse_diagnostics.py --window 1000
# (D2 결과는 이미 results/d2_probe/*/eval_results.json 에 존재)

# registry: leakage(detail로 표기) + collapse 통합. seg는 C1 표로 별도 정리.
python Flagship/AAAI/scripts/build_paper_registry.py \
  --collapse-json Flagship/AAAI/results/collapse_diagnostics.json
```

성공 기준:
- Table_Objective_Balance(wg sweep × brain age/polymicro/infarct/rankme) 생성.
- Table_Protocol_Transfer(task × full-FT/frozen/low-LR Δ-over-scratch) 생성.
- leakage rows는 `claim=detail`로 표기(증거 아님 명시).

주의: `build_paper_registry.py`의 기존 eval2(`resenc_mae` provenance) global rows는 **사용하지 않는다.**
C2 global 수치는 반드시 `results/d2_probe/`(recipe=resenc_s3d, matched random)에서 가져온다.

## Stage 2. C3 External Probe (전처리 완료 후)

외부 코호트가 `*.npy`로 전처리되면, eval_harness에 task로 등록 후 frozen probe.

```bash
# (배선 예시 — 외부 task 등록 후)
python pretrain/eval_harness.py --device cuda \
  --recipe resenc_s3d --tasks brainage_ext \
  --max_subj 100000 --out Flagship/AAAI/results/c3/random_ext      # matched random
python pretrain/eval_harness.py --device cuda \
  --tasks brainage_ext,cnmciad_cls --max_subj 100000 \
  --ckpt experiments/phase_b/resenc_s3d_wg0.5/latest.pt \
  --baseline Flagship/AAAI/results/c3/random_ext/eval_results.json \
  --out Flagship/AAAI/results/c3/wg0.5_ext
```

성공 기준:
- 외부 brain age Δ-over-random > 0, CI가 random과 분리.
- site-disjoint(ADNI/NACC) 및 cross-continent(train ADNI → test KDRC/AJU)에서 비붕괴.
- CN/MCI/AD AUROC가 random/scratch 대비 유의(가능 코호트).

## Stage 3. (선택) Boundary-Bleed Probe (detail)

hidden-content probe 대신, masked 입력에서 *visible→hidden receptive-field 누출*을 측정하는 probe.
학습 불필요. SparK-style re-mask의 *아키텍처적* 역할을 보이는 sanity figure용. main claim 아님.

## Stage 4. Paper Decision

Go for AAAI(hybrid) if:
- C1 protocol-adaptive 깨끗(✅) AND C2 balance+rank 깨끗(✅)
- AND C3 외부 brain age ≥1 코호트(n≥300) Δ>0, site-defensible.

Redirect(medical venue) if:
- C3가 데드라인 내 불가(C1/C2만 남음).

Hold if:
- 외부 brain age가 random과 분리 안 됨 (현재 내부 0.137 vs 0.792로 분리 강함 → 외부도 기대).
